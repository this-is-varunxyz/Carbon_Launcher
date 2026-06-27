package com.example.carbon_launcher

import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "carbon.launcher/channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isDefaultLauncher") {
                // Creates an intent exactly like pressing the physical Home button
                val intent = Intent(Intent.ACTION_MAIN)
                intent.addCategory(Intent.CATEGORY_HOME)
                
                // Asks Android which app is currently assigned to intercept this intent
                val resolveInfo: ResolveInfo? = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
                val currentHomePackage = resolveInfo?.activityInfo?.packageName
                
                // Returns true if Carbon is the default, false if it is not
                result.success(currentHomePackage == packageName)
            } else {
                result.notImplemented()
            }
        }
    }
}