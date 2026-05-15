import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auto_datetime/auto_datetime_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelAutoDatetime platform;
  const channel = MethodChannel('auto_datetime');

  setUp(() {
    platform = MethodChannelAutoDatetime();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  void setHandler(Future<Object?> Function(MethodCall) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  group('isAutomaticDateTimeEnabled', () {
    test('returns true when native side returns true', () async {
      setHandler((call) async => true);
      expect(await platform.isAutomaticDateTimeEnabled(), isTrue);
    });

    test('returns false when native side returns false', () async {
      setHandler((call) async => false);
      expect(await platform.isAutomaticDateTimeEnabled(), isFalse);
    });

    test('returns false when native side returns null', () async {
      setHandler((call) async => null);
      expect(await platform.isAutomaticDateTimeEnabled(), isFalse);
    });

    test('invokes the correct method name', () async {
      String? invokedMethod;
      setHandler((call) async {
        invokedMethod = call.method;
        return true;
      });

      await platform.isAutomaticDateTimeEnabled();
      expect(invokedMethod, 'isAutomaticDateTimeEnabled');
    });

    test('sends no arguments to the native side', () async {
      dynamic capturedArguments = 'not set';
      setHandler((call) async {
        capturedArguments = call.arguments;
        return false;
      });

      await platform.isAutomaticDateTimeEnabled();
      expect(capturedArguments, isNull);
    });

    test('propagates PlatformException from native side', () async {
      setHandler((_) async => throw PlatformException(
            code: 'UNSUPPORTED',
            message: 'Requires iOS 15.0 or later',
          ));

      expect(
        () => platform.isAutomaticDateTimeEnabled(),
        throwsA(isA<PlatformException>().having(
          (e) => e.code,
          'code',
          'UNSUPPORTED',
        )),
      );
    });
  });
}
