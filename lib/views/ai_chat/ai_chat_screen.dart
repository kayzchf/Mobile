import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/tarot_card.dart';
import '../../services/ai_service.dart';
import '../../services/db_helper.dart';
import '../../services/auth_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<TarotCard> _tarotDeck = [];

  @override
  void initState() {
    super.initState();
    _loadTarotDeck();
    _messages.add(
      ChatMessage(
        text: "Halo sahabat! 🌌 Aku Madame Arcanova. Ceritain apa aja yang lagi kamu rasain saat ini—tentang gebetan, cinta, kuliah, karir, atau apapun. Aku siap dengerin dan kasih sudut pandang tarot yang menenangkan buat kamu...",
        isUser: false,
      ),
    );
  }

  Future<void> _loadTarotDeck() async {
    final cards = await DatabaseHelper.instance.getAllTarotCards();
    if (mounted) {
      setState(() => _tarotDeck = cards);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage({TarotCard? cardDrawn}) async {
    final text = _inputController.text.trim();
    if (text.isEmpty && cardDrawn == null) return;

    final user = AuthService.instance.currentUser;
    final userMessage = cardDrawn != null
        ? "Aku baru aja narik kartu: ${cardDrawn.name} (${cardDrawn.symbol}). Apa ya pesan semesta dari kartu ini buat aku?"
        : text;

    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
          attachedCard: cardDrawn,
        ),
      );
      _inputController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    // Natural responsive delay (simulate AI deep reflection)
    await Future.delayed(const Duration(milliseconds: 900));

    final response = await AiTarotService.instance.consultArcanova(
      userMessage: userMessage,
      drawnCard: cardDrawn,
      userZodiac: user?.zodiacSign,
    );

    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _drawCardForChat() {
    if (_tarotDeck.isEmpty) return;
    final random = Random();
    final card = _tarotDeck[random.nextInt(_tarotDeck.length)];
    _sendMessage(cardDrawn: card);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardSurfaceLight,
              ),
              child: const Text("🕯️", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "MADAME ARCANOVA",
                  style: TextStyle(color: AppColors.arcaneSilver, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                Row(
                  children: [
                    Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.celestialCyan, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text("AI Teman Curhat & Tarot • Online", style: TextStyle(color: AppColors.celestialCyan, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List with Animated Bubbles
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildAnimatedBubble(msg, index);
                },
              ),
            ),

            // Realistic Typing Indicator
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: Row(
                  children: [
                    const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: AppColors.brightLavender, strokeWidth: 2)),
                    const SizedBox(width: 10),
                    Text("Madame Arcanova lagi merangkai pesan untukmu...", style: TextStyle(color: AppColors.shimmerSilver.withValues(alpha: 0.8), fontSize: 12)),
                  ],
                ),
              ),

            // Quick casual prompts
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildQuickPrompt("💖 Curhat soal cinta"),
                  _buildQuickPrompt("💼 Gimana arah karirku?"),
                  _buildQuickPrompt("✨ Aku lagi overthinking nih"),
                  _buildQuickPrompt("🃏 Tarik satu kartu acak"),
                ],
              ),
            ),

            // Input Bar with Tarot Card button directly beside the typing textbox!
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                border: Border(top: BorderSide(color: AppColors.mysticViolet.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  // Tarot Card Button right beside the textbox!
                  IconButton(
                    icon: const Icon(Icons.style, color: AppColors.arcaneSilver, size: 24),
                    tooltip: "Tarik Kartu Acak",
                    onPressed: _isLoading ? null : _drawCardForChat,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Cerita atau tanya apa aja yuk...",
                        hintStyle: const TextStyle(color: AppColors.mutedSilver, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: AppColors.cardSurfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.celestialCyan),
                    onPressed: _isLoading ? null : () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPrompt(String prompt) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(prompt, style: const TextStyle(color: Colors.white, fontSize: 11)),
        backgroundColor: AppColors.cardSurfaceLight,
        side: BorderSide(color: AppColors.neonPurple.withValues(alpha: 0.4)),
        onPressed: () {
          _inputController.text = prompt;
          _sendMessage();
        },
      ),
    );
  }

  Widget _buildAnimatedBubble(ChatMessage msg, int index) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.neonPurple.withValues(alpha: 0.85) : AppColors.cardSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 18),
          ),
          border: Border.all(
            color: msg.isUser ? AppColors.mysticViolet : AppColors.mysticViolet.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.voidBlack.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!msg.isUser)
              const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Text(
                  "Madame Arcanova",
                  style: TextStyle(color: AppColors.arcaneSilver, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            Text(
              msg.text,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
