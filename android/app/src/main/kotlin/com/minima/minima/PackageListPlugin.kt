package com.itmarck.minima

import android.app.Activity
import android.content.Intent
import android.content.pm.ResolveInfo
import android.net.Uri
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class PackageListPlugin(
    private val activity: Activity,
    private val ownPackageName: String
) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getInstalledPackages" -> result.success(getInstalledPackages())
            "launchPackage" -> {
                val packageName = call.argument<String>("packageName")
                if (packageName != null) {
                    result.success(launchPackage(packageName))
                } else {
                    result.error("INVALID_ARGUMENT", "packageName is required", null)
                }
            }
            "uninstallPackage" -> {
                val packageName = call.argument<String>("packageName")
                if (packageName != null) {
                    try {
                        uninstallPackage(packageName)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNINSTALL_FAILED", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "packageName is required", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getInstalledPackages(): List<Map<String, Any?>> {
        val pm = activity.packageManager
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val activities: List<ResolveInfo> = pm.queryIntentActivities(intent, 0)

        return activities
            .filter { it.activityInfo.packageName != ownPackageName }
            .map { resolveInfo ->
                mapOf(
                    "packageName" to resolveInfo.activityInfo.packageName,
                    "label" to resolveInfo.loadLabel(pm).toString(),
                    "icon" to drawableToBytes(resolveInfo.loadIcon(pm))
                )
            }
    }

    private fun launchPackage(packageName: String): Boolean {
        val intent = activity.packageManager.getLaunchIntentForPackage(packageName)
        return if (intent != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            activity.startActivity(intent)
            true
        } else {
            false
        }
    }

    private fun uninstallPackage(packageName: String) {
        val intent = Intent(Intent.ACTION_DELETE).apply {
            data = Uri.parse("package:$packageName")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        activity.startActivity(intent)
    }

    private fun drawableToBytes(drawable: Drawable): ByteArray {
        val size = 96
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(canvas)
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        bitmap.recycle()
        return stream.toByteArray()
    }
}
