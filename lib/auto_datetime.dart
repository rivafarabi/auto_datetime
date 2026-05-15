import 'auto_datetime_platform_interface.dart';

class AutoDatetime {
  Future<bool> isAutomaticDateTimeEnabled() {
    return AutoDatetimePlatform.instance.isAutomaticDateTimeEnabled();
  }
}
