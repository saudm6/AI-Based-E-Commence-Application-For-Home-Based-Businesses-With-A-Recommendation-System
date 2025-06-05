import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String heroTagPrefix;
  const FullScreenImageViewer({super.key, required this.images, this.initialIndex = 0, required this.heroTagPrefix});

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {

  // Constructor to manage pages
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize page controller
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Use dark background for images
      backgroundColor: Colors.black,
      body: GestureDetector(

        // Close full screen image viewer on tap
        onTap: () => Navigator.pop(context),
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.images.length,
          itemBuilder: (context, index) {

            // Transition animations
            return Hero(
              tag: '${widget.heroTagPrefix}-image-$index',

              // Enable zoom
              child: InteractiveViewer(
                child: Center(

                  // Load image from network
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}