package com.example.batterylevel

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.app.KeyguardManager
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.Manifest
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/battery"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
      super.configureFlutterEngine(flutterEngine)

      MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
        val manufacturer = Build.MANUFACTURER       // Ex: Samsung
        val model = Build.MODEL                      // Ex: Galaxy S21
        val versionRelease = Build.VERSION.RELEASE   // Ex: "14" (Android 14)
        val sdkInt = Build.VERSION.SDK_INT           // Ex: 34 (API level)

        

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_WIFI_STATE) != PackageManager.PERMISSION_GRANTED ||
          ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            println("Sem permissão para acessar o estado do Wi-Fi ou localização.")
            // Se não tiver permissão, peça as permissões ao usuário
              ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.ACCESS_WIFI_STATE,
                    Manifest.permission.ACCESS_FINE_LOCATION
                ),
                1001 // Código de solicitação de permissão (pode ser qualquer número)
            )
        }else {
          println("Com permissão para acessar o estado do Wi-Fi ou localização.")
        }

        
        if (call.method == "getBatteryLevel") {
          val batteryLevel = getBatteryLevel()

          if (batteryLevel != -1) {
              result.success(batteryLevel)
          } else {
              result.error("UNAVAILABLE", "Battery level not available.", null)
          }
        }
        
        else if (call.method == "hasLockScreen") {
            val hasLockScreen = hasLockScreen(this)
            result.success(hasLockScreen)
        }

        else if (call.method == "wifiIsSafe") {
          val wifiIsSafe = wifiIsSafe(this)
          result.success(wifiIsSafe)
        }
        
        else {
          result.notImplemented()
        }
      }
    }

    fun wifiIsSafe(context: Context): String {
      val wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
      val connectionInfo = wifiManager.connectionInfo
      
       // Obtém o SSID da rede conectada
      val ssid = connectionInfo.ssid?.removeSurrounding("\"") ?: return "Sem SSID válido."

      // Pega a lista de redes Wi-Fi visíveis
      val scanResults = wifiManager.scanResults

      // Procura nos resultados a rede que corresponde ao SSID conectado
      val connectedNetwork = scanResults.find { it.SSID == ssid }

      if (connectedNetwork != null) {
        val capabilities = connectedNetwork.capabilities

        return when {
          capabilities.contains("WPA3") || capabilities.contains("SAE") -> {
              "Rede segura: Usa WPA3 (muito seguro)."
          }
          capabilities.contains("WPA2") -> {
              "Rede segura: Usa WPA2 (seguro)."
          }
          capabilities.contains("WPA") && !capabilities.contains("WPA2") -> {
              "Rede menos segura: Usa WPA (obsoleto)."
          }
          capabilities.contains("WEP") -> {
              "Rede insegura: Usa WEP (vulnerável)."
          }
          capabilities.contains("ESS") && !capabilities.contains("WPA") && !capabilities.contains("WEP") -> {
              "Rede insegura: Rede aberta (sem criptografia)."
          }
          else -> {
              "Segurança desconhecida: Capabilities não reconhecidas."
          }
        }
      } else {
          return "Rede conectada não encontrada nos resultados do scan."
      }
    }

    fun hasLockScreen(context: Context): Boolean {
      val keyguardManager = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
      return keyguardManager.isKeyguardSecure
    }

    private fun getBatteryLevel(): Int {
      val batteryLevel: Int
      if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
          val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
          batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
      } else {
          val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
          batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 /
                  intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
      }

      return batteryLevel
    }
}