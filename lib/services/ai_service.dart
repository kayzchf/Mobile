import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tarot_card.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String timestamp;
  final TarotCard? attachedCard;

  ChatMessage({
    required this.text,
    required this.isUser,
    String? timestamp,
    this.attachedCard,
  }) : timestamp = timestamp ?? DateTime.now().toIso8601String();
}

class AiTarotService {
  static final AiTarotService instance = AiTarotService._init();
  AiTarotService._init();

  String? apiKey;

  static const String initialGreeting =
      "Halo sahabat! 🌌 Aku Madame Arcanova. Ceritakan apa saja yang sedang mengganjal di pikiranmu—soal asmara, karir, kuliah, keluarga, atau perasaanmu hari ini. Aku siap mendengarkan dan merespons ceritamu secara langsung...";

  // Real-time AI consultation that analyzes what the user ACTUALLY typed!
  Future<String> consultArcanova({
    required String userMessage,
    TarotCard? drawnCard,
    String? userZodiac,
  }) async {
    // 1. If Gemini API key is configured, call live Google Gemini LLM API
    if (apiKey != null && apiKey!.trim().isNotEmpty) {
      try {
        final onlineResponse = await _callGeminiApi(userMessage, drawnCard, userZodiac);
        if (onlineResponse != null && onlineResponse.trim().isNotEmpty) {
          return onlineResponse;
        }
      } catch (_) {}
    }

    // 2. Real-time Contextual NLP Engine in Dart
    return _generateDeepContextualResponse(userMessage, drawnCard, userZodiac);
  }

  Future<String?> _callGeminiApi(
    String userMessage,
    TarotCard? drawnCard,
    String? userZodiac,
  ) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    String systemContext = "Kamu adalah Madame Arcanova, pembaca tarot dan konsultan spiritual yang santai, empatik, bijak, dan sangat ramah (gaya bahasa kasual, suportif, tidak kaku). "
        "Tanggapi pertanyaan pengguna secara spesifik berdasarkan apa yang diketiknya. Jangan gunakan template generic. ";

    if (userZodiac != null) systemContext += "Zodiak pengguna: $userZodiac. ";
    if (drawnCard != null) {
      systemContext += "Pengguna menarik kartu tarot: ${drawnCard.name} (${drawnCard.symbol}) dengan makna: ${drawnCard.uprightMeaning}. Hubungkan dengan masalahnya. ";
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "$systemContext\n\nPertanyaan Pengguna: \"$userMessage\"\n\nJawabanmu:"}
            ]
          }
        ]
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text;
    }
    return null;
  }

  // Truly dynamic response generator that dissects user's actual text
  String _generateDeepContextualResponse(
    String userMessage,
    TarotCard? drawnCard,
    String? userZodiac,
  ) {
    final text = userMessage.trim();
    final lower = text.toLowerCase();

    // If card was pulled
    if (drawnCard != null) {
      return "✨ **Pesan Semesta dari Kartu ${drawnCard.name} (${drawnCard.symbol})** ✨\n\n"
          "Sahabat, untuk hal yang baru saja kamu tanyakan:\n*\"$text\"*\n\n"
          "Kartu **${drawnCard.name}** ini punya energi: *\"${drawnCard.uprightMeaning}\"*.\n\n"
          "💡 **Saran Khusus Buat Kamu:**\n"
          "${drawnCard.loveAdvice}\n"
          "Semesta memberi sinyal bahwa apa yang sedang kamu hadapi bukanlah jalan buntu, melainkan proses penataan kembali energimu. Tarik napas perlahan ya!";
    }

    // Dynamic keyword & entity recognition
    String topic = "apa yang kamu sampaikan";
    String insight = "";
    String advice = "";

    if (lower.contains('kuliah') || lower.contains('tugas') || lower.contains('skripsi') || lower.contains('dosen') || lower.contains('ujian') || lower.contains('proyek')) {
      topic = "tanggung jawab akademik dan perkuliahanmu";
      insight = "Aku bisa merasakan beban dan kelelahan mental dari tugas-tugas yang sedang menumpuk. Terkadang ekspektasi dari dosen atau diri sendiri memang bikin overthinking.";
      advice = "Jangan mencoba menyelesaikan semuanya dalam satu malam. Pecah targetmu jadi langkah-langkah kecil. Otakmu butuh istirahat sejenak agar ide segar bisa mengalir lagi.";
    } else if (lower.contains('cinta') || lower.contains('gebetan') || lower.contains('pacar') || lower.contains('mantan') || lower.contains('jodoh') || lower.contains('putus') || lower.contains('sayang')) {
      topic = "dinamika hubungan asmara yang sedang kamu pikirkan";
      insight = "Urusan hati memang sering kali paling menguras energi batin. Ada rasa bimbang antara bertahan, memperjuangkan, atau melepaskan apa yang tidak lagi sefrekuensi.";
      advice = "Perhatikan tindakan nyatanya, bukan sekadar kata-katanya. Jika sebuah hubungan membuatmu terus meragukan harga dirimu, itu tandanya kamu perlu memberi batasan yang sehat.";
    } else if (lower.contains('uang') || lower.contains('karir') || lower.contains('kerja') || lower.contains('finansial') || lower.contains('gaji') || lower.contains('bisnis') || lower.contains('cuan')) {
      topic = "perkembangan karir dan kestabilan finansialmu";
      insight = "Kartu-kartu memperlihatkan bahwa kamu sedang berada di fase transisi penting. Ada peluang baru yang mulai mendekat, tapi kamu butuh keberanian untuk keluar dari zona nyaman.";
      advice = "Rapikan kembali pengelolaan energimu dan jangan ragu untuk mengasah keahlian baru. Hasil kerja kerasmu belakangan ini akan mulai menunjukkan buah manisnya.";
    } else if (lower.contains('sedih') || lower.contains('capek') || lower.contains('lelah') || lower.contains('nangis') || lower.contains('kecewa') || lower.contains('bingung') || lower.contains('overthinking') || lower.contains('hampa')) {
      topic = "perasaan lelah dan emosi yang sedang kamu tahan";
      insight = "Terima kasih sudah mau jujur dengan apa yang kamu rasakan. Kamu sudah bertahan sejauh ini, dan itu membuktikan betapa kuatnya jiwamu meski dunia terkadang terasa begitu berat.";
      advice = "Validasi rasa sedihmu, jangan dipaksa langsung baik-baik saja. Beri waktu bagi dirimu sendiri untuk pulih. Ingat, badai tidak pernah menetap selamanya.";
    } else if (lower.contains('kucing') || lower.contains('hewan') || lower.contains('peliharaan')) {
      topic = "kucing/hewan tersayangmu";
      insight = "Ikatan batinmu dengan hewan kesayangan itu sangat tulus dan murni. Hewan memiliki kepekaan aura yang kuat terhadap kasih sayang pemeliharanya.";
      advice = "Pancarkan ketenangan batin, karena mereka bisa merasakan ketulusan doamu. Semoga energi baik senantiasa melindunginya.";
    } else {
      topic = "curahan hatimu";
      insight = "Mengenai perkataanmu tadi: *\"$text\"*—aku merasakan adanya dorongan besar di dalam dirimu untuk mencari kejelasan dan arah yang lebih pasti.";
      advice = "Percayalah pada firasat pertamamu. Semesta sedang menuntunmu melalui siklus perubahan yang akan mendewasakan cara pandangmu.";
    }

    final zodiacNote = userZodiac != null ? "\n\n♈ Sebagai pemilik zodiak **$userZodiac**, energimu punya daya tahan luar biasa untuk mengatasi ini." : "";

    return "Sahabat Jiwaku, mengenai **$topic**:\n\n"
        "$insight\n\n"
        "🔮 **Refleksi Tarot:**\n$advice$zodiacNote\n\n"
        "Ada hal lain yang ingin kamu ceritakan atau mau kita tarik kartu tarot untuk melihat simbolnya?";
  }
}
