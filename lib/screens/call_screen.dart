import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:hipster/config/zego_config.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({
    Key? key,
    required this.callID,
    required this.attendeeName,
  }) : super(key: key);

  final String callID;
  final String attendeeName;

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: ZegoConfig.appId,
      appSign: ZegoConfig.appSign,
      userID: attendeeName.replaceAll(' ', '_'), // unique per user
      userName: attendeeName,
      callID: callID,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..bottomMenuBarConfig = ZegoBottomMenuBarConfig(
          buttons: [
            ZegoMenuBarButtonName.toggleMicrophoneButton,
            ZegoMenuBarButtonName.toggleCameraButton,
            ZegoMenuBarButtonName.hangUpButton,
            ZegoMenuBarButtonName.toggleScreenSharingButton, // Screen sharing button
            ZegoMenuBarButtonName.minimizingButton, // Minimize button
          ],

        ),
    );
  }
}
