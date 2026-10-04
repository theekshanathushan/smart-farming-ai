import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../data/pest_database.dart';
import '../data/pest_ai_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../../../core/widgets/glass_container.dart';

class KnowledgeBaseScreen extends ConsumerStatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  ConsumerState<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends ConsumerState<KnowledgeBaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCropFilter = 'All';

  final List<String> _cropFilters = [
    'All',
    'Paddy (වී)',
    'Tomato (තක්කාලි)',
    'Chilli (මිරිස්)',
    'Corn (බඩඉරිඟු)',
    'Eggplant (වම්බටු)',
    'Potato (අර්තාපල්)',
    'Banana (කෙසෙල්)',
    'Papaya (පැපොල්)',
    'Cucurbits (පිපිඤ්ඤා/වට්ටක්කා)',
    'Onion (ලූනු)',
    'Coconut (පොල්)',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PestDisease> _getFilteredPests() {
    final query = _searchController.text.trim().toLowerCase();
    return PestDatabase.pests.where((pest) {
      final matchesFilter = _selectedCropFilter == 'All' ||
          pest.crop.toLowerCase().contains(_selectedCropFilter.toLowerCase()) ||
          pest.name.toLowerCase().contains(_selectedCropFilter.toLowerCase());

      if (!matchesFilter) return false;

      if (query.isEmpty) return true;

      return pest.name.toLowerCase().contains(query) ||
          pest.scientificName.toLowerCase().contains(query) ||
          pest.crop.toLowerCase().contains(query) ||
          pest.symptoms.toLowerCase().contains(query) ||
          pest.prevention.toLowerCase().contains(query);
    }).toList();
  }

  void _openAiPestDoctor(BuildContext context, [String? prefillCrop]) {
    final cropInputController = TextEditingController(text: prefillCrop ?? '');
    bool isGenerating = false;
    String? aiResponse;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void generateGuide() async {
              final crop = cropInputController.text.trim();
              if (crop.isEmpty) return;

              setModalState(() {
                isGenerating = true;
                errorMessage = null;
                aiResponse = null;
              });

              try {
                final currentLang = ref.read(localeProvider).languageCode;
                final aiService = ref.read(pestAiServiceProvider);
                final result = await aiService.generatePestGuideForCrop(
                  cropOrPestName: crop,
                  language: currentLang,
                );
                if (mounted) {
                  setModalState(() {
                    isGenerating = false;
                    aiResponse = result;
                  });
                }
              } catch (e) {
                if (mounted) {
                  setModalState(() {
                    isGenerating = false;
                    errorMessage = 'Failed to generate AI guide: $e';
                  });
                }
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: BoxDecoration(
                color: const Color(0xFF141E15),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0, bottom: 8.0),
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.greenAccent, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Crop Pest & Disease Doctor',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Instant comprehensive protection guide for ANY crop',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(sheetCtx),
                        )
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12),

                  // Search input bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cropInputController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter any crop (e.g. Carrot, Passion Fruit, කෙසෙල්)...',
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.08),
                              prefixIcon: const Icon(Icons.grass, color: Colors.greenAccent, size: 20),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => generateGuide(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: isGenerating ? null : generateGuide,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: isGenerating
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Search AI', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  // Quick Suggestion Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Carrot (කැරට්)',
                          'Passion Fruit (වැල් දොඩම්)',
                          'Dragon Fruit',
                          'Manioc (මඤ්ඤොක්කා)',
                          'Okra (බණ්ඩක්කා)',
                          'Betel (බුලත්)',
                          'Cardamom (එනසාල්)',
                        ].map((suggestion) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                            child: ActionChip(
                              label: Text(suggestion, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                              backgroundColor: Colors.white.withValues(alpha: 0.06),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                              onPressed: () {
                                cropInputController.text = suggestion.split(' (').first;
                                generateGuide();
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Results Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: isGenerating
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(color: Colors.greenAccent),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Consulting AI Crop Protection Model for "${cropInputController.text}"...',
                                    style: const TextStyle(color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Generating symptoms, organic remedies & chemical dosages...',
                                    style: TextStyle(color: Colors.white38, fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          : errorMessage != null
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                                      const SizedBox(height: 12),
                                      Text(errorMessage!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                                      const SizedBox(height: 16),
                                      ElevatedButton(onPressed: generateGuide, child: const Text('Try Again')),
                                    ],
                                  ),
                                )
                              : aiResponse != null
                                  ? Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.white12),
                                            ),
                                            child: SingleChildScrollView(
                                              child: MarkdownBody(
                                                data: aiResponse!,
                                                styleSheet: MarkdownStyleSheet(
                                                  p: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                                                  h1: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                                                  h2: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                                                  h3: const TextStyle(color: Colors.lightGreenAccent, fontSize: 15, fontWeight: FontWeight.bold),
                                                  strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  listBullet: const TextStyle(color: Colors.greenAccent),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        FilledButton.icon(
                                          onPressed: () {
                                            Navigator.pop(sheetCtx);
                                            final currentLang = ref.read(localeProvider).languageCode;
                                            String chatPrompt;
                                            if (currentLang == 'si') {
                                              chatPrompt = '${cropInputController.text} බෝගයේ පළිබෝධ හා රෝග පාලනය පිළිබඳව වැඩිදුර විස්තර සාකච්ඡා කරමු.';
                                            } else {
                                              chatPrompt = 'I want in-depth expert advice on pest and disease control for ${cropInputController.text}.';
                                            }
                                            context.push('/chat', extra: chatPrompt);
                                          },
                                          icon: const Icon(Icons.chat_bubble_outline),
                                          label: const Text('Chat with AgriAI about this Crop'),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.greenAccent.shade700,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(double.infinity, 48),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.psychology_outlined, color: Colors.greenAccent.withValues(alpha: 0.4), size: 64),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Type any crop name above to generate\ncomplete AI pest & disease guidelines.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.white54, fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPests = _getFilteredPests();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pest & Disease Guide', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.greenAccent),
            tooltip: 'Ask AI Pest Doctor',
            onPressed: () => _openAiPestDoctor(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedFarmBackground()),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top AI Doctor Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: () => _openAiPestDoctor(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.greenAccent.shade700, Colors.teal.shade800],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Ask AI Pest Doctor',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    SizedBox(width: 6),
                                    Badge(
                                      label: Text('AI LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      backgroundColor: Colors.greenAccent,
                                      textColor: Colors.black,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Generate customized pest & disease advice for ANY crop',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search pest, disease, or crop (e.g. Rice, Blast, මිරිස්)...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.35),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                    ),
                  ),
                ),

                // Category Filter Chips
                SizedBox(
                  height: 46,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _cropFilters.length,
                    itemBuilder: (context, index) {
                      final filter = _cropFilters[index];
                      final isSelected = _selectedCropFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: Colors.greenAccent.shade700,
                          backgroundColor: Colors.black.withValues(alpha: 0.25),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedCropFilter = filter);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Pest List
                Expanded(
                  child: filteredPests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off, color: Colors.white38, size: 54),
                              const SizedBox(height: 12),
                              Text(
                                'No offline entry found for "${_searchController.text}"',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () => _openAiPestDoctor(context, _searchController.text),
                                icon: const Icon(Icons.auto_awesome, color: Colors.greenAccent),
                                label: Text('Search AI for "${_searchController.text}"'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.greenAccent,
                                  side: const BorderSide(color: Colors.greenAccent),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredPests.length,
                          itemBuilder: (context, index) {
                            final pest = filteredPests[index];
                            return _buildPestCard(context, pest);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPestCard(BuildContext context, PestDisease pest) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassContainer(
        borderRadius: 18,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.push('/guide/${pest.id}'),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    pest.imageAsset,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 78,
                      height: 78,
                      color: Colors.grey.withValues(alpha: 0.3),
                      child: const Icon(Icons.bug_report, color: Colors.greenAccent, size: 38),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              pest.crop,
                              style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pest.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pest.name,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        pest.scientificName,
                        style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pest.symptoms,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 24.0, left: 8.0),
                  child: Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
