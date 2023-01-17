import 'dart:ui';

import 'package:eusc_freaks/hooks/use_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewPage extends HookConsumerWidget {
  final Future<PdfDocument> document;
  const PdfViewPage({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = usePdfController(document: document);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SafeArea(
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
                PdfView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  pageSnapping: false,
                  physics: const AlwaysScrollableScrollPhysics(),
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
                ValueListenableBuilder(
                    valueListenable: controller.pageListenable,
                    builder: (context, page, _) {
                      if ((controller.pagesCount ?? 0) == 0) {
                        return const SizedBox();
                      }
                      return Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                color: Theme.of(context)
                                    .backgroundColor
                                    .withOpacity(
                                      0.5,
                                    )),
                            margin: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: () {
                                    controller.previousPage(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) {
                                    return [
                                      for (int i = 0;
                                          i < (controller.pagesCount ?? 0);
                                          i++)
                                        PopupMenuItem(
                                          value: i,
                                          child: Text("Page ${i + 1}"),
                                        )
                                    ];
                                  },
                                  constraints: const BoxConstraints(
                                    maxHeight: 300,
                                  ),
                                  onSelected: (value) {
                                    controller.animateToPage(
                                      value,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Text(
                                    "$page/${controller.pagesCount}",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () {
                                    controller.nextPage(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
