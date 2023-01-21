import 'dart:io';
import 'dart:ui';

import 'package:eusc_freaks/components/markdown/format_markdown.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

/// Widget with markdown buttons
class MarkdownTextInput extends StatefulWidget {
  /// Validator for the TextFormField
  final String? Function(String? value)? validator;

  /// Change the text direction of the input (RTL / LTR)
  final TextDirection textDirection;

  /// The maximum of lines that can be display in the input
  final int? maxLines;

  /// List of action the component can handle
  final List<MarkdownType> actions;

  /// Optional controller to manage the input
  final TextEditingController? controller;

  /// Overrides input text style
  final TextStyle? textStyle;

  /// If you prefer to use the dialog to insert links, you can choose to use the markdown syntax directly by setting [insertLinksByDialog] to false. In this case, the selected text will be used as label and link.
  /// Default value is true.
  final bool insertLinksByDialog;

  final FocusNode? focusNode;

  /// Decoration for the input
  final InputDecoration? decoration;

  /// Constructor for [MarkdownTextInput]
  const MarkdownTextInput({
    super.key,
    this.validator,
    this.textDirection = TextDirection.ltr,
    this.maxLines = 10,
    this.actions = const [
      MarkdownType.bold,
      MarkdownType.italic,
      MarkdownType.title,
      MarkdownType.link,
      MarkdownType.list
    ],
    this.textStyle,
    this.controller,
    this.focusNode,
    this.decoration,
    this.insertLinksByDialog = true,
  });

  @override
  MarkdownTextInputState createState() => MarkdownTextInputState();
}

class MarkdownTextInputState extends State<MarkdownTextInput> {
  late final TextEditingController _controller;
  TextSelection textSelection =
      const TextSelection(baseOffset: 0, extentOffset: 0);
  late final FocusNode focusNode;

  void onTap(MarkdownType type,
      {int titleSize = 1, String? link, String? selectedText}) {
    final basePosition = textSelection.baseOffset;
    final noTextSelected =
        (textSelection.baseOffset - textSelection.extentOffset) == 0;

    final fromIndex = textSelection.baseOffset;
    final toIndex = textSelection.extentOffset;

    final result = FormatMarkdown.convertToMarkdown(
        type, _controller.text, fromIndex, toIndex,
        titleSize: titleSize,
        link: link,
        selectedText:
            selectedText ?? _controller.text.substring(fromIndex, toIndex));

    _controller.value = _controller.value.copyWith(
        text: result.data,
        selection:
            TextSelection.collapsed(offset: basePosition + result.cursorIndex));

    if (noTextSelected) {
      _controller.selection = TextSelection.collapsed(
          offset: _controller.selection.end - result.replaceCursorIndex);
      focusNode.requestFocus();
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      if (_controller.selection.baseOffset != -1) {
        textSelection = _controller.selection;
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          focusNode: focusNode,
          textInputAction: TextInputAction.newline,
          maxLines: widget.maxLines,
          controller: _controller,
          textCapitalization: TextCapitalization.sentences,
          validator: widget.validator,
          style: widget.textStyle ?? Theme.of(context).textTheme.bodyText1,
          cursorColor: Theme.of(context).primaryColor,
          textDirection: widget.textDirection,
          decoration: widget.decoration,
        ),
        SizedBox(
          height: 44,
          child: Material(
            type: MaterialType.transparency,
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widget.actions.map((type) {
                  switch (type) {
                    case MarkdownType.title:
                      return ExpandableNotifier(
                        child: Expandable(
                          key: const Key('H#_button'),
                          collapsed: ExpandableButton(
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'H#',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                          expanded: Container(
                            color: Colors.white10,
                            child: Row(
                              children: [
                                for (int i = 1; i <= 6; i++)
                                  InkWell(
                                    key: Key('H${i}_button'),
                                    onTap: () =>
                                        onTap(MarkdownType.title, titleSize: i),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'H$i',
                                        style: TextStyle(
                                            fontSize: (18 - i).toDouble(),
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ExpandableButton(
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.close,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    case MarkdownType.link:
                      return _basicInkwell(
                        type,
                        customOnTap: !widget.insertLinksByDialog
                            ? null
                            : () async {
                                final text = _controller.text.substring(
                                    textSelection.baseOffset,
                                    textSelection.extentOffset);

                                final textController = TextEditingController()
                                  ..text = text;
                                final linkController = TextEditingController();
                                final textFocus = FocusNode();
                                final linkFocus = FocusNode();

                                final color =
                                    Theme.of(context).colorScheme.secondary;
                                final language = kIsWeb
                                    ? window.locale.languageCode
                                    : Platform.localeName.substring(0, 2);

                                String textLabel = 'Text';
                                String linkLabel = 'Link';
                                try {
                                  final textTranslation =
                                      await GoogleTranslator()
                                          .translate(textLabel, to: language);
                                  textLabel = textTranslation.text;

                                  final linkTranslation =
                                      await GoogleTranslator()
                                          .translate(linkLabel, to: language);
                                  linkLabel = linkTranslation.text;
                                } catch (e) {
                                  textLabel = 'Text';
                                  linkLabel = 'Link';
                                }

                                await showDialog<void>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                                child: const Icon(Icons.close),
                                                onTap: () =>
                                                    Navigator.pop(context))
                                          ],
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: textController,
                                              decoration: InputDecoration(
                                                hintText: 'example',
                                                label: Text(textLabel),
                                                labelStyle:
                                                    TextStyle(color: color),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: color,
                                                            width: 2)),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: color,
                                                            width: 2)),
                                              ),
                                              autofocus: text.isEmpty,
                                              focusNode: textFocus,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onSubmitted: (value) {
                                                textFocus.unfocus();
                                                FocusScope.of(context)
                                                    .requestFocus(linkFocus);
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: linkController,
                                              decoration: InputDecoration(
                                                hintText: 'https://example.com',
                                                label: Text(linkLabel),
                                                labelStyle:
                                                    TextStyle(color: color),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: color,
                                                            width: 2)),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: color,
                                                            width: 2)),
                                              ),
                                              autofocus: text.isNotEmpty,
                                              focusNode: linkFocus,
                                            ),
                                          ],
                                        ),
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                24.0, 20.0, 24.0, 0),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              onTap(type,
                                                  link: linkController.text,
                                                  selectedText:
                                                      textController.text);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    });
                              },
                      );
                    default:
                      return _basicInkwell(type);
                  }
                }).toList(),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _basicInkwell(MarkdownType type, {Function? customOnTap}) {
    return InkWell(
      key: Key(type.key),
      onTap: () => customOnTap != null ? customOnTap() : onTap(type),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(type.icon),
      ),
    );
  }
}
