import 'package:entahlah/Themes/responsive.dart';
import 'package:entahlah/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:entahlah/Themes/style.dart';
import 'package:entahlah/page/HomePage/home_page_controller.dart';
import 'package:get_storage/get_storage.dart';

class SearchPageView extends StatelessWidget {
  const SearchPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final HomeController controller = Get.put(HomeController());
    final TextEditingController _searchController = TextEditingController();

    return Scaffold(
      backgroundColor: BlueGrayColor,
      appBar: AppBar(
        title: Text("Search page", style: textSemiBoldWhite20),
        backgroundColor: BlueGrayColor,
        foregroundColor: WhiteColor,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onSubmitted: (value) {
                      controller
                          .searchForMusicPlaylists(_searchController.text);
                    },
                    style: textSemiBoldWhite14,
                    decoration: InputDecoration(
                      focusColor: WhiteColor,
                      hintStyle: textSemiBoldWhite14,
                      hintText: 'Search...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          controller
                              .searchForMusicPlaylists(_searchController.text);
                        },
                        color: Colors.grey,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final List<dynamic> displayList =
                          controller.spotifyResults;

                      if (displayList.isEmpty) {
                        return Center(
                          child: Text('No results found',
                              style: textMediumWhite16),
                        );
                      }

                      return ListView(
                        children: displayList.map((album) {
                          var images =
                              album['album']['images'] as List<dynamic>? ?? [];
                          var thumbnailUrl =
                              images.isNotEmpty ? images[0]['url'] ?? '' : '';

                          String trackName = album['name'] ?? '';
                          String trackId = album['id'] ?? '';
                          String artist = (album['artists'] as List<dynamic>?)
                                      ?.isNotEmpty ??
                                  false
                              ? album['artists'][0]['name'] ?? ''
                              : '';

                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: thumbnailUrl.isNotEmpty
                                  ? Image.network(thumbnailUrl,
                                      width: 60, height: 60, fit: BoxFit.cover)
                                  : Image.asset(
                                      'assets/images/default.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            title: Text(trackName,
                                style: textSemiBoldWhite16,
                                overflow: TextOverflow.ellipsis),
                            subtitle: Text(artist, style: textSemiBoldWhite14),
                            onTap: () {
                              if (trackId.isNotEmpty) {
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
                    }),
                  ),
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
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  controller.thumbnailUrl.value,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(controller.audioTitle.value,
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
                                    icon: Icon(Icons.close, color: WhiteColor),
                                    onPressed: () {
                                      controller.isPlayerHidden.value = true;
                                      controller.player.stop();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
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
