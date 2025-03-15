import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerPage extends StatelessWidget {
  final ImageProvider imageProvider;

  ImageViewerPage(this.imageProvider);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          imageProvider: imageProvider,
          loadingBuilder: null,
          backgroundDecoration: BoxDecoration(
            color: Colors.white,
          ),
          minScale: null,
          maxScale: null,
          initialScale: null,
          basePosition: null,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}