import 'package:flutter_test/flutter_test.dart';
import 'package:auto_datetime/auto_datetime.dart';
import 'package:auto_datetime/auto_datetime_platform_interface.dart';
import 'package:auto_datetime/auto_datetime_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _EnabledPlatform with MockPlatformInterfaceMixin implements AutoDatetimePlatform {
  @override
  Future<bool> isAutomaticDateTimeEnabled() => Future.value(true);
}

class _DisabledPlatform with MockPlatformInterfaceMixin implements AutoDatetimePlatform {
  @override
  Future<bool> isAutomaticDateTimeEnabled() => Future.value(false);
}

class _ThrowingPlatform with MockPlatformInterfaceMixin implements AutoDatetimePlatform {
  @override
  Future<bool> isAutomaticDateTimeEnabled() => Future.error(Exception('platform error'));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Capture the real default before any test mutates it.
  final AutoDatetimePlatform initialPlatform = AutoDatetimePlatform.instance;

  // Restore the original instance after every test so they stay isolated.
  tearDown(() => AutoDatetimePlatform.instance = initialPlatform);

  group('default instance', () {
    test('is MethodChannelAutoDatetime', () {
      expect(initialPlatform, isInstanceOf<MethodChannelAutoDatetime>());
    });
  });

  group('AutoDatetime.isAutomaticDateTimeEnabled', () {
    test('returns true when platform reports enabled', () async {
      AutoDatetimePlatform.instance = _EnabledPlatform();
      expect(await AutoDatetime().isAutomaticDateTimeEnabled(), isTrue);
    });

    test('returns false when platform reports disabled', () async {
      AutoDatetimePlatform.instance = _DisabledPlatform();
      expect(await AutoDatetime().isAutomaticDateTimeEnabled(), isFalse);
    });

    test('propagates errors from the platform', () async {
      AutoDatetimePlatform.instance = _ThrowingPlatform();
      expect(
        () => AutoDatetime().isAutomaticDateTimeEnabled(),
        throwsA(isA<Exception>()),
      );
    });

    test('returns a bool (not null)', () async {
      AutoDatetimePlatform.instance = _EnabledPlatform();
      final result = await AutoDatetime().isAutomaticDateTimeEnabled();
      expect(result, isA<bool>());
    });
  });

  group('AutoDatetimePlatform', () {
    test('base class throws UnimplementedError', () {
      // Verifies the contract: every subclass must override the method.
      expect(
        () => _UnimplementedPlatform().isAutomaticDateTimeEnabled(),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('instance setter rejects objects without the platform token', () {
      expect(
        () => AutoDatetimePlatform.instance = _TokenlessPlatform(),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

// Calls super to trigger the UnimplementedError.
class _UnimplementedPlatform extends AutoDatetimePlatform {}

// Bypasses MockPlatformInterfaceMixin so it lacks the verification token.
class _TokenlessPlatform extends AutoDatetimePlatform {
  @override
  Future<bool> isAutomaticDateTimeEnabled() => Future.value(false);
}
