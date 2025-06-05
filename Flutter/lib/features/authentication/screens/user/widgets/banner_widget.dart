import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../controllers/banner_controller.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {

    // Register controller banner controller
    final BannerController ctrl = Get.put(BannerController());

    return SafeArea(
      child: Obx(() {

        // Show loading circle if banner empty
        if (ctrl.bannerUrls.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.width / 2.5,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Carousel slider
        return CarouselSlider(
          items: ctrl.bannerUrls.map((url) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: 330,
                placeholder: (_, __) => ColoredBox(
                  color: Colors.white,
                  child: const Center(child: CupertinoActivityIndicator()),
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.error),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: MediaQuery.of(context).size.width / 2.5,
            viewportFraction: 1,
            autoPlay: true,
          ),
        );
      }),
    );
  }
}
