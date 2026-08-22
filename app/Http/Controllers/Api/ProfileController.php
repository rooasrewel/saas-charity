<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash; // لا تنسَ هذا السطر لتشفير كلمة المرور
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    /**
     * استكمال بيانات الملف الشخصي بناءً على دور المستخدم
     */
    public function completeProfile(Request $request)
    {
        $user = $request->user(); // جلب المستخدم المسجل دخوله حالياً

        // 1. إذا كان المستخدم "جمعية"
        if ($user->role === 'organization') {
            $validated = $request->validate([
                'license_number' => 'required|string|unique:organizations,license_number,' . optional($user->organization)->id,
                'address' => 'required|string',
                'description' => 'nullable|string',
            ]);
            $user->organization()->updateOrCreate(['user_id' => $user->id], $validated);
        }

        // 2. إذا كان المستخدم "مستفيد"
        elseif ($user->role === 'beneficiary') {
            $validated = $request->validate([
                'national_id' => 'required|string|unique:beneficiaries,national_id,' . optional($user->beneficiary)->id,
                'address' => 'nullable|string',
                'family_members_count' => 'required|integer|min:1',
            ]);
            $user->beneficiary()->updateOrCreate(['user_id' => $user->id], $validated);
        }

        // 3. إذا كان المستخدم "مندوب"
        elseif ($user->role === 'agent') {
            $this->handleAgentSetup($request, $user);
        }

        // 4. إذا كان المستخدم "متبرع"
        elseif ($user->role === 'donor') {
            $this->handleDonorProfile($request, $user);
        }

        // جلب المستخدم مع بيانات البروفايل الجديد الخاص به لعرضها في الرد
        $user->load($user->role);

        return response()->json([
            'message' => 'تم تحديث واستكمال بيانات الملف الشخصي بنجاح',
            'user' => $user
        ], 200);
    }

    /**
     * مسار منفصل مخصص لإعداد بروفايل المندوب (POST /agent/setup)
     * يستخدم نفس منطق completeProfile بالضبط حتى لا يتعارض الاثنان أو يسببا بيانات متضاربة.
     */
    public function agentSetup(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'agent') {
            return response()->json([
                'status' => 'error',
                'message' => 'هذا المسار مخصص لحسابات المندوبين فقط.'
            ], 403);
        }

        $agent = $this->handleAgentSetup($request, $user);

        return response()->json([
            'status' => 'success',
            'message' => $agent->wasRecentlyCreated
                ? 'تم إرسال بيانات إعدادك بنجاح، بانتظار موافقة الإدارة عليك لتتمكن من استلام المهام.'
                : 'تم تحديث بياناتك بنجاح.',
            'data' => $agent,
        ], 200);
    }

    /**
     * تحديد حالة اعتماد المندوب الحالي (بانتظار المراجعة / معتمد / مرفوض)
     */
    public function agentApprovalStatus(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'agent') {
            return response()->json(['status' => 'error', 'message' => 'هذا المسار مخصص لحسابات المندوبين فقط.'], 403);
        }

        $agent = $user->agent;

        if (!$agent) {
            return response()->json([
                'status' => 'success',
                'message' => 'لم يتم استكمال بيانات البروفايل بعد.',
                'data' => ['status' => 'not_setup'],
            ]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب حالة الاعتماد بنجاح',
            'data' => [
                'status' => $agent->status,
                'rejection_reason' => $agent->rejection_reason,
            ],
        ]);
    }

    /**
     * منطق مشترك لإعداد/تحديث بروفايل المندوب (نوع المركبة...) يُستخدم من مسارين مختلفين
     */
    private function handleAgentSetup(Request $request, $user)
    {
        $validated = $request->validate([
            'vehicle_type' => 'required|string',
            'vehicle_number' => 'nullable|string',
        ]);

        $isNew = !$user->agent()->exists();

        // عند أول إعداد فقط تكون الحالة "بانتظار المراجعة"، لا نغيّر حالة اعتماد سابقة عند مجرد تعديل البيانات
        if ($isNew) {
            $validated['status'] = 'pending';
        }

        return $user->agent()->updateOrCreate(['user_id' => $user->id], $validated);
    }

    /**
     * منطق استكمال بروفايل المتبرع (كان يتجاهل country/city/causes/الصورة رغم إرسال الفرونت إند لها)
     */
    private function handleDonorProfile(Request $request, $user)
    {
        $validated = $request->validate([
            'is_anonymous' => 'required|boolean',
            'country' => 'nullable|string|max:100',
            'city' => 'nullable|string|max:100',
            'causes' => 'nullable|array',
            'causes.*' => 'string|max:100',
            'profile_image' => 'nullable|image|max:4096',
        ]);

        if ($request->hasFile('profile_image')) {
            if ($user->donor && $user->donor->photo) {
                Storage::disk('public')->delete($user->donor->photo);
            }
            $validated['photo'] = $request->file('profile_image')->store('donor-photos', 'public');
        }
        unset($validated['profile_image']);

        $user->donor()->updateOrCreate(['user_id' => $user->id], $validated);
    }

    /**
     * تحديث البيانات الأساسية (الاسم والبريد الإلكتروني لأي مستخدم)
     */
    public function updateInfo(Request $request)
    {
        $user = $request->user();

        // التحقق من البيانات (نسمح بتحديث الاسم أو الإيميل، ونتأكد أن الإيميل غير مستخدم لغيره)
        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|unique:users,email,' . $user->id,
        ]);

        $user->update($request->only(['name', 'email']));

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث البيانات الشخصية الأساسية بنجاح.',
            'data' => clone $user
        ], 200);
    }

    /**
     * رفع أو تحديث صورة البروفايل (كان العمود موجود بدون أي طريقة لرفع صورة فعلياً)
     */
    public function uploadImage(Request $request)
    {
        $request->validate([
            'profile_image' => 'required|image|max:4096', // حتى 4 ميجا
        ]);

        $user = $request->user();

        // حذف الصورة القديمة إن وجدت لتوفير المساحة
        if ($user->profile_image) {
            Storage::disk('public')->delete($user->profile_image);
        }

        $path = $request->file('profile_image')->store('profile-images', 'public');
        $user->update(['profile_image' => $path]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث صورة البروفايل بنجاح.',
            'data' => [
                'profile_image' => $path,
                'url' => Storage::disk('public')->url($path),
            ],
        ]);
    }

    /**
     * تغيير كلمة المرور لأي مستخدم
     */
    public function updatePassword(Request $request)
    {
        // التحقق من كلمة المرور الحالية والجديدة
        $request->validate([
            'current_password' => 'required|current_password',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        // تشفير وتحديث كلمة المرور
        $request->user()->update([
            'password' => Hash::make($request->new_password)
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم تغيير كلمة المرور بنجاح.'
        ], 200);
    }
}
