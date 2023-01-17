import 'dart:ui';

import 'package:eusc_freaks/hooks/use_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PdfViewPage extends HookConsumerWidget {
  final Future<PdfDocument>? document;
  final String? documentUrl;
  const PdfViewPage({
    Key? key,
    required this.document,
    this.documentUrl,
  })  : assert(
          document != null || documentUrl != null,
          'Either document or documentUrl must be provided',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final progress = useState<double>(0);
    final media = useState<Future<PdfDocument>?>(null);

    final stream = useMemoized(
      () => documentUrl != null
          ? DefaultCacheManager().getFileStream(
              documentUrl!,
              headers: {
                'Accept': 'application/pdf',
              },
              withProgress: true,
            )
          : null,
      [documentUrl],
    );

    useEffect(() {
      if (stream == null || media.value != null) return null;
      final subscription = stream.listen(
        (event) {
          if (event is FileInfo) {
            media.value =
                document ?? PdfDocument.openData(event.file.readAsBytes());
          } else if (event is DownloadProgress) {
            progress.value = event.progress ?? progress.value;
          }
        },
      );
      return () => subscription.cancel();
    }, [stream, document]);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            actions: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).backgroundColor.withOpacity(
                            0.5,
                          ),
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Gap(10),
            ],
          ),
          body: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(
              overscroll: true,
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: media.value == null
                ? Center(
                    child: CircularPercentIndicator(
                      radius: 50.0,
                      percent: progress.value,
                      center: Text(
                        "${(progress.value * 100).toInt()}%",
                      ),
                    ),
                  )
                : HookBuilder(builder: (context) {
                    final controller = usePdfController(document: media.value!);
                    return Stack(
                      children: [
                        PdfView(
                          controller: controller,
                          scrollDirection: Axis.horizontal,
                          pageSnapping: false,
                          physics: const AlwaysScrollableScrollPhysics(),
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
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
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
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                        ),
                                        PopupMenuButton(
                                          itemBuilder: (context) {
                                            return [
                                              for (int i = 0;
                                                  i <
                                                      (controller.pagesCount ??
                                                          0);
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
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                          child: Text(
                                            "$page/${controller.pagesCount}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chevron_right),
                                          onPressed: () {
                                            controller.nextPage(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ],
                    );
                  }),
          ),
        ),
      ),
    );
  }
}
