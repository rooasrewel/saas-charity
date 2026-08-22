<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CaseRequest;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class CaseController extends Controller
{
    /**
     * 1) استعراض الحالات المعتمدة (العامة) للمتبرعين
     */
    public function index(Request $request)
    {
        $query = CaseRequest::query()
            ->where('status', 'approved')
            ->with([
                'beneficiary:id,name,profile_image',
                'organization:id,name,profile_image',
            ])
            ->orderBy('created_at', 'desc');

        // فلترة اختيارية حسب نوع الاحتياج
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        $cases = $query->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب الحالات بنجاح',
            'data' => $cases,
        ]);
    }

    /**
     * 2) عرض تفاصيل حالة معينة
     */
    public function show($id)
    {
        $case = CaseRequest::query()
            ->with([
                'beneficiary:id,name,profile_image',
                'organization:id,name,profile_image',
            ])
            ->find($id);

        if (!$case) {
            return response()->json([
                'status' => 'error',
                'message' => 'الحالة غير موجودة.',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب تفاصيل الحالة بنجاح',
            'data' => $case,
        ]);
    }

    /**
     * الحالات الخاصة بالمحتاج الحالي (كل حالاته بمختلف الأوضاع)
     * تشمل حالة زيارة التحقق الميداني (بانتظار مندوب / تم التحقق) حتى يعرف المحتاج أين وصل طلبه
     */
    public function myRequests(Request $request)
    {
        $cases = CaseRequest::query()
            ->where('beneficiary_id', $request->user()->id)
            ->with([
                'organization:id,name,profile_image',
                // نعرض فقط حالة الزيارة وبيانات المندوب (اسمه وهاتفه للتنسيق)، وليس نص تقرير التحقق الداخلي
                'visits' => fn ($q) => $q->select('id', 'case_request_id', 'agent_id', 'status', 'visited_at')
                    ->with('agent:id,name,phone,profile_image')
                    ->latest(),
            ])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب حالاتك بنجاح',
            'data' => $cases,
        ]);
    }

    /**
     * 1) رفع حالة جديدة (خاص بالمحتاج)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'category' => 'nullable|string|max:100',
            'target_amount' => 'required|numeric|min:1',
            'images.*' => 'nullable|image|max:4096', // حتى 4 ميجا لكل صورة
        ]);

        $imagePaths = [];
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                $imagePaths[] = $image->store('cases', 'public');
            }
        }

        $case = CaseRequest::create([
            'beneficiary_id' => $request->user()->id,
            'title' => $validated['title'],
            'description' => $validated['description'],
            'category' => $validated['category'] ?? null,
            'target_amount' => $validated['target_amount'],
            'images' => $imagePaths,
            'status' => 'pending',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم إرسال حالتك بنجاح، وهي الآن بانتظار مراجعة الإدارة.',
            'data' => $case,
        ], 201);
    }

    /**
     * تعديل حالة لم تتم مراجعتها بعد (خاص بصاحب الحالة فقط)
     */
    public function update(Request $request, $id)
    {
        $case = CaseRequest::query()
            ->where('beneficiary_id', $request->user()->id)
            ->find($id);

        if (!$case) {
            return response()->json([
                'status' => 'error',
                'message' => 'الحالة غير موجودة أو لا تخصك.',
            ], 404);
        }

        if ($case->status !== 'pending') {
            return response()->json([
                'status' => 'error',
                'message' => 'لا يمكن تعديل حالة تمت مراجعتها بالفعل.',
            ], 400);
        }

        $validated = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'category' => 'nullable|string|max:100',
            'target_amount' => 'sometimes|required|numeric|min:1',
        ]);

        $case->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث الحالة بنجاح.',
            'data' => $case,
        ]);
    }
}
