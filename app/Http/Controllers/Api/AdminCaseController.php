<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CaseRequest;
use App\Models\Notification;
use Illuminate\Http\Request;

class AdminCaseController extends Controller
{
    /**
     * جلب جميع الحالات المعلقة (بانتظار المراجعة)
     */
    public function pending()
    {
        $cases = CaseRequest::query()
            ->where('status', 'pending')
            ->with('beneficiary:id,name,phone,profile_image')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب الحالات المعلقة بنجاح',
            'data' => $cases,
        ]);
    }

    /**
     * جلب كل الحالات (لأي حالة) - لوحة إدارة عامة
     */
    public function index(Request $request)
    {
        $query = CaseRequest::query()
            ->with(['beneficiary:id,name,phone,profile_image', 'organization:id,name']);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $cases = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب الحالات بنجاح',
            'data' => $cases,
        ]);
    }

    /**
     * قبول أو رفض حالة، مع إمكانية إسناد جمعية مسؤولة عنها عند القبول
     */
    public function updateStatus(Request $request, $id)
    {
        $validated = $request->validate([
            'status' => 'required|in:approved,rejected',
            'organization_id' => 'nullable|exists:users,id',
            'admin_note' => 'nullable|string|max:1000',
        ]);

        $case = CaseRequest::find($id);

        if (!$case) {
            return response()->json(['status' => 'error', 'message' => 'الحالة غير موجودة.'], 404);
        }

        $case->status = $validated['status'];
        $case->admin_note = $validated['admin_note'] ?? null;

        if ($validated['status'] === 'approved' && !empty($validated['organization_id'])) {
            $case->organization_id = $validated['organization_id'];
        }

        $case->save();

        $statusAr = $validated['status'] === 'approved' ? 'اعتماد' : 'رفض';
        Notification::create([
            'user_id' => $case->beneficiary_id,
            'title' => 'تحديث حالة طلبك',
            'message' => "تم $statusAr حالتك '{$case->title}' من قبل الإدارة." . ($case->admin_note ? " ملاحظة: {$case->admin_note}" : ''),
        ]);

        if ($case->organization_id) {
            Notification::create([
                'user_id' => $case->organization_id,
                'title' => 'تم إسناد حالة جديدة لكم',
                'message' => "تم إسناد متابعة حالة '{$case->title}' إلى جمعيتكم.",
            ]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث حالة الطلب بنجاح.',
            'data' => $case,
        ]);
    }
}
