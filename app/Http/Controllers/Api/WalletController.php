<?php

namespace App\Http\Controllers\Api;

use App\Models\Notification;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Transaction; // استدعاء مودل العمليات

class WalletController extends Controller
{
    /**
     * عرض تفاصيل المحفظة (الرصيد الحالي + سجل العمليات)
     */
    public function index(Request $request)
    {
        $user = $request->user();

        // جلب جميع عمليات المستخدم مرتبة من الأحدث إلى الأقدم
        $transactions = Transaction::query()
            ->where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب تفاصيل المحفظة بنجاح',
            'data' => [
                'wallet_balance' => $user->wallet_balance ?? 0,
                'transactions' => $transactions,
            ]
        ], 200);
    }

    /**
     * عرض سجل عمليات المحفظة فقط (إيداع، سحب، تبرع)
     */
    public function transactions(Request $request)
    {
        $transactions = Transaction::query()
            ->where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب سجل العمليات بنجاح',
            'data' => $transactions,
        ]);
    }

    /**
     * شحن رصيد المحفظة (Deposit)
     */
    public function topUp(Request $request)
    {
        // 1. التحقق من صحة المبلغ المدخل
        $request->validate([
            'amount' => 'required|numeric|min:1',
        ]);

        $user = $request->user();

        // 2. تحديث الرصيد في مودل المستخدم
        $user->wallet_balance += $request->amount;
        $user->save();

        // 3. إضافة الحركة لجدول العمليات (Transaction)
        Transaction::create([
            'user_id' => $user->id,
            'amount' => $request->amount,
            'type' => 'deposit', // نوع العملية: إيداع/شحن
            'status' => 'completed',
        ]);

        // إرسال إشعار للمستخدم
        Notification::create([
            'user_id' => $user->id,
            'title' => 'تم شحن المحفظة بنجاح',
            'message' => "تم إضافة مبلغ {$request->amount} إلى محفظتك. رصيدك الحالي هو {$user->wallet_balance}."
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم شحن المحفظة بنجاح.',
            'new_balance' => $user->wallet_balance
        ]);
    }

    /**
     * سحب من رصيد المحفظة (Withdraw)
     */
    public function withdraw(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
        ]);

        $user = $request->user();

        if ($user->wallet_balance < $request->amount) {
            return response()->json([
                'status' => 'error',
                'message' => 'رصيدك الحالي غير كافٍ لإتمام عملية السحب.'
            ], 400);
        }

        $user->wallet_balance -= $request->amount;
        $user->save();

        Transaction::create([
            'user_id' => $user->id,
            'amount' => $request->amount,
            'type' => 'withdraw',
            'status' => 'completed',
        ]);

        Notification::create([
            'user_id' => $user->id,
            'title' => 'تم سحب مبلغ من محفظتك',
            'message' => "تم سحب مبلغ {$request->amount} من محفظتك. رصيدك الحالي هو {$user->wallet_balance}."
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تمت عملية السحب بنجاح.',
            'new_balance' => $user->wallet_balance
        ]);
    }
}
