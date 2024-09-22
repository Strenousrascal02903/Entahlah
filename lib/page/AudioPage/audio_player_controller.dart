import 'dart:async';
import 'package:entahlah/page/AudioPage/lyric_line.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class AudioPlayerPageController extends GetxController {
  var backgroundColor = Colors.white.obs;
  var isBackgroundDark = false.obs;
  var isPlayerHidden = false.obs;
  var lyrics = <Lyric>[].obs; // Menambahkan list lirik
  var currentLyric = ''.obs;
  var currentIndex = 0.obs;
  var position = Duration.zero.obs;
  var duration = Duration.zero.obs;
  var isPlayerLoading = false.obs;
  var isPlaying = false.obs;
  var isRepeatEnabled = false.obs; // Untuk mengaktifkan fitur repeat

  final AudioPlayer player = AudioPlayer();
  final yt = YoutubeExplode();

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void onInit() {
    super.onInit();
    _updateBackgroundColor();
    _initializePlayer();
  }

  Future<void> _updateBackgroundColor() async {
    final thumbnailUrl = GetStorage().read('thumbnail') ?? '';
    if (thumbnailUrl.isNotEmpty) {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(thumbnailUrl),
        size: Size(400, 200),
      );
      final color = paletteGenerator.dominantColor?.color ?? Colors.white;
      backgroundColor.value = color;
      isBackgroundDark.value = _isDarkColor(color);
    }
  }

  bool _isDarkColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance < 0.5;
  }

  void _initializePlayer() {
    player.durationStream.listen((d) {
      if (d != null) {
        duration.value = d;
      }
    });

    player.positionStream.listen((p) {
      position.value = p;
      _scrollToCurrentLyric();

      if (p >= duration.value && isRepeatEnabled.value) {
        player.seek(Duration.zero);
        player.play();
      }
    });

    player.playerStateStream.listen((state) {
      isPlayerLoading.value = state.processingState == ProcessingState.loading;
      isPlaying.value = state.playing;
    });
  }

  void _scrollToCurrentLyric() {
    if (lyrics.isEmpty) return;
    for (int i = 0; i < lyrics.length; i++) {
      if (position.value < lyrics[i].time) {
        if (i > 0) {
          itemScrollController.scrollTo(
            index: i - 1,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        break;
      }
    }
  }

  Future<void> fetchAndSetLyrics(String artist, String title) async {
    final url =
        'https://paxsenixofc.my.id/server/getLyricsMusix.php?q=$title $artist&type=default';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final lines = (response.body as String).split('\n');
        lyrics.value = lines.where((line) => line.contains(']')).map((line) {
          final parts = line.split(']');
          final time = _parseTime(parts[0].substring(1));
          final text = parts[1];
          return Lyric(time, text);
        }).toList();
      } else {
        print('Failed to load lyrics');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Duration _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final minutes = int.parse(parts[0]);
    final seconds = double.parse(parts[1]);
    return Duration(minutes: minutes, seconds: seconds.toInt());
  }

  @override
  void onClose() {
    player.stop();
    player.dispose();
    yt.close();
    super.onClose();
  }
}
