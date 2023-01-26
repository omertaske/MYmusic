import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class PlayingControls extends StatelessWidget {
  final bool isPlaying;
  final LoopMode? loopMode;
  final bool isPlaylist;
  final Function()? onPrevious;
  final Function() onPlay;
  final Function()? onNext;
  final Function()? toggleLoop;
  final Function()? onStop;

  const PlayingControls({
    required this.isPlaying,
    this.isPlaylist = false,
    this.loopMode,
    this.toggleLoop,
    this.onPrevious,
    required this.onPlay,
    this.onNext,
    this.onStop,
  });

  Widget _loopIcon(BuildContext context) {
    final iconSize = 34.0;
    if (loopMode == LoopMode.none) {
      return Icon(
        Icons.loop,
        size: iconSize,
        color: Colors.grey,
      );
    } else if (loopMode == LoopMode.playlist) {
      return Icon(
        Icons.loop,
        size: iconSize,
        color: Colors.black,
      );
    } else {
      //single
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.loop,
            size: iconSize,
            color: Colors.black,
          ),
          const Center(
            child: Text(
              '1',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        GestureDetector(
          onTap: () {
            if (toggleLoop != null) toggleLoop!();
          },
          child: _loopIcon(context),
        ),
        const SizedBox(
          width: 12,
        ),
        NeumorphicButton(
          style: NeumorphicStyle(
            color: Colors.grey.shade700,
            boxShape: NeumorphicBoxShape.circle(),
            depth: 0,
          ),
          padding: const EdgeInsets.all(18),
          onPressed: isPlaylist ? onPrevious : null,
          child: const Icon(Icons.star_outline),
        ),
        const SizedBox(
          width: 12,
        ),
        NeumorphicButton(
          style: NeumorphicStyle(
            depth: 0,
            color: Colors.grey.shade700,
            boxShape: const NeumorphicBoxShape.circle(),
          ),
          padding: const EdgeInsets.all(24),
          onPressed: onPlay,
          child: Icon(
            isPlaying ? CupertinoIcons.stop_circle : CupertinoIcons.play_circle,
            size: 32,
          ),
        ),
        SizedBox(
          width: 12,
        ),
        NeumorphicButton(
          style: NeumorphicStyle(
            depth: 0,
            color: Colors.grey.shade700,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          padding: EdgeInsets.all(18),
          onPressed: isPlaylist ? onNext : null,
          child: Icon(CupertinoIcons.forward_end),
        ),
        SizedBox(
          width: 45,
        ),
        if (onStop != null)
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: 0,
              color: Colors.grey.shade700,
              boxShape: const NeumorphicBoxShape.circle(),
            ),
            padding: EdgeInsets.all(16),
            onPressed: onStop,
            child: Icon(
              CupertinoIcons.stop_fill,
              color: Colors.grey.shade700,
              size: 32,
            ),
          ),
      ],
    );
  }
}
