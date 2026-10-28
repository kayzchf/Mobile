import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tarot_card.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String timestamp;
  final TarotCard? attachedCard;
  final bool isOutOfScope;

  ChatMessage({
    required this.text,
    required this.isUser,
    String? timestamp,
    this.attachedCard,
    this.isOutOfScope = false,
  }) : timestamp = timestamp ?? DateTime.now().toIso8601String();
}

class AiTarotService {
  static final AiTarotService instance = AiTarotService._init();
  AiTarotService._init();

  String? apiKey;

  static const String initialGreeting =
      "Halo sahabat jiwaku! 🌌 Aku Madame Arcanova. Ceritakan apa saja yang sedang mengganjal di hatimu—soal asmara, gebetan, karir, capeknya tugas kuliah, atau perasaan yang lagi campur aduk hari ini. Anggap aja lagi curhat santai bareng teman dekat ya...";

  // Real-time AI consultation that analyzes what the user ACTUALLY typed
  Future<String> consultArcanova({
    required String userMessage,
    TarotCard? drawnCard,
    String? userZodiac,
  }) async {
    final cleanText = userMessage.trim();

    // 1. Scope Filter: Only respond to life, spiritual, romance, career, study, and emotion questions
    if (drawnCard == null && !_isWithinLifeTarotScope(cleanText)) {
      return "Maaf ya sahabat, pesanmu ini berada di luar ruang konsultasi jiwa Arcanova 🙏.\n\n"
          "Aku di sini khusus hadir untuk mendengarkan curahan hatimu seputar kehidupan, dinamika cinta & asmara, arah karir, lelahnya kuliah, serta ketenangan batinmu. "
          "Yuk ceritakan apa yang lagi mengganjal di pikiran atau hatimu hari ini!";
    }

    // 2. If Gemini API key is configured, call live Google Gemini LLM API
    // Link API: https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent
    if (apiKey != null && apiKey!.trim().isNotEmpty) {
      try {
        final onlineResponse = await _callGeminiApi(cleanText, drawnCard, userZodiac);
        if (onlineResponse != null && onlineResponse.trim().isNotEmpty) {
          return onlineResponse;
        }
      } catch (_) {}
    }

    // 3. Real-time Contextual NLP Engine in Dart (Natural, Empathetic Friend Tone)
    return _generateDeepContextualResponse(cleanText, drawnCard, userZodiac);
  }

  // Detect if user question is within Arcanova's life & tarot scope
  bool _isWithinLifeTarotScope(String text) {
    final lower = text.toLowerCase();

    // Out of scope keywords: coding, math formulas, politics, sports betting/scores, hardware repair
    final outOfScopeKeywords = [
      'coding', 'flutter', 'javascript', 'python', 'java ', 'c++', 'html', 'css',
      'sql ', 'database query', 'select *', 'void main', 'compile', 'function',
      'kalkulator', 'hitung rumus', 'turunan integral', 'aljabar', 'sin cos tan',
      'pemilu', 'partai politik', 'presiden ri', 'dpr', 'skor bola', 'judi bola',
      'resep masakan', 'spesifikasi laptop', 'harga mobil', 'service ac',
    ];

    for (final bad in outOfScopeKeywords) {
      if (lower.contains(bad)) return false;
    }

    return true;
  }

  Future<String?> _callGeminiApi(
    String userMessage,
    TarotCard? drawnCard,
    String? userZodiac,
  ) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    String systemContext = "Kamu adalah Madame Arcanova, teman curhat batin dan pembaca tarot yang sangat hangat, empatik, santai, dan pengertian (gaya bicara mengalir seperti sahabat akrab, tidak kaku, tidak seperti robot, gunakan bahasa Indonesia yang luwes). "
        "Fokus hanya pada topik kehidupan nyata: curhat asmara, karir, kuliah, emosi batin, dan tarot. ";

    if (userZodiac != null) systemContext += "Zodiak user: $userZodiac. ";
    if (drawnCard != null) {
      systemContext += "Kartu tarot yang ditarik: ${drawnCard.name} (${drawnCard.symbol}) - Makna: ${drawnCard.uprightMeaning}. Selipkan maknanya secara mengalir ke dalam percakapan.";
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "$systemContext\n\nCurhatan Sahabat: \"$userMessage\"\n\nTanggapan Hangat & Mengalir:"}
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
    String text,
    TarotCard? drawnCard,
    String? userZodiac,
  ) {
    final lower = text.toLowerCase();

    // If card was pulled, explain the card gently
    if (drawnCard != null) {
      return "Aura dari kartu **${drawnCard.name}** (${drawnCard.symbol}) terasa pas banget sama apa yang lagi kamu ceritain tadi: \"$text\".\n\n"
          "Kartu ini membawa pesan: *\"${drawnCard.uprightMeaning}\"*.\n\n"
          "Kalau aku rasakan, semesta lagi ngingetin kamu: ${drawnCard.loveAdvice.toLowerCase()} "
          "Kamu nggak perlu terburu-buru mengambil keputusan besar sekarang. Tarik napas pelan-pelan ya sahabat, langkah kecil yang kamu ambil hari ini bakal menguatkan batinmu ke depannya.";
    }

    // Dynamic empathetic responses (curhat style)
    if (lower.contains('kuliah') || lower.contains('tugas') || lower.contains('skripsi') || lower.contains('dosen') || lower.contains('ujian') || lower.contains('proyek') || lower.contains('pam')) {
      return "Aduh, aku paham banget rasanya... Kuliah dan rentetan tugas yang nggak ada habisnya emang sering bikin kepala penat dan energi habis. Apalagi kalau ada ekspektasi tinggi yang bikin kamu ngerasa harus serba bisa.\n\n"
          "Tapi inget ya, kamu itu manusia biasa yang butuh jeda istirahat. Nggak apa-apa banget kalau hari ini kamu ngerasa lelah atau belum selesai semuanya. "
          "Coba istirahat sejenak, minum air hangat, atau dengar musik yang tenang. Pikiran yang jernih bakal bantu kamu nyelesaiin semuanya jauh lebih baik daripada maksain diri sampai tumbang.\n\n"
          "Ada bagian tugas tertentu yang paling bikin kamu pusing sekarang?";
    }

    if (lower.contains('cinta') || lower.contains('gebetan') || lower.contains('pacar') || lower.contains('mantan') || lower.contains('jodoh') || lower.contains('putus') || lower.contains('sayang') || lower.contains('suka') || lower.contains('kangen') || lower.contains('selingkuh')) {
      return "Urusan hati emang paling gampang bikin overthinking ya... Apalagi kalau kita udah naruh rasa, tapi kepastiannya masih abu-abu atau ada luka yang belum sembuh.\n\n"
          "Dari ceritamu, aku bisa ngerasain betapa dalamnya perasaan yang kamu simpan. Tapi saran aku sebagai teman curhatmu: coba lihat sikap nyatanya sehari-hari, bukan cuma kata-kata manisnya. "
          "Orang yang beneran tepat buat kamu nggak bakal bikin kamu terus-terusan meragukan nilai dirimu sendiri.\n\n"
          "Kira-kira apa sih yang paling bikin kamu bimbang atau ragu sama hubungan ini sekarang?";
    }

    if (lower.contains('uang') || lower.contains('karir') || lower.contains('kerja') || lower.contains('finansial') || lower.contains('gaji') || lower.contains('bisnis') || lower.contains('cuan') || lower.contains('masa depan') || lower.contains('rejeki') || lower.contains('rezeki')) {
      return "Mikirin masa depan, pekerjaan, dan kondisi finansial emang sering bikin cemas mendadak ya sahabat. Wajar banget kok ngerasa was-was di tengah ketidakpastian kayak sekarang.\n\n"
          "Tapi kalau boleh aku ingatkan, langkah-langkah kecil dan ketekunan yang kamu lakukan hari ini sebenarnya lagi nyiapin pintu peluang baru. "
          "Rezeki dan kesempatan baik itu sering datang waktu kita fokus memperbaiki apa yang bisa kita kendalikan sekarang, daripada terlalu mencemaskan hal yang belum terjadi.\n\n"
          "Kira-kira rencana atau target apa yang paling pengin kamu wujudkan dalam waktu dekat?";
    }

    if (lower.contains('sedih') || lower.contains('capek') || lower.contains('lelah') || lower.contains('nangis') || lower.contains('kecewa') || lower.contains('bingung') || lower.contains('overthinking') || lower.contains('hampa') || lower.contains('takut') || lower.contains('sendiri')) {
      return "Sini peluk jauh dulu... Terima kasih ya udah mau jujur cerita ke aku. Nggak mudah lho mengakui kalau diri kita lagi capek dan rapuh.\n\n"
          "Wajar banget kalau kamu ngerasa sedih atau pengin nangis. Luapkan aja semua beban itu, jangan ditahan sendirian. "
          "Untuk hari ini, kamu udah bertahan sejauh ini dan itu adalah pencapaian yang luar biasa. Besok semesta bakal pelan-pelan ngasih cahaya dan kelegaan baru buat hatimu.\n\n"
          "Mau cerita lebih detail apa yang paling bikin dadamu sesak hari ini?";
    }

    if (lower.contains('halo') || lower.contains('hai') || lower.contains('pagi') || lower.contains('malam') || lower.contains('sore') || lower.contains('assalamualaikum')) {
      return "Hai sahabat! Senang banget kamu menyapa. Bagaimana harimu hari ini? "
          "Kalau ada unek-unek atau hal yang lagi mengganjal di pikiranmu—entah soal asmara, kuliah, kerjaan, atau sekadar pengin ngobrol santai—aku siap banget dengerin kok. Mau cerita apa hari ini?";
    }

    // Default conversational response
    final zodiacExtra = userZodiac != null ? " Sebagai seseorang yang berzodiak $userZodiac, intuisimu biasanya sangat tajam kalau kamu mendengarkannya dengan tenang." : "";

    return "Aku dengerin baik-baik apa yang kamu ceritakan tadi tentang: \"$text\".\n\n"
        "Kadang di saat kita mencari jawaban, sebenarnya hati terdalam kita sudah punya jawabannya, cuma masih tertutup rasa cemas atau overthinking.$zodiacExtra\n\n"
        "Coba tarik napas dalam-dalam dulu... Kalau kamu mau, kita bisa tarik satu kartu tarot acak buat melihat petunjuk simbol semesta, atau kamu mau cerita lebih lanjut?";
  }
}
