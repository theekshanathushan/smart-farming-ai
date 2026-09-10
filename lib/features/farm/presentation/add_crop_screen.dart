import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/farm_repository.dart';
import '../../../core/local_db/app_database.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'farm_screen.dart'; // to invalidate cropsProvider

class AddCropScreen extends ConsumerStatefulWidget {
  const AddCropScreen({super.key});

  @override
  ConsumerState<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends ConsumerState<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _areaController = TextEditingController();
  DateTime _plantDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _saveCrop() async {
    if (_formKey.currentState!.validate()) {
      final crop = Crop(
        id: const Uuid().v4(),
        name: _nameController.text,
        variety: _varietyController.text.isNotEmpty ? _varietyController.text : null,
        plantDate: _plantDate,
        expectedHarvestDate: null,
        area: double.tryParse(_areaController.text),
        areaUnit: 'acres',
        createdAt: DateTime.now(),
      );

      await ref.read(farmRepositoryProvider).addCrop(crop);
      
      // Add a default task
      await ref.read(farmRepositoryProvider).addTask(Task(
        id: const Uuid().v4(),
        cropId: crop.id,
        title: 'Water the new ${_nameController.text}',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
        createdAt: DateTime.now(),
      ));

      ref.invalidate(cropsProvider);
      ref.invalidate(tasksProvider);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Crop'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Crop Name (e.g. Tomato)', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _varietyController,
              decoration: const InputDecoration(labelText: 'Variety (Optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(labelText: 'Area (acres)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              onPressed: _saveCrop,
              child: const Text('Save Crop'),
            ),
          ],
        ),
      ),
    );
  }
}
