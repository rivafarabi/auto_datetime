# auto_datetime

A Flutter plugin that detects whether the device has **automatic date and time** enabled — the system-level setting that keeps the clock synchronized via NTP or network time.

Supports Android, iOS, and Windows.

## Platform behavior

| Platform | Detection method | Minimum version |
|----------|-----------------|-----------------|
| **Android** | `Settings.Global.AUTO_TIME` | API 16 |
| **iOS** | NTP comparison + monotonic clock anchor | iOS 12.0 |
| **Windows** | Registry `HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters` → `Type=NTP` | Windows 7+ |

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  auto_datetime: ^0.0.1
```

Then run:

```sh
flutter pub get
```

## Usage

```dart
import 'package:auto_datetime/auto_datetime.dart';

final plugin = AutoDatetime();

final bool isEnabled = await plugin.isAutomaticDateTimeEnabled();
print(isEnabled ? 'Automatic time is ON' : 'Automatic time is OFF');
```

## Platform notes

### iOS

Uses a two-path strategy that works from iOS 12 with no special entitlements:

**Online path** — sends a UDP request to `time.apple.com:123` (NTP), compares the response against the system clock. If the drift is under 60 seconds the clock is considered synchronized (automatic time on).

**Offline path** — on a successful NTP response the plugin saves a `TimeAnchor` to the Keychain:

```
trustedTime  = NTP response time
bootOffset   = ProcessInfo.systemUptime at capture
```

While offline, trusted time is reconstructed as `trustedTime + (currentUptime − bootOffset)` using the monotonic clock, which cannot be tampered with by changing system time. A negative elapsed value indicates a reboot and automatically invalidates the stale anchor.

**No anchor + no network** — returns `false` with a console warning.

> The Keychain anchor survives app restarts and device reboots are detected automatically. No entitlements beyond standard outbound network access are required.

**Minimum deployment target:** iOS 12.0

### Android

Reads `Settings.Global.AUTO_TIME` via the content resolver. No permissions are required.

**Minimum SDK:** API 16

### Windows

Reads the `Type` value from the Windows Time service registry key:

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters
```

Returns `true` when `Type` is `NTP`.

## License

MIT — see [LICENSE](LICENSE).
