package eu.araulin.devinci

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.dialog.MaterialAlertDialogBuilder

class MainActivity : FlutterActivity() {
    private val CHANNEL = "eu.araulin.devinci/channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            Log.d("call.method", call.method)
            when (call.method) {
                "changeIcon" -> {
                    val iconId: Int = (call.arguments as? Int) ?: 0
                    val success = changeIcon(iconId)
                    if (success) {
                    result.success(success)
                    } else {
                        result.error("UNAVAILABLE", "Unknown error", null)
                    }
                }
                "showDialog" -> {
                    showDialog(call.argument("title"),call.argument("content"), call.argument("ok"),call.argument("cancel"), result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun changeIcon(iconId: Int): Boolean {
        
        val success: Boolean = false
        
        return success
    }

    private fun showDialog(title: String?, content: String?, okButtonText: String?, cancelButtonText: String?, result:io.flutter.plugin.common.MethodChannel.Result) {
        val builder = MaterialAlertDialogBuilder(this)
builder.setTitle(title)
builder.setMessage(content)
// builder.setPositiveButton("OK", DialogInterface.OnClickListener(function = x))

builder.setPositiveButton(okButtonText) { dialog, which ->
    result.success(true)
}

builder.setNegativeButton(cancelButtonText) { dialog, which ->
    result.success(false)
}
builder.show()
    }
}
