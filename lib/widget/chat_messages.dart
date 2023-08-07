import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat_app/utils/app_layout.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayWidth = AppLayout.displayWidth(context);
    final displayHeight = AppLayout.displayHeightWithoutAppBar(context);

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages found"),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("Error while loading messages"),
          );
        }

        final loadedMessages = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.only(
            left: displayWidth * 0.05,
            right: displayWidth * 0.05,
            bottom: displayHeight * 0.02,
          ),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            return Text(
              loadedMessages[index].data()["text"],
              textAlign: TextAlign.end,
            );
          },
        );
      },
    );
  }
}
