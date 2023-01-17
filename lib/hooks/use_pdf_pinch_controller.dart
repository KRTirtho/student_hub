import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pdfx/pdfx.dart';

class UsePdfPinchController extends Hook<PdfControllerPinch> {
  final Future<PdfDocument> document;
  final int initialPage;
  final double viewportFraction;
  const UsePdfPinchController({
    required this.document,
    this.initialPage = 0,
    this.viewportFraction = 1.0,
  });

  @override
  _UsePdfPinchControllerState createState() => _UsePdfPinchControllerState();
}

class _UsePdfPinchControllerState
    extends HookState<PdfControllerPinch, UsePdfPinchController> {
  late PdfControllerPinch _pdfController;

  @override
  void initHook() {
    super.initHook();
    _pdfController = PdfControllerPinch(
      document: hook.document,
      initialPage: hook.initialPage,
      viewportFraction: hook.viewportFraction,
    );
  }

  @override
  PdfControllerPinch build(BuildContext context) {
    return _pdfController;
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }
}

PdfControllerPinch usePdfPinchController({
  required Future<PdfDocument> document,
  int initialPage = 0,
  double viewportFraction = 1.0,
}) {
  return use(UsePdfPinchController(
    document: document,
    initialPage: initialPage,
    viewportFraction: viewportFraction,
  ));
}
