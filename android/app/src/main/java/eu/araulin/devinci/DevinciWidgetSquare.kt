package eu.araulin.devinci

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.util.Log
import android.widget.RemoteViews
import okhttp3.*
import java.io.IOException


/**
 * Implementation of App Widget functionality.
 */
class DevinciWidgetSquare : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
        
        


    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }

}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    val widgetText = context.getString(R.string.appwidget_text)
    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.devinci_widget_square)
    //views.setTextViewText(R.id.appwidget_text, widgetText)
    val sharedPref =context.getSharedPreferences("FlutterSharedPreferences",Context.MODE_PRIVATE)
    val url = sharedPref.getString("flutter.ical", "")

    if(url != ""){

        val request= Request.Builder().url(url).build()
        val client= OkHttpClient()
        client.newCall(request).enqueue(object : Callback {

            override fun onResponse(call: Call?, response: Response?) {
                val body=response?.body()?.string()
                Log.d("ical", body);
                if (body != null) {
                    parseIcal(body)
                }
            }

            override fun onFailure(call: Call?, e: IOException?) {
                views.setTextViewText(R.id.textView2, "zbeub2")
            }
        })

    }else{
        views.setTextViewText(R.id.textView2, "zbeub")
    }

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

fun parseIcal(ics: String) : Array<Cours> {
    val res = arrayOf<Cours>()
    val mainReg = """BEGIN:VEVENT([\s\S]*?)END:VEVENT""".toRegex(RegexOption.MULTILINE)
    val foundResults = mainReg.findAll(ics)
    for (vevent in foundResults){
        val dtstart: String
        val dtend: String
        val location: String
        val title: String
        val flag: String


        Log.d("dt", vevent.value)
    }
    return res
}

public class Cours(
    var title: String,
    var location: String,
    var from: Int,
    var to: Int,
    var flag: String)