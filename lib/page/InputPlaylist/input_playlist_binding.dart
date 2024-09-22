
import 'package:entahlah/page/InputPlaylist/input_playlist_controller.dart';
import 'package:get/get.dart';


class InputPlaylistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InputPLaylistController>(
      () => InputPLaylistController(),
    );
  }
}
