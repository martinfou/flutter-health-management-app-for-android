package com.healthapp.health_app

import android.content.Context
import android.os.Build
import android.util.Log
import com.google.mlkit.genai.common.DownloadStatus
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.GenerativeModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.withContext
import org.json.JSONObject

/**
 * Service for interacting with Gemini Nano via ML Kit GenAI Prompt API.
 *
 * Supported devices:
 * - Google Pixel 8 Pro and later
 * - Android 14+ with AI Core enabled
 *
 * This service provides:
 * - Device capability detection
 * - Text generation using on-device Gemini Nano
 * - Model lifecycle management
 */
class AiCoreService(private val context: Context) {

    companion object {
        private const val TAG = "AiCoreService"

        // Minimum Android version for AI Core (Android 14)
        private const val MIN_SDK_FOR_AI_CORE = 34
    }

    private var generativeModel: GenerativeModel? = null
    private var isModelReady = false
    private var aiCoreAvailable: Boolean? = null

    /**
     * Check if AI Core is available on this device.
     */
    suspend fun isAvailable(): Boolean = withContext(Dispatchers.IO) {
        // Return cached result if available
        aiCoreAvailable?.let { return@withContext it }

        val result = checkAiCoreAvailability()
        aiCoreAvailable = result
        result
    }

    private suspend fun checkAiCoreAvailability(): Boolean {
        // Check Android version
        if (Build.VERSION.SDK_INT < MIN_SDK_FOR_AI_CORE) {
            Log.d(TAG, "AI Core not available: Android version ${Build.VERSION.SDK_INT} < $MIN_SDK_FOR_AI_CORE")
            return false
        }

        return try {
            // Initialize the generative model client
            val model = Generation.getClient()
            generativeModel = model

            // Check the feature status
            val status = model.checkStatus()
            Log.d(TAG, "AI Core feature status: $status on ${Build.MODEL}")

            when (status) {
                FeatureStatus.UNAVAILABLE -> {
                    Log.d(TAG, "Gemini Nano not supported on this device")
                    false
                }
                FeatureStatus.DOWNLOADABLE -> {
                    Log.d(TAG, "Gemini Nano is downloadable, starting download...")
                    // Start download in background
                    downloadModel(model)
                    true // Available but needs download
                }
                FeatureStatus.DOWNLOADING -> {
                    Log.d(TAG, "Gemini Nano is currently downloading")
                    true
                }
                FeatureStatus.AVAILABLE -> {
                    Log.d(TAG, "Gemini Nano is ready to use")
                    isModelReady = true
                    true
                }
                else -> {
                    Log.w(TAG, "Unknown feature status: $status")
                    false
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking AI Core availability: ${e.message}", e)
            false
        }
    }

    private suspend fun downloadModel(model: GenerativeModel) {
        try {
            model.download().collect { status ->
                when (status) {
                    is DownloadStatus.DownloadStarted -> {
                        Log.d(TAG, "Starting download for Gemini Nano")
                    }
                    is DownloadStatus.DownloadProgress -> {
                        Log.d(TAG, "Gemini Nano: ${status.totalBytesDownloaded} bytes downloaded")
                    }
                    DownloadStatus.DownloadCompleted -> {
                        Log.d(TAG, "Gemini Nano download complete")
                        isModelReady = true
                    }
                    is DownloadStatus.DownloadFailed -> {
                        Log.e(TAG, "Gemini Nano download failed: ${status.e.message}")
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error downloading model: ${e.message}", e)
        }
    }

    /**
     * Load the on-device model for inference.
     */
    suspend fun loadModel(): Result<Boolean> = withContext(Dispatchers.IO) {
        if (!isAvailable()) {
            return@withContext Result.failure(
                AiCoreException("AI Core not available on this device")
            )
        }

        try {
            val model = generativeModel ?: Generation.getClient().also { generativeModel = it }

            // Warm up the model for faster first inference
            model.warmup()
            Log.d(TAG, "Model warmed up successfully")
            isModelReady = true
            Result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load model: ${e.message}", e)
            Result.failure(AiCoreException("Failed to load model: ${e.message}"))
        }
    }

    /**
     * Unload the model to free memory.
     */
    suspend fun unloadModel(): Result<Boolean> = withContext(Dispatchers.IO) {
        try {
            generativeModel?.close()
            generativeModel = null
            isModelReady = false
            Log.d(TAG, "Model unloaded")
            Result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to unload model: ${e.message}", e)
            Result.failure(AiCoreException("Failed to unload model: ${e.message}"))
        }
    }

    /**
     * Generate text using the on-device model.
     *
     * @param prompt The user prompt
     * @param systemPrompt Optional system prompt for context
     * @param maxTokens Maximum tokens to generate
     * @param temperature Temperature for generation (0.0 to 1.0)
     * @return Generated text response as JSON
     */
    suspend fun generateText(
        prompt: String,
        systemPrompt: String? = null,
        maxTokens: Int = 1024,
        temperature: Double = 0.7
    ): Result<String> = withContext(Dispatchers.IO) {

        if (!isAvailable()) {
            return@withContext Result.failure(
                AiCoreException("AI Core not available on this device")
            )
        }

        try {
            val model = generativeModel ?: Generation.getClient().also { generativeModel = it }

            // Check if model is ready
            val status = model.checkStatus()
            if (status != FeatureStatus.AVAILABLE) {
                return@withContext Result.failure(
                    AiCoreException("Model not ready. Status: $status")
                )
            }

            Log.d(TAG, "Generating text with Gemini Nano")
            Log.d(TAG, "Prompt length: ${prompt.length} chars")
            Log.d(TAG, "System prompt: ${systemPrompt?.take(50) ?: "none"}...")

            // Combine system prompt and user prompt
            val fullPrompt = if (systemPrompt != null) {
                "$systemPrompt\n\n$prompt"
            } else {
                prompt
            }

            // Generate content using ML Kit GenAI
            val response = model.generateContent(fullPrompt)

            // Extract the generated text
            val generatedText = response.candidates.firstOrNull()?.text
                ?: return@withContext Result.failure(
                    AiCoreException("No response generated")
                )

            Log.d(TAG, "Generated response: ${generatedText.take(100)}...")

            // Format response as JSON matching LlmResponse structure
            val jsonResponse = JSONObject().apply {
                put("content", generatedText)
                put("model", "gemini-nano-on-device")
                put("prompt_tokens", estimateTokens(fullPrompt))
                put("completion_tokens", estimateTokens(generatedText))
                put("total_tokens", estimateTokens(fullPrompt + generatedText))
            }

            Result.success(jsonResponse.toString())

        } catch (e: Exception) {
            Log.e(TAG, "Text generation failed: ${e.message}", e)
            Result.failure(AiCoreException("Text generation failed: ${e.message}"))
        }
    }

    /**
     * Estimate token count for a string.
     * Gemini Nano uses ~4 characters per token on average.
     */
    private fun estimateTokens(text: String): Int {
        return (text.length / 4).coerceAtLeast(1)
    }

    /**
     * Get information about the on-device model.
     */
    suspend fun getModelInfo(): Map<String, Any> = withContext(Dispatchers.IO) {
        val model = generativeModel
        val modelName = try {
            model?.getBaseModelName() ?: "gemini-nano"
        } catch (e: Exception) {
            "gemini-nano"
        }

        mapOf(
            "available" to (aiCoreAvailable ?: false),
            "loaded" to isModelReady,
            "device" to Build.MODEL,
            "android_version" to Build.VERSION.SDK_INT,
            "model_name" to modelName,
            "provider" to "on-device",
            "max_context_tokens" to 4000, // ML Kit limit
            "max_output_tokens" to 256, // Recommended limit
            "supports_streaming" to true
        )
    }
}

/**
 * Exception thrown when AI Core operations fail.
 */
class AiCoreException(message: String, cause: Throwable? = null) : Exception(message, cause)
