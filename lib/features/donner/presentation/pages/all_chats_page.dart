import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas/core/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logic/donner_bloc.dart';
import '../../logic/donner_event.dart';
import '../../logic/donner_state.dart';
import 'chat_page.dart';

class AllChatsPage extends StatefulWidget {
  final int currentUserId;
  final String token;

  const AllChatsPage({
    super.key,
    required this.currentUserId,
    required this.token,
  });

  @override
  State<AllChatsPage> createState() => _AllChatsPageState();
}

class _AllChatsPageState extends State<AllChatsPage> {
  @override
  void initState() {
    super.initState();
    // جلب قائمة المحادثات من الباك إند فعلياً
    context.read<DonnerBloc>().add(
      FetchConversationsEvent(token: widget.token),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;

    return Scaffold(
      body: BlocBuilder<DonnerBloc, DonnerState>(
        builder: (context, state) {
          if (state is DonnerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DonnerError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)),
            );
          }

          final conversations = state is ConversationsLoaded
              ? state.conversations
              : <Map<String, dynamic>>[];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: subTitleColor),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد محادثات بعد',
                    style: TextStyle(color: subTitleColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: conversations.length,
            separatorBuilder: (context, index) => Divider(
              color: isDark
                  ? const Color(0xff405954).withOpacity(0.5)
                  : const Color(0xffe2e8f0),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final chat = conversations[index];
              final user = chat['user'] as Map<String, dynamic>? ?? {};
              final name = user['name'] ?? 'مستخدم';
              final lastMessage = chat['last_message'] ?? '';
              final unread = chat['unread_count'] ?? 0;
              final receiverId = user['id'] as int? ?? 0;

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        organizationName: name,
                        receiverId: receiverId,
                        currentUserId: widget.currentUserId,
                        token: widget.token,
                      ),
                    ),
                  ).then((_) {
                    // تحديث القائمة عند العودة
                    context.read<DonnerBloc>().add(
                      FetchConversationsEvent(token: widget.token),
                    );
                  });
                },
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: isDark
                      ? const Color(0xff132e2c)
                      : const Color(0xffe6f4f3),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: subTitleColor, fontSize: 13),
                ),
                trailing: unread > 0
                    ? Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        ),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
