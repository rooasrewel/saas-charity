<?php

namespace App\Console\Commands;

use App\Models\Notification;
use Illuminate\Console\Command;
use App\Models\AutoDonation;
use App\Models\Donation;
use App\Models\Transaction;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class ProcessAutoDonations extends Command
{
    /**
     * اسم الأمر الذي سيُنفذ في الـ Terminal
     */
    protected $signature = 'donations:process-auto';

    /**
     * وصف الأمر
     */
    protected $description = 'معالجة التبرعات التلقائية (اليومية، الأسبوعية، الشهرية)';

    /**
     * تنفيذ الأمر
     */
    public function handle()
    {
        $this->info('بدأ معالجة التبرعات التلقائية...');

        // جلب جميع التبرعات التلقائية النشطة
        $autoDonations = AutoDonation::query()
            ->where('status', 'active')
            ->with(['project', 'caseRequest'])
            ->get();

        $count = 0; // لحساب كم عملية تمت

        foreach ($autoDonations as $donationConfig) {
            $user = User::query()->find($donationConfig->user_id);
            if (!$user) {
                continue;
            }

            // التحقق من أن موعد التبرع قد حان بناءً على الفترة الزمنية (interval)
            $lastProcessed = $donationConfig->last_processed_at ?? $donationConfig->created_at;
            $now = Carbon::now();
            $shouldProcess = match ($donationConfig->interval) {
                'daily' => $lastProcessed->diffInDays($now) >= 1,
                'weekly' => $lastProcessed->diffInWeeks($now) >= 1,
                'monthly' => $lastProcessed->diffInMonths($now) >= 1,
                default => false,
            };

            // تخطي هذا الإعداد إذا لم يحن موعد تنفيذه بعد حسب الفترة المختارة
            if (!$shouldProcess) {
                continue;
            }

            // تحديد الوجهة (مشروع أو حالة) والتأكد أنها لا تزال صالحة لاستقبال تبرعات
            $target = $donationConfig->project ?? $donationConfig->caseRequest;
            $isCase = (bool) $donationConfig->case_request_id;

            if (!$target) {
                $this->error("لا توجد وجهة صالحة للتبرع التلقائي للمستخدم: {$user->name}");
                $donationConfig->update(['last_processed_at' => $now]);
                continue;
            }

            $targetStillValid = $isCase
                ? ($target->status === 'approved' && !$target->isFullyFunded())
                : ($target->status === 'approved');

            if (!$targetStillValid) {
                Notification::create([
                    'user_id' => $user->id,
                    'title' => 'تم إيقاف التبرع التلقائي مؤقتاً',
                    'message' => "لم يُنفذ تبرعك التلقائي لأن الوجهة ({$target->title}) لم تعد متاحة لاستقبال التبرعات حالياً.",
                ]);
                $donationConfig->update(['last_processed_at' => $now]);
                continue;
            }

            // التحقق من توفر الرصيد
            if ($user->wallet_balance < $donationConfig->amount) {
                $this->error("الرصيد غير كافٍ للمستخدم: {$user->name}");

                Notification::create([
                    'user_id' => $user->id,
                    'title' => 'فشل التبرع التلقائي',
                    'message' => "لم يتم تنفيذ تبرعك التلقائي بمبلغ {$donationConfig->amount} بسبب عدم كفاية الرصيد. يرجى شحن محفظتك."
                ]);

                $donationConfig->update(['last_processed_at' => $now]);
                continue;
            }

            DB::transaction(function () use ($user, $donationConfig, $target, $isCase, $now) {
                // 1. خصم الرصيد
                $user->wallet_balance -= $donationConfig->amount;
                $user->save();

                // 2. زيادة المبلغ المجمع بالوجهة (مشروع أو حالة)
                $target->collected_amount += $donationConfig->amount;
                if ($isCase && $target->isFullyFunded()) {
                    $target->status = 'completed';
                }
                $target->save();

                // 3. إنشاء سجل تبرع فعلي (كان مفقوداً سابقاً - التبرع التلقائي ما كان يُنشئ Donation أصلاً)
                Donation::create([
                    'user_id' => $user->id,
                    'project_id' => $isCase ? null : $target->id,
                    'case_request_id' => $isCase ? $target->id : null,
                    'amount' => $donationConfig->amount,
                ]);

                // 4. تسجيل العملية بجدول العمليات
                Transaction::create([
                    'user_id' => $user->id,
                    'amount' => $donationConfig->amount,
                    'type' => 'donation',
                    'status' => 'completed',
                ]);

                // 5. إشعار بالنجاح
                Notification::create([
                    'user_id' => $user->id,
                    'title' => 'تم تنفيذ التبرع التلقائي',
                    'message' => "تم خصم مبلغ {$donationConfig->amount} كتبرع تلقائي لـ '{$target->title}'. تقبل الله!"
                ]);

                // 6. تحديث وقت آخر معالجة
                $donationConfig->update(['last_processed_at' => $now]);
            });

            $count++;
            $this->info("تم خصم {$donationConfig->amount} بنجاح من المستخدم: {$user->name}");
        }

        $this->info("انتهت المعالجة. إجمالي العمليات الناجحة: {$count}");
    }
}
