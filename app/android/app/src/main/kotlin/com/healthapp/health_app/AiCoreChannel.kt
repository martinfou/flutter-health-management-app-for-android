package com.healthapp.health_app

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/**
 * Flutter MethodChannel handler for AI Core operations.
 *
 * This class bridges Flutter (Dart) code with the native Android AI Core service,
 * enabling on-device AI capabilities through a platform channel.
 *
 * Channel name: "com.healthapp.health_app/ai_core"
 *
 * Available methods:
 * - isAvailable: Check if AI Core is available on this device
 * - loadModel: Load the on-device model into memory
 * - unloadModel: Unload the model to free memory
 * - generateText: Generate text using the on-device model
 * - getModelInfo: Get information about the on-device model
 */
class AiCoreChannel(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.healthapp.health_app/ai_core"
        private const val TAG = "AiCoreChannel"
    }

    private val channel = MethodChannel(messenger, CHANNEL_NAME)
    private val aiCoreService = AiCoreService(context)
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    init {
        channel.setMethodCallHandler(this)
        android.util.Log.d(TAG, "AI Core channel initialized")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        android.util.Log.d(TAG, "Method called: ${call.method}")

        when (call.method) {
            "isAvailable" -> handleIsAvailable(result)
            "loadModel" -> handleLoadModel(result)
            "unloadModel" -> handleUnloadModel(result)
            "generateText" -> handleGenerateText(call, result)
            "getModelInfo" -> handleGetModelInfo(result)
            else -> {
                android.util.Log.w(TAG, "Unknown method: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun handleIsAvailable(result: MethodChannel.Result) {
        scope.launch {
            try {
                val available = aiCoreService.isAvailable()
                android.util.Log.d(TAG, "isAvailable: $available")
                result.success(available)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "isAvailable error: ${e.message}")
                result.error("AI_CORE_ERROR", e.message, null)
            }
        }
    }

    private fun handleLoadModel(result: MethodChannel.Result) {
        scope.launch {
            try {
                val loadResult = aiCoreService.loadModel()
                if (loadResult.isSuccess) {
                    android.util.Log.d(TAG, "Model loaded successfully")
                    result.success(true)
                } else {
                    val error = loadResult.exceptionOrNull()
                    android.util.Log.e(TAG, "Model load failed: ${error?.message}")
                    result.error("AI_CORE_ERROR", error?.message ?: "Failed to load model", null)
                }
            } catch (e: Exception) {
                android.util.Log.e(TAG, "loadModel error: ${e.message}")
                result.error("AI_CORE_ERROR", e.message, null)
            }
        }
    }

    private fun handleUnloadModel(result: MethodChannel.Result) {
        scope.launch {
            try {
                val unloadResult = aiCoreService.unloadModel()
                if (unloadResult.isSuccess) {
                    android.util.Log.d(TAG, "Model unloaded successfully")
                    result.success(true)
                } else {
                    val error = unloadResult.exceptionOrNull()
                    android.util.Log.e(TAG, "Model unload failed: ${error?.message}")
                    result.error("AI_CORE_ERROR", error?.message ?: "Failed to unload model", null)
                }
            } catch (e: Exception) {
                android.util.Log.e(TAG, "unloadModel error: ${e.message}")
                result.error("AI_CORE_ERROR", e.message, null)
            }
        }
    }

    private fun handleGenerateText(call: MethodCall, result: MethodChannel.Result) {
        val prompt = call.argument<String>("prompt")
        val systemPrompt = call.argument<String>("systemPrompt")
        val maxTokens = call.argument<Int>("maxTokens") ?: 1024
        val temperature = call.argument<Double>("temperature") ?: 0.7

        if (prompt == null) {
            result.error("INVALID_ARGUMENT", "Prompt is required", null)
            return
        }

        scope.launch {
            try {
                val generateResult = aiCoreService.generateText(
                    prompt = prompt,
                    systemPrompt = systemPrompt,
                    maxTokens = maxTokens,
                    temperature = temperature
                )

                if (generateResult.isSuccess) {
                    val response = generateResult.getOrNull()
                    android.util.Log.d(TAG, "Text generated successfully")
                    result.success(response)
                } else {
                    val error = generateResult.exceptionOrNull()
                    android.util.Log.e(TAG, "Text generation failed: ${error?.message}")
                    result.error("AI_CORE_ERROR", error?.message ?: "Failed to generate text", null)
                }
            } catch (e: Exception) {
                android.util.Log.e(TAG, "generateText error: ${e.message}")
                result.error("AI_CORE_ERROR", e.message, null)
            }
        }
    }

    private fun handleGetModelInfo(result: MethodChannel.Result) {
        scope.launch {
            try {
                val info = aiCoreService.getModelInfo()
                android.util.Log.d(TAG, "Model info: $info")
                result.success(info)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "getModelInfo error: ${e.message}")
                result.error("AI_CORE_ERROR", e.message, null)
            }
        }
    }

    /**
     * Clean up resources when the channel is no longer needed.
     */
    fun dispose() {
        channel.setMethodCallHandler(null)
        android.util.Log.d(TAG, "AI Core channel disposed")
    }
}
