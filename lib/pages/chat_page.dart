import 'dart:core';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/chat_provider.dart';
import 'home_page.dart';

class MassagePage extends StatefulWidget {
   final String name;
   final String email;
   final String otherUid;

  const MassagePage({super.key, required this.otherUid, required this.name, required this.email});

  @override
  State<MassagePage> createState() => _MassagePageState();
}

class _MassagePageState extends State<MassagePage> {
  final uId = FirebaseAuth.instance.currentUser?.uid;
  ScrollController controller=ScrollController();

  @override
  void initState() {
    super.initState();
    var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    Future.delayed(
      const Duration(seconds: 2),
      () async {
        var viewModel = Provider.of<ChatViewModel>(context, listen: false);
        var chatRoomId =
            await viewModel.getChatList(cid: uid, otherId: widget.otherUid);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<ChatViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatHomePage(uid: uId.toString()),
                  ));
            },
            icon: const Icon(Icons.arrow_back)),
        title: Row(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.name,style: TextStyle(color: Colors.white),),
              Text(widget.email,style: TextStyle(color: Colors.white,fontSize: 15))
            ],
          )
        ],),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height -
                210 -
                MediaQuery.of(context).viewInsets.bottom,
            child: Consumer<ChatViewModel>(
              builder: (context, value, child) {
                if (value.chatList.isEmpty) {
                  return const Text("no chat available");
                }
                return ListView.builder(
                  controller: controller,
                  itemCount: value.chatList.length,
                  itemBuilder: (context, index) {
                    var user = value.chatList[index];
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: user.senderId == uId
                            ? Align(
                                alignment: Alignment.topRight,
                                child:  Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 10),
                                      padding: const EdgeInsets.all(10),
                                      constraints:
                                      BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width / 1.2),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primaryContainer,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                          )
                                      ),
                                      child:Text('${user.message}',style: const TextStyle(color: Colors.black,fontSize: 14),)
                                    ),
                                    Text(DateFormat.jm().format(user.dateTime!.toLocal()))
                                  ],
                                ),
                        )
                            : Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.all(10),
                                        constraints:
                                        BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width / 1.2),
                                        decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            )
                                        ),
                                        child:Text('${user.message}')
                                    ),
                                    Text(DateFormat.jm().format(user.dateTime!.toLocal()))
                                  ],
                                ),
                        ));
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 110,
            child: Row(
              children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                                        controller: viewModel.chatController,
                                        decoration: InputDecoration(
                        hintText: " type massage",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                                      ),
                    )),
                IconButton(
                    onPressed: () {
                      viewModel.sendChat(otherUid: widget.otherUid);
                      Future.delayed(Duration(milliseconds: 300),() {
                        controller.jumpTo(controller.position.maxScrollExtent);
                      },);
                    },
                    icon: const Icon(Icons.send))
              ],
            ),
          )
        ],
      ),
    );
  }
}
