<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CaseRequest;
use App\Models\Notification;
use Illuminate\Http\Request;

class CaseMessageController extends Controller
{
    /**
     * التأكد إن المستخدم مسموح له يشوف/يشارك برسائل هذه الحالة.
     * مسموح دائماً لـ: صاحب الحالة، الجمعية المسؤولة، والأدمن.
     * وأي مستخدم آخر (مثل متبرع مهتم بالحالة) مسموح له فقط إذا كانت الحالة "معتمدة" وظاهرة للعامة.
     */
    private function authorizeAccess(Request $request, CaseRequest $case): bool
    {
        $user = $request->user();

        if ($user->id === $case->beneficiary_id || $user->id === $case->organization_id || $user->role === 'admin') {
            return true;
        }

        return $case->status === 'approved';
    }

    /**
     * عرض محادثة حالة معينة
     */
    public function index(Request $request, $caseId)
    {
        $case = CaseRequest::find($caseId);

        if (!$case) {
            return response()->json(['status' => 'error', 'message' => 'الحالة غير موجودة.'], 404);
        }

        if (!$this->authorizeAccess($request, $case)) {
            return response()->json(['status' => 'error', 'message' => 'غير مصرح لك بالاطلاع على هذه المحادثة.'], 403);
        }

        $messages = $case->messages()
            ->with('sender:id,name,profile_image,role')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب المحادثة بنجاح',
            'data' => $messages,
        ]);
    }

    /**
     * إرسال رسالة بخصوص حالة (تواصل مع الجمعية المسؤولة عنها)
     */
    public function store(Request $request, $caseId)
    {
        $case = CaseRequest::find($caseId);

        if (!$case) {
            return response()->json(['status' => 'error', 'message' => 'الحالة غير موجودة.'], 404);
        }

        if (!$case->organization_id) {
            return response()->json([
                'status' => 'error',
                'message' => 'لم يتم تعيين جمعية مسؤولة عن هذه الحالة بعد، لا يمكن بدء محادثة.',
            ], 400);
        }

        if (!$this->authorizeAccess($request, $case)) {
            return response()->json(['status' => 'error', 'message' => 'غير مصرح لك بمراسلة هذه الحالة.'], 403);
        }

        $validated = $request->validate([
            'message' => 'required|string|max:2000',
        ]);

        $sender = $request->user();

        $newMessage = $case->messages()->create([
            'sender_id' => $sender->id,
            'message' => $validated['message'],
        ]);

        // تحديد الطرف الآخر لإشعاره
        $recipientId = $sender->id === $case->organization_id
            ? $case->beneficiary_id
            : $case->organization_id;

        Notification::create([
            'user_id' => $recipientId,
            'title' => 'رسالة جديدة بخصوص حالة',
            'message' => "لديك رسالة جديدة بخصوص حالة '{$case->title}' من {$sender->name}.",
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم إرسال الرسالة بنجاح',
            'data' => $newMessage->load('sender:id,name,profile_image,role'),
        ], 201);
    }
}
