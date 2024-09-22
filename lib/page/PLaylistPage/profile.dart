import 'package:entahlah/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:entahlah/Themes/style.dart';
import 'package:entahlah/Themes/responsive.dart';
import 'package:entahlah/page/HomePage/home_page_controller.dart';
import 'package:get_storage/get_storage.dart';

class ProfilePageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isProfileLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.userProfile.isEmpty) {
            return Center(child: Text('No user profile data'));
          }

          final userProfile = controller.userProfile.value;
          final profileImageUrl =
              userProfile['images'] != null && userProfile['images'].isNotEmpty
                  ? userProfile['images'][1]['url']
                  : '';
          final displayName = userProfile['display_name'] ?? 'Unknown User';
          final userId = userProfile['id'] ?? '';
          final followers = userProfile['followers'] != null
              ? userProfile['followers']['total'].toString()
              : '0';

          return Column(
            children: [
              _buildHeader(displayName, userId, profileImageUrl, followers),
              Expanded(
                child: Container(
                  color: BlueGrayColor,
                  child: _buildProfileOptions(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(String displayName, String userId, String profileImageUrl,
      String followers) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: BlueGrayColor800),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Profile',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : AssetImage('assets/images/ppdefaullt.png') as ImageProvider,
          ),
          SizedBox(height: 10),
          Text(
            displayName,
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            '$followers Followers',
            style: textMediumWhite12,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    final storage = GetStorage();
    final options = [
      {'icon': Icons.exit_to_app, 'title': 'Sign Out'},
    ];

    return ListView.separated(
      itemCount: options.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final option = options[index];
        return ListTile(
          leading: Icon(option['icon'] as IconData, color: WhiteColor),
          title: Text(
            option['title'] as String,
            style: textMediumWhite16,
          ),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            if (option['title'] == 'Sign Out') {
              storage.remove('spotifyUserId');
              Get.offAllNamed(Routes.INPUT_PAGE);
            } else {
              // Handle other options
              print('Tapped on ${option['title']}');
            }
          },
        );
      },
    );
  }
}
