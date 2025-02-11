import 'package:bat_karo/core/const.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallingPage extends StatefulWidget {
  // String callerId;
  String userName;
  String userId;
  String callId;

  VideoCallingPage(
      {super.key,
      required this.userName,
      required this.userId,
      required this.callId});

  @override
  State<VideoCallingPage> createState() => _VideoCallingPageState();
}

class _VideoCallingPageState extends State<VideoCallingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZegoUIKitPrebuiltCall(
          appID: AppInfo.appId,
          appSign: AppInfo.appSign,
          callID: widget.callId,
          userID: widget.userId,
          userName: widget.userName,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()),
    );
  }
}
