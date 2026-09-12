import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import '../data/farm_repository.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/widgets/animated_farm_background.dart';
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
  final DateTime _plantDate = DateTime.now();

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
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Add New Crop', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: AnimatedFarmBackground(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.eco, size: 64, color: Colors.green),
                      const SizedBox(height: 16),
                      Text(
                        'Crop Details',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      _buildTextField(
                        controller: _nameController,
                        label: 'Crop Name',
                        hint: 'e.g. Tomato, Wheat, Corn',
                        icon: Icons.grass,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _varietyController,
                        label: 'Variety (Optional)',
                        hint: 'e.g. Cherry Tomato',
                        icon: Icons.category,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _areaController,
                        label: 'Area (acres)',
                        hint: 'e.g. 2.5',
                        icon: Icons.landscape,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      
                      const SizedBox(height: 48),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _saveCrop,
                        child: const Text('Save Crop', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
        ),
      ),
    );
  }
}
