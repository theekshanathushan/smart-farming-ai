import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../data/pest_database.dart';
import '../data/pest_ai_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../../../core/widgets/glass_container.dart';

class PestDetailScreen extends ConsumerStatefulWidget {
  final String pestId;

  const PestDetailScreen({super.key, required this.pestId});

  @override
  ConsumerState<PestDetailScreen> createState() => _PestDetailScreenState();
}

class _PestDetailScreenState extends ConsumerState<PestDetailScreen> {
  bool _isLoadingAiAdvice = false;
  String? _aiProtocol;

  void _generateAiProtocol(PestDisease pest) async {
    setState(() {
      _isLoadingAiAdvice = true;
    });

    try {
      final currentLang = ref.read(localeProvider).languageCode;
      final aiService = ref.read(pestAiServiceProvider);
      final advice = await aiService.getInDepthPestAdvice(
        pestName: pest.name,
        symptoms: pest.symptoms,
        crop: pest.crop,
        language: currentLang,
      );
      if (mounted) {
        setState(() {
          _aiProtocol = advice;
          _isLoadingAiAdvice = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAiAdvice = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load AI protocol: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _askAgriAiInChat(PestDisease pest) {
    final currentLang = ref.read(localeProvider).languageCode;
    String prompt;
    if (currentLang == 'si') {
      prompt = 'මගේ ${pest.crop} වගාවේ හඳුනාගත් පළිබෝධ / රෝගය පිළිබඳ විස්තර:\n\n'
          '• රෝගය/කෘමියා: ${pest.name}\n'
          '• විද්‍යාත්මක නම: ${pest.scientificName}\n'
          '• රෝග ලක්ෂණ: ${pest.symptoms}\n\n'
          'කරුණාකර මෙම රෝගය/කෘමි හානිය පාලනය කිරීමට අවශ්‍ය කඩිනම් කාබනික හා රසායනික ප්‍රතිකාර, යෙදිය යුතු කෘමිනාශක/දිලීරනාශක මාත්‍රා සහ නැවත බෝවීම වැළැක්වීමේ ක්‍රම කරුණු වශයෙන් (Point by point) සවිස්තරාත්මකව පැහැදිලි කරන්න.';
    } else {
      prompt = 'I need emergency pest & disease management advice for ${pest.crop}:\n\n'
          '• Identified Pest / Disease: ${pest.name}\n'
          '• Scientific Name: ${pest.scientificName}\n'
          '• Symptoms: ${pest.symptoms}\n\n'
          'Please provide comprehensive, point-by-point instructions on immediate organic remedies, chemical dosages, application intervals, and long-term prevention.';
    }

    context.push('/chat', extra: prompt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final tagBg = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06);

    final pest = PestDatabase.pests.firstWhere(
      (p) => p.id == widget.pestId,
      orElse: () => PestDatabase.pests.first,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          pest.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      pest.imageAsset,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 220,
                        color: isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.shade200,
                        child: const Icon(Icons.bug_report, color: Colors.green, size: 90),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tag Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.greenAccent.withValues(alpha: 0.4) : Colors.green.shade400),
                        ),
                        child: Text(
                          pest.crop,
                          style: TextStyle(
                            color: isDark ? Colors.greenAccent : Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pest.category,
                          style: TextStyle(color: subtextColor, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _askAgriAiInChat(pest),
                          icon: const Icon(Icons.psychology, size: 18),
                          label: const Text('Chat with AgriAI', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.greenAccent.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: _isLoadingAiAdvice ? null : () => _generateAiProtocol(pest),
                        icon: _isLoadingAiAdvice
                            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.greenAccent : Colors.green.shade700))
                            : Icon(Icons.auto_awesome, color: isDark ? Colors.greenAccent : Colors.green.shade700, size: 18),
                        label: Text('AI In-Depth Plan', style: TextStyle(color: isDark ? Colors.greenAccent : Colors.green.shade700)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDark ? Colors.greenAccent : Colors.green.shade700),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),

                  // AI Generated Protocol (if generated)
                  if (_aiProtocol != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.green.shade400,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: isDark ? 0.15 : 0.1),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: isDark ? Colors.greenAccent : Colors.green.shade700, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'AI Live Treatment Protocol',
                                style: TextStyle(
                                  color: isDark ? Colors.greenAccent : Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(Icons.close, color: subtextColor, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => setState(() => _aiProtocol = null),
                              ),
                            ],
                          ),
                          Divider(color: isDark ? Colors.white12 : Colors.black12, height: 20),
                          MarkdownBody(
                            data: _aiProtocol!,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(color: textColor, fontSize: 14, height: 1.5),
                              h1: TextStyle(color: isDark ? Colors.greenAccent : Colors.green.shade800, fontSize: 16, fontWeight: FontWeight.bold),
                              h2: TextStyle(color: isDark ? Colors.greenAccent : Colors.green.shade800, fontSize: 15, fontWeight: FontWeight.bold),
                              h3: TextStyle(color: isDark ? Colors.lightGreenAccent : Colors.green.shade700, fontSize: 14, fontWeight: FontWeight.bold),
                              strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                              listBullet: TextStyle(color: isDark ? Colors.greenAccent : Colors.green.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  _buildSection(context, 'Scientific Name', pest.scientificName, Icons.science, Colors.cyan),
                  const SizedBox(height: 14),
                  _buildSection(context, 'Symptoms & Damage', pest.symptoms, Icons.warning_amber_rounded, Colors.orange),
                  const SizedBox(height: 14),
                  if (pest.organicControl.isNotEmpty) ...[
                    _buildSection(context, 'Organic & Biological Control', pest.organicControl, Icons.eco, Colors.green),
                    const SizedBox(height: 14),
                  ],
                  if (pest.chemicalControl.isNotEmpty) ...[
                    _buildSection(context, 'Recommended Chemical Control', pest.chemicalControl, Icons.medication_liquid_outlined, Colors.redAccent),
                    const SizedBox(height: 14),
                  ],
                  _buildSection(context, 'Field Prevention & Care', pest.prevention, Icons.shield_outlined, Colors.blue),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, IconData icon, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final contentColor = isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF334155);

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(color: contentColor, fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}
