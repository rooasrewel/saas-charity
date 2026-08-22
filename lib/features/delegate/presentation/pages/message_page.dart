import 'package:flutter/material.dart';
import 'package:saas/core/app_theme.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {

  TextEditingController controller = TextEditingController();

  List<String> messages = [
    "Hello, we received your report.",
    "Please check the beneficiary details.",
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.textDark,
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Messages",
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),

      body: Column(

        children: [

          // ================= CHAT LIST =================

          Expanded(

            child: ListView.builder(

              itemCount: messages.length,

              itemBuilder: (context, index) {

                bool isMe = index % 2 == 0;

                return Align(

                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(

                    margin: const EdgeInsets.all(10),

                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(

                      color: isMe
                          ? AppTheme.primaryColor
                          : Colors.white,

                      borderRadius: BorderRadius.circular(12),

                    ),

                    child: Text(

                      messages[index],

                      style: TextStyle(

                        color: isMe
                            ? Colors.white
                            : AppTheme.textDark,

                      ),

                    ),

                  ),

                );
              },
            ),
          ),

          // ================= INPUT =================

          Container(

            padding: const EdgeInsets.all(10),

            color: Colors.white,

            child: Row(

              children: [

                Expanded(

                  child: TextField(

                    controller: controller,

                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),

                  ),

                ),

                IconButton(

                  icon: const Icon(Icons.send,
                      color: AppTheme.primaryColor),

                  onPressed: () {

                    if (controller.text.isNotEmpty) {

                      setState(() {

                        messages.add(controller.text);

                        controller.clear();

                      });

                    }

                  },

                ),

              ],

            ),

          ),

        ],

      ),

    );
  }
}