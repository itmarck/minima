package com.itmarck.minima

import android.app.WallpaperManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val WALLPAPER = "wallpaper"
  private val PACKAGES = "packages"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PACKAGES)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getInstalledPackages" -> {
            val packageProvider = PackageProvider(applicationContext)
            val packages = packageProvider.getInstalledPackages()
            result.success(packages)
          }
          "launch" -> {
            val name = call.argument<String>("name")
            if (name != null) {
              val packageProvider = PackageProvider(applicationContext)
              val success = packageProvider.launch(name)
              result.success(success)
            } else {
              result.error("INVALID_ARGUMENT", "Package name is required", null)
            }
          }
          else -> {
            result.notImplemented()
          }
        }
      }
  }

  override fun onResume() {
    super.onResume()

    MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, WALLPAPER)
      .setMethodCallHandler { call, result ->
        if (call.method == "setWallpaper") {
          setWallpaper()
          result.success(null)
        }
      }
  }

  private fun setWallpaper() {
    val wallpaperManager = WallpaperManager.getInstance(applicationContext)

    val displayMetrics = resources.displayMetrics
    val width = displayMetrics.widthPixels
    val height = displayMetrics.heightPixels

    val blackBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)

    val paint = Paint()
    paint.color = Color.BLACK

    val canvas = Canvas(blackBitmap)
    canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)

    wallpaperManager.setBitmap(blackBitmap)
  }
}