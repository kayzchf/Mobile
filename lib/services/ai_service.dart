import 'dart:convert';
import 'dart:math';
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

  // User can optionally supply Gemini API Key in runtime or settings
  String? apiKey;

  // Initial greeting from Madame Arcanova
  static const String initialGreeting =
      "Selamat datang di ruang batin Arcanova, Jiwa yang berharga. 🌌 Aku adalah Madame Arcanova, pembaca pesan-pesan semesta. Ceritakanlah apa yang sedang menggelisahkan hatimu—tentang asmara, karir, atau arah langkah hidupmu. Kartu-kartu kosmis ini siap membimbingmu...";

  // Send message to LLM or use mystic spiritual heuristic engine
  Future<String> consultArcanova({
    required String userMessage,
    TarotCard? drawnCard,
    String? userZodiac,
  }) async {
    // If user provided a Gemini API Key, try online API first
    if (apiKey != null && apiKey!.isNotEmpty) {
      try {
        final onlineResponse = await _callGeminiApi(userMessage, drawnCard, userZodiac);
        if (onlineResponse != null && onlineResponse.isNotEmpty) {
          return onlineResponse;
        }
      } catch (_) {
        // Fallback to mystic offline engine
      }
    }

    // Intelligent Mystic Heuristic Engine (Offline Guarantee)
    return _generateMysticSpiritualResponse(userMessage, drawnCard, userZodiac);
  }

  Future<String?> _callGeminiApi(
    String userMessage,
    TarotCard? drawnCard,
    String? userZodiac,
  ) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    String systemContext = "Kamu adalah Madame Arcanova, peramal tarot dan penasihat spiritual yang anggun, penuh empati, dan bijaksana. "
        "Gunakan bahasa Indonesia puitis, hangat, dan menenangkan namun logis dan memotivasi. "
        "Sapa pengguna sebagai 'Sahabat Jiwaku'. ";

    if (userZodiac != null) {
      systemContext += "Zodiak pengguna adalah $userZodiac. ";
    }
    if (drawnCard != null) {
      systemContext += "Pengguna menarik kartu tarot: ${drawnCard.name} (Elemen: ${drawnCard.element}, Makna: ${drawnCard.uprightMeaning}). Hubungkan nasihatmu dengan kartu ini. ";
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "$systemContext\nPengguna bertanya: $userMessage"}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text;
    }
    return null;
  }

  String _generateMysticSpiritualResponse(
    String userMessage,
    TarotCard? drawnCard,
    String? userZodiac,
  ) {
    final lower = userMessage.toLowerCase();
    final random = Random();

    // 1. If a tarot card was drawn
    if (drawnCard != null) {
      return "✨ **Resonansi Kartu ${drawnCard.name} (${drawnCard.symbol})** ✨\n\n"
          "Sahabat Jiwaku, semesta mempertemukanmu dengan energi ${drawnCard.name}. Kartu ini memancarkan pesan: *\"${drawnCard.uprightMeaning}\"*\n\n"
          "Terkait apa yang kamu rasakan: ${drawnCard.loveAdvice} Jangan biarkan keraguan menutupi intuisimu. Tarik nafas perlahan, semesta sedang merajut jalan terbaik untukmu.";
    }

    // 2. Love / Asmara questions
    if (lower.contains('cinta') || lower.contains('jodoh') || lower.contains('pacar') || lower.contains('mantan') || lower.contains('hubungan')) {
      final loveResponses = [
        "Kurasakan getaran hangat namun ada sedikit kebingungan di dalam hatimu, Sahabat Jiwaku. Dalam cinta, keikhlasan melepaskan luka masa lalu adalah kunci terbukanya pintu belahan jiwa baru. Percayalah, orang yang tepat tidak akan membuatmu terus-menerus mempertanyakan harga dirimu.",
        "Kartu Asmara Semesta menunjukkan bahwa energi hatimu sedang dalam fase pemulihan. Jangan tergesa-gesa memaksakan kepastian. Berikan ruang bagi rasa saling menghargai untuk tumbuh secara alami.",
        "Cinta sejati bukanlah tentang mencari kesempurnaan, melainkan tentang dua jiwa yang berani saling melengkapi dalam kejujuran. Dengarkan suara hatimu saat malam hening, jawaban itu sebenarnya sudah ada di sana."
      ];
      return loveResponses[random.nextInt(loveResponses.length)];
    }

    // 3. Career / Uang / Kuliah / Masa Depan
    if (lower.contains('karir') || lower.contains('uang') || lower.contains('kuliah') || lower.contains('tugas') || lower.contains('kerja') || lower.contains('sukses')) {
      final careerResponses = [
        "Mengenai jalan ikhtiar dan karirmu, Sahabat Jiwaku: Kurasakan tekadmu yang kuat di balik kelelahanmu. Usaha keras dan begadangmu belakangan ini tidak akan sia-sia. Siklus keberuntungan sedang mendekat; tetaplah fokus pada detail teknis karyamu.",
        "Pintu peluang baru akan segera terbuka. Yang kamu butuhkan saat ini bukanlah meragukan kemampuanmu, melainkan merapikan kembali fokus dan manajemen energimu. Hasil manis akan kamu petik tepat pada waktunya.",
        "Jangan biarkan ekspektasi orang lain membebani langkahmu. Setiap orang memiliki garis waktu takdir masing-masing. Teruslah berkarya dengan integritas, rezeki dan pengakuan akan mengalir dengan sendirinya."
      ];
      return careerResponses[random.nextInt(careerResponses.length)];
    }

    // 4. Default Empathetic Mystic Wisdom
    final generalResponses = [
      "Aku mendengarkan setiap keluh kesahmu, Sahabat Jiwaku. Dunia terkadang begitu riuh hingga kita lupa mendengarkan bisikan nurani sendiri. Lepaskan beban yang bukan tanggung jawabmu untuk dipikul. Hari esok selalu membawa lembaran baru.",
      "Kurasakan energi batinmu yang begitu murni. Di balik setiap kegelapan ada bintang harapan yang sedang menanti fajar. Percayalah pada proses pendewasaan jiwamu, kamu jauh lebih kuat dari apa yang kamu kira.",
      "Tariklah nafas dalam-dalam, hembuskan perlahan segala gundah. Semesta sedang menata kembali frekuensi hidupmu. Apa yang hilang darimu akan digantikan dengan sesuatu yang jauh lebih bernilai bagi kedamaian jiwamu."
    ];
    return generalResponses[random.nextInt(generalResponses.length)];
  }
}

