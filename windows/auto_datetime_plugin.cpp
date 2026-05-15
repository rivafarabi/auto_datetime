#include "auto_datetime_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <windows.h>

#include <memory>
#include <string>

namespace auto_datetime {

namespace {

bool IsAutomaticDateTimeEnabled() {
  HKEY hKey;
  LONG res = RegOpenKeyExW(
      HKEY_LOCAL_MACHINE,
      L"SYSTEM\\CurrentControlSet\\Services\\W32Time\\Parameters",
      0, KEY_READ, &hKey);

  if (res != ERROR_SUCCESS) {
    return false;
  }

  wchar_t value[256] = {};
  DWORD valueSize = sizeof(value);
  DWORD valueType = 0;

  res = RegQueryValueExW(hKey, L"Type", nullptr, &valueType,
                         reinterpret_cast<LPBYTE>(value), &valueSize);
  RegCloseKey(hKey);

  if (res != ERROR_SUCCESS || valueType != REG_SZ) {
    return false;
  }

  return std::wstring(value) == L"NTP";
}

}  // namespace

// static
void AutoDatetimePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "auto_datetime",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AutoDatetimePlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

AutoDatetimePlugin::AutoDatetimePlugin() {}

AutoDatetimePlugin::~AutoDatetimePlugin() {}

void AutoDatetimePlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name() == "isAutomaticDateTimeEnabled") {
    result->Success(flutter::EncodableValue(IsAutomaticDateTimeEnabled()));
  } else {
    result->NotImplemented();
  }
}

}  // namespace auto_datetime
