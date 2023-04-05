import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
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

class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService._();

  static AudioPlayerService? _instance;
  static AudioPlayer? _audioPlayer;
  static final http.Client _httpClient = http.Client();

  final String _apiBaseUrl = "https://api.classroom-jukebox.nightfeather.dev";

  final ValueNotifier<SongData?> _currentSong = ValueNotifier(null);
  final ValueNotifier<List<SongData>> _songQueue = ValueNotifier([]);
  final ValueNotifier<int> _currentPlayingSongProgress = ValueNotifier(0);
  final ValueNotifier<double> _currentVolume = ValueNotifier(0.6);
  final ValueNotifier<bool> _currentSongIsPlaying = ValueNotifier(false);
  final ValueNotifier<int> _lunchBreakDividerIndex = ValueNotifier(999);

  static AudioPlayerService get instance {
    if (_instance == null) {
      _instance = AudioPlayerService._();

      _audioPlayer = AudioPlayer();
      _audioPlayer!.setVolume(_instance!._currentVolume.value);

      _audioPlayer!.onPlayerComplete.listen((event) async {
        _instance!._songQueue.value.removeAt(0);
        _instance!._songQueue.notifyListeners();
        if (_instance!._songQueue.value.isEmpty) {
          _instance!._currentSongIsPlaying.value = false;
          _instance!._currentSong.value = null;
          _instance!._currentPlayingSongProgress.value = 0;

          _instance!._currentSongIsPlaying.notifyListeners();
          _instance!._currentSong.notifyListeners();
          _instance!._currentPlayingSongProgress.notifyListeners();

          await _audioPlayer!.release();
        } else {
          _instance!._currentSong.value = _instance!._songQueue.value.first;
          _instance!._currentPlayingSongProgress.value = 0;
          _instance!._currentSongIsPlaying.value = true;

          _instance!._currentSongIsPlaying.notifyListeners();
          _instance!._currentSong.notifyListeners();
          _instance!._currentPlayingSongProgress.notifyListeners();

          await _audioPlayer!.play(UrlSource(_instance!._currentSong.value!.audioSource));
        }
      });
      _audioPlayer!.onPositionChanged.listen((event) {
        _instance!._currentPlayingSongProgress.value = event.inSeconds;
      });
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

  Future setVolume(double volume) async {
    _currentVolume.value = volume;
    _currentVolume.notifyListeners();

    await _audioPlayer!.setVolume(volume);
  }

  Future pause() async {
    _currentSongIsPlaying.value = false;
    _currentSongIsPlaying.notifyListeners();

    await _audioPlayer!.pause();
  }

  Future resume() async {
    _currentSongIsPlaying.value = true;
    _currentSongIsPlaying.notifyListeners();

    await _audioPlayer!.resume();
  }

  Future seekTo(int second) async {
    _currentPlayingSongProgress.value = second;
    _currentPlayingSongProgress.notifyListeners();

    await _audioPlayer!.seek(Duration(seconds: second));
  }

  Future nextTrack() async {
    await _audioPlayer!.stop();

    if (_songQueue.value.isEmpty) return;

    _songQueue.value.removeAt(0);
    _songQueue.notifyListeners();

    if (_songQueue.value.isEmpty) {
      _currentSong.value = null;
      _currentPlayingSongProgress.value = 0;
      _currentSongIsPlaying.value = false;

      _instance!._currentSongIsPlaying.notifyListeners();
      _instance!._currentSong.notifyListeners();
      _instance!._currentPlayingSongProgress.notifyListeners();

      await _audioPlayer!.release();
    } else {
      _currentSong.value = _songQueue.value.first;
      _currentPlayingSongProgress.value = 0;
      _currentSongIsPlaying.value = true;

      _currentSongIsPlaying.notifyListeners();
      _currentSong.notifyListeners();
      _currentPlayingSongProgress.notifyListeners();

      await _audioPlayer!.play(UrlSource(_currentSong.value!.audioSource));
    }
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