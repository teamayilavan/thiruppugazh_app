package org.ayilavan.thiruppugazh

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.database.DatabaseUtils
import android.database.sqlite.SQLiteDatabase
import android.net.Uri
import android.util.Log
import android.widget.RemoteViews
import java.util.Calendar

/**
 * Home-screen widget showing the song of the day. Entirely offline: it reads
 * the app's own song database (read-only) and uses the same date-seeded pick
 * as the app's Home card ([DailySong]). Tapping it opens that song through the
 * app's existing `thiruppugazh://song/{id}` link. The user adds it from the
 * widget picker; the app never asks them to.
 */
class TodaysSongWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val views = buildViews(context)
        for (id in appWidgetIds) appWidgetManager.updateAppWidget(id, views)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // The song changes with the calendar date, so refresh when the date,
        // time or time zone changes, not only on the periodic update.
        when (intent.action) {
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> {
                val manager = AppWidgetManager.getInstance(context)
                val ids = manager.getAppWidgetIds(ComponentName(context, TodaysSongWidget::class.java))
                if (ids.isNotEmpty()) onUpdate(context, manager, ids)
            }
        }
    }

    private data class TodaysSong(
        val id: Int,
        val title: String,
        val englishTitle: String?,
        val place: String,
        val englishVenue: String?,
    )

    private fun buildViews(context: Context): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.todays_song_widget)

        // Flutter's SharedPreferences plugin stores values under a "flutter."
        // prefix. The widget follows the app's own language choices.
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val englishUi = prefs.getString("flutter.app_language", "ta") == "en"
        val englishLyrics = prefs.getString("flutter.lyrics_language", "ta") == "en"

        val label = context.getString(
            if (englishUi) R.string.widget_label_en else R.string.widget_label_ta,
        )
        views.setTextViewText(R.id.widget_label, label)

        val song = loadTodaysSong(context)
        val title: String
        val place: String
        val clickIntent: Intent
        if (song == null) {
            // The app has not been opened yet (no database) or it could not be
            // read: invite the user in rather than show nothing.
            title = context.getString(
                if (englishUi) R.string.widget_open_app_en else R.string.widget_open_app_ta,
            )
            place = ""
            clickIntent = Intent(context, MainActivity::class.java)
        } else {
            title = if (englishLyrics && !song.englishTitle.isNullOrBlank()) song.englishTitle else song.title
            place = if (englishLyrics && !song.englishVenue.isNullOrBlank()) song.englishVenue else song.place
            clickIntent = Intent(Intent.ACTION_VIEW, Uri.parse("thiruppugazh://song/${song.id}"))
                .setPackage(context.packageName)
        }

        views.setTextViewText(R.id.widget_title, title)
        views.setTextViewText(R.id.widget_place, place)
        views.setContentDescription(
            R.id.widget_root,
            listOf(label, title, place).filter { it.isNotBlank() }.joinToString(". "),
        )
        views.setOnClickPendingIntent(
            R.id.widget_root,
            PendingIntent.getActivity(
                context,
                0,
                clickIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            ),
        )
        return views
    }

    private fun loadTodaysSong(context: Context): TodaysSong? {
        val file = context.getDatabasePath(DB_NAME)
        if (!file.exists()) return null
        return try {
            SQLiteDatabase.openDatabase(file.path, null, SQLiteDatabase.OPEN_READONLY).use { db ->
                val count = DatabaseUtils.longForQuery(db, "SELECT COUNT(*) FROM songs", null).toInt()
                if (count <= 0) return@use null
                val today = Calendar.getInstance()
                val index = DailySong.indexFor(
                    today.get(Calendar.YEAR),
                    today.get(Calendar.MONTH) + 1,
                    today.get(Calendar.DAY_OF_MONTH),
                    count,
                )
                db.rawQuery(
                    "SELECT id, title, english_title, place, english_venue " +
                        "FROM songs ORDER BY id LIMIT 1 OFFSET ?",
                    arrayOf(index.toString()),
                ).use { cursor ->
                    if (!cursor.moveToFirst()) {
                        null
                    } else {
                        TodaysSong(
                            id = cursor.getInt(0),
                            title = cursor.getString(1) ?: "",
                            englishTitle = cursor.getString(2),
                            place = cursor.getString(3) ?: "",
                            englishVenue = cursor.getString(4),
                        )
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not read today's song for the widget", e)
            null
        }
    }

    companion object {
        private const val TAG = "TodaysSongWidget"
        private const val DB_NAME = "thiruppugazh.db"
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
    }
}
