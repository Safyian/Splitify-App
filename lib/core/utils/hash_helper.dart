import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashHelper {
  HashHelper._();

  static String hashContact(String value) {
    final normalised = value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '');
    final bytes = utf8.encode(normalised);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static List<String> hashContacts(List<String> values) {
    return values.map((v) => hashContact(v)).toList();
  }

  static String normalisePhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.startsWith('00')) {
      return '+${cleaned.substring(2)}';
    }
    if (cleaned.startsWith('04') && cleaned.length == 10) {
      return '+61${cleaned.substring(1)}';
    }
    if (cleaned.startsWith('4') && cleaned.length == 9) {
      return '+61$cleaned';
    }
    if (cleaned.startsWith('0') && cleaned.length == 10) {
      return '+61${cleaned.substring(1)}';
    }
    if (cleaned.startsWith('07') && cleaned.length == 11) {
      return '+44${cleaned.substring(1)}';
    }
    if (!cleaned.startsWith('0') && cleaned.length == 10) {
      return '+1$cleaned';
    }
    if (cleaned.length >= 11 && !cleaned.startsWith('0')) {
      return '+$cleaned';
    }
    return cleaned;
  }

  static String hashPhone(String phone) {
    return hashContact(normalisePhone(phone));
  }

  static List<String> hashPhones(List<String> phones) {
    return phones.map((p) => hashPhone(p)).toList();
  }
}
