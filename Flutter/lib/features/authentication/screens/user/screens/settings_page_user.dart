import 'package:ai_test/data/repositories/product/like_page_user.dart';
import 'package:ai_test/features/authentication/screens/user/screens/chatbot/chatbot_main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'orders/order_page_user.dart';

class SettingsPageUser extends StatelessWidget {
  const SettingsPageUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [

          // User orders page
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('My Orders'),
            onTap: () {
              Get.to(() => OrdersPageUser());
            },
          ),

          // Likes
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Likes'),
            onTap: () {

              // Go to OrderPageUser
              Get.to(() => LikesPageUser());
            },
          ),

          // AI Assistant page
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('AI Assistant'),
            onTap: () {

              // Go to OrderPageUser
              Get.to(() => ChatbotMain());
            },
          ),
          const Spacer(),


          // Log out button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Get.offAllNamed('/sign-in');
              },
            ),
          ),
        ],
      ),
    );
  }
}
