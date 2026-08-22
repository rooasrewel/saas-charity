<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AutoDonation;
use App\Models\Donation;
use Illuminate\Http\Request;

class DonorController extends Controller
{
    /**
     * لوحة تحكم المتبرع: إحصائيات حقيقية بدل رسالة ترحيب ثابتة
     */
    public function dashboard(Request $request)
    {
        $user = $request->user();

        $totalDonated = Donation::query()->where('user_id', $user->id)->sum('amount');
        $donationsCount = Donation::query()->where('user_id', $user->id)->count();
        $projectsSupported = Donation::query()->where('user_id', $user->id)->whereNotNull('project_id')->distinct('project_id')->count('project_id');
        $casesSupported = Donation::query()->where('user_id', $user->id)->whereNotNull('case_request_id')->distinct('case_request_id')->count('case_request_id');

        $autoDonation = AutoDonation::query()
            ->where('user_id', $user->id)
            ->with(['project:id,title', 'caseRequest:id,title'])
            ->first();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب لوحة تحكم المتبرع بنجاح',
            'data' => [
                'wallet_balance' => (float) $user->wallet_balance,
                'total_donated' => (float) $totalDonated,
                'donations_count' => $donationsCount,
                'projects_supported' => $projectsSupported,
                'cases_supported' => $casesSupported,
                'auto_donation' => $autoDonation,
            ],
        ]);
    }
}
