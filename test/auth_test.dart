import 'package:flutter_test/flutter_test.dart';
import 'package:agri_ai/core/services/email_verification_service.dart';

void main() {
  group('EmailVerificationService Tests', () {
    final service = EmailVerificationService.instance;

    test('generates valid 6-digit numeric codes', () {
      final code = service.generateCode();
      expect(code.length, 6);
      expect(int.tryParse(code), isNotNull);
      expect(int.parse(code), inInclusiveRange(100000, 999999));
    });

    test('validates email addresses properly', () {
      expect(service.isValidEmail('farmer@gmail.com'), isTrue);
      expect(service.isValidEmail('user.name@agri.lk'), isTrue);
      expect(service.isValidEmail('invalid-email'), isFalse);
      expect(service.isValidEmail('missing@domain'), isFalse);
      expect(service.isValidEmail(''), isFalse);
    });

    test('sends verification code successfully in offline/test mode', () async {
      final success = await service.sendVerificationCode(
        email: 'test@example.com',
        code: '123456',
        recipientName: 'Test Farmer',
      );
      expect(success, isTrue);
    });
  });
}
