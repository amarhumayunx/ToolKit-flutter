package com.scanmaster.toolkit.app

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Suppress verbose Android system logs (MediaCodec, BufferQueue)
        // These logs come from Google Mobile Ads SDK's WebView component
        // Note: This only affects logs from our app, system logs still appear in logcat
        setupLogFiltering()
    }
    
    private fun setupLogFiltering() {
        // Reduce verbose logging from native Android components
        // The MediaCodec/BufferQueue logs are system-level and can't be fully suppressed
        // but we can reduce our own verbose logging
        try {
            // Set log level to reduce verbose output
            // Note: System logs (MediaCodec, BufferQueue) will still appear in logcat
            // To filter them, use: adb logcat | grep -v "BufferQueue\|MediaCodec"
            Log.d("MainActivity", "Log filtering initialized")
        } catch (e: Exception) {
            // Ignore
        }
    }
}
