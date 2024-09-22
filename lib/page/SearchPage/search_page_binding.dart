import 'package:entahlah/page/SearchPage/search_page_controller.dart';
import 'package:entahlah/page/SplashScreen/splash_screen_controller.dart';
import 'package:get/get.dart';


class SearchPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchPageController>(
      () => SearchPageController(),
    );
  }
}
