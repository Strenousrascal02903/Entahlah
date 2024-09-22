import 'package:entahlah/Themes/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:entahlah/Themes/style.dart';
import 'package:entahlah/routes/app_pages.dart';
import 'home_page_controller.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final TextEditingController _searchController = TextEditingController();
    final storage = GetStorage();
    final String playlistName = storage.read('playlistName') ?? 'Unknown';

    // Call getSpotifyPlaylist after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getSpotifyPlaylist(controller.selectedPlaylistId.value);
    });

    Future<void> _refresh() async {
      await controller.getSpotifyPlaylist(controller.selectedPlaylistId.value);
    }

    Widget _buildTrackList(List<dynamic> tracks) {
      return ListView(
        children: tracks.map((track) {
          var album = track['album'];
          var thumbnailUrl = album['images'][0]['url'];
          String trackName = track['name'];
          String trackId = track['id'] ?? '';
          String artist = track['artists'][0]['name'];

          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(thumbnailUrl,
                  width: 60, height: 60, fit: BoxFit.cover),
            ),
            title: Text(trackName,
                style: textSemiBoldWhite16, overflow: TextOverflow.ellipsis),
            subtitle: Text(artist, style: textSemiBoldWhite14),
            onTap: () {
              if (trackId.isNotEmpty) {
                print("track :$trackId");
                controller.playAudio(spotifyTrackId: trackId);
                controller.fetchAndSetLyrics(artist, trackName);
                storage.write('audioTitle', trackName);
                storage.write('thumbnail', thumbnailUrl);
                storage.write('artist', artist);

                controller.audioTitle.value = trackName;
                controller.thumbnailUrl.value = thumbnailUrl;
                controller.isPlayerHidden.value = false;
                Get.toNamed(Routes.AUDIO_PLAYER_PAGE);
              } else {
                print('Track ID not found');
              }
            },
          );
        }).toList(),
      );
    }

    return Scaffold(
      backgroundColor: BlueGrayColor,
      appBar: AppBar(
        title: Text(playlistName, style: textSemiBoldWhite20),
        backgroundColor: BlueGrayColor,
        foregroundColor: WhiteColor,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: BlueGrayColor800,
                              color: WhiteColor,
                            ),
                          );
                        }

                        final List<dynamic> displayList =
                            _searchController.text.isEmpty
                                ? controller.playlists
                                : controller.spotifyResults;

                        if (displayList.isEmpty) {
                          return Center(
                            child: Text('No results found',
                                style: textMediumWhite16),
                          );
                        }

                        return _buildTrackList(displayList);
                      }),
                    ),
                  ),
                  Obx(() => !controller.isPlayerHidden.value
                      ? SizedBox(
                          height: AppResponsive().screenHeight(context) * 0.06)
                      : Container()),
                ],
              ),
            ),
            Obx(() {
              if (controller.isPlayerHidden.value) {
                return SizedBox.shrink();
              } else {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.AUDIO_PLAYER_PAGE);
                    },
                    child: Obx(() {
                      if (controller.isPlayerLoading.value) {
                        return Container(
                          child: CircularProgressIndicator(
                            backgroundColor: BlueGrayColor800,
                            color: WhiteColor,
                          ),
                        );
                      } else {
                        return Container(
                          height: AppResponsive().screenHeight(context) * 0.08,
                          decoration: BoxDecoration(
                            color: BlueGrayColor800,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Obx(() {
                            final title = controller.audioTitle.value;
                            final thumbnailUrl = controller.thumbnailUrl.value;
                            return Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(thumbnailUrl,
                                      width: 50, height: 50, fit: BoxFit.cover),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(title,
                                          style: textSemiBoldWhite16,
                                          overflow: TextOverflow.ellipsis),
                                      Text(
                                        '${controller.formatDuration(controller.position.value)} / ${controller.formatDuration(controller.duration.value)}',
                                        style: textSemiBoldWhite16,
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      color: WhiteColor,
                                      icon: Icon(
                                        controller.isPlaying.value
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                      ),
                                      onPressed: () {
                                        if (controller.isPlaying.value) {
                                          controller.player.pause();
                                        } else {
                                          controller.player.play();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.close, color: WhiteColor),
                                      onPressed: () {
                                        controller.isPlayerHidden.value = true;
                                        controller.player.stop();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                        );
                      }
                    }),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
