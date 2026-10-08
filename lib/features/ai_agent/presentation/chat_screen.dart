import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

import '../data/agent_api_client.dart';
import '../domain/chat_session.dart';
import '../../../core/utils/location_service.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/services/firebase_sync_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../camera_scan/presentation/scan_controller.dart';
import '../../camera_scan/data/crop_disease_classifier.dart';

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
  final String? initialSessionId;
  final String? initialSessionTitle;
  final String? initialCropType;

  const AiChatScreen({
    super.key,
    this.initialMessage,
    this.initialImagePath,
    this.initialSessionId,
    this.initialSessionTitle,
    this.initialCropType,
  });

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Position? _currentPosition;
  bool _isFetchingLocation = true;
  bool _initialSent = false;
  bool _recentScanDismissed = false;

  late String _currentSessionId;
  String? _currentCropType;
  String _currentSessionTitle = 'Ask AgriAI';

  @override
  void initState() {
    super.initState();
    _currentSessionId = widget.initialSessionId ?? const Uuid().v4();
    _currentCropType = widget.initialCropType ?? widget.initialSessionTitle;
    _currentSessionTitle = widget.initialSessionTitle ?? 'Ask AgriAI';
    _fetchLocation();
    _initChat();
  }

  Future<void> _initChat() async {
    final db = ref.read(databaseProvider);

    if (widget.initialMessage != null && widget.initialMessage!.trim().isNotEmpty) {
      _currentSessionId = widget.initialSessionId ?? const Uuid().v4();
      _currentCropType = widget.initialCropType ?? widget.initialSessionTitle;
      _currentSessionTitle = widget.initialSessionTitle ?? _truncateTitle(widget.initialMessage!.trim());
      if (!_initialSent) {
        _initialSent = true;
        _sendMessage(widget.initialMessage!.trim(), widget.initialImagePath);
      }
    } else if (widget.initialSessionId != null) {
      _currentSessionId = widget.initialSessionId!;
      _currentCropType = widget.initialCropType ?? widget.initialSessionTitle;
      _currentSessionTitle = widget.initialSessionTitle ?? 'Ask AgriAI';
      await _loadMessagesForSession(_currentSessionId);
    } else {
      // Load recent session if available, or start fresh
      try {
        final sessions = await db.getChatSessionSummaries();
        if (sessions.isNotEmpty) {
          final latest = sessions.first;
          _currentSessionId = latest.sessionId;
          _currentCropType = latest.title;
          _currentSessionTitle = latest.title;
          await _loadMessagesForSession(latest.sessionId);
        } else {
          _currentSessionId = const Uuid().v4();
          _currentCropType = null;
          _currentSessionTitle = 'Ask AgriAI';
          if (mounted) {
            setState(() {
              _messages.clear();
            });
          }
        }
      } catch (e) {
        debugPrint('Error loading initial session: $e');
        if (mounted) {
          setState(() {
            _messages.clear();
          });
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant AiChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMessage != null &&
        widget.initialMessage!.trim().isNotEmpty &&
        widget.initialMessage != oldWidget.initialMessage) {
      if (widget.initialSessionId != null && widget.initialSessionId != _currentSessionId) {
        _currentSessionId = widget.initialSessionId!;
        _currentCropType = widget.initialCropType ?? widget.initialSessionTitle;
        _currentSessionTitle = widget.initialSessionTitle ?? _truncateTitle(widget.initialMessage!.trim());
        _messages.clear();
      }
      _sendMessage(widget.initialMessage!.trim(), widget.initialImagePath);
    }
  }

  Future<void> _loadMessagesForSession(String sessionId) async {
    final db = ref.read(databaseProvider);
    try {
      final savedMessages = await db.getChatMessagesForSession(sessionId);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(
            savedMessages.map(
              (entry) => ChatMessage(text: entry.message, isUser: entry.isUser),
            ),
          );
          if (savedMessages.isNotEmpty) {
            final cropEntry = savedMessages.firstWhere(
              (m) => m.cropType != null && m.cropType!.trim().isNotEmpty,
              orElse: () => savedMessages.first,
            );
            if (cropEntry.cropType != null && cropEntry.cropType!.trim().isNotEmpty) {
              _currentCropType = cropEntry.cropType;
              _currentSessionTitle = cropEntry.cropType!;
            } else {
              _currentCropType = null;
              final firstUser = savedMessages.firstWhere(
                (m) => m.isUser && m.message.trim().isNotEmpty,
                orElse: () => savedMessages.first,
              );
              _currentSessionTitle = _truncateTitle(firstUser.message);
            }
          } else {
            _currentCropType = null;
            final currentLang = ref.read(localeProvider).languageCode;
            _currentSessionTitle = currentLang == 'si'
                ? 'අලුත් සාකච්ඡාවක්'
                : (currentLang == 'ta' ? 'புதிய அரட்டை' : 'New Chat');
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error loading chat session messages: $e');
    }
  }

  void _startNewChat() {
    final currentLang = ref.read(localeProvider).languageCode;
    setState(() {
      _currentSessionId = const Uuid().v4();
      _currentSessionTitle = currentLang == 'si'
          ? 'අලුත් සාකච්ඡාවක්'
          : (currentLang == 'ta' ? 'புதிய அரட்டை' : 'New Chat');
      _currentCropType = null;
      _messages.clear();
      _initialSent = false;
      _isLoading = false;
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _switchSession(ChatSessionSummary session) async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    if (_currentSessionId == session.sessionId) return;

    setState(() {
      _currentSessionId = session.sessionId;
      _currentSessionTitle = session.title;
      _currentCropType = null;
      _messages.clear();
      _isLoading = false;
    });

    await _loadMessagesForSession(session.sessionId);
  }

  String _truncateTitle(String text) {
    String clean = text.trim();
    if (clean.startsWith('[Farmer Context:') && clean.contains('Question:')) {
      clean = clean.split('Question:').last.trim();
    }
    if (clean.contains('\n')) {
      clean = clean.split('\n').first.trim();
    }
    if (clean.length > 34) {
      return '${clean.substring(0, 32)}...';
    }
    return clean.isEmpty ? 'Farming Chat' : clean;
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

  void _sendMessage([String? promptText, String? imagePath]) async {
    final text = (promptText ?? _controller.text).trim();
    if (text.isEmpty) return;

    // Update title if this is the first message in this session
    if (_messages.isEmpty) {
      setState(() {
        if (_currentCropType != null && _currentCropType!.trim().isNotEmpty) {
          _currentSessionTitle = _currentCropType!;
        } else {
          _currentSessionTitle = _truncateTitle(text);
        }
      });
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, imagePath: imagePath));
      _isLoading = true;
      // Placeholder for AI response
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
          sessionId: Value(_currentSessionId),
          cropType: Value(_currentCropType),
        ),
      );
      firebaseSync.syncChatMessage(
        message: text,
        isUser: true,
        timestamp: DateTime.now(),
        sessionId: _currentSessionId,
      );
    } catch (e) {
      debugPrint('Failed to persist user chat message: $e');
    }

    final apiClient = ref.read(agentApiClientProvider);

    try {
      final currentLang = ref.read(localeProvider).languageCode;

      // Extract preceding conversation turns for multi-turn conversational context
      final historyTurns = _messages
          .take(_messages.length - 2)
          .where((m) => m.text.trim().isNotEmpty)
          .map((m) => AgentChatTurn(text: m.text, isUser: m.isUser))
          .toList();

      final stream = apiClient.streamChatAdvice(
        message: text,
        language: currentLang,
        conversationHistory: historyTurns,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
      );

      await for (final chunk in stream) {
        if (!mounted) return;
        setState(() {
          final lastIndex = _messages.length - 1;
          final currentText = _messages[lastIndex].text;
          _messages[lastIndex] = ChatMessage(
            text: currentText + chunk,
            isUser: false,
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
              sessionId: Value(_currentSessionId),
              cropType: Value(_currentCropType),
            ),
          );
          firebaseSync.syncChatMessage(
            message: responseText,
            isUser: false,
            timestamp: DateTime.now(),
            sessionId: _currentSessionId,
          );
        } catch (e) {
          debugPrint('Failed to persist AI chat response: $e');
        }
      } else {
        setState(() {
          _messages[lastIndex] = ChatMessage(
            text: '⚠️ AI මගින් ප්‍රතිචාරයක් නොලැබුණි (Empty response received). කරුණාකර ප්‍රශ්නය නැවත යොමු කරන්න.',
            isUser: false,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final lastIndex = _messages.length - 1;
        _messages[lastIndex] = ChatMessage(
          text: '⚠️ AI ප්‍රතිචාර ලබාගැනීමේදී දෝෂයක් සිදුවිය (Error):\n\n$e\n\nකරුණාකර ඔබගේ අන්තර්ජාල සම්බන්ධතාවය හෝ API Key එක පරීක්ෂා කර නැවත උත්සාහ කරන්න.',
          isUser: false,
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
    ref.listen(authProvider, (previous, next) {
      if (previous?.phoneNumber != next.phoneNumber) {
        _initChat();
      }
    });

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLang = ref.watch(localeProvider).languageCode;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.surface,
      drawer: _buildChatGPTDrawer(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          tooltip: currentLang == 'si'
              ? 'සාකච්ඡා ඉතිහාසය'
              : (currentLang == 'ta' ? 'அரட்டை வரலாறு' : 'Chat History'),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _currentSessionTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_isFetchingLocation) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                ] else if (_currentPosition != null) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.location_on, size: 14, color: colorScheme.secondary),
                ],
              ],
            ),
            Text(
              currentLang == 'si'
                  ? 'AgriAI • කෘෂිකාර්මික උපදෙස් පමණි'
                  : (currentLang == 'ta'
                      ? 'AgriAI • விவசாயம் மட்டுமே'
                      : 'AgriAI • Agriculture Only'),
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: currentLang == 'si'
                ? 'අලුත් සාකච්ඡාවක්'
                : (currentLang == 'ta' ? 'புதிய அரட்டை' : 'New Chat'),
            onPressed: _startNewChat,
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: currentLang == 'si'
                ? 'සාකච්ඡා ඉතිහාසය'
                : (currentLang == 'ta' ? 'வரலாற்றைக் காண்க' : 'View History'),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
            child: _messages.isEmpty
                ? _buildEmptyWelcomeState(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                                ? colorScheme.primary
                                : colorScheme.surface,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isUser ? 20 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 20),
                            ),
                            border: isUser
                                ? null
                                : Border.all(
                                    color: colorScheme.primary.withValues(alpha: 0.15),
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
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: colorScheme.onPrimary,
                                        height: 1.4,
                                      ),
                                    )
                                  : MarkdownBody(
                                      data: message.text,
                                      selectable: true,
                                      styleSheet: MarkdownStyleSheet(
                                        p: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                          height: 1.6,
                                          fontSize: 15,
                                        ),
                                        h1: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                          height: 1.4,
                                        ),
                                        h2: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                          height: 1.4,
                                        ),
                                        h3: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                          height: 1.4,
                                        ),
                                        strong: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                        listBullet: TextStyle(
                                          color: colorScheme.primary,
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
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
                    tooltip: currentLang == 'si'
                        ? 'කොළයක් ස්කෑන් කර අසන්න'
                        : (currentLang == 'ta'
                            ? 'இலையை ஸ்கேன் செய்து கேளுங்கள்'
                            : 'Scan Leaf & Ask AI'),
                    onPressed: _isLoading ? null : _scanLeafFromChat,
                  ),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: currentLang == 'si'
                            ? 'වගාවන්, පොහොර, රෝග ගැන අසන්න...'
                            : (currentLang == 'ta'
                                ? 'பயிர்கள், பூச்சிகள், உரங்கள் பற்றி கேளுங்கள்...'
                                : 'Ask about crops, pests, fertilizers...'),
                        hintStyle: TextStyle(color: colorScheme.primary.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
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
                    backgroundColor: colorScheme.secondary,
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

  /// ChatGPT style Drawer with session history & New Chat button
  Widget _buildChatGPTDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final db = ref.read(databaseProvider);
    final currentLang = ref.watch(localeProvider).languageCode;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.eco_rounded, color: colorScheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentLang == 'si' ? 'AgriAI සාකච්ඡා' : 'AgriAI Conversations',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currentLang == 'si' ? 'කෘෂිකාර්මික උපදේශක' : 'Smart Farming AI',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Prominent "+ New Chat" Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: _startNewChat,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(
                    currentLang == 'si' ? '+ අලුත් සාකච්ඡාවක්' : '+ New Conversation',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              ),
            ),

            const Divider(height: 16),

            // History Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    currentLang == 'si' ? 'පෙර සාකච්ඡා (History)' : 'Recent Chats',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Sessions List Stream
            Expanded(
              child: StreamBuilder<List<ChatSessionSummary>>(
                stream: db.watchChatSessionSummaries(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sessions = snapshot.data ?? [];
                  if (sessions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              currentLang == 'si'
                                  ? 'තවමත් සාකච්ඡා නොමැත.\nනව සාකච්ඡාවක් ආරම්භ කරන්න.'
                                  : 'No conversations yet.\nStart asking your farming queries!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final isSelected = session.sessionId == _currentSessionId;

                      return Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: colorScheme.primary.withValues(alpha: 0.4))
                              : null,
                        ),
                        child: ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          leading: Icon(
                            isSelected ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: isSelected ? colorScheme.primary : Colors.grey.shade600,
                          ),
                          title: Text(
                            session.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            _formatTimestamp(session.lastTimestamp),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            color: Colors.grey.shade500,
                            tooltip: 'Delete Chat',
                            onPressed: () => _confirmDeleteSession(session),
                          ),
                          onTap: () => _switchSession(session),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Footer / Clear all option
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 20),
                title: Text(
                  currentLang == 'si' ? 'සියලු සාකච්ඡා මකන්න' : 'Clear All Conversations',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: _confirmClearAllHistory,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (now.year == time.year && now.month == time.month && now.day == time.day) {
      return DateFormat('h:mm a').format(time);
    } else if (now.year == time.year && now.month == time.month && now.day - time.day == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat('EEE, h:mm a').format(time);
    } else {
      return DateFormat('MMM d, yyyy').format(time);
    }
  }

  Future<void> _confirmDeleteSession(ChatSessionSummary session) async {
    final currentLang = ref.read(localeProvider).languageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(currentLang == 'si' ? 'සාකච්ඡාව මකන්නද?' : 'Delete Conversation?'),
        content: Text(
          currentLang == 'si'
              ? '"${session.title}" සාකච්ඡාව සම්පූර්ණයෙන්ම මකා දැමීමට ඔබට අවශ්‍යද?'
              : 'Are you sure you want to delete "${session.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(currentLang == 'si' ? 'අවලංගු කරන්න' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              currentLang == 'si' ? 'මකන්න' : 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final db = ref.read(databaseProvider);
      await db.deleteChatSession(session.sessionId);

      // If the deleted session is the currently active one, start a fresh new chat
      if (_currentSessionId == session.sessionId) {
        _startNewChat();
      }
    }
  }

  Future<void> _confirmClearAllHistory() async {
    final currentLang = ref.read(localeProvider).languageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(currentLang == 'si' ? 'සියලු සාකච්ඡා මකන්නද?' : 'Clear All Conversations?'),
        content: Text(
          currentLang == 'si'
              ? 'ඔබගේ සියලුම පැරණි කෘෂි සාකච්ඡා ඉතිහාසය මකා දැමීමට ඔබට සහතිකද?'
              : 'Are you sure you want to delete all saved conversations? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(currentLang == 'si' ? 'අවලංගු කරන්න' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              currentLang == 'si' ? 'ඔව්, මකන්න' : 'Clear All',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(databaseProvider).clearChatHistory();
      _startNewChat();
    }
  }

  /// ChatGPT-style Welcome view when in a new chat with 0 messages
  Widget _buildEmptyWelcomeState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLang = ref.watch(localeProvider).languageCode;

    final suggestions = currentLang == 'si'
        ? [
            (
              icon: Icons.pest_control_rounded,
              title: 'වගාවේ රෝග සහ පළිබෝධ',
              desc: 'මගේ වගාවේ කොළ කහ පැහැ ගැන්වී ඇත, හේතුව කුමක්ද?',
              prompt: 'මගේ වගාවේ කොළ කහ පැහැ ගැන්වී ඇත. එයට හේතු සහ ස්වාභාවික පිළියම් කරුණු වශයෙන් පැහැදිලි කරන්න.',
            ),
            (
              icon: Icons.compost_rounded,
              title: 'කාබනික පොහොර වට්ටෝරු',
              desc: 'නිවසේදීම සාදාගත හැකි ස්වාභාවික දියර පොහොර මොනවාද?',
              prompt: 'ගෙවත්තේදීම සාදාගත හැකි කාබනික කොම්පෝස්ට් සහ දියර පොහොර වට්ටෝරු පියවරෙන් පියවර විස්තර කරන්න.',
            ),
            (
              icon: Icons.water_drop_rounded,
              title: 'ජල සම්පාදන උපදෙස්',
              desc: 'වියළි කාලගුණයේදී එළවළු සඳහා හොඳම ජල ක්‍රමය',
              prompt: 'වියළි කාලගුණය තුළ එළවළු බෝග සඳහා ප්‍රශස්ත ජල සම්පාදන කාලසටහන සහ උපදෙස් ලබා දෙන්න.',
            ),
            (
              icon: Icons.camera_alt_rounded,
              title: 'කොළයක් ස්කෑන් කර අසන්න',
              desc: 'කැමරාවෙන් කොළයේ ඡායාරූපයක් ගෙන රෝගය සොයාගන්න',
              prompt: '__SCAN__',
            ),
          ]
        : [
            (
              icon: Icons.pest_control_rounded,
              title: 'Pest & Disease Diagnosis',
              desc: 'Why are my crop leaves turning yellow?',
              prompt: 'My crop leaves are turning yellow with brown spots. What are the causes, remedies, and prevention steps point-by-point?',
            ),
            (
              icon: Icons.compost_rounded,
              title: 'Organic Fertilizer Recipes',
              desc: 'Best natural homemade fertilizers for high yield',
              prompt: 'Explain how to prepare effective organic liquid fertilizer and compost step-by-step.',
            ),
            (
              icon: Icons.water_drop_rounded,
              title: 'Irrigation & Watering',
              desc: 'Optimal watering schedule in dry weather',
              prompt: 'What is the optimal irrigation schedule and water conservation method for vegetable cultivation?',
            ),
            (
              icon: Icons.camera_alt_rounded,
              title: 'Scan Leaf with Camera',
              desc: 'Take a leaf photo for instant AI diagnosis',
              prompt: '__SCAN__',
            ),
          ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // AI Sprout Emblem
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Icons.eco_rounded, size: 48, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            currentLang == 'si' ? 'AgriAI කෘෂි සහායක' : 'AgriAI Smart Assistant',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              currentLang == 'si'
                  ? 'වගාවන්, පළිබෝධ, පස, පොහොර සහ ගොවිතැන් කටයුතු පිළිබඳ ඕනෑම ගැටලුවක් විමසන්න. (කෘෂිකාර්මික උපදෙස් සඳහා පමණි)'
                  : 'Your dedicated 24/7 farming companion. Ask anything about crops, plant diseases, soil, fertilizers, and irrigation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 28),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              currentLang == 'si' ? 'ජනප්‍රිය කෘෂි මාතෘකා' : 'Popular Inquiries',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 12),

          // Suggestion Cards Grid
          ...suggestions.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (item.prompt == '__SCAN__') {
                    _scanLeafFromChat();
                  } else {
                    _sendMessage(item.prompt);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: colorScheme.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.desc,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentScanBanner(BuildContext context, ScanState scanState) {
    final result = scanState.result!;
    final condition = result.diseaseName.isNotEmpty ? result.diseaseName : result.label;
    final currentLang = ref.watch(localeProvider).languageCode;

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
                  currentLang == 'si'
                      ? 'මෑතකදී ස්කෑන් කළ බෝගයක් හඳුනාගැනිණි'
                      : (currentLang == 'ta' ? 'சமீபத்திய ஸ்கேன் கண்டறியப்பட்டது' : 'Recent Scan Detected'),
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
              final plantTitle = result.label.contains('Unrecognized')
                  ? 'Plant Diagnostic Scan'
                  : (result.diseaseName.isNotEmpty && !result.label.toLowerCase().contains(result.diseaseName.toLowerCase())
                      ? '${result.label} ($condition)'
                      : result.label);

              setState(() {
                _recentScanDismissed = true;
                _currentSessionId = const Uuid().v4();
                _currentCropType = plantTitle;
                _currentSessionTitle = plantTitle;
                _messages.clear();
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
              _sendMessage(prompt, scanState.imagePath);
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            child: Text(
              currentLang == 'si'
                  ? 'AI වෙත යවන්න'
                  : (currentLang == 'ta' ? 'AI க்கு அனுப்பு' : 'Send to AI'),
            ),
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

      final plantTitle = result.label.contains('Unrecognized')
          ? 'Plant Diagnostic Scan'
          : (result.diseaseName.isNotEmpty && !result.label.toLowerCase().contains(result.diseaseName.toLowerCase())
              ? '${result.label} ($condition)'
              : result.label);

      setState(() {
        _currentSessionId = const Uuid().v4();
        _currentCropType = plantTitle;
        _currentSessionTitle = plantTitle;
        _messages.clear();
      });

      _sendMessage(prompt, image.path);
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
        borderRadius: const BorderRadius.only(
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
