package eu.araulin.devinci

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.opengl.Visibility
import android.util.Log
import android.view.View
import android.webkit.URLUtil
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import okhttp3.*
import java.io.IOException
import java.text.SimpleDateFormat
import java.time.LocalDate
import java.time.format.DateTimeFormatter
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
    views.setViewVisibility(R.id.no_class, View.GONE)
    views.setViewVisibility(R.id.error, View.GONE)
    views.setViewVisibility(R.id.main, View.GONE)
    views.setViewVisibility(R.id.setup, View.GONE)
    //views.setTextViewText(R.id.appwidget_text, widgetText)
    val sharedPref =context.getSharedPreferences("FlutterSharedPreferences",Context.MODE_PRIVATE)
    val url = sharedPref.getString("flutter.ical", "")

    if(url != "" && isOnline(context)){
        if( URLUtil.isValidUrl(url)) {
            val request = Request.Builder().url(url).build()
            val client = OkHttpClient()
            client.newCall(request).enqueue(object : Callback {

                override fun onResponse(call: Call?, response: Response?) {
                    val body = response?.body()?.string()

                    if (body != null) {
                        val events = parseIcal(body)
                        var title = ""
                        var location = ""
                        var time = ""
                        var flag = ""
                        val d = Date()
                        var date = addHoursToJavaUtilDate(d, -1)
                        val begin = date?.time
                        if (date != null) {
                            date.hours = 23
                        }
                        val end = date?.time
                        for (event in events) {
                            if (event.from?.time!! > begin!! && event.to?.time!! < end!!) {
                                title = event.title!!
                                location = event.location!!
                                if (location.contains("-")) {
                                    location = location.split("-")[0]
                                }
                                if (location.contains("(")) {
                                    location = location.split("(")[0]
                                }
                                if (location.contains("[")) {
                                    location = location.split("[")[0]
                                }
                                val calendar = GregorianCalendar.getInstance() // creates a new calendar instance
                                calendar.time = event.from
                                val calendar2 = GregorianCalendar.getInstance()
                                calendar2.time = event.to
                                time = calendar.get(Calendar.HOUR_OF_DAY).toString() + "h" + calendar.get(Calendar.MINUTE).toString() + " - " + calendar2.get(Calendar.HOUR_OF_DAY).toString() + "h" + calendar2.get(Calendar.MINUTE).toString()
                                flag = event.flag!!
                                break
                            }
                        }
                        if (title == "") {
                            views.setViewVisibility(R.id.no_class, View.VISIBLE)
                        } else {
                            views.setViewVisibility(R.id.main, View.VISIBLE)
                        }
                        if (flag == "distanciel") views.setTextColor(R.id.textView2, ContextCompat.getColor(context, R.color.zoom))
                        else views.setTextColor(R.id.textView2, ContextCompat.getColor(context, R.color.primary))
                        views.setTextViewText(R.id.textView, title)
                        views.setTextViewText(R.id.textView2, location)
                        views.setTextViewText(R.id.textView3, time)
                        appWidgetManager.updateAppWidget(appWidgetId, views)
                    }
                }

                override fun onFailure(call: Call?, e: IOException?) {
                    views.setTextViewText(R.id.errorTV, "Erreur réseau")
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                }
            })
        }else{
            views.setViewVisibility(R.id.setup, View.VISIBLE)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

    }else{
        views.setViewVisibility(R.id.setup, View.VISIBLE)
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

fun isOnline(context: Context): Boolean {
    val connectivityManager =
            context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    if (connectivityManager != null) {
        val capabilities =
                connectivityManager.getNetworkCapabilities(connectivityManager.activeNetwork)
        if (capabilities != null) {
            if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                Log.i("Internet", "NetworkCapabilities.TRANSPORT_CELLULAR")
                return true
            } else if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                Log.i("Internet", "NetworkCapabilities.TRANSPORT_WIFI")
                return true
            } else if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
                Log.i("Internet", "NetworkCapabilities.TRANSPORT_ETHERNET")
                return true
            }
        }
    }
    return false
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

fun addDaysToJavaUtilDate(date: Date?, days: Int): Date? {
    val calendar = Calendar.getInstance()
    calendar.time = date
    calendar.add(Calendar.DAY_OF_YEAR, days)
    return calendar.time
}