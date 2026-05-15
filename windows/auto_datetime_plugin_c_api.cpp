#include "include/auto_datetime_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "auto_datetime_plugin.h"

void AutoDatetimePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auto_datetime::AutoDatetimePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
