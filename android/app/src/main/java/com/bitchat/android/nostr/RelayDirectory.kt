package com.bitchat.android.nostr

import android.app.Application
import android.util.Log
import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader
import java.security.MessageDigest
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Loads the pinned relay coordinates bundled with MeshTalk and provides
 * nearest-relay lookup by geohash.
 *
 * MeshTalk deliberately does not download relay lists at runtime. The bundled
 * CSV is the only source, so the network configuration cannot be changed by
 * the upstream projects after release.
 */
object RelayDirectory {

    private const val TAG = "RelayDirectory"
    private const val ASSET_FILE = "nostr_relays.csv"

    data class RelayInfo(
        val url: String,
        val latitude: Double,
        val longitude: Double
    )

    @Volatile
    private var initialized: Boolean = false

    private val relays: MutableList<RelayInfo> = mutableListOf()
    private val relaysLock = Any()

    fun initialize(application: Application) {
        if (initialized) return
        synchronized(this) {
            if (initialized) return
            try {
                loadFromAssets(application)
                initialized = true
            } catch (e: Exception) {
                Log.e(TAG, "Failed to initialize RelayDirectory: ${e.message}")
            }
        }
    }

    /**
     * Return up to nRelays closest relay URLs to the geohash center.
     */
    fun closestRelaysForGeohash(geohash: String, nRelays: Int): List<String> {
        val snapshot = synchronized(relaysLock) { relays.toList() }
        if (snapshot.isEmpty()) return emptyList()
        val center = try {
            com.bitchat.android.geohash.Geohash.decodeToCenter(geohash)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to decode geohash")
            return emptyList()
        }

        val (lat, lon) = center
        return snapshot
            .asSequence()
            .sortedBy { haversineMeters(lat, lon, it.latitude, it.longitude) }
            .take(nRelays.coerceAtLeast(0))
            .map { it.url }
            .toList()
    }

    private fun haversineMeters(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
        val r = 6371000.0 // meters
        val dLat = Math.toRadians(lat2 - lat1)
        val dLon = Math.toRadians(lon2 - lon1)
        val a = sin(dLat / 2).pow(2.0) +
            cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) * sin(dLon / 2).pow(2.0)
        val c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return r * c
    }

    private fun normalizeRelayUrl(raw: String): String {
        val trimmed = raw.trim()
        if (trimmed.isEmpty()) return trimmed
        return if ("://" in trimmed) trimmed else "wss://$trimmed"
    }

    private fun loadFromAssets(application: Application) {
        val list = try {
            parseCsv(application.assets.open(ASSET_FILE))
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open asset $ASSET_FILE: ${e.message}")
            emptyList()
        }
        synchronized(relaysLock) {
            relays.clear()
            relays.addAll(list)
        }
        val hash = try {
            application.assets.open(ASSET_FILE).use { input ->
                streamSha256Hex(input)
            }
        } catch (e: Exception) {
            "error:${e.message}"
        }
        Log.i(TAG, "Loaded ${list.size} relay entries from assets/$ASSET_FILE, sha256=$hash")
    }

    private fun parseCsv(input: InputStream): List<RelayInfo> {
        val result = mutableListOf<RelayInfo>()
        BufferedReader(InputStreamReader(input)).use { reader ->
            while (true) {
                val line = reader.readLine() ?: break
                val trimmed = line.trim()
                if (trimmed.isEmpty()) continue
                if (trimmed.lowercase().startsWith("relay url")) continue
                val parts = trimmed.split(",")
                if (parts.size < 3) continue
                val url = normalizeRelayUrl(parts[0].trim())
                val lat = parts[1].trim().toDoubleOrNull()
                val lon = parts[2].trim().toDoubleOrNull()
                if (url.isEmpty() || lat == null || lon == null) continue
                result.add(RelayInfo(url = url, latitude = lat, longitude = lon))
            }
        }
        return result
    }

    private fun streamSha256Hex(input: InputStream): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val buf = ByteArray(8192)
        var read: Int
        while (true) {
            read = input.read(buf)
            if (read <= 0) break
            digest.update(buf, 0, read)
        }
        val bytes = digest.digest()
        return bytes.joinToString("") { b ->
            val v = b.toInt() and 0xff
            val s = Integer.toHexString(v)
            if (s.length == 1) "0$s" else s
        }
    }
}
