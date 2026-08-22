<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Project;
use App\Models\AgentTask;
use App\Models\CaseRequest;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. إنشاء حساب مدير ثابت للتجربة
        $admin = User::create([
            'name' => 'الإدارة العامة',
            'email' => 'admin@admin.com',
            'password' => bcrypt('password'), // كلمة المرور الموحدة: password
            'role' => 'admin',
            'phone' => '000000000',
        ]);

        // 2. إنشاء حساب جمعية ثابت
        $org = User::create([
            'name' => 'جمعية الأمل الخيرية',
            'email' => 'org@org.com',
            'password' => bcrypt('password'),
            'role' => 'organization',
            'phone' => '111111111',
        ]);

        // 3. إنشاء حساب متبرع ثابت مع رصيد 5000
        $donor = User::create([
            'name' => 'أحمد المتبرع',
            'email' => 'donor@donor.com',
            'password' => bcrypt('password'),
            'role' => 'donor',
            'phone' => '222222222',
            'wallet_balance' => 5000,
        ]);

        // 4. إنشاء حساب مندوب ثابت
        $agent = User::create([
            'name' => 'خالد المندوب',
            'email' => 'agent@agent.com',
            'password' => bcrypt('password'),
            'role' => 'agent',
            'phone' => '333333333',
        ]);

        // إنشاء بروفايل المندوب (نوع المركبة وحالة التوفر) - بدونه لا يظهر ضمن المندوبين المتاحين
        $agent->agent()->create([
            'vehicle_type' => 'سيارة',
            'vehicle_number' => 'أ ب ج 1234',
            'is_available' => true,
            'status' => 'approved', // معتمد مسبقاً للتجربة الفورية
        ]);

        // مندوب ثاني بانتظار موافقة الإدارة (لتجربة workflow الاعتماد الجديد)
        $pendingAgent = User::create([
            'name' => 'مندوب جديد بانتظار الموافقة',
            'email' => 'pending.agent@agent.com',
            'password' => bcrypt('password'),
            'role' => 'agent',
            'phone' => '333333334',
        ]);
        $pendingAgent->agent()->create([
            'vehicle_type' => 'دراجة نارية',
            'is_available' => true,
            'status' => 'pending',
        ]);

        // 4.1 إنشاء حساب محتاج ثابت
        $beneficiary = User::create([
            'name' => 'سالم المحتاج',
            'email' => 'beneficiary@beneficiary.com',
            'password' => bcrypt('password'),
            'role' => 'beneficiary',
            'phone' => '444444444',
        ]);

        // 4.2 إنشاء حالتين تجريبيتين: واحدة معتمدة (تظهر للمتبرعين) وواحدة معلقة (بانتظار مراجعة الأدمن)
        CaseRequest::create([
            'beneficiary_id' => $beneficiary->id,
            'organization_id' => $org->id, // جمعية مسؤولة عنها، تقدر توضح التواصل
            'title' => 'عملية جراحية عاجلة لطفلي',
            'description' => 'طفلي بحاجة لعملية جراحية عاجلة في القلب وتكلفتها تفوق قدرتنا المادية.',
            'category' => 'علاج طبي',
            'target_amount' => 8000,
            'collected_amount' => 1200,
            'status' => 'approved',
        ]);

        CaseRequest::create([
            'beneficiary_id' => $beneficiary->id,
            'title' => 'مساعدة في إيجار السكن',
            'description' => 'أحتاج مساعدة لدفع إيجار المنزل لهذا الشهر بعد فقدان عملي.',
            'category' => 'سكن',
            'target_amount' => 1500,
            'status' => 'pending',
        ]);

        // 5. إنشاء بعض المشاريع (الحالات)
       // 5. إنشاء بعض المشاريع (الحالات)
        Project::create([
            'organization_id' => $org->id,
            'title' => 'حفر بئر مياه',
            'description' => 'توفير مياه شرب نقية لقرية نائية تحتاج المساعدة العاجلة.',
            'target_amount' => 1000, // تم التعديل لتطابق المودل
            'collected_amount' => 200,
            'is_urgent' => true,
            'status' => 'approved',
        ]);

        Project::create([
            'organization_id' => $org->id,
            'title' => 'كفالة أيتام',
            'description' => 'كفالة 5 أيتام لمدة سنة كاملة وتوفير مستلزماتهم.',
            'target_amount' => 5000, // تم التعديل لتطابق المودل
            'collected_amount' => 0,
            'is_urgent' => false,
            'status' => 'pending',
        ]);

        // 6. إنشاء مهمة وهمية للمندوب
        AgentTask::create([
            'agent_id' => $agent->id,
            'title' => 'استلام تبرع عيني (ملابس شتوية)',
            'description' => 'التوجه لعنوان المتبرع لاستلام الملابس وتوثيق العملية.',
            'qr_code' => Str::random(10), // كود QR عشوائي
            'status' => 'pending',
        ]);

        $this->command->info('تم زراعة البيانات الوهمية بنجاح! جميع الحسابات كلمة مرورها: password');
        $this->command->info('حساب المحتاج للتجربة: beneficiary@beneficiary.com');
    }
}
