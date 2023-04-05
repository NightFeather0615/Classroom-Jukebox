import 'dart:ui';

import 'package:classroom_jukebox/service/audio_player.dart';
import 'package:classroom_jukebox/widget/current_playing.dart';
import 'package:classroom_jukebox/widget/song_queue.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.getFont('Noto Sans');
  AudioPlayerService.instance;
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classroom Jukebox',
      theme: ThemeData(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      body: SizedBox.expand(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.23
          ),
          child: Column(
            children: const [
              CurrentPlaying(),
              SizedBox(height: 36,),
              Expanded(
                child: SongQueue()
              )
            ],
          )
        ),
      )
    );
  }
}

