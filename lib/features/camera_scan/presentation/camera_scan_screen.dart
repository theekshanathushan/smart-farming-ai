import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'scan_controller.dart';

class CameraScanScreen extends ConsumerWidget {
  const CameraScanScreen({super.key});

  Future<void> _handleCapture(WidgetRef ref, BuildContext context, ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission is required.')),
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
      appBar: AppBar(
        title: const Text('Crop Disease Scanner'),
        actions: [
          if (state.imagePath != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(scanControllerProvider.notifier).reset(),
            )
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ScanState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing crop...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (state.imagePath != null && state.result != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(state.imagePath!),
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Disease Detected:',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.result!.label,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(state.result!.confidence * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Recommendation:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Based on this result, consider appropriate treatment. Ensure you consult a local agricultural expert before applying any chemicals.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: state.isSaved
                  ? null
                  : () {
                      ref.read(scanControllerProvider.notifier).saveResult(null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Result saved to offline database!')),
                      );
                    },
              icon: Icon(state.isSaved ? Icons.check : Icons.save),
              label: Text(state.isSaved ? 'Saved' : 'Save Result'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.yard, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            'Scan your crop to detect diseases.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _handleCapture(ref, context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _handleCapture(ref, context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
