import 'dart:convert';
import 'package:crypto/crypto.dart';

class BlockchainBlock {
  final int index;
  final int timestamp;
  final Map<String, dynamic> sessionData;
  final String previousHash;
  final int nonce;
  final String hash;

  BlockchainBlock({
    required this.index,
    required this.timestamp,
    required this.sessionData,
    required this.previousHash,
    required this.nonce,
    required this.hash,
  });

  static String calculateHash({
    required int index,
    required int timestamp,
    required Map<String, dynamic> sessionData,
    required String previousHash,
    required int nonce,
  }) {
    final rawData = '$index:$timestamp:${jsonEncode(sessionData)}:$previousHash:$nonce';
    final bytes = utf8.encode(rawData);
    return sha256.convert(bytes).toString();
  }

  factory BlockchainBlock.mineBlock({
    required int index,
    required Map<String, dynamic> sessionData,
    required String previousHash,
    int difficulty = 2,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    int nonce = 0;
    String hash = '';
    final prefix = '0' * difficulty;

    while (true) {
      hash = calculateHash(
        index: index,
        timestamp: timestamp,
        sessionData: sessionData,
        previousHash: previousHash,
        nonce: nonce,
      );
      if (hash.startsWith(prefix)) {
        break;
      }
      nonce++;
    }

    return BlockchainBlock(
      index: index,
      timestamp: timestamp,
      sessionData: sessionData,
      previousHash: previousHash,
      nonce: nonce,
      hash: hash,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'block_index': index,
      'timestamp': timestamp,
      'session_data': jsonEncode(sessionData),
      'previous_hash': previousHash,
      'nonce': nonce,
      'hash': hash,
    };
  }

  factory BlockchainBlock.fromMap(Map<String, dynamic> map) {
    return BlockchainBlock(
      index: map['block_index'] as int,
      timestamp: map['timestamp'] as int,
      sessionData: jsonDecode(map['session_data'] as String) as Map<String, dynamic>,
      previousHash: map['previous_hash'] as String,
      nonce: map['nonce'] as int,
      hash: map['hash'] as String,
    );
  }
}

