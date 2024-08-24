import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiProvider extends ChangeNotifier {
  Future<void> createMeeting({
    required String roomName,
    required bool isAudioMuted,
    required bool isVideoMuted,
    String username = '',
    String email = '',
    bool preJoined = true,
    bool isVideo = true,
    bool isGroup = true,
  }) async {
    try {
      Map<String, Object> featureFlags = {
        'welcomepage.enabled': false,
        'prejoinpage.enabled': preJoined,
        'add-people.enabled': isGroup,
      };

      var options = JitsiMeetConferenceOptions(
        room: roomName,
        serverURL: 'https://meet.jit.si', // Update this URL if using a custom Jitsi server
        configOverrides: {
          "startWithAudioMuted": isAudioMuted,
          "startWithVideoMuted": isVideoMuted,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: username,
          email: email,
        ),
        featureFlags: featureFlags,
      );

      var jitsiMeet = JitsiMeet();
      await jitsiMeet.join(options);
    } catch (error) {
      print("Error starting Jitsi meeting: $error");
      // Optionally, notify listeners about errors
      notifyListeners();
    }
  }
}
