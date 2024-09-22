import 'package:entahlah/Themes/style.dart';
import 'package:entahlah/page/HomePage/home_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class LyricPage extends StatelessWidget {
  LyricPage({super.key});
  final HomeController controller = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlueGrayColor,
      appBar: AppBar(
        backgroundColor: BlueGrayColor,
        foregroundColor: WhiteColor,
      ),
      body: Obx(() {
        final lyrics = controller.lyrics;
        if (lyrics.isEmpty) {
          return Center(
            child: Text(
              'Lirik tidak tersedia',
              style: textSemiBoldWhite14,
            ),
          );
        }
        return ScrollablePositionedList.builder(
          itemCount: lyrics.length,
          itemBuilder: (context, index) {
            final lyric = lyrics[index];
            return Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                lyric.text,
                style: textSemiBoldWhite14.copyWith(
                  color: controller.position.value >= lyric.time
                      ? WhiteColor
                      : Colors.grey,
                ),
              ),
            );
          },
          itemScrollController: controller.itemScrollController,
          itemPositionsListener: controller.itemPositionsListener,
        );
      }),
    );
  }
}
