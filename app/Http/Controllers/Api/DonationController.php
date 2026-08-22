<?php

namespace App\Http\Controllers\Api;
use App\Models\Notification;
use App\Http\Controllers\Controller;
use App\Models\CaseRequest;
use App\Models\Donation;
use App\Models\Project;
use App\Models\Transaction; // تم إضافة مودل العمليات هنا
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DonationController extends Controller
{
    /**
     * استعراض سجل تبرعات المستخدم
     */
    public function index(Request $request)
    {
        // استخدام الأسلوب المعتمد: تهيئة الاستعلام أولاً
        $donations = Donation::query()
            ->where('user_id', $request->user()->id)
            ->with(['project:id,title', 'caseRequest:id,title']) // جلب اسم المشروع أو الحالة
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب سجل التبرعات بنجاح',
            'data' => $donations
        ]);
    }

    /**
     * عملية تبرع: إما لمشروع جمعية (project_id) أو مباشرة لحالة محتاج (case_request_id)
     * يجب إرسال أحدهما فقط
     */
    public function store(Request $request)
    {
        $request->validate([
            'project_id' => 'required_without:case_request_id|nullable|exists:projects,id',
            'case_request_id' => 'required_without:project_id|nullable|exists:case_requests,id',
            'amount' => 'required|numeric|min:1',
        ]);

        if ($request->filled('project_id') && $request->filled('case_request_id')) {
            return response()->json([
                'status' => 'error',
                'message' => 'اختر إما مشروعاً أو حالة للتبرع لها، وليس الاثنين معاً.'
            ], 400);
        }

        $user = $request->user();
        $amount = $request->amount;

        // التحقق من أن الرصيد يكفي
        if ($user->wallet_balance < $amount) {
            return response()->json([
                'status' => 'error',
                'message' => 'رصيدك غير كافٍ لإتمام التبرع.'
            ], 400);
        }

        return $request->filled('project_id')
            ? $this->donateToProject($request, $user, $amount)
            : $this->donateToCase($request, $user, $amount);
    }

    /**
     * تبرع لمشروع جمعية
     */
    private function donateToProject(Request $request, $user, $amount)
    {
        $project = Project::query()->find($request->project_id);

        if ($project->status !== 'approved') {
            return response()->json([
                'status' => 'error',
                'message' => 'لا يمكن التبرع لمشروع غير معتمد.'
            ], 400);
        }

        return DB::transaction(function () use ($request, $user, $amount, $project) {
            $user->wallet_balance -= $amount;
            $user->save();

            $project->collected_amount += $amount;
            $project->save();

            $donation = Donation::query()->create([
                'user_id' => $user->id,
                'project_id' => $project->id,
                'amount' => $amount,
            ]);

            Transaction::query()->create([
                'user_id' => $user->id,
                'amount' => $amount,
                'type' => 'donation',
                'status' => 'completed',
            ]);

            Notification::create([
                'user_id' => $user->id,
                'title' => 'تبرع ناجح، تقبل الله!',
                'message' => "تم التبرع بمبلغ {$amount} لمشروع '{$project->title}' بنجاح."
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'تم التبرع بنجاح، جزاك الله خيراً!',
                'donation' => $donation,
                'remaining_balance' => $user->wallet_balance
            ]);
        });
    }

    /**
     * تبرع مباشر لحالة محتاج
     */
    private function donateToCase(Request $request, $user, $amount)
    {
        $case = CaseRequest::query()->find($request->case_request_id);

        if ($case->status !== 'approved') {
            return response()->json([
                'status' => 'error',
                'message' => 'لا يمكن التبرع لحالة غير معتمدة من الإدارة.'
            ], 400);
        }

        if ($case->isFullyFunded()) {
            return response()->json([
                'status' => 'error',
                'message' => 'تم سد احتياج هذه الحالة بالكامل، شكراً لتفاعلك.'
            ], 400);
        }

        return DB::transaction(function () use ($request, $user, $amount, $case) {
            $user->wallet_balance -= $amount;
            $user->save();

            $case->collected_amount += $amount;
            if ($case->isFullyFunded()) {
                $case->status = 'completed';
            }
            $case->save();

            $donation = Donation::query()->create([
                'user_id' => $user->id,
                'case_request_id' => $case->id,
                'amount' => $amount,
            ]);

            Transaction::query()->create([
                'user_id' => $user->id,
                'amount' => $amount,
                'type' => 'donation',
                'status' => 'completed',
            ]);

            Notification::create([
                'user_id' => $user->id,
                'title' => 'تبرع ناجح، تقبل الله!',
                'message' => "تم التبرع بمبلغ {$amount} لحالة '{$case->title}' بنجاح."
            ]);

            // إشعار المحتاج بوصول تبرع جديد
            Notification::create([
                'user_id' => $case->beneficiary_id,
                'title' => 'تبرع جديد لحالتك',
                'message' => $case->status === 'completed'
                    ? "تم سد كامل المبلغ المطلوب لحالتك '{$case->title}'، تقبل الله!"
                    : "وصل تبرع جديد بمبلغ {$amount} لحالتك '{$case->title}'."
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'تم التبرع بنجاح، جزاك الله خيراً!',
                'donation' => $donation,
                'remaining_balance' => $user->wallet_balance,
                'case_status' => $case->status,
            ]);
        });
    }
}
