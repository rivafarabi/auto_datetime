import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'auto_datetime_platform_interface.dart';

class MethodChannelAutoDatetime extends AutoDatetimePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('auto_datetime');

  @override
  Future<bool> isAutomaticDateTimeEnabled() async {
    final enabled = await methodChannel.invokeMethod<bool>('isAutomaticDateTimeEnabled');
    return enabled ?? false;
  }
}
