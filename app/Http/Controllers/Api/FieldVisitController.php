<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Agent;
use App\Models\CaseRequest;
use App\Models\CaseVisit;
use App\Models\Notification;
use Illuminate\Http\Request;

class FieldVisitController extends Controller
{
    /**
     * (أدمن) إسناد حالة لمندوب معتمد للتحقق منها ميدانياً
     */
    public function assignAgent(Request $request, $caseId)
    {
        $validated = $request->validate([
            'agent_id' => 'required|exists:users,id',
        ]);

        $case = CaseRequest::find($caseId);
        if (!$case) {
            return response()->json(['status' => 'error', 'message' => 'الحالة غير موجودة.'], 404);
        }

        $agent = Agent::query()->where('user_id', $validated['agent_id'])->first();
        if (!$agent || $agent->status !== 'approved') {
            return response()->json(['status' => 'error', 'message' => 'يجب اختيار مندوب معتمد من الإدارة.'], 422);
        }

        // منع إسناد مكرر طالما فيه زيارة مفتوحة (لم يُرفع تقريرها بعد) لنفس الحالة
        $hasOpenVisit = CaseVisit::query()
            ->where('case_request_id', $case->id)
            ->where('status', 'assigned')
            ->exists();

        if ($hasOpenVisit) {
            return response()->json(['status' => 'error', 'message' => 'يوجد بالفعل مندوب مُسند لهذه الحالة بانتظار تقريره.'], 400);
        }

        $visit = CaseVisit::create([
            'case_request_id' => $case->id,
            'agent_id' => $agent->user_id,
            'status' => 'assigned',
        ]);

        Notification::create([
            'user_id' => $agent->user_id,
            'title' => 'مهمة تحقق ميداني جديدة',
            'message' => "تم إسناد حالة '{$case->title}' لك للتحقق منها ميدانياً.",
        ]);

        // إشعار المحتاج بأن مندوباً سيزوره للتحقق من حالته
        Notification::create([
            'user_id' => $case->beneficiary_id,
            'title' => 'سيتم التحقق من حالتك ميدانياً',
            'message' => "تم تعيين مندوب ({$agent->user->name}) للتحقق من حالتك '{$case->title}' ميدانياً، ترقب تواصله معك.",
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم إسناد الحالة للمندوب بنجاح.',
            'data' => $visit,
        ], 201);
    }

    /**
     * (أدمن) عرض كل زيارات التحقق الميداني وتقاريرها الخاصة بحالة معينة
     */
    public function caseFieldReports($caseId)
    {
        $visits = CaseVisit::query()
            ->where('case_request_id', $caseId)
            ->with('agent:id,name,phone')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب تقارير التحقق الميداني بنجاح',
            'data' => $visits,
        ]);
    }

    /**
     * (مندوب) قائمة الحالات المسندة له للتحقق الميداني منها
     */
    public function myFieldCases(Request $request)
    {
        $visits = CaseVisit::query()
            ->where('agent_id', $request->user()->id)
            ->with('caseRequest:id,title,description,category,target_amount')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب حالاتك الميدانية بنجاح',
            'data' => $visits,
        ]);
    }

    /**
     * (مندوب) تفاصيل حالة ميدانية واحدة مسندة له
     */
    public function show(Request $request, $id)
    {
        $visit = CaseVisit::query()
            ->where('agent_id', $request->user()->id)
            ->with('caseRequest.beneficiary:id,name,phone,profile_image')
            ->find($id);

        if (!$visit) {
            return response()->json(['status' => 'error', 'message' => 'الزيارة غير موجودة أو لا تخصك.'], 404);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب تفاصيل الحالة الميدانية بنجاح',
            'data' => $visit,
        ]);
    }

    /**
     * (مندوب) رفع تقرير التحقق الميداني (نص + صور/مستندات دليل)
     */
    public function submitReport(Request $request, $id)
    {
        $visit = CaseVisit::query()
            ->where('agent_id', $request->user()->id)
            ->find($id);

        if (!$visit) {
            return response()->json(['status' => 'error', 'message' => 'الزيارة غير موجودة أو لا تخصك.'], 404);
        }

        if ($visit->status === 'reported') {
            return response()->json(['status' => 'error', 'message' => 'تم رفع تقرير هذه الزيارة مسبقاً.'], 400);
        }

        $validated = $request->validate([
            'report_text' => 'required|string',
            'photos.*' => 'nullable|image|max:4096',
            'documents.*' => 'nullable|file|mimes:pdf,jpg,jpeg,png,doc,docx|max:8192',
        ]);

        $photoPaths = [];
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $photoPaths[] = $photo->store('field-visits/photos', 'public');
            }
        }

        $documentPaths = [];
        if ($request->hasFile('documents')) {
            foreach ($request->file('documents') as $document) {
                $documentPaths[] = $document->store('field-visits/documents', 'public');
            }
        }

        $visit->update([
            'report_text' => $validated['report_text'],
            'photos' => $photoPaths,
            'documents' => $documentPaths,
            'status' => 'reported',
            'visited_at' => now(),
        ]);

        // إشعار تأكيد للمندوب نفسه
        $case = $visit->caseRequest;
        Notification::query()->create([
            'user_id' => $visit->agent_id,
            'title' => 'تم إرسال التقرير الميداني',
            'message' => "تم إرسال تقريرك الميداني بخصوص حالة '{$case?->title}' بنجاح، بانتظار مراجعة الإدارة.",
        ]);

        // إشعار المحتاج بأن الزيارة الميدانية اكتملت وحالته الآن قيد المراجعة النهائية
        if ($case) {
            Notification::query()->create([
                'user_id' => $case->beneficiary_id,
                'title' => 'اكتملت الزيارة الميدانية',
                'message' => "قام المندوب بزيارة والتحقق من حالتك '{$case->title}'، وهي الآن قيد المراجعة النهائية من الإدارة.",
            ]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم إرسال التقرير الميداني بنجاح.',
            'data' => $visit,
        ]);
    }
}
