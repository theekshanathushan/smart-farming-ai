import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/agent_api_client.dart';
import '../../../core/theme/app_theme.dart';

final agentApiClientProvider = Provider((ref) => AgentApiClient());

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
      // Add a placeholder for the AI response
      _messages.add(ChatMessage(text: '', isUser: false));
    });
    
    _controller.clear();
    _scrollToBottom();
    
    final apiClient = ref.read(agentApiClientProvider);
    
    try {
      final stream = apiClient.streamChatAdvice(
        message: text,
        language: 'en', // Default language
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
      backgroundColor: AppTheme.sunbakedClay,
      appBar: AppBar(
        title: const Text('Ask AgriAI'),
      ),
      body: Column(
        children: [
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

                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.all(16.0),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser 
                          ? AppTheme.sprout 
                          : AppTheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(24),
                        topRight: const Radius.circular(24),
                        bottomLeft: Radius.circular(message.isUser ? 24 : 4),
                        bottomRight: Radius.circular(message.isUser ? 4 : 24),
                      ),
                      boxShadow: [
                        if (!message.isUser)
                          BoxShadow(
                            color: AppTheme.deepCanopy.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: message.isUser ? Colors.white : AppTheme.richLoam,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppTheme.surface,
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
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: AppTheme.richLoam),
                      decoration: InputDecoration(
                        hintText: 'Ask about your crops...',
                        hintStyle: TextStyle(color: AppTheme.deepCanopy.withOpacity(0.5)),
                        filled: true,
                        fillColor: AppTheme.sunbakedClay,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.sprout,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _isLoading ? null : _sendMessage,
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
      decoration: const BoxDecoration(
        color: AppTheme.surface,
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
            child: const Icon(Icons.eco, color: AppTheme.sprout, size: 24),
          );
        },
      ),
    );
  }
}
