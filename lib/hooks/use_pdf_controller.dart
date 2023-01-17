import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pdfx/pdfx.dart';

class UsePdfController extends Hook<PdfController> {
  final Future<PdfDocument> document;
  final int initialPage;
  final double viewportFraction;
  const UsePdfController({
    required this.document,
    this.initialPage = 0,
    this.viewportFraction = 1.0,
  });

  @override
  _UsePdfControllerState createState() => _UsePdfControllerState();
}

class _UsePdfControllerState
    extends HookState<PdfController, UsePdfController> {
  late PdfController _pdfController;

  @override
  void initHook() {
    super.initHook();
    _pdfController = PdfController(
      document: hook.document,
      initialPage: hook.initialPage,
      viewportFraction: hook.viewportFraction,
    );
  }

  @override
  PdfController build(BuildContext context) {
    return _pdfController;
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }
}

PdfController usePdfController({
  required Future<PdfDocument> document,
  int initialPage = 0,
  double viewportFraction = 1.0,
}) {
  return use(UsePdfController(
    document: document,
    initialPage: initialPage,
    viewportFraction: viewportFraction,
  ));
}
