import 'dart:ui';

import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PostMedia extends HookConsumerWidget {
  final List<Uri> medias;
  final int initialPage;
  const PostMedia({
    Key? key,
    required this.medias,
    this.initialPage = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final pageController = usePageController(initialPage: initialPage);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            overscroll: true,
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: Stack(
            children: [
              PhotoViewGallery.builder(
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                itemCount: medias.length,
                pageController: pageController,
                scrollPhysics: const BouncingScrollPhysics(),
                enableRotation: true,
                allowImplicitScrolling: true,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: UniversalImage.imageProvider(
                      medias[index].toString(),
                    ),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    heroAttributes: PhotoViewHeroAttributes(
                      tag: medias[index].toString(),
                      transitionOnUserGestures: true,
                    ),
                  );
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white38,
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              if (medias.length > 1) ...[
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.white38),
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.white38),
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
