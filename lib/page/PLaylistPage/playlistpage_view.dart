import 'package:entahlah/Themes/responsive.dart';
import 'package:entahlah/Themes/style.dart';
import 'package:entahlah/page/HomePage/home_page_controller.dart';
import 'package:entahlah/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PlaylistPageView extends StatelessWidget {
  const PlaylistPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final storage = GetStorage();
    final String userId = storage.read('spotifyUserId') ?? 'Unknown';

    Future<void> _refresh() async {
      await controller.getUserPlaylist(userId);
    }

    print(userId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getUserPlaylist(userId);
    });

    return Scaffold(
      backgroundColor: BlueGrayColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.logout,
                            color: WhiteColor,
                          ),
                          onPressed: () {
                            storage.remove('spotifyUserId');
                            Get.offAllNamed(Routes.INPUT_PAGE);
                          },
                        ),
                        Text(
                          "Entahlah",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: WhiteColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search, color: WhiteColor),
                          onPressed: () {
                            Get.toNamed(Routes.SEARCH_PAGE);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: AppResponsive().screenHeight(context) * 0.05,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: 'Your Playlist', style: textMediumWhite16),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: WhiteColor,
                          ));
                        }

                        if (controller.dataPlaylists.isEmpty) {
                          return Center(
                            child: Text('No playlists found',
                                style: textMediumWhite16),
                          );
                        }

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Jumlah kolom
                            childAspectRatio: 2.5, // Rasio aspek item grid
                            crossAxisSpacing: 10, // Jarak horizontal antar item
                            mainAxisSpacing: 10, // Jarak vertical antar item
                          ),
                          itemCount: controller.dataPlaylists.length,
                          itemBuilder: (context, index) {
                            var playlist = controller.dataPlaylists[index];
                            var thumbnailUrl = playlist['images'] != null
                                ? playlist['images'][0]['url']
                                : '';
                            String playlistName = playlist['name'];

                            String playlistId = playlist['id'];

                            return GestureDetector(
                                onTap: () async {
                                  storage.write('playlistName', playlistName);
                                  controller.selectedPlaylistId.value =
                                      playlistId;

                                  Get.toNamed(Routes.HOME_PAGE);
                                },
                                child: Card(
                                  color: BlueGrayColor800,
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: thumbnailUrl.isNotEmpty
                                              ? Image.network(
                                                  thumbnailUrl,
                                                  width: 60,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  'assets/images/default.png',
                                                  width: 60,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                              ),
                                            ),
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              playlistName,
                                              style: textSemiBoldWhite12,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                          },
                        );
                      }),
                    ),
                  ),
                  Obx(() => !controller.isPlayerHidden.value
                      ? SizedBox(
                          height: AppResponsive().screenHeight(context) * 0.06,
                        )
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
                                  child: thumbnailUrl.isNotEmpty
                                      ? Image.network(
                                          thumbnailUrl,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/default.png',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
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
