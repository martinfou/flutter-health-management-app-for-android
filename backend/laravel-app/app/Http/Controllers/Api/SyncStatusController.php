<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseHelper;
use App\Http\Controllers\Controller;
use App\Models\UserDevice;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SyncStatusController extends Controller
{
    /**
     * Register or update device sync status
     * POST /api/v1/sync-status
     */
    public function sync(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            $validator = Validator::make($request->all(), [
                'device_id' => 'required|string',
                'device_name' => 'nullable|string',
                'device_model' => 'nullable|string',
                'platform' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return ResponseHelper::validationError($validator->errors());
            }

            $device = $user->devices()->updateOrCreate(
                [
                    'device_id' => $request->device_id,
                ],
                [
                    'device_name' => $request->device_name,
                    'device_model' => $request->device_model,
                    'platform' => $request->platform,
                    'last_sync_at' => now(),
                ]
            );

            // Get all user devices for coordination info
            $devices = $user->devices()
                ->orderBy('last_sync_at', 'desc')
                ->get();

            return ResponseHelper::success(
                [
                    'current_device' => $device,
                    'all_devices' => $devices,
                ],
                'Sync status updated successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to update sync status: ' . $e->getMessage());
        }
    }

    /**
     * Get sync status for all user devices
     * GET /api/v1/sync-status
     */
    public function index(Request $request)
    {
        try {
            $user = $request->attributes->get('user');

            $devices = $user->devices()
                ->orderBy('last_sync_at', 'desc')
                ->get();

            return ResponseHelper::success(
                ['devices' => $devices],
                'Device sync statuses retrieved successfully'
            );

        } catch (\Exception $e) {
            return ResponseHelper::serverError('Failed to retrieve sync statuses: ' . $e->getMessage());
        }
    }
}
