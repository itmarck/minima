package com.itmarck.minima

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import java.util.*

class PackageProvider(private val context: Context) {

  fun getInstalledPackages(): List<Map<String, Any>> {
    val packageManager = context.packageManager
    val applications = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
    val packages = mutableListOf<Map<String, Any>>()

    for (applicationInfo in applications) {
      if (isInternalPackage(applicationInfo)) {
        continue
      }

      if (!isLaunchable(applicationInfo)) {
        continue
      }

      val draft = mutableMapOf<String, Any>()

      draft["packageName"] = applicationInfo.packageName
      draft["label"] = packageManager.getApplicationLabel(applicationInfo).toString()

      packages.add(draft)
    }

    return packages.sortedBy { it["name"].toString().lowercase(Locale.getDefault()) }
  }

  fun launch(name: String): Boolean {
    try {
      val packageManager = context.packageManager
      val launchIntent = packageManager.getLaunchIntentForPackage(name)

      if (launchIntent != null) {
        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(launchIntent)
        return true
      }

      return false
    } catch (e: Exception) {
      return false
    }
  }

  private fun isInternalPackage(applicationInfo: ApplicationInfo): Boolean {
    // Puedes agregar aquí una lista negra si quieres ocultar apps específicas
    // val blackList = listOf("com.android.settings", ...)
    // if (applicationInfo.packageName in blackList) return true

    return false
  }

  private fun isLaunchable(applicationInfo: ApplicationInfo): Boolean {
    val packageManager = context.packageManager
    val launchIntent = packageManager.getLaunchIntentForPackage(applicationInfo.packageName)
    return launchIntent != null
  }
}
