import Flutter
import UIKit
import Foundation
import Security

public class AutoDatetimePlugin: NSObject, FlutterPlugin {

    private static let keychainKey = "com.auto_datetime.timeAnchor"
    // Clocks in good sync are accurate to milliseconds; 60 s covers any reasonable NTP drift
    // while still catching deliberate manual changes.
    private static let driftThreshold: TimeInterval = 60

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "auto_datetime",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(AutoDatetimePlugin(), channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isAutomaticDateTimeEnabled":
            checkAutomaticDateTimeEnabled(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Core check

    private func checkAutomaticDateTimeEnabled(result: @escaping FlutterResult) {
        fetchNTPTime { [weak self] ntpTime in
            guard let self else { return }

            if let ntpTime {
                // Online path: compare fresh NTP time against system clock.
                self.saveAnchor(ntpTime: ntpTime)
                let drift = abs(Date().timeIntervalSince(ntpTime))
                result(drift < AutoDatetimePlugin.driftThreshold)
                return
            }

            // Offline path: reconstruct trusted time from the saved anchor.
            if let estimated = self.estimatedTrustedTime() {
                let drift = abs(Date().timeIntervalSince(estimated))
                result(drift < AutoDatetimePlugin.driftThreshold)
                return
            }

            // No anchor yet and no network — cannot determine; return false with a warning.
            print("""
                [auto_datetime] WARNING: Could not reach NTP server and no local anchor exists. \
                Returning true as a safe default.
                """)
            result(false)
        }
    }

    // MARK: - NTP (RFC 5905, UDP port 123)

    private func fetchNTPTime(completion: @escaping (Date?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            // Build a minimal NTP client request packet (48 bytes).
            // Byte 0: LI=0b00, VN=0b100 (v4), Mode=0b011 (client) → 0x23
            var packet = [UInt8](repeating: 0, count: 48)
            packet[0] = 0x23

            guard let addr = self.resolveHost("time.apple.com", port: 123) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
            guard sock >= 0 else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            defer { close(sock) }

            var timeout = timeval(tv_sec: 3, tv_usec: 0)
            setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &timeout,
                       socklen_t(MemoryLayout<timeval>.size))

            var mutableAddr = addr
            let sent = withUnsafePointer(to: &mutableAddr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    sendto(sock, &packet, 48, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
            guard sent == 48 else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            var response = [UInt8](repeating: 0, count: 48)
            guard recv(sock, &response, 48, 0) == 48 else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // Transmit timestamp occupies bytes 40–43 (seconds since NTP epoch 1900-01-01).
            let seconds = UInt32(response[40]) << 24
                        | UInt32(response[41]) << 16
                        | UInt32(response[42]) << 8
                        | UInt32(response[43])

            // NTP epoch → Unix epoch offset: 70 years = 2 208 988 800 s
            let unix = TimeInterval(seconds) - 2_208_988_800
            DispatchQueue.main.async { completion(Date(timeIntervalSince1970: unix)) }
        }
    }

    private func resolveHost(_ host: String, port: UInt16) -> sockaddr_in? {
        var hints = addrinfo()
        hints.ai_family   = AF_INET
        hints.ai_socktype = SOCK_DGRAM

        var res: UnsafeMutablePointer<addrinfo>?
        guard getaddrinfo(host, "\(port)", &hints, &res) == 0, let first = res else {
            return nil
        }
        defer { freeaddrinfo(res) }

        return first.pointee.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
            $0.pointee
        }
    }

    // MARK: - Monotonic anchor

    private struct TimeAnchor: Codable {
        let trustedTime: Date
        let bootOffset: TimeInterval  // ProcessInfo.systemUptime at the moment of capture
    }

    private func saveAnchor(ntpTime: Date) {
        guard let data = try? JSONEncoder().encode(
            TimeAnchor(trustedTime: ntpTime,
                       bootOffset: ProcessInfo.processInfo.systemUptime)
        ) else { return }

        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: AutoDatetimePlugin.keychainKey,
            kSecValueData:   data,
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func estimatedTrustedTime() -> Date? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: AutoDatetimePlugin.keychainKey,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data   = item as? Data,
              let anchor = try? JSONDecoder().decode(TimeAnchor.self, from: data)
        else { return nil }

        let elapsed = ProcessInfo.processInfo.systemUptime - anchor.bootOffset

        // A negative elapsed value means the device rebooted after the anchor was saved
        // (the monotonic clock resets to 0 on each boot). Discard the stale anchor.
        guard elapsed >= 0 else {
            SecItemDelete([
                kSecClass:       kSecClassGenericPassword,
                kSecAttrAccount: AutoDatetimePlugin.keychainKey,
            ] as CFDictionary)
            return nil
        }

        return anchor.trustedTime.addingTimeInterval(elapsed)
    }
}
