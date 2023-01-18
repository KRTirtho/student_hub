import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Avatar extends HookConsumerWidget {
  final User user;
  final double radius;
  final double? iconSize;
  final Object? tag;
  final VoidCallback? onTap;
  const Avatar({
    Key? key,
    required this.user,
    this.radius = 20,
    this.onTap,
    this.iconSize,
    this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final imageProvider = user.avatar.isNotEmpty
        ? UniversalImage.imageProvider(
            user.getAvatarURL(Size(0, radius * 2)).toString(),
          )
        : null;
    final avatar = imageProvider != null
        ? Material(
            type: MaterialType.transparency,
            child: Ink(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.circle,
              ),
              height: radius * 2,
              width: radius * 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: onTap ??
                    () {
                      if (user.id == ref.read(authenticationProvider)?.id) {
                        GoRouter.of(context).go("/profile/authenticated");
                      } else {
                        GoRouter.of(context).push("/profile/${user.id}");
                      }
                    },
              ),
            ),
          )
        : CircleAvatar(
            radius: radius,
            backgroundImage: imageProvider,
          );
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
          child: tag != null
              ? Hero(
                  tag: tag!,
                  transitionOnUserGestures: true,
                  child: avatar,
                )
              : avatar,
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
        ),
      ],
    );
  }
}
