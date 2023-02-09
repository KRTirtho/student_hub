import 'dart:io';
import 'dart:ui';

import 'package:student_hub/hooks/use_pdf_controller.dart';
import 'package:student_hub/utils/platform.dart';
import 'package:student_hub/utils/save_file/save_file.dart';
import 'package:student_hub/utils/snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final media = useState<Future<PdfDocument>?>(document);
    final mounted = useIsMounted();

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
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor.withOpacity(.6),
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
                tooltip: "Save to device",
                icon: const Icon(Icons.file_download_outlined),
                onPressed: media.value == null
                    ? null
                    : () async {
                        final file = await DefaultCacheManager().getSingleFile(
                          documentUrl!,
                          headers: {
                            'Accept': 'application/pdf',
                          },
                        );
                        if (!mounted()) return;
                        if (kIsWeb) {
                          await saveFile(
                            await file.readAsBytes(),
                            file.basename,
                          );
                          return;
                        }
                        Directory? directory;

                        switch (Theme.of(context).platform) {
                          case TargetPlatform.android:
                            directory = await getExternalStorageDirectory();
                            break;
                          case TargetPlatform.iOS:
                            directory =
                                await getApplicationDocumentsDirectory();
                            break;
                          case TargetPlatform.linux:
                          case TargetPlatform.macOS:
                          case TargetPlatform.windows:
                            directory = await getDownloadsDirectory();
                            break;
                          default:
                            throw UnsupportedError("Unsupported platform");
                        }

                        if (directory == null) return;
                        final path = join(directory.path, file.basename);
                        await file.copy(path);
                        if (mounted()) {
                          showSnackbar(
                            context,
                            "Book saved to $path",
                            isDismissible: false,
                            customAction: SnackBarAction(
                              textColor: Theme.of(context).backgroundColor,
                              label: "Open",
                              onPressed: () async {
                                if (kIsDesktop) {
                                  await launchUrl(Uri.file(directory!.path));
                                } else {
                                  await OpenFilex.open(path);
                                }
                              },
                            ),
                          );
                        }
                      },
              ),
              const Gap(10),
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
