<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {

        // --- أضف هذا الجزء لتعريف الحارس الخاص بنا ---
        $middleware->alias([
            'role' => \App\Http\Middleware\CheckRole::class,
        ]);
        // ----------------------------------------------

    })
    ->withExceptions(function (Exceptions $exceptions) {
        // ضمان إن كل أخطاء مسارات الـ API (تحقق، 404، استثناءات عامة...) ترجع JSON دائماً
        // بدل صفحة HTML/إعادة توجيه، حتى لو الفرونت إند ما أرسل Accept: application/json
        $exceptions->shouldRenderJsonWhen(function (\Illuminate\Http\Request $request, \Throwable $e) {
            return $request->is('api/*') || $request->expectsJson();
        });
    })->create();
