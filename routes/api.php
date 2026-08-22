<?php

use Illuminate\Http\Request;
use App\Http\Controllers\Api\AgentTaskController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\AdminProjectController;
use App\Http\Controllers\Api\AdminCaseController;
use App\Http\Controllers\Api\AutoDonationController;
use App\Http\Controllers\Api\CaseController;
use App\Http\Controllers\Api\CaseMessageController;
use App\Http\Controllers\Api\OrganizationController;
use App\Http\Controllers\Api\DonorController;
use App\Http\Controllers\Api\AdminAgentController;
use App\Http\Controllers\Api\FieldVisitController;
use App\Http\Controllers\Api\UploadController;
use App\Http\Controllers\Api\ChatController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AdminAuthController;
use App\Http\Controllers\Api\DonationController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\LeaderboardController;

// ==========================================
// المسارات العامة (متاحة لأي شخص)
// ==========================================
Route::get('/projects', [ProjectController::class, 'index']);
Route::get('/projects/urgent', [ProjectController::class, 'urgent']); // مسار الحالات العاجلة الجديد
Route::get('/projects/{id}', [ProjectController::class, 'show']); // مسار عرض تفاصيل مشروع
Route::get('/leaderboard', [LeaderboardController::class, 'topDonors']); // مسار لوحة الصدارة

// مسارات "حالات" المحتاجين العامة (تصفح المتبرعين)
Route::get('/cases', [CaseController::class, 'index']);
Route::get('/cases/{id}', [CaseController::class, 'show']);

// ------------------ مسارات المستخدمين العاديين ------------------
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// ------------------ مسارات لوحة تحكم المدراء ------------------
Route::post('/admin/register', [AdminAuthController::class, 'register']);
Route::post('/admin/login', [AdminAuthController::class, 'login']);

// ==========================================
// المسارات المحمية العامة (تحتاج توكن فقط لأي دور)
// ==========================================
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/admin/logout', [AdminAuthController::class, 'logout']);

    // استكمال البروفايل وتعديله وكلمة المرور (متاح للجميع)
    Route::post('/profile/complete', [ProfileController::class, 'completeProfile']);
    Route::put('/profile/info', [ProfileController::class, 'updateInfo']);
    Route::put('/profile/password', [ProfileController::class, 'updatePassword']);
    Route::post('/profile/image', [ProfileController::class, 'uploadImage']);

    // مسار التبرع (لمشروع أو لحالة محتاج) وعرض السجل وشحن المحفظة والسحب منها
    Route::post('/donations', [DonationController::class, 'store']);
    Route::get('/donations', [DonationController::class, 'index']);
    Route::post('/wallet/top-up', [WalletController::class, 'topUp']);
    Route::post('/wallet/withdraw', [WalletController::class, 'withdraw']);
    Route::get('/wallet/transactions', [WalletController::class, 'transactions']);
    Route::get('/wallet', [WalletController::class, 'index']);

    // مسارات الإشعارات (جديد)
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);

    // التواصل بخصوص حالة (متبرع أو محتاج يراسل الجمعية المسؤولة، أو العكس)
    Route::get('/cases/{caseId}/messages', [CaseMessageController::class, 'index']);
    Route::post('/cases/{caseId}/messages', [CaseMessageController::class, 'store']);

    // رفع صورة/مستند عام (متاح لأي مستخدم مسجل دخول)
    Route::post('/upload/photo', [UploadController::class, 'uploadPhoto']);
    Route::post('/upload/document', [UploadController::class, 'uploadDocument']);

    // المحادثات المباشرة (نظام polling بسيط - نفس المسارات التي يتوقعها الفرونت إند فعلياً)
    Route::get('/chat/messages/{receiverId}', [ChatController::class, 'fetchMessages']);
    Route::post('/chat/send', [ChatController::class, 'sendMessage']);
    Route::get('/chat/conversations', [ChatController::class, 'conversations']);
});

// ==========================================
// مسارات الجمعية (مسجل دخول + دور جمعية فقط)
// ==========================================
Route::middleware(['auth:sanctum', 'role:organization'])->group(function () {
    Route::get('/organization/dashboard', [OrganizationController::class, 'stats']);
    Route::get('/organization/projects', [OrganizationController::class, 'myProjects']);
    Route::get('/organization/cases', [OrganizationController::class, 'assignedCases']);

    // إنشاء مهمة لمندوب (مثلاً استلام تبرع عيني) وعرض المندوبين المتاحين
    Route::post('/organization/agent-tasks', [AgentTaskController::class, 'store']);
    Route::get('/organization/agents/available', [AgentTaskController::class, 'availableAgents']);

    // إضافة مشروع جديد (خاص بالجمعيات فقط)
    Route::post('/projects', [ProjectController::class, 'store']);
});

// ==========================================
// مسارات المحتاج (مسجل دخول + دور محتاج فقط)
// ==========================================
Route::middleware(['auth:sanctum', 'role:beneficiary'])->group(function () {
    // رفع حالة جديدة، استعراض حالاتي، تعديل حالة لسا معلقة
    Route::get('/my-cases', [CaseController::class, 'myRequests']);
    Route::post('/cases', [CaseController::class, 'store']);
    Route::put('/cases/{id}', [CaseController::class, 'update']);
});

// ==========================================
// مسارات المتبرع (مسجل دخول + دور متبرع فقط)
// ==========================================
Route::middleware(['auth:sanctum', 'role:donor'])->group(function () {
    Route::get('/donor/dashboard', [DonorController::class, 'dashboard']);

    // مسارات التبرع التلقائي
    Route::get('/auto-donations', [AutoDonationController::class, 'index']);
    Route::post('/auto-donations', [AutoDonationController::class, 'store']);
    Route::put('/auto-donations/status', [AutoDonationController::class, 'toggleStatus']);
});

// ==========================================
// مسارات الإدارة (مسجل دخول + دور أدمن فقط)
// ==========================================
Route::middleware(['auth:sanctum', 'role:admin'])->group(function () {
    // عرض المشاريع المعلقة
    Route::get('/admin/projects/pending', [AdminProjectController::class, 'pendingProjects']);

    // تغيير حالة المشروع (قبول أو رفض)
    Route::put('/admin/projects/{id}/status', [AdminProjectController::class, 'updateStatus']);

    // إدارة حالات المحتاجين: عرض الكل / المعلقة فقط، وتغيير الحالة (قبول/رفض + إسناد جمعية)
    Route::get('/admin/cases', [AdminCaseController::class, 'index']);
    Route::get('/admin/cases/pending', [AdminCaseController::class, 'pending']);
    Route::put('/admin/cases/{id}/status', [AdminCaseController::class, 'updateStatus']);

    // إنشاء مهمة لمندوب وعرض المندوبين المتاحين
    Route::post('/admin/agent-tasks', [AgentTaskController::class, 'store']);
    Route::get('/admin/agents/available', [AgentTaskController::class, 'availableAgents']);

    // موافقة/رفض حسابات المندوبين الجدد
    Route::get('/admin/agents/pending', [AdminAgentController::class, 'pending']);
    Route::put('/admin/agents/{id}/status', [AdminAgentController::class, 'updateStatus']);

    // إسناد حالة لمندوب للتحقق الميداني منها، وعرض تقارير الزيارات الخاصة بحالة معينة
    Route::post('/admin/cases/{id}/assign-agent', [FieldVisitController::class, 'assignAgent']);
    Route::get('/admin/cases/{id}/field-reports', [FieldVisitController::class, 'caseFieldReports']);
});
// ==========================================
// مسارات المندوب (مسجل دخول + دور مندوب فقط)
// ==========================================
Route::middleware(['auth:sanctum', 'role:agent'])->group(function () {
    // عرض مهام المندوب وتفاصيل مهمة واحدة
    Route::get('/agent/tasks', [AgentTaskController::class, 'index']);
    Route::get('/agent/tasks/{id}', [AgentTaskController::class, 'show']);

    // مسح الـ QR لتأكيد المهمة، أو تسجيل فشلها
    Route::post('/agent/tasks/scan', [AgentTaskController::class, 'scanQrCode']);
    Route::post('/agent/tasks/{id}/fail', [AgentTaskController::class, 'markFailed']);

    // تحديث حالة التوفر (متاح / غير متاح لاستلام مهام جديدة)
    Route::put('/agent/availability', [AgentTaskController::class, 'updateAvailability']);

    // إعداد بروفايل المندوب (مسار موازٍ لـ /profile/complete بنفس المنطق) وحالة الاعتماد
    Route::post('/agent/setup', [ProfileController::class, 'agentSetup']);
    Route::get('/agent/approval-status', [ProfileController::class, 'agentApprovalStatus']);

    // الحالات الميدانية المسندة له للتحقق منها (Field Cases) ورفع تقرير الزيارة
    Route::get('/agent/field-cases', [FieldVisitController::class, 'myFieldCases']);
    Route::get('/agent/field-cases/{id}', [FieldVisitController::class, 'show']);
    Route::post('/agent/field-cases/{id}/report', [FieldVisitController::class, 'submitReport']);
});
Route::middleware('auth:sanctum')->get('/user', function (Illuminate\Http\Request $request) {
    return response()->json([
        'status' => 'success',
        'data' => $request->user()
    ]);
});
