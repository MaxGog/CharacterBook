package ru.maxgog.listcharacters

import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ContentResolver
import android.os.Bundle
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

class MainActivity: FlutterActivity() {
    private val TAG = "MainActivity"
    private val CHANNEL = "file_picker"
    private val FILE_HANDLE_CHANNEL = "file_handler"
    private var result: MethodChannel.Result? = null
    private lateinit var fileHandlerChannel: MethodChannel
    private val STORAGE_PERMISSION_CODE = 102
    private var pendingFileUri: Uri? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "pickFile") {
                this.result = result
                val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "*/*"
                }
                startActivityForResult(intent, 101)
            } else {
                result.notImplemented()
            }
        }

        fileHandlerChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FILE_HANDLE_CHANNEL)
        fileHandlerChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getOpenedFile" -> {
                    pendingFileUri?.let { uri ->
                        processFile(uri, result)
                        pendingFileUri = null
                    } ?: result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent, null)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent, null)
    }

    private fun handleIntent(intent: Intent) {
        handleIntent(intent, null)
    }

    private fun handleIntent(intent: Intent, result: MethodChannel.Result?) {
        val action = intent.action
        val data = intent.data
        val type = intent.type

        if (Intent.ACTION_VIEW == action && data != null) {
            pendingFileUri = data
            val fileType = when {
                data.toString().contains(".character") -> "character"
                data.toString().contains(".race") -> "race"
                data.toString().contains(".chax") -> "chax"
                type == "application/json" -> "json"
                else -> {
                    val path = data.path ?: ""
                    when {
                        path.contains(".character", ignoreCase = true) -> "character"
                        path.contains(".race", ignoreCase = true) -> "race"
                        path.contains(".chax", ignoreCase = true) -> "chax"
                        else -> "unknown"
                    }
                }
            }

            if (fileType != "unknown") {
                showImportDialog(data, fileType, result)
            } else {
                result?.error("UNKNOWN_TYPE", "Unknown file type", null)
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == STORAGE_PERMISSION_CODE && grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            handleIntent(intent, null)
        }
    }

    private fun processFile(uri: Uri, result: MethodChannel.Result?) {
        try {
            val filePath = copyFileToCache(uri)
            filePath?.let { path ->
                fileHandlerChannel.invokeMethod("onFileOpened", mapOf(
                    "path" to path,
                    "type" to path.substringAfterLast('.', "")
                ))
                result?.success(path)
            } ?: run {
                result?.error("FILE_ERROR", "Could not copy file", null)
            }
        } catch (e: Exception) {
            result?.error("FILE_ERROR", "Error: ${e.message}", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 101) {
            if (resultCode == RESULT_OK && data != null) {
                val uri: Uri? = data.data
                uri?.let {
                    val filePath = copyFileToCache(uri)
                    filePath?.let { path ->
                        result?.success(path)
                    } ?: run {
                        result?.error("COPY_FAILED", "Failed to copy file", null)
                    }
                } ?: run {
                    result?.error("NO_FILE", "No file selected", null)
                }
            } else {
                result?.error("CANCELLED", "File picking cancelled", null)
            }
            result = null
        }
    }

    private fun copyFileToCache(uri: Uri): String? {
        return try {
            val contentResolver = applicationContext.contentResolver
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val fileName = uri.lastPathSegment ?: "imported_file"
            val outputFile = File(applicationContext.cacheDir, fileName)

            inputStream.use { input ->
                FileOutputStream(outputFile).use { output ->
                    input.copyTo(output)
                }
            }

            outputFile.absolutePath
        } catch (e: Exception) {
            null
        }
    }

    private fun showImportDialog(uri: Uri, fileType: String, result: MethodChannel.Result?) {
        fileHandlerChannel.invokeMethod("showImportDialog", mapOf(
            "uri" to uri.toString(),
            "type" to fileType
        ), object : MethodChannel.Result {
            override fun success(result: Any?) {
                processFile(uri, result as? MethodChannel.Result)
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                result?.error(errorCode, errorMessage, errorDetails)
            }

            override fun notImplemented() {
                processFile(uri, result)
            }
        })
    }
}