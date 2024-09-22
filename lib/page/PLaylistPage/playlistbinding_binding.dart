import 'package:entahlah/page/PLaylistPage/playlistpage_controller.dart';
import 'package:entahlah/page/SplashScreen/splash_screen_controller.dart';
import 'package:get/get.dart';


class PLaylistPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PLaylistController>(
      () => PLaylistController(),
    );
  }
}
