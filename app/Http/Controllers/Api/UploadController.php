<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class UploadController extends Controller
{
    /**
     * رفع صورة عامة (لأي مستخدم مسجل دخول) وإرجاع مسارها/رابطها
     * يمكن استخدامها لأي غرض (مثلاً رفع صور تباعاً قبل إرسال نموذج نهائي)
     */
    public function uploadPhoto(Request $request)
    {
        $request->validate([
            'photo' => 'required|image|max:4096',
        ]);

        $path = $request->file('photo')->store('uploads/photos', 'public');

        return response()->json([
            'status' => 'success',
            'message' => 'تم رفع الصورة بنجاح.',
            'data' => [
                'path' => $path,
                'url' => Storage::disk('public')->url($path),
            ],
        ], 201);
    }

    /**
     * رفع مستند عام (PDF، صورة، Word) وإرجاع مساره/رابطه
     */
    public function uploadDocument(Request $request)
    {
        $request->validate([
            'document' => 'required|file|mimes:pdf,jpg,jpeg,png,doc,docx|max:8192',
        ]);

        $path = $request->file('document')->store('uploads/documents', 'public');

        return response()->json([
            'status' => 'success',
            'message' => 'تم رفع المستند بنجاح.',
            'data' => [
                'path' => $path,
                'url' => Storage::disk('public')->url($path),
            ],
        ], 201);
    }
}
