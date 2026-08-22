<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AgentTask;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AgentTaskController extends Controller
{
    /**
     * جلب المهام الخاصة بالمندوب الحالي
     */
    public function index(Request $request)
    {
        $tasks = AgentTask::query()
            ->where('agent_id', $request->user()->id)
            ->with(['donation.user:id,name,phone', 'donation.project:id,title', 'donation.caseRequest:id,title'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب المهام بنجاح',
            'data' => $tasks
        ]);
    }

    /**
     * تفاصيل مهمة واحدة (تُظهر بيانات المتبرع/الحالة المرتبطة بالمهمة)
     */
    public function show(Request $request, $id)
    {
        $task = AgentTask::query()
            ->where('agent_id', $request->user()->id)
            ->with(['donation.user:id,name,phone', 'donation.project:id,title', 'donation.caseRequest:id,title'])
            ->find($id);

        if (!$task) {
            return response()->json(['status' => 'error', 'message' => 'المهمة غير موجودة أو لا تخصك.'], 404);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب تفاصيل المهمة بنجاح',
            'data' => $task,
        ]);
    }

    /**
     * إنشاء مهمة جديدة لمندوب (خاص بالأدمن أو الجمعية)
     * مثال: استلام تبرع عيني، أو توصيل مساعدة لحالة معينة
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'agent_id' => 'required|exists:users,id',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'donation_id' => 'nullable|exists:donations,id',
        ]);

        $agent = User::query()->where('id', $validated['agent_id'])->where('role', 'agent')->first();

        if (!$agent) {
            return response()->json([
                'status' => 'error',
                'message' => 'المستخدم المحدد ليس مندوباً.'
            ], 422);
        }

        if (!$agent->agent || $agent->agent->status !== 'approved') {
            return response()->json([
                'status' => 'error',
                'message' => 'لا يمكن إسناد مهمة لمندوب لم توافق الإدارة على حسابه بعد.'
            ], 422);
        }

        $task = AgentTask::create([
            'agent_id' => $agent->id,
            'donation_id' => $validated['donation_id'] ?? null,
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'qr_code' => (string) Str::uuid(),
            'status' => 'pending',
        ]);

        Notification::create([
            'user_id' => $agent->id,
            'title' => 'مهمة جديدة',
            'message' => "تم إسناد مهمة جديدة لك: {$task->title}",
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم إنشاء المهمة وإسنادها للمندوب بنجاح.',
            'data' => $task,
        ], 201);
    }

    /**
     * قائمة المندوبين المتاحين حالياً (لمساعدة الجمعية/الأدمن باختيار من يُسند له المهمة)
     */
    public function availableAgents()
    {
        $agents = User::query()
            ->where('role', 'agent')
            ->whereHas('agent', fn ($q) => $q->where('is_available', true)->where('status', 'approved'))
            ->with('agent')
            ->get(['id', 'name', 'phone', 'profile_image']);

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب المندوبين المتاحين بنجاح',
            'data' => $agents,
        ]);
    }

    /**
     * مسح QR Code لتأكيد إنجاز المهمة
     */
    public function scanQrCode(Request $request)
    {
        $request->validate([
            'qr_code' => 'required|string',
            'notes' => 'nullable|string|max:500',
        ]);

        // البحث عن المهمة بناءً على الـ QR Code الخاص بها، والتأكد أنها تابعة لهذا المندوب
        $task = AgentTask::query()
            ->where('qr_code', $request->qr_code)
            ->where('agent_id', $request->user()->id)
            ->first();

        if (!$task) {
            return response()->json([
                'status' => 'error',
                'message' => 'الرمز غير صحيح أو المهمة لا تخصك'
            ], 404);
        }

        if ($task->status === 'completed') {
            return response()->json([
                'status' => 'error',
                'message' => 'تم إنجاز هذه المهمة مسبقاً'
            ], 400);
        }

        // تحديث حالة المهمة
        $task->update([
            'status' => 'completed',
            'notes' => $request->notes ?? $task->notes,
        ]);

        // (اختياري) إرسال إشعار للمندوب بنجاح العملية
        Notification::create([
            'user_id' => $request->user()->id,
            'title' => 'تم إنجاز المهمة',
            'message' => "تم تأكيد إنجاز المهمة: {$task->title}"
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم تأكيد إنجاز المهمة بنجاح!',
            'data' => $task
        ]);
    }

    /**
     * تسجيل فشل مهمة (مثلاً: المتبرع لم يرد أو العنوان غير صحيح) - كانت هذه الحالة موجودة
     * بقاعدة البيانات (enum) لكن لا توجد أي طريقة لتفعيلها فعلياً
     */
    public function markFailed(Request $request, $id)
    {
        $request->validate([
            'notes' => 'required|string|max:500',
        ]);

        $task = AgentTask::query()
            ->where('agent_id', $request->user()->id)
            ->find($id);

        if (!$task) {
            return response()->json(['status' => 'error', 'message' => 'المهمة غير موجودة أو لا تخصك.'], 404);
        }

        if ($task->status !== 'pending') {
            return response()->json(['status' => 'error', 'message' => 'لا يمكن تعديل مهمة تم إنجازها أو تسجيل فشلها بالفعل.'], 400);
        }

        $task->update([
            'status' => 'failed',
            'notes' => $request->notes,
        ]);

        Notification::create([
            'user_id' => $task->agent_id,
            'title' => 'تم تسجيل فشل المهمة',
            'message' => "تم تسجيل فشل المهمة '{$task->title}'. السبب: {$request->notes}",
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم تسجيل فشل المهمة.',
            'data' => $task,
        ]);
    }

    /**
     * تحديث حالة توفر المندوب (متاح / غير متاح لاستلام مهام جديدة)
     * لم تكن هذه الميزة موجودة إطلاقاً رغم وجود عمود is_available بقاعدة البيانات
     */
    public function updateAvailability(Request $request)
    {
        $validated = $request->validate([
            'is_available' => 'required|boolean',
        ]);

        $user = $request->user();

        if (!$user->agent) {
            return response()->json([
                'status' => 'error',
                'message' => 'يجب استكمال بيانات بروفايل المندوب أولاً (نوع المركبة) عبر /profile/complete.',
            ], 400);
        }

        $user->agent()->update(['is_available' => $validated['is_available']]);

        return response()->json([
            'status' => 'success',
            'message' => $validated['is_available'] ? 'أصبحت متاحاً لاستلام المهام.' : 'أصبحت غير متاح حالياً.',
            'data' => $user->agent()->first(),
        ]);
    }
}
