<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class OrganizationController extends Controller
{
    /**
     * المشاريع الخاصة بالجمعية الحالية (كل الحالات، مو بس المعتمدة)
     */
    public function myProjects(Request $request)
    {
        $projects = $request->user()->projects()
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب مشاريعكم بنجاح',
            'data' => $projects,
        ]);
    }

    /**
     * حالات المحتاجين المُسندة لهذه الجمعية لمتابعتها
     */
    public function assignedCases(Request $request)
    {
        $cases = $request->user()->assignedCases()
            ->with('beneficiary:id,name,phone,profile_image')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب الحالات المسندة لكم بنجاح',
            'data' => $cases,
        ]);
    }

    /**
     * إحصائيات سريعة للجمعية
     */
    public function stats(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب الإحصائيات بنجاح',
            'data' => [
                'projects_count' => $user->projects()->count(),
                'approved_projects_count' => $user->projects()->where('status', 'approved')->count(),
                'total_collected' => (float) $user->projects()->sum('collected_amount'),
                'assigned_cases_count' => $user->assignedCases()->count(),
                'pending_assigned_cases' => $user->assignedCases()->where('status', 'pending')->count(),
            ],
        ]);
    }
}
