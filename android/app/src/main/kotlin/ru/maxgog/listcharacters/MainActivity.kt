package ru.maxgog.listcharacters

import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ContentResolver
import android.os.Bundle
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "file_picker"
    private val FILE_HANDLE_CHANNEL = "file_handler"
    private var result: MethodChannel.Result? = null
    private lateinit var fileHandlerChannel: MethodChannel

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
            if (call.method == "getOpenedFile") {
                handleIntent(intent, result)
            } else {
                result.notImplemented()
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

    private fun handleIntent(intent: Intent, result: MethodChannel.Result?) {
        val action = intent.action
        val data = intent.data
        val type = intent.type

        if ((Intent.ACTION_VIEW == action || Intent.ACTION_SEND == action) && data != null) {
            when {
                data.toString().endsWith(".character") -> processFile(data, result)
                data.toString().endsWith(".race") -> processFile(data, result)
                type == "application/vnd.listcharacters.character" -> processFile(data, result)
                type == "application/vnd.listcharacters.race" -> processFile(data, result)
                type == "application/octet-stream" -> processFile(data, result)
                else -> {
                    val path = data.path
                    if (path != null) {
                        when {
                            path.endsWith(".character", ignoreCase = true) -> processFile(data, result)
                            path.endsWith(".race", ignoreCase = true) -> processFile(data, result)
                        }
                    }
                }
            }
        }
    }

    private fun processFile(uri: Uri, result: MethodChannel.Result?) {
        val filePath = copyFileToCache(uri)
        filePath?.let { path ->
            result?.success(path) ?: run {
                fileHandlerChannel.invokeMethod("onFileOpened", path)
            }
        } ?: run {
            result?.error("FILE_ERROR", "Could not process file", null)
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
            val contentResolver: ContentResolver = applicationContext.contentResolver
            val inputStream: InputStream? = contentResolver.openInputStream(uri)
            val cacheDir = applicationContext.cacheDir
            val fileName = getFileName(contentResolver, uri) ?: "file_${System.currentTimeMillis()}"
            val outputFile = File(cacheDir, fileName)

            inputStream?.use { input ->
                FileOutputStream(outputFile).use { output ->
                    input.copyTo(output)
                }
            }

            outputFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun getFileName(contentResolver: ContentResolver, uri: Uri): String? {
        val name = uri.lastPathSegment ?: return null
        if (name.startsWith("/")) {
            return name.substringAfterLast('/')
        }
        return name
    }
}