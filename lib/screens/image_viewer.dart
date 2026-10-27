import 'package:flutter/material.dart';

const Color _aquaFoam = Color(0xFF96FCDF);

/// بيفتح الصورة بشاشة كاملة (تكبير بالقرصة، وضغطة وحدة للإغلاق).
void showFullImage(BuildContext context, String imagePath) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => _FullImagePage(imagePath: imagePath),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}

class _FullImagePage extends StatelessWidget {
  final String imagePath;
  const _FullImagePage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, error, __) {
                    debugPrint('Full image error: $error');
                    return const Icon(Icons.broken_image_rounded,
                        color: Colors.white54, size: 64);
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: _aquaFoam.withAlpha(40),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(Icons.close_rounded,
                          color: _aquaFoam, size: 22),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}