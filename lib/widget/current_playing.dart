import 'package:classroom_jukebox/widget/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../service/audio_player.dart';

class CurrentPlaying extends StatefulWidget {
  const CurrentPlaying({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentPlayingState();
}

class _CurrentPlayingState extends State<CurrentPlaying> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService.instance;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(26),
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _audioPlayerService.currentSong,
            builder: (context, value, child) {
              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _audioPlayerService.currentSong.value == null ? Container(
                      color: const Color(0xfffafafa),
                      width: 180,
                      height: 180,
                    ) : Image.network(
                      _audioPlayerService.currentSong.value!.thumbnailSource,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 24,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _audioPlayerService.currentSong.value == null ? "N/A" : _audioPlayerService.currentSong.value!.title,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.zenKakuGothicNew(
                            textStyle: const TextStyle(
                              color: Color(0xff1d1d1f),
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: -0.6,
                              wordSpacing: -0.2,
                              fontFamilyFallback: ["Noto Sans"]
                            )
                          )
                        ),
                        const SizedBox(height: 4,),
                        Text(
                          _audioPlayerService.currentSong.value == null ? "N/A" : _audioPlayerService.currentSong.value!.channel,
                          style: GoogleFonts.zenKakuGothicNew(
                              textStyle: const TextStyle(
                              color: Color(0xff1d1d1f),
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              letterSpacing: -0.6,
                              wordSpacing: -0.2,
                              fontFamilyFallback: ["Noto Sans"]
                            )
                          )
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
          const SizedBox(height: 20,),
          const PlayerController(),
        ],
      ),
    );
  }
}
