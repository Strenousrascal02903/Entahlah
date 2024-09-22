import 'package:entahlah/Themes/style.dart';
import 'package:entahlah/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';


void main() async {
  await GetStorage.init();
   WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('offlineSongs');
 runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return   GetMaterialApp(
     debugShowCheckedModeBanner: false,
      title: "Application",
      theme: ThemeData(
        primarySwatch: Colors.amber,
        dividerColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          surfaceTintColor: WhiteColor,
        ),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
