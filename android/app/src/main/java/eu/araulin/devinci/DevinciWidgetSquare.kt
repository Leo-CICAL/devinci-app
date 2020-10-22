package eu.araulin.devinci

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.util.Log
import android.widget.RemoteViews
import okhttp3.*
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

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

                if (body != null) {
                   val events = parseIcal(body)
                    var title = ""
                    var location = ""
                    var time = ""
                    var flag = ""
                    val date = addHoursToJavaUtilDate(Date(), 1)!!
                    val begin = date.time
                    date.hours = 23
                    val end = date.time
                    for(event in events){
                        if(event.from?.time!! > begin && event.to?.time!! < end){
                            title = event.title!!
                            location = event.location!!
                            if(location.contains("-")){
                                location = location.split("-")[0]
                            }
                            if(location.contains("(")){
                                location = location.split("(")[0]
                            }
                            if(location.contains("[")){
                                location = location.split("[")[0]
                            }
                            val calendar = GregorianCalendar.getInstance() // creates a new calendar instance
                            calendar.time = event.from
                            val calendar2 = GregorianCalendar.getInstance()
                            calendar2.time = event.to
                            time = calendar.get(Calendar.HOUR_OF_DAY).toString()+"h"+calendar.get(Calendar.MINUTE).toString()+" - "+calendar2.get(Calendar.HOUR_OF_DAY).toString()+"h"+calendar2.get(Calendar.MINUTE).toString()
                            break
                        }
                    }
                    Log.d("title",title)
                    views.setTextViewText(R.id.textView, title)
                    views.setTextViewText(R.id.textView2, location)
                    views.setTextViewText(R.id.textView3, time)
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                }
            }

            override fun onFailure(call: Call?, e: IOException?) {
                views.setTextViewText(R.id.textView2, "zbeub2")
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        })

    }else{
        views.setTextViewText(R.id.textView2, "zbeub")
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    // Instruct the widget manager to update the widget

}

fun parseIcal(ics: String) : MutableList<Cours> {
    val res = mutableListOf<Cours>()
    val mainReg = """BEGIN:VEVENT([\s\S]*?)END:VEVENT""".toRegex(RegexOption.MULTILINE)
    val foundResults = mainReg.findAll(ics)
    for (vevent in foundResults){
        //Log.d("vevent", vevent.value);
        val dtstart = Regex("""DTSTART:.*""").find(vevent.value)?.value?.replace("DTSTART:", "")
        val dtend = Regex("""DTEND:.*""").find(vevent.value)?.value?.replace("DTEND:", "")
        val location = Regex("""LOCATION:.*""").find(vevent.value)?.value?.replace("LOCATION:", "")
        val title = Regex("""TITLE:.*""").find(vevent.value)?.value?.replace("TITLE:", "")
        val flag = Regex("""FLAGPRESENTIEL:.*""").find(vevent.value)?.value?.replace("FLAGPRESENTIEL:", "")
        val sdf = SimpleDateFormat("yyyyMMdd'T'HHmmss")
        val from: Date = sdf.parse(dtstart)
        val to: Date = sdf.parse(dtend)
        res += Cours(title, location, from, to, flag)
    }
    return res
}

public class Cours(
        var title: String?,
        var location: String?,
        var from: Date?,
        var to: Date?,
        var flag: String?)

fun addHoursToJavaUtilDate(date: Date?, hours: Int): Date? {
    val calendar = Calendar.getInstance()
    calendar.time = date
    calendar.add(Calendar.HOUR_OF_DAY, hours)
    return calendar.time
}