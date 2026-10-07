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
import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/location_service.dart';

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

  void _showImagePickerOptions(AppLocalizations l10n, Color textColor, Color subtextColor, bool isDark) {
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
              Text(
                l10n.updateProfilePhoto,
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(Icons.camera_alt, l10n.camera, textColor, isDark, () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  }),
                  _buildOptionButton(Icons.photo_library, l10n.gallery, textColor, isDark, () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  }),
                  if (authState.profileImagePath != null)
                    _buildOptionButton(Icons.delete, l10n.remove, textColor, isDark, () {
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

  Widget _buildOptionButton(
    IconData icon,
    String label,
    Color textColor,
    bool isDark,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : textColor;
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
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.2)
                    : (isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.08)),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String? currentName) {
    final controller = TextEditingController(text: currentName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name / නම වෙනස් කරන්න'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Your Name (ඔබගේ නම)',
            hintText: 'e.g. Theekshana Thushan',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(authProvider.notifier).updateName(newName);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userLocationAsync = ref.watch(userLocationProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
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
                            border: Border.all(
                              color: isDark ? Colors.white38 : Colors.black12,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: isDark ? Colors.white24 : Colors.black12,
                            backgroundImage: authState.profileImagePath != null
                                ? FileImage(File(authState.profileImagePath!))
                                : null,
                            child: authState.profileImagePath == null
                                ? Icon(Icons.person, size: 50, color: textColor)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () => _showImagePickerOptions(l10n, textColor, subtextColor, isDark),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          authState.name?.isNotEmpty == true ? authState.name! : 'Farmer User',
                          style: TextStyle(color: textColor, fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: textColor.withValues(alpha: 0.7), size: 20),
                          tooltip: 'Edit Name / නම වෙනස් කරන්න',
                          onPressed: () => _showEditNameDialog(context, authState.name),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Info Section
                  _buildSectionTitle(l10n.personalDetails, textColor),
                  const SizedBox(height: 12),
                  GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.phone_rounded,
                          l10n.phoneNumber,
                          authState.phoneNumber ?? l10n.notProvided,
                          textColor,
                          subtextColor,
                        ),
                        Divider(color: isDark ? Colors.white12 : Colors.black12, height: 24),
                        _buildInfoRow(
                          Icons.location_on_rounded,
                          l10n.location,
                          userLocationAsync.value?.displayName ?? 'Detecting location...',
                          textColor,
                          subtextColor,
                          trailing: IconButton(
                            icon: const Icon(Icons.my_location_rounded, size: 20),
                            tooltip: 'Detect Location / ස්ථානය සොයන්න',
                            onPressed: () async {
                              await ref.read(userLocationProvider.notifier).refreshLocation();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Location updated successfully!')),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings Section
                  _buildSectionTitle(l10n.appSettings, textColor),
                  const SizedBox(height: 12),
                  GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Theme Mode Switcher Row
                        _buildActionRow(
                          context,
                          themeMode == ThemeMode.dark
                              ? Icons.dark_mode_rounded
                              : (themeMode == ThemeMode.light
                                  ? Icons.light_mode_rounded
                                  : Icons.brightness_auto_rounded),
                          locale.languageCode == 'si'
                              ? 'තේමාව (Theme)'
                              : (locale.languageCode == 'ta' ? 'தீம் (Theme)' : 'Theme Mode'),
                          _getThemeModeName(themeMode, locale.languageCode),
                          textColor,
                          subtextColor,
                          iconColor: themeMode == ThemeMode.light
                              ? Colors.amber
                              : (themeMode == ThemeMode.dark ? Colors.tealAccent : Colors.blueAccent),
                          onTap: () => _showThemeModeDialog(context, themeMode, locale.languageCode, textColor, subtextColor, isDark),
                        ),
                        Divider(color: isDark ? Colors.white12 : Colors.black12, height: 24),

                        // Language Row
                        _buildActionRow(
                          context,
                          Icons.language_rounded,
                          l10n.language,
                          _getLanguageName(locale.languageCode, l10n),
                          textColor,
                          subtextColor,
                          iconColor: Theme.of(context).colorScheme.primary,
                          onTap: () => _showLanguageDialog(context, l10n, locale.languageCode, textColor, subtextColor, isDark),
                        ),
                        Divider(color: isDark ? Colors.white12 : Colors.black12, height: 24),

                        // About App Row
                        _buildActionRow(
                          context,
                          Icons.info_outline_rounded,
                          l10n.aboutApp,
                          'Version 1.0.0 (Offline-First AI)',
                          textColor,
                          subtextColor,
                          iconColor: Colors.purpleAccent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Logout Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      l10n.logout,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
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

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color subtextColor, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: subtextColor, fontSize: 13)),
              const SizedBox(height: 3),
              Text(value, style: TextStyle(color: textColor, fontSize: 15.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    IconData icon,
    String label,
    String subtitle,
    Color textColor,
    Color subtextColor, {
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final effectiveColor = iconColor ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label settings coming soon')),
            );
          },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: effectiveColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: textColor, fontSize: 15.5, fontWeight: FontWeight.w600)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: subtextColor, fontSize: 13)),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: subtextColor.withValues(alpha: 0.6), size: 15),
          ],
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode, String lang) {
    if (lang == 'si') {
      switch (mode) {
        case ThemeMode.light:
          return 'ලා තේමාව (Light Mode)';
        case ThemeMode.dark:
          return 'අඳුරු තේමාව (Dark Mode)';
        case ThemeMode.system:
          return 'පද්ධතිය අනුව (System Default)';
      }
    } else if (lang == 'ta') {
      switch (mode) {
        case ThemeMode.light:
          return 'வெளிச்சம் (Light Mode)';
        case ThemeMode.dark:
          return 'இருள் (Dark Mode)';
        case ThemeMode.system:
          return 'கணினி இயல்புநிலை (System)';
      }
    } else {
      switch (mode) {
        case ThemeMode.light:
          return 'Light Mode';
        case ThemeMode.dark:
          return 'Dark Mode';
        case ThemeMode.system:
          return 'System Default';
      }
    }
  }

  void _showThemeModeDialog(
    BuildContext context,
    ThemeMode currentMode,
    String lang,
    Color textColor,
    Color subtextColor,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GlassContainer(
          borderRadius: 28,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.brightness_6_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    lang == 'si'
                        ? 'තේමාව තෝරන්න (Theme Mode)'
                        : (lang == 'ta' ? 'தீம் அமைப்புகள்' : 'Select Theme Mode'),
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Light Mode Option
              _buildThemeOptionTile(
                context,
                title: lang == 'si' ? 'ලා තේමාව (Light Mode)' : 'Light Mode',
                subtitle: lang == 'si' ? 'දවල් කාලයට පහසු සුදු/ලා පැහැය' : 'Clean & bright interface for daytime',
                icon: Icons.light_mode_rounded,
                iconColor: Colors.amber,
                isSelected: currentMode == ThemeMode.light,
                textColor: textColor,
                subtextColor: subtextColor,
                isDark: isDark,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 10),

              // Dark Mode Option
              _buildThemeOptionTile(
                context,
                title: lang == 'si' ? 'අඳුරු තේමාව (Dark Mode)' : 'Dark Mode',
                subtitle: lang == 'si' ? 'ඇසට පහසු නවීන අඳුරු/Obsidian පැහැය' : 'Sleek dark obsidian look, easy on eyes',
                icon: Icons.dark_mode_rounded,
                iconColor: Colors.tealAccent,
                isSelected: currentMode == ThemeMode.dark,
                textColor: textColor,
                subtextColor: subtextColor,
                isDark: isDark,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 10),

              // System Default Option
              _buildThemeOptionTile(
                context,
                title: lang == 'si' ? 'පද්ධතිය අනුව (System Default)' : 'System Default',
                subtitle: lang == 'si' ? 'දුරකථනයේ තේමාව අනුව ස්වයංක්‍රීයව' : 'Match device OS settings automatically',
                icon: Icons.brightness_auto_rounded,
                iconColor: Colors.blueAccent,
                isSelected: currentMode == ThemeMode.system,
                textColor: textColor,
                subtextColor: subtextColor,
                isDark: isDark,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOptionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required Color textColor,
    required Color subtextColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: subtextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 22)
            else
              Icon(Icons.circle_outlined, color: subtextColor.withValues(alpha: 0.4), size: 22),
          ],
        ),
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

  void _showLanguageDialog(
    BuildContext context,
    AppLocalizations l10n,
    String currentCode,
    Color textColor,
    Color subtextColor,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.languageSettings,
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildLanguageTile('English', 'en', currentCode == 'en', textColor, subtextColor, isDark, () {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.pop(context);
              }),
              const SizedBox(height: 8),
              _buildLanguageTile('සිංහල (Sinhala)', 'si', currentCode == 'si', textColor, subtextColor, isDark, () {
                ref.read(localeProvider.notifier).setLocale(const Locale('si'));
                Navigator.pop(context);
              }),
              const SizedBox(height: 8),
              _buildLanguageTile('தமிழ் (Tamil)', 'ta', currentCode == 'ta', textColor, subtextColor, isDark, () {
                ref.read(localeProvider.notifier).setLocale(const Locale('ta'));
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(
    String name,
    String code,
    bool isSelected,
    Color textColor,
    Color subtextColor,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
