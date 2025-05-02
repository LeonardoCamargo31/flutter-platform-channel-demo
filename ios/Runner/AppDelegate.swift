import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let deviceSecurityChannel = FlutterMethodChannel(name: "samples.flutter.dev/battery",
                                               binaryMessenger: controller.binaryMessenger)
    GeneratedPluginRegistrant.register(with: self)

    deviceSecurityChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "hasLockScreen" {
        result(self.hasLockScreen())
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func hasLockScreen() -> Bool {
    let context = LAContext()
    var error: NSError?
    
    // Verifica se o dispositivo tem um passcode configurado
    // LAPolicyDeviceOwnerAuthentication verifica se é possível autenticar com senha/PIN/Face ID/Touch ID
    // Isso só retorna true se houver uma tela de bloqueio configurada
    let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    
    // Se não puder avaliar, verificamos o código de erro
    if !canEvaluate {
      if let error = error as? LAError {
        // LAError.passcodeNotSet indica que não há passcode configurado
        if error.code == .passcodeNotSet {
          return false
        }
        // Outros erros podem ocorrer, mas ainda podem significar que há um bloqueio configurado
        print("Erro ao verificar passcode: \(error.localizedDescription)")
      }
    }
    
    // Se puder avaliar, significa que há um passcode configurado
    return canEvaluate
  }
}
