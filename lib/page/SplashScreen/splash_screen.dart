import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:entahlah/Themes/style.dart';
import 'package:entahlah/page/HomePage/home_page_view.dart';
import 'package:entahlah/page/InputPlaylist/Inputplaylist_view.dart';
import 'package:entahlah/page/PLaylistPage/playlistpage_view.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final userId = box.read('spotifyUserId');
    print("id : $userId");
    return AnimatedSplashScreen(
      splash: Text(
        "Ini Splash screen",
        style: textSemiBoldWhite20,
      ),
      nextScreen: userId != null ? PlaylistPageView() : InputUserPage(),
      splashTransition: SplashTransition.slideTransition,
      backgroundColor: BlueGrayColor,
      animationDuration: const Duration(milliseconds: 600),
      duration: 2000,
    );
  }
}
