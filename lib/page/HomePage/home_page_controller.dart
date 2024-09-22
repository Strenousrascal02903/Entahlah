import 'dart:async';
import 'dart:convert';
import 'package:entahlah/page/AudioPage/lyric_line.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;
import 'package:kana_kit/kana_kit.dart';

class HomeController extends GetxController {
  var playlists = <dynamic>[].obs;
  var dataPlaylists = <dynamic>[].obs;
  var spotifyResults = <dynamic>[].obs;
  var isLoading = false.obs;
  var selectedAudioUrl = ''.obs;
  final AudioPlayer player = AudioPlayer();
  final yt = YoutubeExplode();

  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var isPlayerLoading = true.obs;
  var isPlaying = false.obs;
  var isPlayerHidden = true.obs;
  var lastPosition = Duration.zero.obs;

  var isShuffleEnabled = false.obs;
  var isRepeatEnabled = false.obs;
  var spotifyAccessToken = ''.obs;
  var selectedPlaylistId = ''.obs;

  String currentLyric = '';

  var currentLyricIndex = 0.obs;

  var audioTitle = ''.obs;
  var thumbnailUrl = ''.obs;
  var lyrics = <Lyric>[].obs;
  var isLyricsVisible = false.obs;
  final RxBool isButtonDisabled = true.obs;
  var playbackQueue = <Map<String, String>>[].obs; // List of metadata maps
  var currentIndex = 0.obs; // Index of the currently playing song

  final String apiKey = 'AIzaSyAINSMX7RsPZtKzrF9MAENrN-gSw7ZLt5E';

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  @override
  void onInit() {
    super.onInit();
    // Mengganti playlistMusic dengan getSpotifyPlaylist
    _initializePlayer();
  }

  void _initializePlayer() {
    player.durationStream.listen((d) {
      if (d != null) {
        duration.value = d;
      }
    });

    player.positionStream.listen((p) {
      position.value = p;
      scrollToCurrentLyric();

      if (p >= duration.value && isRepeatEnabled.value) {
        player.seek(Duration.zero);
        player.play();
      }
    });

    player.playerStateStream.listen((state) {
      isPlayerLoading.value = state.processingState == ProcessingState.loading;
      isPlaying.value = state.playing;
    });

    // Panggil _scrollToCurrentLyric setelah inisialisasi
    Future.delayed(Duration(milliseconds: 500), () {
      if (lastPosition.value != Duration.zero) {
        player.seek(lastPosition.value).then((_) {
          scrollToCurrentLyric();
        });
      } else {
        scrollToCurrentLyric();
      }
    });
  }

  void scrollToCurrentLyric() {
    if (lyrics.isEmpty) return;

    for (int i = 0; i < lyrics.length; i++) {
      if (position.value < lyrics[i].time) {
        if (i > 0 && currentLyricIndex.value != i - 1) {
          // Update currentLyricIndex sebelum scroll
          currentLyricIndex.value = i - 1;

          // Menggeser ke lirik yang sedang aktif dan menempatkannya di tengah layar
          itemScrollController.scrollTo(
            index: i,
            alignment: 0.5, // Nilai ini mengatur agar item berada di tengah
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        break;
      }
    }
  }

  @override
  void onClose() {
    lastPosition.value = position.value;
    player.dispose();
    yt.close();
    super.onClose();
  }

  void restoreLastPosition() {
    if (lastPosition.value != Duration.zero) {
      player.seek(lastPosition.value); // Kembalikan ke posisi terakhir
    }
  }

  Future<void> searchForMusicPlaylists(String query) async {
    isLoading.value = true;
    try {
      if (spotifyAccessToken.value.isEmpty) {
        await fetchSpotifyToken();
      }

      final url = Uri.parse('https://api.spotify.com/v1/search'
          '?q=$query&type=track&limit=10');

      final spotifyResponse = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${spotifyAccessToken.value}',
        },
      );

      if (spotifyResponse.statusCode == 200) {
        var spotifyData = jsonDecode(spotifyResponse.body);
        spotifyResults.value = spotifyData['tracks']['items'];
      } else {
        throw Exception('Failed to search Spotify');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserPlaylist(String userId) async {
    if (spotifyAccessToken.value.isEmpty) {
      await fetchSpotifyToken();
    }
    isLoading.value = true;
    try {
      final url =
          Uri.parse('https://api.spotify.com/v1/users/$userId/playlists');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${spotifyAccessToken.value}',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        dataPlaylists.value = (data['items'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load Spotify playlist');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSpotifyPlaylist(String playlistId) async {
    if (spotifyAccessToken.value.isEmpty) {
      await fetchSpotifyToken();
    }

    try {
      isLoading.value = true; // Set loading to true here
      final url = Uri.parse('https://api.spotify.com/v1/playlists/$playlistId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${spotifyAccessToken.value}',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        playlists.value = data['tracks']['items']
            .map<Map<String, dynamic>>(
                (item) => item['track'] as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load Spotify playlist');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      if (isLoading.value) {
        isLoading.value = false; // Set loading to false here
      }
    }
  }

  Future<String> getAudioUrl(String videoId) async {
    try {
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();
      return audioStreamInfo.url.toString();
    } catch (e) {
      print('Error fetching audio URL: $e');
      rethrow;
    }
  }

  Future<String> getSpotifyAudioUrl(String trackId) async {
    try {
      final url = Uri.parse('https://api.spotify.com/v1/tracks/$trackId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${spotifyAccessToken.value}',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var name = data['name'] as String?;
        var artist = (data['artists'][0]['name'] as String?);
        if (name != null && artist != null) {
          var searchQuery = '$name $artist';
          var video = (await yt.search.search(searchQuery)).first;
          var videoId = video.id.value;
          var manifest = await yt.videos.streamsClient.getManifest(videoId);
          var audioUrl = manifest.audioOnly.first.url;
          return audioUrl.toString();
        } else {
          throw Exception(
              'Failed to fetch name or artist from Spotify API response');
        }
      } else {
        throw Exception('Failed to fetch Spotify audio URL');
      }
    } catch (e) {
      print('Error fetching Spotify audio URL: $e');
      rethrow;
    }
  }

  Future<void> playAudio({String? videoId, String? spotifyTrackId}) async {
    if ((videoId == null || videoId.isEmpty) &&
        (spotifyTrackId == null || spotifyTrackId.isEmpty)) {
      print('Both video ID and Spotify track ID are null or empty');
      return;
    }

    try {
      lyrics.clear();
      String audioUrl;
      audioUrl = "";
      if (videoId != null && videoId.isNotEmpty) {
        audioUrl = await getAudioUrl(videoId);
      } else {
        audioUrl = await getSpotifyAudioUrl(spotifyTrackId!);
      }
      selectedAudioUrl.value = audioUrl;
      await player.setUrl(audioUrl);
      player.play();
      print('Audio URL set and playing: $audioUrl');
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void seekTo(Duration position) {
    player.seek(position);
  }

  void playNext() {}

  void playPrevious() {}

  void toggleShuffle() {
    isShuffleEnabled.value = !isShuffleEnabled.value;
    player.setShuffleModeEnabled(isShuffleEnabled.value);
  }

  void toggleRepeat() {
    isRepeatEnabled.value = !isRepeatEnabled.value;
    player.setLoopMode(isRepeatEnabled.value ? LoopMode.one : LoopMode.off);
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> fetchSpotifyToken() async {
    const clientId = '7fb9d1d8d78f485982a2fbb7f1f5b56f';
    const clientSecret = '928910c8485542a5af7b6db8fc049733';

    final url = Uri.parse('https://accounts.spotify.com/api/token');
    final credentials = '$clientId:$clientSecret';
    final encodedCredentials = base64Encode(utf8.encode(credentials));

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic $encodedCredentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      spotifyAccessToken.value = body['access_token'];
      print("Token :$spotifyAccessToken");
    } else {
      print('Failed to get Spotify token: ${response.statusCode}');
    }
  }

  Future<String?> searchLyrics(String artist, String title) async {
    final url = 'https://api.lyrics.ovh/v1/$artist/$title';

    try {
      final response = await http.get(
        Uri.parse(url),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('lyrics') && data['lyrics'].isNotEmpty) {
          currentLyric = data['lyrics'];
        } else {
          currentLyric = 'Lirik tidak tersedia';
        }
      } else {
        currentLyric = 'Lirik tidak tersedia';
        print('Failed to load lyrics');
      }
    } catch (e) {
      currentLyric = 'Lirik tidak tersedia';
      print('Error: $e');
    }

    return currentLyric;
  }

  Future<void> fetchAndSetLyrics(String artist, String title) async {
    final url =
        'https://paxsenixofc.my.id/server/getLyricsMusix.php?q=$title $artist&type=default';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final lines = (response.body as String).split('\n');
        final kanaKit = KanaKit(); // Instance of KanaKit
        lyrics.value = lines.where((line) => line.contains(']')).map((line) {
          final parts = line.split(']');
          final time = _parseTime(parts[0].substring(1));
          final text = parts[1];

          // Debugging: Print original text
          print('Original Text: $text');

          // Convert Japanese text to Romaji if needed
          final convertedText = kanaKit.toRomaji(text);

          // Debugging: Print converted text
          print('Converted Text: $convertedText');

          return Lyric(time, convertedText);
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

  String extractUserId(String url) {
    // Ambil bagian setelah '/' terakhir
    final lastSegment = url.split('/').last;

    // Cek apakah ada '?'
    if (lastSegment.contains('?')) {
      // Ambil bagian sebelum '?'
      return lastSegment.split('?').first;
    }

    // Jika tidak ada '?', kembalikan seluruh lastSegment
    return lastSegment;
  }
}
