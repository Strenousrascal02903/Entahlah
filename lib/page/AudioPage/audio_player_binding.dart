import 'package:entahlah/page/AudioPage/audio_player_controller.dart';
import 'package:get/get.dart';


class AudioPlayerPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AudioPlayerPageController>(
      () => AudioPlayerPageController(),
    );
  }
}
