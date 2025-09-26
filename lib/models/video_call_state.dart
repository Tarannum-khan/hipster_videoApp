import 'package:equatable/equatable.dart';

abstract class VideoCallState extends Equatable {
  const VideoCallState();

  @override
  List<Object?> get props => [];
}

class VideoCallInitial extends VideoCallState {}

class VideoCallLoading extends VideoCallState {}

class VideoCallConnected extends VideoCallState {
  final String meetingId;
  final bool isMuted;
  final bool isVideoEnabled;
  final bool isScreenSharing;

  const VideoCallConnected({
    required this.meetingId,
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.isScreenSharing = false,
  });

  VideoCallConnected copyWith({
    String? meetingId,
    bool? isMuted,
    bool? isVideoEnabled,
    bool? isScreenSharing,
  }) {
    return VideoCallConnected(
      meetingId: meetingId ?? this.meetingId,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
    );
  }

  @override
  List<Object?> get props => [meetingId, isMuted, isVideoEnabled, isScreenSharing];
}

class VideoCallDisconnected extends VideoCallState {}

class VideoCallError extends VideoCallState {
  final String message;

  const VideoCallError(this.message);

  @override
  List<Object?> get props => [message];
}

