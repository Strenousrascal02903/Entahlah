import 'package:entahlah/page/SplashScreen/splash_screen_controller.dart';
import 'package:get/get.dart';


class SplashScreenPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashScreenPageController>(
      () => SplashScreenPageController(),
    );
  }
}
