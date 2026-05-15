import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'auto_datetime_method_channel.dart';

abstract class AutoDatetimePlatform extends PlatformInterface {
  AutoDatetimePlatform() : super(token: _token);

  static final Object _token = Object();

  static AutoDatetimePlatform _instance = MethodChannelAutoDatetime();

  static AutoDatetimePlatform get instance => _instance;

  static set instance(AutoDatetimePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isAutomaticDateTimeEnabled() {
    throw UnimplementedError('isAutomaticDateTimeEnabled() has not been implemented.');
  }
}
