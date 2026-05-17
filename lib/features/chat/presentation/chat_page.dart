import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/core/constants/app_colors.dart';
import 'package:since_together/features/chat/presentation/widgets/message_bubble.dart';
import 'package:since_together/features/chat/providers/chat_provider.dart';
import 'package:since_together/features/couple/providers/couple_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

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
    final coupleIdAsync = ref.watch(coupleIdProvider);

    return coupleIdAsync.when(
      data: (coupleId) {
        if (coupleId == null) {
          return const Scaffold(body: Center(child: Text('No couple found')));
        }

        final messagesAsync = ref.watch(messagesStreamProvider(coupleId));

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Column(
              children: [
                Text(
                  '💬 Our Chat',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'online',
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    _scrollToBottom();
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (_, i) =>
                          MessageBubble(message: messages[i]),
                    );
                  },
                  error: (e, _) => Center(child: Text('$e')),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
              _buildInput(coupleId),
            ],
          ),
        );
      },
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  Widget _buildInput(String coupleId) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type a message ...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: () async {
                final text = _controller.text.trim();
                if (text.isEmpty) return;
                _controller.clear();
                await ref
                    .read(chatRepositoryProvider)
                    .sendMessage(coupleId: coupleId, content: text);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
