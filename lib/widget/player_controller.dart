import 'package:classroom_jukebox/service/audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerController extends StatefulWidget {
  const PlayerController({super.key});

  @override
  State<StatefulWidget> createState() => _PlayerControllerState();
}

class _PlayerControllerState extends State<PlayerController> {
  Color prevIconColor = const Color(0xff1d1d1f);

  final AudioPlayerService _audioPlayerService = AudioPlayerService.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProgressBar(),
        const SizedBox(height: 8,),
        Row(
          children: [
            const Spacer(),
            const VolumeButton(),
            const SizedBox(width: 14,),
            ValueListenableBuilder(
              valueListenable: _audioPlayerService.currentSongIsPlaying,
              builder: (context, value, child) {
                return IconButton(
                  splashRadius: 20,
                  onPressed: () async {
                    _audioPlayerService.currentSongIsPlaying.value ? _audioPlayerService.pause() : _audioPlayerService.resume();
                  },
                  icon: SvgPicture.network(
                    _audioPlayerService.currentSongIsPlaying.value ? "https://tabler-icons.io/static/tabler-icons/icons/player-pause-filled.svg" : "https://tabler-icons.io/static/tabler-icons/icons/player-play-filled.svg"
                  )
                );
              },
            ),
            const SizedBox(width: 14,),
            IconButton(
              splashRadius: 20,
              onPressed: () {
                _audioPlayerService.nextTrack();
              },
              icon: SvgPicture.network(
                "https://tabler-icons.io/static/tabler-icons/icons/player-track-next-filled.svg"
              )
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}

class ProgressBar extends StatelessWidget {
  ProgressBar({super.key});

  final AudioPlayerService _audioPlayerService = AudioPlayerService.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _audioPlayerService.currentSong,
        _audioPlayerService.currentPlayingSongProgress
      ]),
      builder: (context, value) {
        return Row(
          children: [
            const SizedBox(width: 1,),
            SizedBox(
              width: 44,
              child: Text(
                AudioPlayerService.formatDuration(_audioPlayerService.currentPlayingSongProgress.value),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Color(0xff1d1d1f),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  textBaseline: TextBaseline.alphabetic
                )
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 10,
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbColor: const Color(0xff1d1d1f),
                    overlayColor: Colors.transparent,
                    activeTickMarkColor: Colors.transparent,
                    overlappingShapeStrokeColor: Colors.transparent,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 2.438,
                      disabledThumbRadius: 2.438,
                      elevation: 0
                    ),
                    trackHeight: 3,
                    trackShape: const RoundedRectSliderTrackShape(),
                    activeTrackColor: const Color(0xff1d1d1f),
                    inactiveTrackColor: const Color(0xff1d1d1f).withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _audioPlayerService.currentPlayingSongProgress.value.toDouble(),
                    max: _audioPlayerService.currentSong.value == null ? 0 : _audioPlayerService.currentSong.value!.duration.toDouble(),
                    min: 0,
                    divisions: _audioPlayerService.currentSong.value == null ? 1 : _audioPlayerService.currentSong.value!.duration,
                    onChanged: (value) async {
                      await _audioPlayerService.seekTo(value.toInt());
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                _audioPlayerService.currentSong.value == null ? "0:00" : AudioPlayerService.formatDuration(_audioPlayerService.currentSong.value!.duration),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Color(0xff1d1d1f),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  textBaseline: TextBaseline.alphabetic
                )
              ),
            ),
            const SizedBox(width: 1,),
          ],
        );
      },
    );
  }

}

class VolumeButton extends StatefulWidget {
  const VolumeButton({super.key});

  @override
  State<StatefulWidget> createState() => _VolumeButtonState();
}

class _VolumeButtonState extends State<VolumeButton> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService.instance;

  OverlayEntry? _overlayEntry;

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - 240,
        top: offset.dy + 10,
        width: 240,
        height: 20,
        child: Material(
          elevation: 0,
          child: ValueListenableBuilder(
            valueListenable: _audioPlayerService.currentVolume,
            builder: (context, value, child) {
              return Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "${(_audioPlayerService.currentVolume.value * 100).toInt()}%",
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                            color: Color(0xff1d1d1f),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            letterSpacing: -0.6,
                            wordSpacing: -0.2,
                            fontFamilyFallback: ["Noto Sans"]
                          )
                        )
                      ),
                    )
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbColor: const Color(0xff1d1d1f),
                        overlayColor: Colors.transparent,
                        activeTickMarkColor: Colors.transparent,
                        overlappingShapeStrokeColor: Colors.transparent,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 2.438,
                          disabledThumbRadius: 2.438,
                          elevation: 0
                        ),
                        trackHeight: 3,
                        trackShape: const RoundedRectSliderTrackShape(),
                        activeTrackColor: const Color(0xff1d1d1f),
                        inactiveTrackColor: const Color(0xff1d1d1f).withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _audioPlayerService.currentVolume.value,
                        max: 1.0,
                        min: 0.0,
                        divisions: 100,
                        onChanged: (value) async {
                          await _audioPlayerService.setVolume(value);
                        }
                      ),
                    ),
                  )
                ],
              );
            },
          )
        )
      )
    );
  }

  String getVolumeIcon(double volume) {
    if (volume == 0.0) {
      return "https://tabler-icons.io/static/tabler-icons/icons/volume-3.svg";
    } else if (volume > 0.0 && volume < 0.5) {
      return "https://tabler-icons.io/static/tabler-icons/icons/volume-2.svg";
    } else {
      return "https://tabler-icons.io/static/tabler-icons/icons/volume.svg";
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 20,
      onPressed: () {
        if (_overlayEntry == null) {
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context).insert(_overlayEntry!);
        } else {
          _overlayEntry?.remove();
          _overlayEntry = null;
        }
      },
      icon: ValueListenableBuilder(
        valueListenable: _audioPlayerService.currentVolume,
        builder: (context, value, child) {
          return SvgPicture.network(
            getVolumeIcon(_audioPlayerService.currentVolume.value)
          );
        },
      )
    );
  }
}