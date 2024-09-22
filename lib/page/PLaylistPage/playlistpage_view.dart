import 'package:entahlah/Themes/responsive.dart';
import 'package:entahlah/Themes/style.dart';
import 'package:entahlah/page/HomePage/home_page_controller.dart';
import 'package:entahlah/page/PLaylistPage/profile.dart';
import 'package:entahlah/page/SearchPage/search_page_view.dart';
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
      await controller.getUserProfile(userId);
    }

    // Fetch user profile and playlist on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });

    return Scaffold(
      backgroundColor: BlueGrayColor,
      body: SafeArea(
        child: Obx(() {
          switch (controller.selectedIndex.value) {
            case 0:
              return _buildPlaylistPage(controller, userId, _refresh, context);
            case 1:
              return _buildSearchPage(); // Ganti dengan halaman Search
            case 2:
              return _buildProfilePage(controller); // Profile page
            default:
              return _buildPlaylistPage(controller, userId, _refresh, context);
          }
        }),
      ),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: (index) {
            controller.selectedIndex.value = index;
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.playlist_play),
              label: 'Playlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: BlueGrayColor800,
        );
      }),
    );
  }

  Widget _buildPlaylistPage(HomeController controller, String userId,
      Future<void> Function() _refresh, BuildContext context) {
    return Obx(() {
      // Cek apakah sedang loading
      if (controller.isLoading.value) {
        return Expanded(
          child: Center(
            child: CircularProgressIndicator(color: WhiteColor),
          ),
        );
      }

      var userProfile = controller.userProfile.value;
      String displayName = userProfile['display_name'] ?? 'Guest';
      print(userProfile['display_name']);

      return Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  alignment: Alignment.bottomLeft,
                  margin: EdgeInsets.only(top: 18, left: 10),
                  child: Text(
                    "Hello, $displayName",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: WhiteColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: AppResponsive().screenHeight(context) * 0.02,
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
                      if (controller.dataPlaylists.isEmpty) {
                        return Center(
                          child: Text('No playlists found',
                              style: textMediumWhite16),
                        );
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
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
                              GetStorage().write('playlistName', playlistName);
                              controller.selectedPlaylistId.value = playlistId;
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
                                      borderRadius: BorderRadius.circular(10),
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
                                            bottomRight: Radius.circular(10),
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
                            ),
                          );
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
          _buildPlayer(controller, context),
        ],
      );
    });
  }

  Widget _buildPlayer(HomeController controller, BuildContext context) {
    return Obx(() {
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              icon: Icon(Icons.close, color: WhiteColor),
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
    });
  }

  Widget _buildSearchPage() {
    return SearchPageView(); // Replace with your actual search page implementation
  }

  Widget _buildProfilePage(HomeController controller) {
    return ProfilePageView();
  }
}
