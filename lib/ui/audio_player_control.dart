import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/data/models/media.dart';

class AudioPlayerControl extends StatefulWidget {
  AudioPlayerControl(
      {Key? key,
      required this.audioPlayer,
      required this.isDownloaded,
      required this.media})
      : super(key: key);

  final AudioPlayer audioPlayer;
  bool isDownloaded;
  Media media;

  @override
  State<AudioPlayerControl> createState() => _AudioPlayerControlState();
}

class _AudioPlayerControlState extends State<AudioPlayerControl> {
  bool isFirstTime = true;
  bool? isAudioInCache;

  @override
  void initState() {
    Utils.isAudioInCache(widget.audioPlayer, widget.media.audioLink)
        .then((value) => {isAudioInCache = value});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 66,height: 66,
      child: StreamBuilder<PlayerState>(
        stream: widget.audioPlayer.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final processingState = playerState?.processingState;
          final playing = playerState?.playing;
          if ((processingState == ProcessingState.buffering || processingState == ProcessingState.loading) && (!isAudioInCache! && !widget.isDownloaded)) {
            return SizedBox(
              height: 42,
              width: 42,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Utils.primaryColor,
                ),
              ),
            );
          }
          if (!(playing ?? false)) {
            return IconButton(
              onPressed: () async {
                widget.audioPlayer.play();

                FToast fToast = FToast();
                fToast.init(context);

                if (!isFirstTime) {
                  return;
                }

                if (!widget.isDownloaded && !isAudioInCache!) {
                  fToast.showToast(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Now Streaming Online',
                        style: TextStyle(color: Colors.white, fontFamily: 'pm'),
                      ),
                    ),
                  );
                } else {
                  fToast.showToast(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Now Playing Offline',
                        style: TextStyle(color: Colors.white, fontFamily: 'pm'),
                      ),
                    ),
                  );
                }
                isFirstTime = false;
              },
              iconSize: 50,
              color: Utils.primaryColor,
              icon: const Icon(Iconsax.play),
            );
          } else if (processingState != ProcessingState.completed) {
            return IconButton(
              onPressed: widget.audioPlayer.pause,
              iconSize: 50,
              color: Utils.primaryColor,
              icon: const Icon(Iconsax.pause),
            );
          }
          return IconButton(
            onPressed: widget.audioPlayer.load,
            iconSize: 50,
            color: Utils.primaryColor,
            icon: const Icon(Iconsax.play),
          );
        },
      ),
    );
  }
}
