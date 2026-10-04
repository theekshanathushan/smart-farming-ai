import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import '../data/agent_api_client.dart';
import '../../../core/utils/location_service.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/services/firebase_sync_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../../camera_scan/presentation/scan_controller.dart';
import '../../camera_scan/data/crop_disease_classifier.dart';
import 'package:geolocator/geolocator.dart';

final agentApiClientProvider = Provider((ref) => AgentApiClient());

class ChatMessage {
  final String text;
  final bool isUser;
  final String? imagePath;

  ChatMessage({required this.text, required this.isUser, this.imagePath});
}

class AiChatScreen extends ConsumerStatefulWidget {
  final String? initialMessage;
  final String? initialImagePath;

  const AiChatScreen({super.key, this.initialMessage, this.initialImagePath});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Position? _currentPosition;
  bool _isFetchingLocation = true;
  bool _initialSent = false;
  bool _recentScanDismissed = false;
  
  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      await _loadSavedMessages();
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
    if (!_initialSent && widget.initialMessage != null && widget.initialMessage!.trim().isNotEmpty) {
      _initialSent = true;
      _sendMessage(widget.initialMessage!.trim(), imagePath: widget.initialImagePath);
    }
  }

  @override
  void didUpdateWidget(covariant AiChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMessage != null &&
        widget.initialMessage!.trim().isNotEmpty &&
        widget.initialMessage != oldWidget.initialMessage) {
      _sendMessage(widget.initialMessage!.trim(), imagePath: widget.initialImagePath);
    }
  }

  Future<void> _loadSavedMessages() async {
    final db = ref.read(databaseProvider);
    final savedMessages = await db.getAllChatMessages();
    if (mounted && savedMessages.isNotEmpty) {
      setState(() {
        _messages.addAll(
          savedMessages.map(
            (entry) => ChatMessage(text: entry.message, isUser: entry.isUser),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  Future<void> _fetchLocation() async {
    final locationService = ref.read(locationServiceProvider);
    final position = await locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _currentPosition = position;
        _isFetchingLocation = false;
      });
    }
  }
  
  void _sendMessage([String? promptText, {String? imagePath}]) async {
    final text = (promptText ?? _controller.text).trim();
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, imagePath: imagePath));
      _isLoading = true;
      // Add a placeholder for the AI response
      _messages.add(ChatMessage(text: '', isUser: false));
    });
    
    if (promptText == null) {
      _controller.clear();
    }
    _scrollToBottom();

    final db = ref.read(databaseProvider);
    final firebaseSync = ref.read(firebaseSyncServiceProvider);

    // Persist user prompt to local database & sync to Firebase
    try {
      await db.insertChatMessage(
        ChatMessagesCompanion(
          message: Value(text),
          isUser: const Value(true),
          timestamp: Value(DateTime.now()),
        ),
      );
      firebaseSync.syncChatMessage(
        message: text,
        isUser: true,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Failed to persist user chat message: $e');
    }
    
    final apiClient = ref.read(agentApiClientProvider);
    
    try {
      final currentLang = ref.read(localeProvider).languageCode;
      final stream = apiClient.streamChatAdvice(
        message: text,
        language: currentLang,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
      );
      
      await for (final chunk in stream) {
        if (!mounted) return;
        setState(() {
          // Append the chunk to the last message
          final lastIndex = _messages.length - 1;
          final currentText = _messages[lastIndex].text;
          _messages[lastIndex] = ChatMessage(
            text: currentText + chunk, 
            isUser: false
          );
        });
        _scrollToBottom();
      }

      // Persist completed AI response to local database & sync to Firebase
      final lastIndex = _messages.length - 1;
      final responseText = _messages[lastIndex].text.trim();
      if (responseText.isNotEmpty) {
        try {
          await db.insertChatMessage(
            ChatMessagesCompanion(
              message: Value(responseText),
              isUser: const Value(false),
              timestamp: Value(DateTime.now()),
            ),
          );
          firebaseSync.syncChatMessage(
            message: responseText,
            isUser: false,
            timestamp: DateTime.now(),
          );
        } catch (e) {
          debugPrint('Failed to persist AI chat response: $e');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final lastIndex = _messages.length - 1;
        _messages[lastIndex] = ChatMessage(
          text: 'Error: Failed to fetch response. Please try again.', 
          isUser: false
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ask AgriAI'),
            if (_isFetchingLocation) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ] else if (_currentPosition != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.secondary),
            ],
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Chat History',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Chat History'),
                    content: const Text('Are you sure you want to delete all saved conversations?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  await ref.read(databaseProvider).clearChatHistory();
                  setState(() {
                    _messages.clear();
                  });
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final scanState = ref.watch(scanControllerProvider);
              if (!_recentScanDismissed &&
                  scanState.result != null &&
                  !scanState.result!.label.contains('Unrecognized')) {
                return _buildRecentScanBanner(context, scanState);
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                
                // Show loading indicator if it's the last message and empty
                if (!message.isUser && message.text.isEmpty && _isLoading && index == _messages.length - 1) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: _BreathingSproutIndicator(),
                    ),
                  );
                }

                if (!message.isUser && message.text.isEmpty) {
                  return const SizedBox.shrink();
                }

                final isUser = message.isUser;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.82 : 0.88),
                    ),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 20),
                      ),
                      border: isUser
                          ? null
                          : Border.all(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              width: 1,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (message.imagePath != null && File(message.imagePath!).existsSync()) ...[
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: InteractiveViewer(
                                      child: Image.file(File(message.imagePath!)),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(message.imagePath!),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        isUser
                            ? Text(
                                message.text,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  height: 1.4,
                                ),
                              )
                            : MarkdownBody(
                                data: message.text,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    height: 1.6,
                                    fontSize: 15,
                                  ),
                                  h1: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                    height: 1.4,
                                  ),
                                  h2: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                    height: 1.4,
                                  ),
                                  h3: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                    height: 1.4,
                                  ),
                                  strong: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  listBullet: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  listBulletPadding: const EdgeInsets.only(right: 6),
                                  blockSpacing: 10.0,
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined, color: Theme.of(context).colorScheme.primary),
                    tooltip: 'Scan Leaf & Ask AI',
                    onPressed: _isLoading ? null : _scanLeafFromChat,
                  ),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Ask about your crops...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _isLoading ? null : () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScanBanner(BuildContext context, ScanState scanState) {
    final result = scanState.result!;
    final condition = result.diseaseName.isNotEmpty ? result.diseaseName : result.label;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (scanState.imagePath != null && File(scanState.imagePath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(scanState.imagePath!),
                width: 46,
                height: 46,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.eco, color: Theme.of(context).colorScheme.primary),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recent Scan Detected',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  condition,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _recentScanDismissed = true;
              });
              final currentLang = ref.read(localeProvider).languageCode;
              final isDiseased = !result.isHealthy && !result.label.contains('Unrecognized');
              String prompt;
              if (isDiseased) {
                if (currentLang == 'si') {
                  prompt = 'මගේ බෝගයේ කොළ ස්කෑන් කළ විට හඳුනාගත් රෝග විස්තර පහත දැක්වේ:\n\n'
                      '• හඳුනාගත් රෝගය: $condition\n'
                      '• බරපතලකම: ${result.severity}\n'
                      '• ආකෘති විශ්වාසනීයත්වය: ${(result.confidence * 100).toStringAsFixed(1)}%\n'
                      '${result.treatmentPlan.isNotEmpty ? '• මූලික උපදෙස්: ${result.treatmentPlan}\n' : ''}\n'
                      'කරුණාකර මෙම රෝගය සුව කිරීමට අවශ්‍ය සවිස්තරාත්මක ප්‍රතිකාර හා වැළැක්වීමේ උපදෙස් කරුණු වශයෙන් ලබා දෙන්න.';
                } else if (currentLang == 'ta') {
                  prompt = 'எனது பயிரின் இலை ஸ்கேன் செய்யப்பட்டதன் முடிவுகள்:\n\n'
                      '• நோய்: $condition\n'
                      '• தீவிரம்: ${result.severity}\n'
                      '• மாதிரி துல்லியம்: ${(result.confidence * 100).toStringAsFixed(1)}%\n\n'
                      'தயவுசெய்து இந்த நோயைக் கட்டுப்படுத்த வழிகாட்டல்களை குறிப்புகளாக (Point by point) விளக்கவும்.';
                } else {
                  prompt = 'I scanned a crop leaf and the diagnosis returned the following details:\n\n'
                      '• Condition: $condition\n'
                      '• Severity: ${result.severity}\n'
                      '• Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%\n\n'
                      'Please provide point-by-point advice covering treatment, remedies, and prevention.';
                }
              } else {
                if (currentLang == 'si') {
                  prompt = 'මගේ බෝගය නිරෝගී (${result.label}) ලෙස ස්කෑන් කර ඇත. මෙම බෝගයේ නිරෝගීභාවය රැක ගැනීමට අවශ්‍ය උපදෙස් කරුණු වශයෙන් ලබා දෙන්න.';
                } else {
                  prompt = 'I scanned my crop leaf and it was identified as healthy (${result.label}). Please provide care tips to maximize yield.';
                }
              }
              _sendMessage(prompt, imagePath: scanState.imagePath);
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            child: const Text('Send to AI'),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _recentScanDismissed = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _scanLeafFromChat() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Scan Leaf for Instant AI Advice',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Capture or choose a photo of the affected plant leaf to send directly to AgriAI',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _processChatScan(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _processChatScan(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processChatScan(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
    if (image == null) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Analyzing leaf with AI...'),
          ],
        ),
        duration: Duration(seconds: 4),
      ),
    );

    try {
      final classifier = ref.read(cropDiseaseClassifierProvider);
      final results = await classifier.classifyImage(image.path);
      if (results.isEmpty) return;

      final result = results.first;
      final currentLang = ref.read(localeProvider).languageCode;
      final isDiseased = !result.isHealthy && !result.label.contains('Unrecognized');
      final condition = result.diseaseName.isNotEmpty ? result.diseaseName : result.label;

      String prompt;
      if (isDiseased) {
        if (currentLang == 'si') {
          prompt = 'මගේ බෝගයේ කොළ ස්කෑන් කළ විට හඳුනාගත් රෝග විස්තර පහත දැක්වේ:\n\n'
              '• හඳුනාගත් රෝගය: $condition\n'
              '• බරපතලකම (Severity): ${result.severity}\n'
              '• ආකෘති විශ්වාසනීයත්වය: ${(result.confidence * 100).toStringAsFixed(1)}%\n'
              '${result.treatmentPlan.isNotEmpty ? '• මූලික උපදෙස්: ${result.treatmentPlan}\n' : ''}\n'
              'කරුණාකර මෙම රෝගය සුව කිරීමට අවශ්‍ය සවිස්තරාත්මක ප්‍රතිකාර, ස්වාභාවික හා කාබනික ක්‍රම, සහ නැවත බෝවීම වැළැක්වීමේ පියවර කරුණු වශයෙන් (Point by point) පැහැදිලිව ලබා දෙන්න.';
        } else if (currentLang == 'ta') {
          prompt = 'எனது பயிரின் இலை ஸ்கேன் செய்யப்பட்டதன் முடிவுகள்:\n\n'
              '• கண்டறியப்பட்ட நோய்: $condition\n'
              '• தீவிரம்: ${result.severity}\n'
              '• மாதிரி துல்லியம்: ${(result.confidence * 100).toStringAsFixed(1)}%\n'
              '${result.treatmentPlan.isNotEmpty ? '• முதற்கட்ட சிகிச்சை: ${result.treatmentPlan}\n' : ''}\n'
              'தயவுசெய்து இந்த நோயைக் கட்டுப்படுத்த இயற்கை முறைகள், மருந்து பரிந்துரைகள் மற்றும் தடுப்பு வழிகளை குறிப்புகளாக (Point by point) தெளிவாக விளக்குங்கள்.';
        } else {
          prompt = 'I scanned a crop leaf and the diagnosis returned the following details:\n\n'
              '• Crop Condition / Disease: $condition\n'
              '• Severity: ${result.severity}\n'
              '• Model Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%\n'
              '${result.treatmentPlan.isNotEmpty ? '• Preliminary Treatment: ${result.treatmentPlan}\n' : ''}\n'
              'Please provide comprehensive, point-by-point advice covering:\n'
              '1. Diagnosis & Key Symptoms\n'
              '2. Causes & Environmental Factors\n'
              '3. Immediate Organic & Natural Remedies\n'
              '4. Chemical Controls or Fertilizer Adjustments with recommended dosages\n'
              '5. Long-term Prevention & Field Care';
        }
      } else {
        if (currentLang == 'si') {
          prompt = 'මගේ බෝගය නිරෝගී (${result.label}) ලෙස ස්කෑන් කර ඇත. මෙම බෝගයේ නිරෝගීභාවය රැකගෙන උපරිම අස්වැන්නක් ලබා ගැනීමට අවශ්‍ය ජල සම්පාදනය, පොහොර යෙදීම සහ රැකවරණ උපදෙස් කරුණු වශයෙන් (Point by point) පැහැදිලි කරන්න.';
        } else if (currentLang == 'ta') {
          prompt = 'எனது பயிர் ஆரோக்கியமானது (${result.label}) என உறுதி செய்யப்பட்டுள்ளது. இதன் ஆரோக்கியத்தைப் பேணவும் அதிக விளைச்சலைப் பெறவும் தேவையான ஆலோசனைகளை குறிப்புகளாக (Point by point) விளக்கவும்.';
        } else {
          prompt = 'I scanned my crop leaf and it was identified as healthy (${result.label}). Please provide point-by-point advice on optimal fertilizers, irrigation schedule, and preventive care to maximize healthy yield.';
        }
      }

      _sendMessage(prompt, imagePath: image.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to analyze image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _BreathingSproutIndicator extends StatefulWidget {
  @override
  State<_BreathingSproutIndicator> createState() => _BreathingSproutIndicatorState();
}

class _BreathingSproutIndicatorState extends State<_BreathingSproutIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(Icons.eco, color: Theme.of(context).colorScheme.secondary, size: 24),
          );
        },
      ),
    );
  }
}
