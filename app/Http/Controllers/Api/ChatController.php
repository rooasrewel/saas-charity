<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Message;
use App\Models\Notification;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    /**
     * جلب المحادثة الكاملة بين المستخدم الحالي ومستخدم آخر، مرتبة من الأقدم للأحدث.
     * الفرونت إند يستدعي هذا المسار دورياً (polling) بدل الاعتماد على WebSocket.
     */
    public function fetchMessages(Request $request, $receiverId)
    {
        $userId = $request->user()->id;

        $messages = Message::query()
            ->where(function ($q) use ($userId, $receiverId) {
                $q->where('sender_id', $userId)->where('receiver_id', $receiverId);
            })
            ->orWhere(function ($q) use ($userId, $receiverId) {
                $q->where('sender_id', $receiverId)->where('receiver_id', $userId);
            })
            ->orderBy('created_at', 'asc')
            ->get();

        // وضع علامة "مقروءة" على الرسائل الواردة من الطرف الآخر
        Message::query()
            ->where('sender_id', $receiverId)
            ->where('receiver_id', $userId)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب الرسائل بنجاح',
            'data' => $messages,
        ]);
    }

    /**
     * إرسال رسالة جديدة
     */
    public function sendMessage(Request $request)
    {
        $validated = $request->validate([
            'receiver_id' => 'required|exists:users,id',
            'message' => 'required|string|max:2000',
        ]);

        $sender = $request->user();

        if ((int) $validated['receiver_id'] === $sender->id) {
            return response()->json(['status' => 'error', 'message' => 'لا يمكنك مراسلة نفسك.'], 422);
        }

        $newMessage = Message::create([
            'sender_id' => $sender->id,
            'receiver_id' => $validated['receiver_id'],
            'message' => $validated['message'],
        ]);

        Notification::create([
            'user_id' => $validated['receiver_id'],
            'title' => 'رسالة جديدة',
            'message' => "لديك رسالة جديدة من {$sender->name}.",
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم إرسال الرسالة بنجاح',
            'data' => $newMessage,
        ], 201);
    }

    /**
     * قائمة المحادثات الحالية (آخر رسالة مع كل شخص تراسلت معه) - لعرض شاشة "كل المحادثات"
     */
    public function conversations(Request $request)
    {
        $userId = $request->user()->id;

        $messages = Message::query()
            ->where('sender_id', $userId)
            ->orWhere('receiver_id', $userId)
            ->with(['sender:id,name,profile_image', 'receiver:id,name,profile_image'])
            ->orderBy('created_at', 'desc')
            ->get();

        // تجميع آخر رسالة لكل محادثة (حسب الطرف الآخر)
        $conversations = $messages
            ->groupBy(fn ($m) => $m->sender_id === $userId ? $m->receiver_id : $m->sender_id)
            ->map(function ($group) use ($userId) {
                $last = $group->first();
                $otherUser = $last->sender_id === $userId ? $last->receiver : $last->sender;
                $unreadCount = $group->where('receiver_id', $userId)->whereNull('read_at')->count();

                return [
                    'user' => $otherUser,
                    'last_message' => $last->message,
                    'last_message_at' => $last->created_at,
                    'unread_count' => $unreadCount,
                ];
            })
            ->values();

        return response()->json([
            'status' => 'success',
            'message' => 'تم جلب المحادثات بنجاح',
            'data' => $conversations,
        ]);
    }
}
