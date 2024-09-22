import 'package:entahlah/page/AudioPage/audio_player_binding.dart';
import 'package:entahlah/page/AudioPage/audio_player_page.dart';
import 'package:entahlah/page/HomePage/home_page_binding.dart';
import 'package:entahlah/page/HomePage/home_page_view.dart';
import 'package:entahlah/page/InputPlaylist/Inputplaylist_view.dart';
import 'package:entahlah/page/InputPlaylist/input_playlist_binding.dart';
import 'package:entahlah/page/PLaylistPage/playlistbinding_binding.dart';
import 'package:entahlah/page/PLaylistPage/playlistpage_view.dart';
import 'package:entahlah/page/SearchPage/search_page_binding.dart';
import 'package:entahlah/page/SearchPage/search_page_view.dart';
import 'package:entahlah/page/SplashScreen/splash_screen.dart';
import 'package:entahlah/page/SplashScreen/splash_screen_binding.dart';
import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN_PAGE;

  static final routes = [
    GetPage(
      name: Routes.SPLASH_SCREEN_PAGE,
      page: () => Splashscreen(),
      binding: SplashScreenPageBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.HOME_PAGE,
      page: () => HomePageView(),
      binding: HomePageBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.AUDIO_PLAYER_PAGE,
      page: () => AudioPlayerView(),
      binding: AudioPlayerPageBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.PLAYLIST_PAGE,
      page: () => PlaylistPageView(),
      binding: PLaylistPageBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.INPUT_PAGE,
      page: () => InputUserPage(),
      binding: InputPlaylistBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.SEARCH_PAGE,
      page: () => SearchPageView(),
      binding: SearchPageBinding(),
      transition: Transition.noTransition,
    ),
  ];
}
