<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Agent;
use App\Models\Notification;
use Illuminate\Http\Request;

class AdminAgentController extends Controller
{
    /**
     * قائمة المندوبين بانتظار موافقة الإدارة
     */
    public function pending()
    {
        $agents = Agent::query()
            ->where('status', 'pending')
            ->with('user:id,name,email,phone')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب المندوبين بانتظار المراجعة بنجاح',
            'data' => $agents,
        ]);
    }

    /**
     * الموافقة أو الرفض على مندوب جديد
     */
    public function updateStatus(Request $request, $id)
    {
        $validated = $request->validate([
            'status' => 'required|in:approved,rejected',
            'rejection_reason' => 'nullable|string|max:1000',
        ]);

        $agent = Agent::query()->find($id);

        if (!$agent) {
            return response()->json(['status' => 'error', 'message' => 'المندوب غير موجود.'], 404);
        }

        $agent->status = $validated['status'];
        $agent->rejection_reason = $validated['status'] === 'rejected' ? ($validated['rejection_reason'] ?? null) : null;
        $agent->save();

        $statusAr = $validated['status'] === 'approved' ? 'تمت الموافقة على' : 'تم رفض';
        Notification::create([
            'user_id' => $agent->user_id,
            'title' => 'تحديث حالة حسابك كمندوب',
            'message' => "$statusAr طلب انضمامك كمندوب." . ($agent->rejection_reason ? " السبب: {$agent->rejection_reason}" : ''),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث حالة المندوب بنجاح.',
            'data' => $agent,
        ]);
    }
}
