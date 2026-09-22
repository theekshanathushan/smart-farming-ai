import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:agri_ai/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (image != null) {
        await ref.read(authProvider.notifier).updateProfileImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions(AppLocalizations l10n) {
    final authState = ref.read(authProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.updateProfilePhoto, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(Icons.camera_alt, l10n.camera, () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  }),
                  _buildOptionButton(Icons.photo_library, l10n.gallery, () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  }),
                  if (authState.profileImagePath != null)
                    _buildOptionButton(Icons.delete, l10n.remove, () {
                      Navigator.pop(context);
                      ref.read(authProvider.notifier).updateProfileImage(null);
                    }, isDestructive: true),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.redAccent : Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDestructive ? Colors.red.withValues(alpha: 0.2) : Colors.white24,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.profileTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedFarmBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white24,
                            backgroundImage: authState.profileImagePath != null
                                ? FileImage(File(authState.profileImagePath!))
                                : null,
                            child: authState.profileImagePath == null
                                ? const Icon(Icons.person, size: 50, color: Colors.white)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () => _showImagePickerOptions(l10n),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      authState.name?.isNotEmpty == true ? authState.name! : 'Farmer User',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Info Section
                  _buildSectionTitle(l10n.personalDetails),
                  const SizedBox(height: 12),
                  GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.phone, l10n.phoneNumber, authState.phoneNumber ?? l10n.notProvided),
                        const Divider(color: Colors.white24, height: 24),
                        _buildInfoRow(Icons.location_on, l10n.location, 'Dambulla, Sri Lanka'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings Section
                  _buildSectionTitle(l10n.appSettings),
                  const SizedBox(height: 12),
                  GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildActionRow(context, Icons.language, l10n.language, _getLanguageName(locale.languageCode, l10n), onTap: () {
                          _showLanguageDialog(context, l10n);
                        }),
                        const Divider(color: Colors.white24, height: 24),
                        _buildActionRow(context, Icons.info_outline, l10n.aboutApp, 'Version 1.0.0'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text(l10n.logout, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context, IconData icon, String label, String subtitle, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label settings coming soon')),
        );
      },
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.tertiary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        ],
      ),
    );
  }

  String _getLanguageName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'si':
        return l10n.sinhala;
      case 'ta':
        return l10n.tamil;
      default:
        return l10n.english;
    }
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.languageSettings, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('English', style: TextStyle(color: Colors.white)),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('සිංහල', style: TextStyle(color: Colors.white)),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('si'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('தமிழ்', style: TextStyle(color: Colors.white)),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('ta'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
