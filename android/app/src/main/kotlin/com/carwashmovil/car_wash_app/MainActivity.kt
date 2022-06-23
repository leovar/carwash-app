package com.carwashmovil.car_wash_app

import android.content.*
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.os.Parcel
import android.os.ResultReceiver
import android.util.Log
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.UnsupportedEncodingException


class MainActivity : FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/battery"

    var templateData = "\u0010CT~~CD,~CC^~CT~\n" +
            "^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD10^JUS^LRN^CI0^XZ\n" +
            "^XA\n" +
            "^MMT\n" +
            "^PW591\n" +
            "^LL0203\n" +
            "^LS0\n" +
            "^FT171,82^A0N,27,26^FH\\^FD%PRODUCT_NAME%^FS\n" +
            "^FT222,107^A0N,17,16^FH\\^FD%MSRP%^FS\n" +
            "^FT424,163^A0N,23,24^FB82,1,0,R^FH\\^FD%PCT%^FS\n" +
            "^FT314,167^A0N,28,28^FH\\^FD%FINAL%^FS\n" +
            "^FT367,107^A0N,17,16^FH\\^FD%UPC_CODE%^FS\n" +
            "^FT471,138^A0N,14,14^FH\\^FDYou saved:^FS\n" +
            "^FO451,119^GB103,54,2^FS\n" +
            "^FT171,20^A0N,17,16^FH\\^FDPrintConnect Template Print Example^FS\n" +
            "^FT171,167^A0N,28,28^FH\\^FDFinal Price:^FS\n" +
            "^FT171,51^A0N,17,16^FH\\^FDProduct:^FS\n" +
            "^FT171,107^A0N,17,16^FH\\^FDMSRP:^FS\n" +
            "^FT508,163^A0N,23,24^FH\\^FD%^FS\n" +
            "^FT328,107^A0N,17,16^FH\\^FDUPC:^FS\n" +
            "^FO171,119^GB259,0,2^FS\n" +
            "^PQ1,0,1,Y^XZ\n"

    // This method makes your ResultReceiver safe for inter-process communication
    private fun buildIPCSafeReceiver(actualReceiver: ResultReceiver): ResultReceiver? {
        val parcel = Parcel.obtain()
        actualReceiver.writeToParcel(parcel, 0)
        parcel.setDataPosition(0)
        val receiverForSending = ResultReceiver.CREATOR.createFromParcel(parcel)
        parcel.recycle()
        return receiverForSending
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != "-1") {
                    result.success(call.argument("bat2")) //batteryLevel
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): String {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        var templateBytes: ByteArray? = null

        try { // Convert template ZPL string to a UTF-8 encoded byte array, which will be sent as an extra with the intent
            templateBytes = templateData.toByteArray(charset("UTF-8"))
        } catch (e: UnsupportedEncodingException) { // Handle exception
        }

        val variableData: HashMap<String, String> = HashMap()
        variableData.put("%PRODUCT_NAME%", "Apples")
        variableData.put("%MSRP%", "$1.00")
        variableData.put("%PCT%", "50")
        variableData.put("%FINAL%", "$0.50")
        variableData.put("%UPC_CODE%", "12345678")

        val intentPrint = Intent()
        intentPrint.component = ComponentName("com.zebra.printconnect",
                "com.zebra.printconnect.print.TemplatePrintWithContentService")
        intentPrint.putExtra("com.zebra.printconnect.PrintService.TEMPLATE_DATA", templateBytes)
        intentPrint.putExtra("com.zebra.printconnect.PrintService.VARIABLE_DATA", variableData)
        intentPrint.putExtra("com.zebra.printconnect.PrintService.RESULT_RECEIVER",
                buildIPCSafeReceiver(object : ResultReceiver(null) {
                    override fun onReceiveResult(resultCode: Int, resultData: Bundle) {
                        if (resultCode == 0) { // Result code 0 indicates success
                        // Handle successful print
                        } else { // Handle unsuccessful print
                            // Error message (null on successful print)
                            //var errorMessage: String = resultData.getString("com.zebra.printconnect.PrintService.ERROR_MESSAGE")
                            //Log.e("error al imprimir", errorMessage)
                        }
                    }
                }
                )
        )
        startService(intentPrint)


        return batteryLevel.toString()
    }
}
