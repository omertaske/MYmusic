import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:benim_music/Helpers/playing_controls.dart';
import 'package:benim_music/Helpers/position_seek_week.dart';
import 'package:benim_music/Helpers/song_selecter.dart';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late AssetsAudioPlayer _assetsAudioPlayer;
  final List<StreamSubscription> _subscriptions = [];
  final audios = <Audio>[
    //ALEM FM
    Audio.network(
      'https://turkmedya.radyotvonline.net/alemfmaac',
      metas: Metas(
        id: '89.2',
        title: 'Alem Fm',
        artist: 'Delikanlı Radyo.',
        album: 'Turkısh',
        image: const MetasImage.network(
          'https://upload.wikimedia.org/wikipedia/tr/thumb/b/bf/Alem_fm.jpg/800px-Alem_fm.jpg',
        ),
      ),
    ),
    //DOKSANLAR RADYO
    Audio.network(
      'http://37.247.98.8/stream/166/',
      //playSpeed: 2.0,
      metas: Metas(
        id: '89.6',
        title: 'Doksanlar Radyo',
        artist: 'Doksanlar Radyo',
        album: 'Turkısh',
        image: const MetasImage.network(
          'https://www.canliradyodinle.fm/wp-content/uploads/doksanlar-fm-dinle.jpg',
        ),
      ),
    ),
    //KRAL FM
    Audio.network(
      'http://kralpopwmp.radyotvonline.com/;',
      metas: Metas(
        id: '102.0',
        title: 'Kral Fm',
        artist: 'Kral Müzik Radyo',
        album: 'Turkish',
        image: const MetasImage.network(
          'https://cdn1.kralmuzik.com.tr/media/content/19-05/17/kralfm.png',
        ),
      ),
    ),


    // TRT FM

    Audio.network(
      'https://nmicenotrt.mediatriple.net/trt_1.aac',
      metas: Metas(
        id: '91.4',
        title: 'TRT FM',
        artist: 'TRT FM Radyo',
        album: 'Turkish',
        image: const MetasImage.network(
          'https://pbs.twimg.com/profile_images/1458539237792489475/FmWy47qK_400x400.jpg',
        ),
      ),
    ),
    //TRT NAĞME

    Audio.network(
      'https://nmicenotrt.mediatriple.net/trt_nagme.aac',
      metas: Metas(
        id: ' 101.6',
        title: 'TRT NAĞME',
        artist: 'TRT FM NAĞME',
        album: 'Turkish',
        image: const MetasImage.network(
          'https://pbs.twimg.com/profile_images/1458540664598274054/2-_48UZE_400x400.jpg',
        ),
      ),
    ),
    //POWER TÜRK

    Audio.network(
      'https://live.powerapp.com.tr/powerturk/mpeg/icecast.audio?/;stream.mp3',
      metas: Metas(
        id: '11.4',
        title: 'Power Türk',
        artist: 'Power Türk',
        album: 'Turkish',
        image: const MetasImage.network(
          'https://pbs.twimg.com/profile_images/1580234415023742977/EI9GBKtd_400x400.jpg',
        ),
      ),
    ),
    //BEST FM
    Audio.network(
      'http://46.20.7.126/;stream.mp3',
      metas: Metas(
        id: '11.4',
        title: 'Best FM',
        artist: 'Best FM',
        album: 'Turkish',
        image: const MetasImage.network(
          'https://pbs.twimg.com/profile_images/1180025697521295360/iqMxVc2a_400x400.png',
        ),
      ),
    ),
    Audio.network(
      'https://21303.live.streamtheworld.com/METRO_FM_SC?/;stream.mp3https://25643.live.streamtheworld.com/METRO_FM_SC?/;stream.mp3',
      metas: Metas(
        id: '11.4',
        title: 'Metro FM',
        artist: 'Metro FM',
        album: 'Unknown',
        image: const MetasImage.network(
          'https://pbs.twimg.com/profile_images/1264907990618038281/lwQsLugx_400x400.jpg',
        ),
      ),
    ),
    Audio.network(
      'https://22183.live.streamtheworld.com/KISS_FM_SC?/;stream.mp3',
      metas: Metas(
        id: '91.6',
        title: 'Kiss FM',
        artist: 'Kiss FM',
        album: 'Turkish',
        image: const MetasImage.network(
          'https://www.kissfm.com.tr/images/kissfm-logo.png',
        ),
      ),
    ),
    Audio.network(
      'https://n29b-e2.revma.ihrhls.com/zc1481?rj-ttl=5&rj-tok=AAABg_A58UsAgRV3R3W6hV0Hcw',
      metas: Metas(
        id: '91.6',
        title: 'Power USA',
        artist: 'Power USA',
        album: 'USA',
        image: const MetasImage.network(
          'https://radiostationusa.fm/assets/image/radio/180/1481.png',
        ),
      ),
    ),
    Audio.network(
      'https://strm112.1.fm/x_mobile_mp3?aw_0_req.gdpr=true',
      metas: Metas(
        id: 'Online',
        title: 'ONE FM',
        artist: 'ONE FM',
        album: 'USA',
        image: const MetasImage.network(
          'https://static.mytuner.mobi/media/tvos_radios/8Kz23zJEKE.png',
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

    _subscriptions.add(_assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print('playlistAudioFinished : $data');
    }));
    _subscriptions.add(_assetsAudioPlayer.audioSessionId.listen((sessionId) {
      print('audioSessionId : $sessionId');
    }));

    openPlayer();
  }

  void openPlayer() async {
    await _assetsAudioPlayer.open(
      Playlist(audios: audios, startIndex: 0),
      showNotification: false,
      autoStart: false,
    );
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    print('dispose');
    super.dispose();
  }

  Audio find(List<Audio> source, String fromPath) {
    return source.firstWhere((element) => element.path == fromPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    StreamBuilder<Playing?>(
                        stream: _assetsAudioPlayer.current,
                        builder: (context, playing) {
                          if (playing.data != null) {
                            final myAudio = find(
                                audios, playing.data!.audio.assetAudioPath);
                            print(playing.data!.audio.assetAudioPath);
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Neumorphic(
                                style: const NeumorphicStyle(
                                  depth: 0,
                                  surfaceIntensity: 1,
                                  shape: NeumorphicShape.convex,
                                  boxShape: NeumorphicBoxShape.circle(),
                                ),
                                child: myAudio.metas.image?.path == null
                                    ? const SizedBox()
                                    : myAudio.metas.image?.type ==
                                            ImageType.network
                                        ? Image.network(
                                            myAudio.metas.image!.path,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4.2,
                                            fit: BoxFit.contain,
                                          )
                                        : Image.asset(
                                            myAudio.metas.image!.path,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4.2,
                                            fit: BoxFit.contain,
                                          ),
                              ),
                            );
                          }
                          return const Center(child:  CircularProgressIndicator());
                        }),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
                _assetsAudioPlayer.builderCurrent(
                    builder: (context, Playing? playing) {
                  return Column(
                    children: <Widget>[
                      _assetsAudioPlayer.builderLoopMode(
                        builder: (context, loopMode) {
                          return PlayerBuilder.isPlaying(
                              player: _assetsAudioPlayer,
                              builder: (context, isPlaying) {
                                return PlayingControls(
                                  loopMode: loopMode,
                                  isPlaying: isPlaying,
                                  isPlaylist: true,
                                  toggleLoop: () {
                                    _assetsAudioPlayer.toggleLoop();
                                  },
                                  onPlay: () {
                                    _assetsAudioPlayer.playOrPause();
                                  },
                                  onNext: () {
                                    //_assetsAudioPlayer.forward(Duration(seconds: 10));
                                    _assetsAudioPlayer.next(
                                        keepLoopMode:
                                            true /*keepLoopMode: false*/);
                                  },
                                  onPrevious: () {
                                    _assetsAudioPlayer.previous(
                                        /*keepLoopMode: false*/);
                                  },
                                );
                              });
                        },
                      ),
                      _assetsAudioPlayer.builderRealtimePlayingInfos(
                          builder: (context, RealtimePlayingInfos? infos) {
                        if (infos == null) {
                          return const SizedBox();
                        }
                        //print('infos: $infos');
                        return Column(
                          children: [
                            PositionSeekWidget(
                              currentPosition: infos.currentPosition,
                              duration: infos.duration,
                              seekTo: (to) {
                                _assetsAudioPlayer.seek(to);
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                NeumorphicButton(
                                  style: NeumorphicStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                  onPressed: () {
                                    _assetsAudioPlayer
                                        .seekBy(const Duration(seconds: -10));
                                  },
                                  child: const Text(
                                    '-10',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                NeumorphicButton(
                                  style: NeumorphicStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                  onPressed: () {
                                    _assetsAudioPlayer
                                        .seekBy(const Duration(seconds: 10));
                                  },
                                  child: const Text(
                                    '+10',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      }),
                    ],
                  );
                }),
                const SizedBox(
                  height: 20,
                ),
                _assetsAudioPlayer.builderCurrent(
                    builder: (BuildContext context, Playing? playing) {
                  return SongsSelector(
                    audios: audios,
                    onPlaylistSelected: (myAudios) {
                      _assetsAudioPlayer.open(
                        Playlist(audios: myAudios),
                        showNotification: true,
                        headPhoneStrategy:
                            HeadPhoneStrategy.pauseOnUnplugPlayOnPlug,
                        audioFocusStrategy: const AudioFocusStrategy.request(
                          resumeAfterInterruption: true,
                        ),
                      );
                    },
                    onSelected: (myAudio) async {
                      try {
                        await _assetsAudioPlayer.open(
                          myAudio,
                          autoStart: true,
                          showNotification: true,
                          playInBackground: PlayInBackground.enabled,
                          audioFocusStrategy: const AudioFocusStrategy.request(
                              resumeAfterInterruption: true,
                              resumeOthersPlayersAfterDone: true),
                          headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplug,
                          notificationSettings: const NotificationSettings(
                              //seekBarEnabled: false,
                              //stopEnabled: true,
                              //customStopAction: (player){
                              //  player.stop();
                              //}
                              //prevEnabled: false,
                              //customNextAction: (player) {
                              //  print('next');
                              //}
                              //customStopIcon: AndroidResDrawable(name: 'ic_stop_custom'),
                              //customPauseIcon: AndroidResDrawable(name:'ic_pause_custom'),
                              //customPlayIcon: AndroidResDrawable(name:'ic_play_custom'),
                              ),
                        );
                      } catch (e) {
                        print(e);
                      }
                    },
                    playing: playing,
                  );
                }),
                /*
                  PlayerBuilder.volume(
                      player: _assetsAudioPlayer,
                      builder: (context, volume) {
                        return VolumeSelector(
                          volume: volume,
                          onChange: (v) {
                            _assetsAudioPlayer.setVolume(v);
                          },
                        );
                      }),
                   */
                /*
                  PlayerBuilder.forwardRewindSpeed(
                      player: _assetsAudioPlayer,
                      builder: (context, speed) {
                        return ForwardRewindSelector(
                          speed: speed,
                          onChange: (v) {
                            _assetsAudioPlayer.forwardOrRewind(v);
                          },
                        );
                      }),
                   */
                /*
                  PlayerBuilder.playSpeed(
                      player: _assetsAudioPlayer,
                      builder: (context, playSpeed) {
                        return PlaySpeedSelector(
                          playSpeed: playSpeed,
                          onChange: (v) {
                            _assetsAudioPlayer.setPlaySpeed(v);
                          },
                        );
                      }),
                   */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
