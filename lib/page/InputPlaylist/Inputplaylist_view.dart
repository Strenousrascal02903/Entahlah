import 'package:entahlah/Themes/style.dart';
import 'package:entahlah/page/HomePage/home_page_controller.dart';
import 'package:entahlah/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class InputUserPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final storage = GetStorage();
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    // Menambahkan listener ke TextEditingController
    _controller.addListener(() {
      // Mengupdate nilai isButtonDisabled berdasarkan teks di TextField
      controller.isButtonDisabled.value = _controller.text.isEmpty;
    });

    return Scaffold(
      body: Center(
        child: Container(
          color: BlueGrayColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _controller,
                  style: textSemiBoldWhite14,
                  decoration: InputDecoration(
                    focusColor: WhiteColor,
                    hintStyle: textSemiBoldWhite14,
                    hintText: 'Masukan link Spotify User',
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
                SizedBox(height: 20),
                Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BlueGrayColor600,
                        foregroundColor: WhiteColor,
                      ),
                      onPressed: controller.isButtonDisabled.value
                          ? null
                          : () {
                              final link = _controller.text;
                              final userId = controller.extractUserId(link);

                              storage.write('spotifyUserId', userId);
                              controller.getUserPlaylist(userId);

                              print(userId);
                              Get.offNamed(Routes.PLAYLIST_PAGE);
                            },
                      child: Text(
                        'Save',
                        style: textSemiBoldWhite14,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
