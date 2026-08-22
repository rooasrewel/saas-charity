<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    /**
     * معالجة الطلب القادم.
     * $roles ممكن يكون دور واحد "admin" أو عدة أدوار مفصولة بفاصلة "organization,admin"
     */
    public function handle(Request $request, Closure $next, string $roles): Response
    {
        // 1. التأكد أولاً أن المستخدم مسجل دخول
        if (!$request->user()) {
            return response()->json(['message' => 'غير مصرح لك، يرجى تسجيل الدخول أولاً'], 401);
        }

        $allowedRoles = array_map('trim', explode(',', $roles));

        // 2. التحقق من أن دور المستخدم يطابق أحد الأدوار المسموحة في المسار
        if (!in_array($request->user()->role, $allowedRoles, true)) {
            return response()->json([
                'message' => 'عذراً، لا تملك الصلاحيات الكافية للوصول إلى هذا القسم'
            ], 403); // 403 تعني Forbidden (ممنوع)
        }

        // إذا نجح في الاختبارين، نسمح للطلب بالمرور إلى الكنترولر
        return $next($request);
    }
}
