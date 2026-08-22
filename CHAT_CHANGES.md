# تعديلات الشات — Flutter Frontend

## ما الذي تغيّر؟

استُبدل نظام Pusher بـ **HTTP Polling بسيط** يتوافق مع الباك إند الجديد.

### الملفات المعدّلة

| الملف | ما تغيّر |
|---|---|
| `lib/services/chat_service.dart` | حُذف Pusher بالكامل، بقيت `fetchMessages` و`sendMessage` كما هي + أُضيفت `fetchConversations` |
| `lib/features/donner/logic/donner_bloc.dart` | `InitChatEvent` يبدأ Timer كل 3 ثوانٍ بدل `initPusher`. أُضيف `StopChatEvent` و`FetchConversationsEvent` |
| `lib/features/donner/logic/donner_event.dart` | حُذف `ReceiveChatMessageEvent` (كان لـ Pusher). أُضيف `StopChatEvent` و`FetchConversationsEvent` |
| `lib/features/donner/logic/donner_state.dart` | نُظّف + أُضيف `ConversationsLoaded` |
| `lib/features/donner/presentation/pages/chat_page.dart` | `initState` يرسل `InitChatEvent(receiverId, token)` بدل حدثين منفصلين. `dispose` يرسل `StopChatEvent` لإيقاف الـ Timer |
| `lib/features/donner/presentation/pages/all_chats_page.dart` | مربوطة بـ `FetchConversationsEvent` فعلياً + تعرض قائمة المحادثات الحقيقية مع عدّاد غير المقروء |

## مسارات الباك إند المستخدمة

```
GET  /api/chat/messages/{receiverId}   ← جلب المحادثة
POST /api/chat/send                    ← إرسال رسالة
GET  /api/chat/conversations           ← قائمة كل المحادثات
```

## ملاحظة: ApiConstants

بعض ثوابت `api_constants.dart` تشير لمسارات delegate غير موجودة بالباك إند الحالي:
```
/associations          → غير موجود (الجمعيات مدمجة مع users بدور organization)
/delegate/profile      → الصحيح: POST /api/agent/setup
/delegate/approval-status → الصحيح: GET /api/agent/approval-status
/delegate/cases        → الصحيح: GET /api/agent/field-cases
/delegate/field-report → الصحيح: POST /api/agent/field-cases/{id}/report
```

## كيف يعمل الآن

1. المستخدم يفتح شاشة الدردشة
2. `InitChatEvent` يُرسَل → يجلب الرسائل فوراً + يبدأ Timer كل 3 ثوانٍ
3. كل 3 ثوانٍ: `FetchChatMessagesEvent` → `GET /chat/messages/{id}` → `ChatMessagesLoaded`
4. عند الإرسال: `POST /chat/send` → ثم جلب فوري للقائمة المحدّثة
5. عند مغادرة الشاشة: `StopChatEvent` يوقف الـ Timer
