import 'dart:ui';
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:entahlah/Themes/style.dart';
import 'package:entahlah/Themes/responsive.dart';
import 'package:entahlah/page/HomePage/home_page_controller.dart';

class AudioPlayerView extends StatelessWidget {
  AudioPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final String title = GetStorage().read('audioTitle') ?? 'Unknown';
    final String thumbnail = GetStorage().read('thumbnail') ?? 'Unknown';
    final String artist = GetStorage().read('artist') ?? 'Unknown';
    controller.restoreLastPosition();

    // Call scrollToCurrentLyric after restoreLastPosition
    Future.delayed(Duration(milliseconds: 500), () {
      controller.scrollToCurrentLyric();
    });

    return Scaffold(
      bottomSheet: DraggableBottomSheet(
        minExtent: 60,
        useSafeArea: false,
        curve: Curves.easeIn,
        previewWidget: _previewWidget(context),
        expandedWidget: _expandedWidget(controller),
        backgroundWidget:
            _backgroundWidget(controller, title, thumbnail, artist, context),
        duration: const Duration(milliseconds: 10),
        maxExtent: MediaQuery.of(context).size.height * 0.8,
        onDragging: (pos) {},
      ),
      backgroundColor: BlueGrayColor,
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        foregroundColor: WhiteColor,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Now Playing',
          style: textSemiBoldWhite20,
        ),
      ),
    );
  }

  Widget _previewWidget(BuildContext context) {
    return Container(
      height: AppResponsive().screenHeight(context) * 0.2,
      decoration: BoxDecoration(
          color: BlueGrayColor800,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
      child: Center(
        child: Text(
          'Lihat Lirik',
          style: textSemiBoldWhite20,
        ),
      ),
    );
  }

  Widget _expandedWidget(HomeController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: BlueGrayColor800,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
      child: Obx(
        () {
          if (controller.isPlayerLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: BlueGrayColor800,
                color: WhiteColor,
              ),
            );
          } else if (controller.lyrics.isEmpty) {
            return Center(
              child: Text(
                'Lirik tidak tersedia',
                style: textSemiBoldWhite16,
              ),
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Lirik',
                    style: textSemiBoldWhite16,
                  ),
                ),
                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemCount: controller.lyrics.length,
                    itemBuilder: (context, index) {
                      final lyric = controller.lyrics[index];
                      return Obx(() {
                        bool isCurrent =
                            controller.position.value >= lyric.time &&
                                (index == controller.lyrics.length - 1 ||
                                    controller.position.value <
                                        controller.lyrics[index + 1].time);
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            lyric.text,
                            textAlign: TextAlign.center,
                            style: isCurrent
                                ? textSemiBoldWhite20
                                : textMediumWhite16.copyWith(
                                    color: LightGreyColor.withOpacity(0.8)),
                          ),
                        );
                      });
                    },
                    itemScrollController: controller.itemScrollController,
                    itemPositionsListener: controller.itemPositionsListener,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _backgroundWidget(HomeController controller, String title,
      String thumbnail, String artist, BuildContext context) {
    return SafeArea(
      child: Container(
        color: BlueGrayColor,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Obx(
              () {
                bool shouldShowIndicator = controller.isPlayerLoading.value;

                return shouldShowIndicator
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: BlueGrayColor800,
                          color: WhiteColor,
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$title - $artist',
                                      style: textSemiBoldWhite16,
                                    ),
                                    SizedBox(height: 20),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        thumbnail,
                                        width: AppResponsive()
                                                .screenWidth(context) *
                                            0.8,
                                        height: AppResponsive()
                                                .screenHeight(context) *
                                            0.35,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${controller.formatDuration(controller.position.value)}',
                                          style: textSemiBoldWhite16,
                                        ),
                                        Container(
                                          width: AppResponsive()
                                                  .screenWidth(context) *
                                              0.6,
                                          child: Slider(
                                            activeColor: BlueGrayColor700,
                                            inactiveColor: WhiteColor,
                                            value: controller
                                                .position.value.inSeconds
                                                .toDouble(),
                                            min: 0.0,
                                            max: controller
                                                .duration.value.inSeconds
                                                .toDouble(),
                                            onChanged: (double value) {
                                              controller.seekTo(Duration(
                                                  seconds: value.toInt()));
                                            },
                                          ),
                                        ),
                                        Text(
                                          '${controller.formatDuration(controller.duration.value)}',
                                          style: textSemiBoldWhite16,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          color: WhiteColor,
                                          icon: Icon(
                                            controller.isShuffleEnabled.value
                                                ? Icons.shuffle_on_outlined
                                                : Icons.shuffle,
                                          ),
                                          onPressed: controller.toggleShuffle,
                                        ),
                                        IconButton(
                                          color: WhiteColor,
                                          icon: Icon(Icons.skip_previous),
                                          onPressed: controller.playPrevious,
                                        ),
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
                                          color: WhiteColor,
                                          icon: Icon(Icons.skip_next),
                                          onPressed: controller.playNext,
                                        ),
                                        IconButton(
                                          color: WhiteColor,
                                          icon: Icon(
                                            controller.isRepeatEnabled.value
                                                ? Icons.repeat_one
                                                : Icons.repeat,
                                          ),
                                          onPressed: controller.toggleRepeat,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
