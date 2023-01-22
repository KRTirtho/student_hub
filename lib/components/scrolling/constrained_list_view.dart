import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ConstrainedListView extends ListView {
  final Alignment alignment;
  final BoxConstraints constraints;

  ConstrainedListView({
    super.key,
    super.scrollDirection = Axis.vertical,
    super.reverse = false,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap = false,
    super.padding,
    super.itemExtent,
    super.addAutomaticKeepAlives = true,
    super.addRepaintBoundaries = true,
    super.addSemanticIndexes = true,
    super.cacheExtent,
    super.children = const <Widget>[],
    super.clipBehavior = Clip.hardEdge,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.prototypeItem,
    super.semanticChildCount,
    super.restorationId,
    this.alignment = Alignment.topLeft,
    required this.constraints,
  });

  static Widget separated({
    Key? key,
    Axis? scrollDirection,
    bool? reverse,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool? shrinkWrap,
    EdgeInsets? padding,
    required IndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    required IndexedWidgetBuilder separatorBuilder,
    required int itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    DragStartBehavior? dragStartBehavior,
    ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior,
    String? restorationId,
    Clip? clipBehavior,
    Alignment alignment = Alignment.topLeft,
    required BoxConstraints constraints,
  }) {
    return Scrollbar(
      controller: controller,
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: constraints,
            child: ListView.separated(
              itemBuilder: itemBuilder,
              findChildIndexCallback: findChildIndexCallback,
              separatorBuilder: separatorBuilder,
              itemCount: itemCount,
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              addRepaintBoundaries: addRepaintBoundaries,
              addSemanticIndexes: addSemanticIndexes,
              cacheExtent: cacheExtent,
              dragStartBehavior: dragStartBehavior ?? DragStartBehavior.start,
              keyboardDismissBehavior: keyboardDismissBehavior ??
                  ScrollViewKeyboardDismissBehavior.manual,
              restorationId: restorationId,
              clipBehavior: clipBehavior ?? Clip.hardEdge,
              controller: controller,
              key: key,
              padding: padding,
              physics: physics,
              primary: primary,
              scrollDirection: scrollDirection ?? Axis.vertical,
              shrinkWrap: shrinkWrap ?? false,
              reverse: reverse ?? false,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: constraints,
            child: super.build(context),
          ),
        ),
      ),
    );
  }
}
