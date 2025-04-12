package com.carwashmovil.car_wash_app

import android.content.ContentValues
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.car_wash_app.channel.media_store"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "saveImageToPictures") {
                val filename = call.argument<String>("filename") ?: "image.png"
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes != null) {
                    val contentValues = ContentValues().apply {
                        put(MediaStore.Images.Media.DISPLAY_NAME, filename)
                        put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                        put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/CarWashFacturas")
                        put(MediaStore.Images.Media.IS_PENDING, 1)
                    }

                    val resolver = applicationContext.contentResolver
                    val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                    if (uri != null) {
                        val outputStream: OutputStream? = resolver.openOutputStream(uri)
                        outputStream?.write(bytes)
                        outputStream?.flush()
                        outputStream?.close()

                        contentValues.clear()
                        contentValues.put(MediaStore.Images.Media.IS_PENDING, 0)
                        resolver.update(uri, contentValues, null, null)

                        // Obtener ruta absoluta real desde la URI
                        val cursor = resolver.query(uri, arrayOf(MediaStore.Images.Media.DATA), null, null, null)
                        var filePath: String? = null
                        cursor?.use {
                            if (it.moveToFirst()) {
                                filePath = it.getString(0)
                            }
                        }

                        result.success(filePath ?: uri.toString())
                    } else {
                        result.error("SAVE_FAILED", "No se pudo guardar la imagen", null)
                    }
                } else {
                    result.error("NO_BYTES", "No se proporcionaron datos de imagen", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
