package io.github.aleksandurbojilov09.garage

import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    private val expectedCertificate = "a431369f4e84aebe18c87de7630bd364d248153e537251a8dfd0501de30d85f0"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bubka/updates")
            .setMethodCallHandler { call, result ->
                if (call.method != "install") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    val path = requireNotNull(call.argument<String>("path"))
                    val build = requireNotNull(call.argument<Int>("build"))
                    val version = requireNotNull(call.argument<String>("version"))
                    result.success(installUpdate(path, build, version))
                } catch (_: Exception) {
                    result.error("UPDATE_REJECTED", "APK verification or installation failed", null)
                }
            }
    }

    @Suppress("DEPRECATION")
    private fun certificate(info: PackageInfo): String {
        val signatures = if (Build.VERSION.SDK_INT >= 28)
            info.signingInfo?.apkContentsSigners else info.signatures
        require(signatures != null && signatures.size == 1)
        return MessageDigest.getInstance("SHA-256").digest(signatures[0].toByteArray())
            .joinToString("") { "%02x".format(it.toInt() and 255) }
    }

    @Suppress("DEPRECATION")
    private fun build(info: PackageInfo): Long =
        if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()

    @Suppress("DEPRECATION")
    private fun installUpdate(path: String, targetBuild: Int, targetVersion: String): String {
        val folder = File(filesDir, "bubka-data/updates").canonicalFile
        val file = File(path).canonicalFile
        require(file.parentFile == folder && file.isFile && file.extension == "apk")
        val flags = if (Build.VERSION.SDK_INT >= 28)
            PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES
        val archive = requireNotNull(packageManager.getPackageArchiveInfo(file.path, flags))
        val installed = packageManager.getPackageInfo(packageName, flags)
        require(archive.packageName == packageName && archive.versionName == targetVersion)
        require(build(archive) == targetBuild.toLong() && build(archive) > build(installed))
        require(certificate(archive) == expectedCertificate && certificate(installed) == expectedCertificate)
        if (Build.VERSION.SDK_INT >= 26 && !packageManager.canRequestPackageInstalls()) {
            startActivity(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:$packageName")))
            return "permission"
        }
        val uri = FileProvider.getUriForFile(this, "$packageName.updates", file)
        startActivity(Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        })
        return "opened"
    }
}
