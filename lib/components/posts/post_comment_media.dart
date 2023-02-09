import 'package:student_hub/components/image/universal_image.dart';
import 'package:student_hub/models/lol_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostCommentMedia extends HookConsumerWidget {
  final List<LOLFile> medias;
  final bool enabled;
  final ValueChanged<List<LOLFile>> onChanged;
  const PostCommentMedia({
    Key? key,
    required this.onChanged,
    this.medias = const [],
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final selectedMedias = useState(medias);

    useEffect(() {
      selectedMedias.value = medias;
      return null;
    }, [medias]);

    return SizedBox(
      height: 70,
      child: Row(
        children: [
          const Gap(10),
          ...selectedMedias.value.map(
            (media) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        image: DecorationImage(
                          image:
                              UniversalImage.imageProvider(media.universalPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white60,
                          ),
                          color: Colors.red[400]?.withOpacity(.8),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                          ),
                          onPressed: !enabled
                              ? null
                              : () {
                                  selectedMedias.value = selectedMedias.value
                                      .where(
                                        (element) => element != media,
                                      )
                                      .toList();
                                  onChanged(selectedMedias.value);
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            width: 70,
            child: MaterialButton(
              height: 80,
              color: Theme.of(context).cardColor,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              disabledElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: !enabled
                  ? null
                  : () async {
                      final files = await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        dialogTitle: "Select post media",
                        type: FileType.image,
                        withData: true,
                      );
                      if (files == null) return;
                      if ((files.count + selectedMedias.value.length) > 3) {
                        selectedMedias.value = [
                          ...selectedMedias.value,
                          ...files.files
                              .sublist(0, 3 - selectedMedias.value.length)
                              .map((e) => LOLFile.fromPlatformFile(e, "image")),
                        ];
                      } else {
                        selectedMedias.value = [
                          ...selectedMedias.value,
                          ...files.files
                              .map((e) => LOLFile.fromPlatformFile(e, "image"))
                        ];
                      }
                      onChanged(selectedMedias.value);
                    },
              child: const Icon(
                Icons.add_photo_alternate_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
