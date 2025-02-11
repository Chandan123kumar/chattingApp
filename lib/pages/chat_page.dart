import 'dart:async';
import 'dart:core';

import 'package:bat_karo/audio_video_calling/audio_video_call_service.dart';
import 'package:bat_karo/audio_video_calling/generate_caller_id.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../audio_video_calling/VideoCalling.dart';
import '../controller/chat_provider.dart';
import '../user_status_manager/user_status_manager.dart';
import 'home_page.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String email;
  final String otherUid;
  final String profile;

  const ChatPage(
      {super.key, required this.otherUid, required this.name, required this.email, required this.profile});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final uId = FirebaseAuth.instance.currentUser!.uid;
  ScrollController controller = ScrollController();
  UserStatusManager userStatusManager = UserStatusManager();
  final RequestCallService _callService = RequestCallService();
  TextEditingController _controller = TextEditingController();
  Timer? _seenTimer;


  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (Provider
          .of<ChatViewModel>(context, listen: false)
          .chatController
          .text
          .isNotEmpty) {
        userStatusManager.startTypingStatus();
      } else {
        userStatusManager.stopTyping();
      }
    },);
    var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    String callID = GenerateCallerId.generateCallId(widget.otherUid, uId);
    var viewModel = Provider.of<ChatViewModel>(context, listen: false)
        .markMessageAsSeen(callID, uId);

    Future.delayed(
      const Duration(seconds: 2),
          () async {
        var viewModel = Provider.of<ChatViewModel>(context, listen: false);
        var chatRoomId = await viewModel.getChatList(
            cid: uid, otherId: widget.otherUid);
      },
    );

    userStatusManager.setUserStatus(isOnline: true);
    userStatusManager.userOfflineStatus();
  }

  @override
  void dispose() {
    userStatusManager.setUserStatus(isOnline: false);
    _seenTimer?.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    userStatusManager.setUserStatus(isOnline: false, isTyping: false);
    super.deactivate();
  }

  @override
  void activate() {
    userStatusManager.setUserStatus(isOnline: true, isTyping: true);
    super.activate();
  }

  void onStartTyping() {
    userStatusManager.setUserStatus(isOnline: true, isTyping: true);
    _seenTimer?.cancel();
    _seenTimer = Timer(Duration(seconds: 0), () {
      userStatusManager.setUserStatus(isOnline: true, isTyping: false);
    },);
  }

  void _listenFirIncomingCall() {
    _callService.listenForIncomingcall(uId).listen((event) {
      if (event.snapshot.exists) {
        Map callData = event.snapshot.value as Map;
        String callID = callData['call_id'];
        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
            VideoCallingPage(
              userName: widget.name, userId: uId, callId: callID,),));
      }
    },);
  }

  void _startCall() {
    String callID = GenerateCallerId.generateCallId(widget.otherUid, uId);
    _callService.sendCallRequest(widget.otherUid, callID);
    _listenFirIncomingCall();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
        VideoCallingPage(userName: widget.name, userId: uId, callId: callID),));
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<ChatViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        leadingWidth: 25,
        leading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const ChatHomePage(uid: ''),));
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white,)),
        title: Row(children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.profile),
          ),
          const SizedBox(width: 5,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.name,
                style: const TextStyle(color: Colors.white, fontSize: 18),),
              userStatusWidget(widget.otherUid)
            ],
          ), const SizedBox(width: 20,),
          SizedBox(
            child: Row(children: [IconButton(onPressed: () {
              _startCall();
            },
                icon: const Icon(
                  Icons.video_call, color: Colors.white, size: 25,)),
              IconButton(onPressed: () {

              },
                  icon: const Icon(Icons.call, color: Colors.white, size: 25,)),

            ],),
          )
        ],),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height -
                210 -
                MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              InkWell(
                                onLongPress: () {},
                                child: Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    padding: const EdgeInsets.all(10),
                                    constraints:
                                    BoxConstraints(maxWidth: MediaQuery
                                        .sizeOf(context)
                                        .width / 1.2),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        )
                                    ),
                                    child: Text('${user.message}',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14),
                                          )),
                                    ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(DateFormat.jm().format(
                                      user.dateTime!.toLocal())),
                                  SizedBox(width: 4,),
                                  Icon(Icons.done_all, color: Colors.grey,)
                                ],
                              ),
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
                                  BoxConstraints(maxWidth: MediaQuery
                                      .sizeOf(context)
                                      .width / 1.2),
                                  decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      )
                                  ),
                                  child: Text('${user.message}')
                              ),
                              Text(DateFormat.jm().format(
                                  user.dateTime!.toLocal()))
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
                IconButton(
                  icon: const Icon(
                    Icons.image, color: Colors.pinkAccent, size: 30,),
                  onPressed: () async {
                    // File? image = await viewModel.pickAndSendImage(widget.otherUid);
                    // if (image != null) {
                    //   await viewModel.sendChat(
                    //       otherUid: widget.otherUid,);
                    // }
                  },
                ),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: viewModel.chatController,
                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            userStatusManager.startTypingStatus();
                          } else {
                            userStatusManager.stopTyping();
                          }
                        },
                        decoration: InputDecoration(
                            hintText: " type massage...",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20))),
                      ),
                    )),
                IconButton(
                    onPressed: () {
                      viewModel.sendChat(otherUid: widget.otherUid);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        controller.jumpTo(controller.position.maxScrollExtent);
                      },);
                    },
                    icon: const Icon(
                      Icons.send, color: Colors.pinkAccent, size: 30,))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget userStatusWidget(String userId) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .ref('users/$userId/status')
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          Map<String, dynamic> status =
          Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          bool isOnline = status['Online'] ?? false;
          bool isTyping = status['isTyping'] ?? false;
          String lastSeen = status['lastSeen'] ?? '';

          if (isTyping) {
            return const Text(
              'Typing...',
              style: TextStyle(
                  color: CupertinoColors.systemGrey2, fontSize: 14),);
          }
          else if (isOnline) {
            return const Text(
              'Online',
              style: TextStyle(color: Colors.white, fontSize: 14),
            );
          } else {
            DateTime lastSeenTime = DateTime.parse(lastSeen);
            DateTime now = DateTime.now();

            String formattedTime = DateFormat('hh:mm a').format(lastSeenTime);

            String lastSeenText;
            if (lastSeenTime.year == now.year &&
                lastSeenTime.month == now.month &&
                lastSeenTime.day == now.day) {
              lastSeenText = "last seen today at $formattedTime";
            } else if (lastSeenTime.year == now.year &&
                lastSeenTime.month == now.month &&
                lastSeenTime.day == now.day - 1) {
              lastSeenText = "last seen yesterday at $formattedTime";
            } else {
              lastSeenText =
              "seen on ${DateFormat('dd/MM/yyyy, hh:mm a').format(
                  lastSeenTime)}";
            }

            return Text(
              lastSeenText,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            );
          }
        }
        return const Text('');
      },
    );
  }

  Widget getMessageStatusIcon(String status) {
    if (status == "sent") {
      return const Icon(Icons.check, color: Colors.grey); // Single tick
    } else if (status == "delivered") {
      return const Icon(Icons.check, color: Colors.blue); // Single blue tick
    } else if (status == "seen") {
      return const Icon(
          Icons.done_all, color: Colors.blue); // Double blue ticks
    }
    return Container();
  }


// void markMessagesAsSeen() {
//   // var chatId = viewModel.getChatId(cid: uId, otherId: widget.otherUid);
//   DatabaseReference chatRef =
//       FirebaseDatabase.instance.ref('messages/$chatId');
//   chatRef.once().then((DatabaseEvent event) {
//     for (var child in event.snapshot.children) {
//       var messageData = child.value as Map<dynamic, dynamic>;
//       if (messageData["receiver_id"] == uId &&
//           messageData["status"] != "seen") {
//         chatRef.child(child.key!).update({"status": "seen"});
//       }
//     }
//   });
// }
}