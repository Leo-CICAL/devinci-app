package eu.araulin.devinci

import `in`.myinnos.library.AppIconNameChanger
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "eu.araulin.devinci/channel"
    //var activeName = "eu.araulin.devinci.MainActivity2"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            Log.d("call.method", call.method)
            if (call.method == "changeIcon1") {
                Log.d("call.method changeIcon1", "true")
                val success = changeIcon1()

                if (success) {
                    result.success(success)
                } else {
                    result.error("UNAVAILABLE", "Unknown error", null)
                }
            }else if (call.method == "changeIcon2") {
                Log.d("call.method changeIcon2", "true")
                val success = changeIcon2()

                if (success) {
                    result.success(success)
                } else {
                    result.error("UNAVAILABLE", "Unknown error", null)
                }
            }else if (call.method == "changeIcon3") {
                Log.d("call.method changeIcon3", "true")
                val success = changeIcon3()

                if (success) {
                    result.success(success)
                } else {
                    result.error("UNAVAILABLE", "Unknown error", null)
                }
            }else if (call.method == "changeIcon4") {
                Log.d("call.method changeIcon4", "true")
                val success = changeIcon4()

                if (success) {
                    result.success(success)
                } else {
                    result.error("UNAVAILABLE", "Unknown error", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun changeIcon1(): Boolean {
        Log.d("changeIcon", "start")
        var activeName = "eu.araulin.devinci.MainActivity"
        val success: Boolean
        success = false
        val disableNames: MutableList<String> = ArrayList()
        disableNames.add("eu.araulin.devinci.MainActivity2")
        disableNames.add("eu.araulin.devinci.MainActivity3")
        disableNames.add("eu.araulin.devinci.MainActivity4")
        //disableNames.add("in.myinnos.changeappiconandname.MainActivityMessage")
        AppIconNameChanger.Builder(this@MainActivity)
                .activeName(activeName) // String
                .disableNames(disableNames) // List<String>
                .packageName(BuildConfig.APPLICATION_ID)
                .build()
                .setNow()
        Log.d("changeIcon", "changed")
        return success

    }

    private fun changeIcon2(): Boolean {
        Log.d("changeIcon", "start")
        var activeName = "eu.araulin.devinci.MainActivity2"
        val success: Boolean
        success = false
        val disableNames: MutableList<String> = ArrayList()
        disableNames.add("eu.araulin.devinci.MainActivity")
        disableNames.add("eu.araulin.devinci.MainActivity3")
        disableNames.add("eu.araulin.devinci.MainActivity4")
        //disableNames.add("in.myinnos.changeappiconandname.MainActivityMessage")
        AppIconNameChanger.Builder(this@MainActivity)
                .activeName(activeName) // String
                .disableNames(disableNames) // List<String>
                .packageName(BuildConfig.APPLICATION_ID)
                .build()
                .setNow()
        Log.d("changeIcon", "changed")
        return success

    }

    private fun changeIcon3(): Boolean {
        Log.d("changeIcon", "start")
        var activeName = "eu.araulin.devinci.MainActivity3"
        val success: Boolean
        success = false
        val disableNames: MutableList<String> = ArrayList()
        disableNames.add("eu.araulin.devinci.MainActivity")
        disableNames.add("eu.araulin.devinci.MainActivity2")
        disableNames.add("eu.araulin.devinci.MainActivity4")
        //disableNames.add("in.myinnos.changeappiconandname.MainActivityMessage")
        AppIconNameChanger.Builder(this@MainActivity)
                .activeName(activeName) // String
                .disableNames(disableNames) // List<String>
                .packageName(BuildConfig.APPLICATION_ID)
                .build()
                .setNow()
        Log.d("changeIcon", "changed")
        return success

    }

    private fun changeIcon4(): Boolean {
        Log.d("changeIcon", "start")
        var activeName = "eu.araulin.devinci.MainActivity4"
        val success: Boolean
        success = false
        val disableNames: MutableList<String> = ArrayList()
        disableNames.add("eu.araulin.devinci.MainActivity")
        disableNames.add("eu.araulin.devinci.MainActivity3")
        disableNames.add("eu.araulin.devinci.MainActivity2")
        //disableNames.add("in.myinnos.changeappiconandname.MainActivityMessage")
        AppIconNameChanger.Builder(this@MainActivity)
                .activeName(activeName) // String
                .disableNames(disableNames) // List<String>
                .packageName(BuildConfig.APPLICATION_ID)
                .build()
                .setNow()
        Log.d("changeIcon", "changed")
        return success

    }
}
