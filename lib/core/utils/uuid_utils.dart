import 'dart:math';

class UuidUtils {
  static final Random _random = Random.secure();

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Generates an RFC 4122 version 4 UUID string (e.g., "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d").
  static String generateV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant 10xxxxxx
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Checks if [value] is a valid UUID string.
  static bool isValid(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return _uuidRegex.hasMatch(value.trim());
  }
}
