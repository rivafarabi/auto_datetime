#ifndef FLUTTER_PLUGIN_AUTO_DATETIME_PLUGIN_H_
#define FLUTTER_PLUGIN_AUTO_DATETIME_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace auto_datetime {

class AutoDatetimePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  AutoDatetimePlugin();
  virtual ~AutoDatetimePlugin();

  AutoDatetimePlugin(const AutoDatetimePlugin&) = delete;
  AutoDatetimePlugin& operator=(const AutoDatetimePlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace auto_datetime

#endif  // FLUTTER_PLUGIN_AUTO_DATETIME_PLUGIN_H_
