import '../models/blockchain_block.dart';
import 'db_helper.dart';

class BlockchainService {
  static final BlockchainService instance = BlockchainService._init();
  BlockchainService._init();

  // Genesis Block Creation
  BlockchainBlock createGenesisBlock() {
    final genesisData = {
      'event': 'GENESIS_ARCANOVA_PORTAL',
      'creator': 'Master Madame Arcanova',
      'sanctuary': 'Malioboro Sanctuary Yogyakarta',
      'note': 'Inaugural Block of Mystic Tarot Reading Ledger',
    };

    return BlockchainBlock.mineBlock(
      index: 0,
      sessionData: genesisData,
      previousHash: '0000000000000000000000000000000000000000000000000000000000000000',
      difficulty: 2,
    );
  }

  // Ensure Genesis Block Exists in Database
  Future<void> ensureGenesisBlock() async {
    final blocks = await DatabaseHelper.instance.getAllBlocks();
    if (blocks.isEmpty) {
      final genesis = createGenesisBlock();
      await DatabaseHelper.instance.insertBlock(genesis);
    }
  }

  // Record a New Tarot Reading Certificate to the Blockchain
  Future<BlockchainBlock> recordReadingCertificate({
    required String bookingId,
    required int userId,
    required String serviceTitle,
    required String clientName,
    required List<String> cardsDrawn,
    required String spiritualSummary,
  }) async {
    await ensureGenesisBlock();
    final blocks = await DatabaseHelper.instance.getAllBlocks();
    final lastBlock = blocks.last;

    final sessionData = {
      'booking_id': bookingId,
      'user_id': userId,
      'client_name': clientName,
      'service_title': serviceTitle,
      'cards_drawn': cardsDrawn,
      'spiritual_summary': spiritualSummary,
      'seal_status': 'IMMUTABLE_ARCANE_PROOF',
    };

    final newBlock = BlockchainBlock.mineBlock(
      index: lastBlock.index + 1,
      sessionData: sessionData,
      previousHash: lastBlock.hash,
      difficulty: 2,
    );

    await DatabaseHelper.instance.insertBlock(newBlock);
    return newBlock;
  }

  // Mine a manual or user-triggered spiritual affirmation block
  Future<BlockchainBlock> mineSpiritualBlock({
    required int userId,
    required String userName,
    required String intention,
  }) async {
    return recordReadingCertificate(
      bookingId: 'MINE-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      userId: userId,
      serviceTitle: 'Konsultasi Spiritual & Penyelarasan Energi',
      clientName: userName,
      cardsDrawn: ['The Star ⭐', 'The Sun ☀️', 'Wheel of Fortune 🎡'],
      spiritualSummary: intention,
    );
  }

  // Verify the entire blockchain integrity
  Future<Map<String, dynamic>> verifyChainIntegrity() async {
    final blocks = await DatabaseHelper.instance.getAllBlocks();
    if (blocks.isEmpty) {
      return {'valid': true, 'message': 'Rantai blok masih kosong.'};
    }

    for (int i = 1; i < blocks.length; i++) {
      final current = blocks[i];
      final previous = blocks[i - 1];

      // 1. Check previousHash link
      if (current.previousHash != previous.hash) {
        return {
          'valid': false,
          'message': 'Rantai rusak di Blok #${current.index}: Previous Hash tidak cocok!',
          'brokenIndex': current.index,
        };
      }

      // 2. Recalculate hash to verify no tampering
      final calculatedHash = BlockchainBlock.calculateHash(
        index: current.index,
        timestamp: current.timestamp,
        sessionData: current.sessionData,
        previousHash: current.previousHash,
        nonce: current.nonce,
      );

      if (current.hash != calculatedHash) {
        return {
          'valid': false,
          'message': 'Data Blok #${current.index} telah dimanipulasi! Hash tidak valid.',
          'brokenIndex': current.index,
        };
      }
    }

    return {
      'valid': true,
      'message': 'Semua (${blocks.length}) Blok Terverifikasi Aman & Asli oleh SHA-256 Cryptography.',
      'totalBlocks': blocks.length,
    };
  }

  // Get all reading blocks
  Future<List<BlockchainBlock>> getLedgerBlocks() async {
    await ensureGenesisBlock();
    return await DatabaseHelper.instance.getAllBlocks();
  }
}
