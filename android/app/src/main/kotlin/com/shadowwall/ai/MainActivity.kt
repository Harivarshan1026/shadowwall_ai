package com.shadowwall.ai

import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.provider.Settings
import android.app.KeyguardManager
import android.content.Context
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.shadowwall.ai/native_scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val apps = getInstalledAppsWithPermissions()
                            withContext(Dispatchers.Main) {
                                result.success(apps)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("SCAN_ERROR", e.message, null)
                            }
                        }
                    }
                }
                "analyzeApk" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("INVALID_ARGUMENT", "Path is required", null)
                        return@setMethodCallHandler
                    }
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val info = analyzeLocalApk(path)
                            withContext(Dispatchers.Main) {
                                result.success(info)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("APK_ERROR", e.message, null)
                            }
                        }
                    }
                }
                "getDeviceSecurityStatus" -> {
                    try {
                        val status = getDeviceSecurityStatus()
                        result.success(status)
                    } catch (e: Exception) {
                        result.error("SECURITY_ERROR", e.message, null)
                    }
                }
                "secureScreen" -> {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getInstalledAppsWithPermissions(): List<Map<String, Any>> {
        val pm = packageManager
        val packages = pm.getInstalledPackages(PackageManager.GET_PERMISSIONS)
        val result = mutableListOf<Map<String, Any>>()

        for (pkg in packages) {
            // Filter out system apps
            val isSystemApp = ((pkg.applicationInfo?.flags ?: 0) and ApplicationInfo.FLAG_SYSTEM) != 0
            if (!isSystemApp) {
                val appName = pkg.applicationInfo?.loadLabel(pm)?.toString() ?: pkg.packageName
                val permissions = pkg.requestedPermissions?.toList() ?: emptyList()
                
                result.add(
                    mapOf(
                        "package" to pkg.packageName,
                        "name" to appName,
                        "permissions" to permissions,
                        "version" to (pkg.versionName ?: "1.0")
                    )
                )
            }
        }
        return result
    }

    private fun analyzeLocalApk(path: String): Map<String, Any> {
        val pm = packageManager
        val pkg = pm.getPackageArchiveInfo(path, PackageManager.GET_PERMISSIONS)
            ?: throw Exception("Invalid APK file or unsupported format")
        
        pkg.applicationInfo?.sourceDir = path
        pkg.applicationInfo?.publicSourceDir = path
        
        val appName = pkg.applicationInfo?.loadLabel(pm)?.toString() ?: pkg.packageName
        val permissions = pkg.requestedPermissions?.toList() ?: emptyList()

        return mapOf(
            "package" to pkg.packageName,
            "name" to appName,
            "version" to (pkg.versionName ?: "Unknown"),
            "permissions" to permissions
        )
    }

    private fun getDeviceSecurityStatus(): Map<String, Boolean> {
        val cr = contentResolver
        
        // Developer Options
        val devOptionsEnabled = Settings.Global.getInt(cr, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) == 1
        
        // USB Debugging
        val adbEnabled = Settings.Global.getInt(cr, Settings.Global.ADB_ENABLED, 0) == 1
        
        // Screen Lock
        val km = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        val isDeviceSecure = km.isDeviceSecure
        
        return mapOf(
            "developerOptions" to devOptionsEnabled,
            "usbDebugging" to adbEnabled,
            "screenLock" to isDeviceSecure
        )
    }
}
