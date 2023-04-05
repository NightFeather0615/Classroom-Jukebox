import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../service/audio_player.dart';

class SongQueue extends StatefulWidget {
  const SongQueue({super.key});

  @override
  State<StatefulWidget> createState() => _SongQueueState();
}

class _SongQueueState extends State<SongQueue> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService.instance;

  late ScrollController _queueScrollController;

  @override
  void initState() {
    super.initState();
    _queueScrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _queueScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2.8),
                child: Text(
                  "Next in Queue",
                  style: GoogleFonts.zenKakuGothicNew(
                      textStyle: const TextStyle(
                      color: Color(0xff1d1d1f),
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      letterSpacing: 0,
                      wordSpacing: -0.2
                    )
                  )
                ),
              ),
              const Spacer(),
              FilledButton(
                style: ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)
                    )
                  ),
                  side: const MaterialStatePropertyAll(
                    BorderSide(color: Color(0xff1d1d1f), width: 2)
                  ),
                  backgroundColor: const MaterialStatePropertyAll(
                    Colors.transparent
                  ),
                
                ),
                onPressed: () async {
                  await _audioPlayerService.addSong("https://www.youtube.com/watch?v=7G0ovtPqHnI");
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2.8),
                  child: Text(
                    "Add Song",
                    style: GoogleFonts.zenKakuGothicNew(
                        textStyle: const TextStyle(
                        color: Color(0xff1d1d1f),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0,
                        wordSpacing: -0.2
                      )
                    )
                  ),
                )
              )
            ],
          ),
          const SizedBox(height: 14,),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _audioPlayerService.songQueue,
              builder: (context, value, child) {
                return ListView.builder(
                  controller: _queueScrollController,
                  itemCount: _audioPlayerService.songQueue.value.length,
                  itemBuilder: (context, listIndex) {
                    if (listIndex < _audioPlayerService.lunchBreakDividerIndex.value) {
                      return SongTile(
                        index: listIndex,
                        songData: _audioPlayerService.songQueue.value[listIndex],
                      );
                    } else if (listIndex == _audioPlayerService.lunchBreakDividerIndex.value) {
                      return const QueueDivider(title: "Lunch Break",);
                    } else {
                      return SongTile(
                        index: listIndex - 1,
                        songData: _audioPlayerService.songQueue.value[listIndex - 1],
                      );
                    }
                  },
                );
              },
            )
          )
        ],
      ),
    );
  }
}

class QueueDivider extends StatelessWidget {
  const QueueDivider({super.key, required this.title});
  
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4,),
        const Expanded(
          child: Divider(
            color: Color(0xffff463a),
          ),
        ),
        const SizedBox(width: 14,),
        Padding(
          padding: const EdgeInsets.only(bottom: 2.8),
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.zenKakuGothicNew(
              textStyle: const TextStyle(
                color: Color(0xffff463a),
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: -0.6,
                wordSpacing: -0.2,
                fontFamilyFallback: ["Noto Sans"]
              )
            )
          ),
        ),
        const SizedBox(width: 14,),
        const Expanded(
          child: Divider(
            color: Color(0xffff463a),
          ),
        ),
        const SizedBox(width: 4,),
      ],
    );
  }
}

class SongTile extends StatelessWidget {
  const SongTile({super.key, required this.index, required this.songData});

  final int index;
  final SongData songData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                (index + 1).toString(),
                style: GoogleFonts.robotoMono(
                    textStyle: const TextStyle(
                    color: Color(0xff1d1d1f),
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    letterSpacing: -0.6,
                    wordSpacing: -0.2,
                    fontFamilyFallback: ["Noto Sans"]
                  )
                )
              ),
            )
          ),
          const SizedBox(width: 14,),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              songData.thumbnailSource,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                songData.title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.zenKakuGothicNew(
                  textStyle: const TextStyle(
                    color: Color(0xff1d1d1f),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: -0.6,
                    wordSpacing: -0.2,
                    fontFamilyFallback: ["Noto Sans"]
                  )
                )
              ),
              const SizedBox(height: 2,),
              Text(
                songData.channel,
                style: GoogleFonts.zenKakuGothicNew(
                    textStyle: const TextStyle(
                    color: Color(0xff1d1d1f),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    letterSpacing: -0.6,
                    wordSpacing: -0.2,
                    fontFamilyFallback: ["Noto Sans"]
                  )
                )
              ),
            ],
          ),
          const Spacer(),
          Text(
            AudioPlayerService.formatDuration(songData.duration),
            style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                color: Color(0xff1d1d1f),
                fontWeight: FontWeight.w400,
                fontSize: 16,
                letterSpacing: -0.6,
                wordSpacing: -0.2,
                fontFamilyFallback: ["Noto Sans"]
              )
            )
          ),
          const SizedBox(width: 10,),
        ],
      ),
    );
  }
}