import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat_app/widget/chat_messages.dart';
import 'package:simple_chat_app/widget/new_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        title: const Text("Flutter Chat"),
        actions: [
          PopupMenuButton(
              itemBuilder: (ctx){
                return [
                  const PopupMenuItem(
                      value: 1,
                      child: Text("Logout")
                  ),
                ];
              },
            offset: const Offset(10, 50),
            onSelected: (value){
                switch(value){
                  case 1 :
                    FirebaseAuth.instance.signOut();
                    break;
                }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: ChatMessages()),
          NewMessage()
        ],
      ),
    );
  }
}
