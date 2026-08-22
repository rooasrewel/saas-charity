import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas/core/app_theme.dart';
import '../../data/message_model.dart';
import '../../logic/donner_bloc.dart';
import '../../logic/donner_event.dart';
import '../../logic/donner_state.dart';

class ChatPage extends StatefulWidget {
  final String organizationName;
  final int receiverId;
  final int currentUserId;
  final String token;

  const ChatPage({
    super.key,
    required this.organizationName,
    required this.receiverId,
    required this.currentUserId,
    required this.token,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // يبدأ polling تلقائي كل 3 ثوانٍ بدل Pusher
    context.read<DonnerBloc>().add(
      InitChatEvent(
        receiverId: widget.receiverId,
        token: widget.token,
      ),
    );
  }

  @override
  void dispose() {
    // إيقاف الـ polling عند مغادرة الشاشة لتوفير الطاقة
    context.read<DonnerBloc>().add(StopChatEvent());
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<DonnerBloc>().add(
        SendChatMessageEvent(
          receiverId: widget.receiverId,
          message: text,
          token: widget.token,
        ),
      );
      _messageController.clear();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 1,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  isDark ? const Color(0xff132e2c) : AppTheme.primaryLight,
              radius: 18,
              child: Icon(Icons.business,
                  color: Theme.of(context).primaryColor, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              widget.organizationName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<DonnerBloc, DonnerState>(
              listener: (context, state) {
                // تمرير للأسفل تلقائياً عند وصول رسائل جديدة
                if (state is ChatMessagesLoaded) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());
                }
              },
              builder: (context, state) {
                if (state is DonnerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatMessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Text(
                        'ابدأ المحادثة مع ${widget.organizationName}',
                        style: TextStyle(color: subTitleColor),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isMe = msg.senderId == widget.currentUserId;
                      final time =
                          '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}';
                      return _buildBubble(
                        message: msg.message,
                        isMe: isMe,
                        time: time,
                        isDark: isDark,
                        subTitleColor: subTitleColor,
                      );
                    },
                  );
                }
                if (state is DonnerError) {
                  return Center(
                      child: Text(state.message,
                          style: const TextStyle(color: Colors.red)));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInputField(isDark: isDark, subTitleColor: subTitleColor),
        ],
      ),
    );
  }

  Widget _buildBubble({
    required String message,
    required bool isMe,
    required String time,
    required bool isDark,
    required Color subTitleColor,
  }) {
    final bubbleColor = isMe
        ? Theme.of(context).primaryColor
        : (isDark ? const Color(0xff1e293b) : const Color(0xffe0f2fe));
    final textColor =
        isMe ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final timeColor = isMe ? Colors.white70 : subTitleColor;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message,
                style:
                    TextStyle(color: textColor, fontSize: 14, height: 1.4)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time,
                    style: TextStyle(color: timeColor, fontSize: 10)),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all,
                      color: Colors.white70, size: 14),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      {required bool isDark, required Color subTitleColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xff405954).withOpacity(0.5)
                : const Color(0xffe2e8f0),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: subTitleColor),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
