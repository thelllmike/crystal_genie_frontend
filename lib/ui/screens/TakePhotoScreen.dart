// lib/ui/screens/take_photo_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/cg.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import '../../core/services/subscription_service.dart';
import '../widgets/page_transitions.dart';
import 'main_shell.dart';
import 'paywall_screen.dart';
import 'result_screen.dart';

class TakePhotoScreen extends StatefulWidget {
  /// Whether this tab is the visible one. The shell keeps every tab alive, so
  /// the camera hardware is only opened while [active] is true.
  final bool active;

  const TakePhotoScreen({Key? key, this.active = true}) : super(key: key);
  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _usingFront = false;
  bool _noCamera = false;
  XFile? _pickedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.active) _startCamera();
  }

  @override
  void didUpdateWidget(TakePhotoScreen old) {
    super.didUpdateWidget(old);
    if (widget.active == old.active) return;
    if (widget.active) {
      _startCamera();
    } else {
      _stopCamera();
    }
  }

  Future<void> _startCamera() async {
    if (_controller != null) return;
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) setState(() => _noCamera = true);
        return;
      }
      await _restartController();
    } catch (_) {
      if (mounted) setState(() => _noCamera = true);
    }
  }

  /// Releases the camera when the user switches to another tab.
  Future<void> _stopCamera() async {
    final controller = _controller;
    _controller = null;
    if (mounted) setState(() => _pickedImage = null);
    await controller?.dispose();
  }

  Future<void> _restartController() async {
    if (_cameras.isEmpty) return;
    final cam = _cameras.firstWhere(
      (c) => c.lensDirection == (_usingFront ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => _cameras.first,
    );
    await _controller?.dispose();
    final controller =
        CameraController(cam, ResolutionPreset.high, enableAudio: false);
    await controller.initialize();
    // The user may have left the tab while the hardware was warming up.
    if (!mounted || !widget.active) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  @override
  void dispose() {
    _scan.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _switchCamera() async {
    _usingFront = !_usingFront;
    await _restartController();
  }

  /// Scanning is the premium feature: free for the trial week, then it needs a
  /// subscription. Shows the paywall and returns true if the user came back
  /// with access.
  Future<bool> _ensureAccess() async {
    if (await SubscriptionService.hasAccess()) return true;
    if (!mounted) return false;
    await Navigator.of(context).push(
      SmoothPageRoute<bool>(builder: (_) => const PaywallScreen()),
    );
    return SubscriptionService.current?.hasAccess ?? false;
  }

  Future<void> _pickFromGallery() async {
    if (!await _ensureAccess()) return;
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _pickedImage = file);
      await _sendAndNavigate(file);
    }
  }

  Future<void> _takePhoto() async {
    if (!await _ensureAccess()) return;
    if (_controller?.value.isInitialized ?? false) {
      final photo = await _controller!.takePicture();
      setState(() => _pickedImage = photo);
      await _sendAndNavigate(photo);
    }
  }

  Future<void> _sendAndNavigate(XFile file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x6B14262A),
      builder: (_) => const _Identifying(),
    );
    try {
      final dets = await ApiService().detectCrystal(file.path);
      if (!mounted) return;
      Navigator.of(context).pop(); // hide loader
      if (dets.isEmpty) {
        setState(() => _pickedImage = null);
        CG.snack(context, 'No crystal detected. Keep it within the frame and try again.');
        return;
      }
      // Record the find in the user's history (best effort).
      if (AuthService.isLoggedIn) {
        DbService.addFind(
          crystalName: dets.first.className,
          headline: dets.first.description.headline,
        ).catchError((e) => debugPrint('Could not save find: $e'));
      }
      Navigator.of(context).push(SmoothPageRoute(
        builder: (_) => ResultScreen(
          imageFile: File(file.path),
          detections: dets,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      CG.snack(context, 'Error: $e');
    }
  }

  /// Fills the frame with the camera feed (cover), the picked photo, or a
  /// state message.
  Widget _framePreview() {
    if (_pickedImage != null) {
      return Image.file(File(_pickedImage!.path), fit: BoxFit.cover);
    }
    if (_controller?.value.isInitialized ?? false) {
      final size = _controller!.value.previewSize;
      if (size == null) return const ColoredBox(color: CG.s3);
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: CameraPreview(_controller!),
        ),
      );
    }
    if (_noCamera) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GemCluster(color: Color(0xFF9B7DF0), width: 96, height: 112),
              const SizedBox(height: 18),
              Text(
                'No camera available.\nPick a photo from your gallery.',
                textAlign: TextAlign.center,
                style: CG.sub(14),
              ),
            ],
          ),
        ),
      );
    }
    return const CGLoading();
  }

  Widget _corner(Alignment a) {
    const side = BorderSide(color: CG.brand, width: 3);
    const r = Radius.circular(26);
    final top = a.y < 0, left = a.x < 0;
    return Align(
      alignment: a,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          border: Border(
            top: top ? side : BorderSide.none,
            bottom: top ? BorderSide.none : side,
            left: left ? side : BorderSide.none,
            right: left ? BorderSide.none : side,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? r : Radius.zero,
            topRight: top && !left ? r : Radius.zero,
            bottomLeft: !top && left ? r : Radius.zero,
            bottomRight: !top && !left ? r : Radius.zero,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const glass = Color(0xD1FFFFFF);
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F5),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.12),
            radius: 1.1,
            colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F5), Color(0xFFE3EBEB)],
            stops: [0, .55, 1],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final frameW = (c.maxWidth - 110).clamp(200.0, 320.0);
              final frameH = (frameW * 340 / 280).clamp(0.0, c.maxHeight * .5);
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CGIconButton(
                          icon: HugeIcons.strokeRoundedCancel01,
                          tooltip: 'Close camera',
                          background: glass,
                          onTap: () => MainShell.selectedTab.value = MainShell.homeTab,
                        ),
                        const Spacer(),
                        const CGChip('Scan a crystal', background: glass),
                        const Spacer(),
                        const SizedBox(width: 44),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: frameW,
                      height: frameH,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: ColoredBox(color: CG.s2, child: _framePreview()),
                              ),
                            ),
                          ),
                          _corner(Alignment.topLeft),
                          _corner(Alignment.topRight),
                          _corner(Alignment.bottomLeft),
                          _corner(Alignment.bottomRight),
                          if (_pickedImage == null)
                            AnimatedBuilder(
                              animation: _scan,
                              builder: (_, __) => Positioned(
                                left: 14,
                                right: 14,
                                top: 14 + (frameH - 30) * _scan.value,
                                child: Container(
                                  height: 2,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0x001D7F80), CG.brand, Color(0x001D7F80)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: Color(0x80187A7B), blurRadius: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Keep your crystal within the frame',
                      textAlign: TextAlign.center,
                      style: CG.body(17, weight: FontWeight.w500),
                    ),
                    const SizedBox(height: 14),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        CGChip('Good light', background: glass),
                        CGChip('Plain background', background: glass),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CGIconButton(
                          icon: HugeIcons.strokeRoundedImage01,
                          tooltip: 'Choose from gallery',
                          size: 56,
                          background: glass,
                          onTap: _pickFromGallery,
                        ),
                        const SizedBox(width: 44),
                        Semantics(
                          button: true,
                          label: _pickedImage != null ? 'Retake' : 'Take photo',
                          child: GestureDetector(
                            onTap: () {
                              if (_pickedImage != null) {
                                setState(() => _pickedImage = null);
                              } else {
                                _takePhoto();
                              }
                            },
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: CG.tx, width: 3),
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 66,
                                height: 66,
                                decoration: const BoxDecoration(color: CG.tx, shape: BoxShape.circle),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 44),
                        CGIconButton(
                          icon: HugeIcons.strokeRoundedExchange01,
                          tooltip: 'Flip camera',
                          size: 56,
                          background: glass,
                          onTap: _switchCamera,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Shown while the photo is being identified.
class _Identifying extends StatelessWidget {
  const _Identifying();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          width: 220,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: CG.s1,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: CG.line2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GemCluster(color: Color(0xFFA98BFF), width: 72, height: 84),
              const SizedBox(height: 18),
              Text('Identifying…',
                  style: CG.display(20), textAlign: TextAlign.center),
              const SizedBox(height: 14),
              const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(2)),
                child: SizedBox(
                  width: 96,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: CG.s3,
                    color: CG.brand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
