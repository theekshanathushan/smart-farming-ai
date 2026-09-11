import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'scan_controller.dart';
import '../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class CameraScanScreen extends ConsumerWidget {
  const CameraScanScreen({super.key});

  Future<void> _handleCapture(WidgetRef ref, BuildContext context, ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required.'),
              backgroundColor: AppTheme.harvestGold,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }
    await ref.read(scanControllerProvider.notifier).captureAndClassify(source);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Immersive dark background for this screen
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (state.imagePath != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => ref.read(scanControllerProvider.notifier).reset(),
            ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => context.push('/scan/history'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image (Real or Placeholder)
          Positioned.fill(
            child: state.imagePath != null
                ? Image.file(
                    File(state.imagePath!),
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/leaf_placeholder.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: AppTheme.deepCanopy,
                      child: const Center(
                        child: Icon(Icons.eco, size: 120, color: Colors.white24),
                      ),
                    ),
                  ),
          ),
          
          // Dark Overlay with clear focus area (only when idle)
          if (state.imagePath == null)
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white, // This part is "punched out"
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // Focus Brackets (idle)
          if (state.imagePath == null)
            Center(
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            
          // Scanning Animation Layer
          if (state.isLoading)
            Positioned.fill(
              child: _ScanningAnimationOverlay(),
            ),
            
          // Bottom Sheet Controls or Results
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 48),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _buildBottomPanel(context, ref, state),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, WidgetRef ref, ScanState state) {
    if (state.isLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppTheme.sprout),
          SizedBox(height: 16),
          Text(
            'Analyzing crop...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.richLoam),
          ),
          SizedBox(height: 8),
          Text(
            'Please keep the device steady.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    if (state.error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Analysis Failed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            state.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.richLoam),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(scanControllerProvider.notifier).reset(),
            child: const Text('Try Again'),
          )
        ],
      );
    }

    if (state.imagePath != null && state.result != null) {
      final isUnrecognized = state.result!.label.contains('Unrecognized');

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isUnrecognized ? 'Scan Result' : 'Disease Detected',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            state.result!.label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isUnrecognized ? Colors.orange : AppTheme.deepCanopy,
              fontSize: isUnrecognized ? 20 : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.harvestGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Confidence: ${(state.result!.confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.richLoam),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (isUnrecognized)
            ElevatedButton(
              onPressed: () => ref.read(scanControllerProvider.notifier).reset(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else
            ElevatedButton.icon(
              onPressed: state.isSaved
                  ? null
                  : () {
                      ref.read(scanControllerProvider.notifier).saveResult(null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Saved to offline database'),
                          backgroundColor: AppTheme.sprout,
                        ),
                      );
                    },
              icon: Icon(state.isSaved ? Icons.check : Icons.save),
              label: Text(state.isSaved ? 'Saved' : 'Save Result'),
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isSaved ? Colors.grey : AppTheme.sprout,
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
        ],
      );
    }

    // Default Idle State (Bottom Panel)
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Identify Crop Disease',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Position the leaf clearly within the frame for best results.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleCapture(ref, context, ImageSource.gallery),
                icon: const Icon(Icons.photo_library, color: AppTheme.deepCanopy),
                label: const Text('Gallery', style: TextStyle(color: AppTheme.deepCanopy)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.deepCanopy, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleCapture(ref, context, ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.sprout,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _ScanningAnimationOverlay extends StatefulWidget {
  @override
  State<_ScanningAnimationOverlay> createState() => _ScanningAnimationOverlayState();
}

class _ScanningAnimationOverlayState extends State<_ScanningAnimationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Colors.black.withOpacity(0.3)),
            Positioned(
              top: MediaQuery.of(context).size.height * _animation.value,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.sprout,
                  boxShadow: [
                    BoxShadow(color: AppTheme.sprout.withOpacity(0.8), blurRadius: 10, spreadRadius: 2),
                    BoxShadow(color: AppTheme.sprout.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
