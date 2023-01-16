import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Avatar extends HookWidget {
  final User user;
  final double radius;
  final double? iconSize;
  const Avatar({
    Key? key,
    required this.user,
    this.radius = 20,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: user.isMaster == true
                  ? Colors.orange
                  : Colors.blueAccent[200]!,
              width: radius < 20 ? 1 : 2,
            ),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundImage: user.avatar.isNotEmpty
                ? UniversalImage.imageProvider(
                    pb
                        .getFileUrl(
                          user,
                          user.avatar,
                          thumb: "${radius}x$radius",
                        )
                        .toString(),
                  )
                : null,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Icon(
              user.isMaster == true
                  ? Icons.location_city_outlined
                  : Icons.school_sharp,
              size: iconSize ?? radius * .75,
              color: user.isMaster == true ? Colors.orange : Colors.blue[300],
            ),
          ),
        )
      ],
    );
  }
}
