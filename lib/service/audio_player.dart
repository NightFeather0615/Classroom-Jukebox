// ignore: avoid_web_libraries_in_flutter
import 'dart:js';
import 'dart:convert';
import 'package:js/js.dart';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SongData {
  late final String id;
  final String videoId;
  final String originalUrl;
  final String title;
  final String channel;
  final String audioSource;
  final String thumbnailSource;
  final int duration;

  SongData({
    required this.videoId,
    required this.originalUrl,
    required this.title,
    required this.channel,
    required this.audioSource,
    required this.thumbnailSource,
    required this.duration,
  }) {
    id = const Uuid().v4();
  }

  factory SongData.fromJson(Map<String, dynamic> json) {
    return SongData(
      videoId: json["video_id"],
      originalUrl: json["original_url"],
      title: json["title"],
      channel: json["channel"],
      audioSource: json["audio_source"],
      thumbnailSource: json["thumbnail"],
      duration: json["duration"],
    );
  }
}


@JS('playerEndedCallback')
external set _playerEndedCallback(void Function() f);

@JS('playerTimeUpdateCallback')
external set _playerTimeUpdateCallback(void Function(int) f);

class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService._();

  static AudioPlayerService? _instance;
  late final JsObject _audioPlayer;
  late final http.Client _httpClient;

  final String _apiBaseUrl = "https://api.classroom-jukebox.nightfeather.dev";

  final ValueNotifier<SongData?> _currentSong = ValueNotifier(null);
  final ValueNotifier<List<SongData>> _songQueue = ValueNotifier([]);
  final ValueNotifier<int> _currentPlayingSongProgress = ValueNotifier(0);
  final ValueNotifier<double> _currentVolume = ValueNotifier(0.6);
  final ValueNotifier<bool> _currentSongIsPlaying = ValueNotifier(false);
  final ValueNotifier<int> _lunchBreakDividerIndex = ValueNotifier(999);

  static _playerEnded() {
    if (_instance!._songQueue.value.isEmpty) {
      _instance!._currentSongIsPlaying.value = false;
      _instance!._currentSong.value = null;
      _instance!._currentPlayingSongProgress.value = 0;

      _instance!._audioPlayer.callMethod("stop");
      _instance!._audioPlayer["_src"] = "";

      return;
    }

    _instance!._currentSong.value = instance._songQueue.value.first;
    
    _instance!._songQueue.value.removeAt(0);
    _instance!._songQueue.notifyListeners();

    _instance!._currentSongIsPlaying.value = true;
    _instance!._currentPlayingSongProgress.value = 0;

    _instance!._audioPlayer["_src"] = instance._currentSong.value!.audioSource;
    _instance!._audioPlayer.callMethod("stop");
    _instance!._audioPlayer.callMethod("load");
    _instance!._audioPlayer.callMethod("play");
  }   

  static _playerTimeUpdate(int second) {
    _instance!._currentPlayingSongProgress.value = second;
  }  

  static AudioPlayerService get instance {
    if (_instance == null) {
      _instance = AudioPlayerService._();

      _playerEndedCallback = allowInterop(_playerEnded);
      _playerTimeUpdateCallback = allowInterop(_playerTimeUpdate);

      _instance!._httpClient = http.Client();
      _instance!._audioPlayer = context['jsAudioPlayer'];
      (context["Howler"] as JsObject).callMethod("volume", [_instance!._currentVolume.value]);
    }
    return _instance!;
  }
  
  ValueNotifier<SongData?> get currentSong {
    return _currentSong;
  }

  ValueNotifier<List<SongData>> get songQueue {
    return _songQueue;
  }
  
  ValueNotifier<double> get currentVolume {
    return _currentVolume;
  }
  
  ValueNotifier<int> get currentPlayingSongProgress {
    return _currentPlayingSongProgress;
  }

  ValueNotifier<bool> get currentSongIsPlaying {
    return _currentSongIsPlaying;
  }

  ValueNotifier<int> get lunchBreakDividerIndex {
    return _lunchBreakDividerIndex;
  }

  void setVolume(double volume) {
    _currentVolume.value = volume;

    (context["Howler"] as JsObject).callMethod("volume", [volume]);
  }

  void pause() {
    _currentSongIsPlaying.value = false;

    _audioPlayer.callMethod("pause");
  }

  void resume() {
    _currentSongIsPlaying.value = true;

    _audioPlayer.callMethod("play");
  }

  void seekTo(int second) {
    _audioPlayer.callMethod("seek", [second]);
  }

  void nextTrack() {
    _playerEnded();
  }

  static String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;

    final minutesString = '$minutes';
    final secondsString = '$seconds'.padLeft(2, '0');
    return '$minutesString:$secondsString';
  }

  Future<bool> addSong(String youtubeUrl) async {
    final http.Response response = await _httpClient.get(
      Uri.parse("$_apiBaseUrl/playback-data?youtube_url=$youtubeUrl")
    );
    if (response.statusCode != 200) {
      return false;
    } else {
      _songQueue.value.add(
        SongData.fromJson(jsonDecode(response.body))
      );
      _songQueue.notifyListeners();
      return true;
    }
  }
}