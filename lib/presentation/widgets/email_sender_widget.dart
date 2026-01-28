import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/email_repository.dart';
import '../../data/repositories/admin_email_functions.dart';
import '../../logic/providers.dart';

/// Widget para enviar emails fácilmente desde cualquier parte de la app
class EmailSenderWidget extends ConsumerWidget {
  final String emailTo;
  final String? subject;
  final String? htmlContent;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const EmailSenderWidget({
    super.key,
    required this.emailTo,
    this.subject,
    this.htmlContent,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _sendEmail(context, ref),
      child: const Text('Enviar Email'),
    );
  }

  Future<void> _sendEmail(BuildContext context, WidgetRef ref) async {
    if (emailTo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Email inválido')),
      );
      return;
    }

    final emailRepo = ref.read(emailRepositoryProvider);
    
    try {
      final success = await emailRepo.sendNewsletter(
        [emailTo],
        subject ?? 'Mensaje de KicksPremium',
        htmlContent ?? '<p>Mensaje de KicksPremium</p>',
      ).then((result) => (result['successful'] ?? 0) > 0);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Email enviado correctamente')),
        );
        onSuccess?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error al enviar email')),
        );
        onError?.call();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
      onError?.call();
    }
  }
}

/// Mixin para agregar funcionalidad de email a widgets
mixin EmailMixin {
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String htmlBody,
  }) async {
    final emailRepo = EmailRepository();
    final result = await emailRepo.sendNewsletter([to], subject, htmlBody);
    return (result['successful'] ?? 0) > 0;
  }

  Future<bool> sendWelcomeEmail({
    required String email,
    required String name,
  }) async {
    final emailRepo = EmailRepository();
    return emailRepo.sendWelcome(email, name);
  }

  Future<bool> sendOrderConfirmationEmail({
    required String email,
    required String orderId,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    final emailRepo = EmailRepository();
    return emailRepo.sendOrderConfirmation(email, orderId, total, items);
  }
}

/// Dialog para enviar emails de forma rápida
Future<void> showEmailDialog(BuildContext context) {
  final subjectController = TextEditingController();
  final contentController = TextEditingController();
  final recipientController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('✉️ Enviar Email'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: recipientController,
              decoration: InputDecoration(
                labelText: 'Email del Destinatario',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Asunto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Contenido (HTML)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            subjectController.dispose();
            contentController.dispose();
            recipientController.dispose();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (recipientController.text.isEmpty ||
                subjectController.text.isEmpty ||
                contentController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('❌ Por favor completa todos los campos')),
              );
              return;
            }

            final emailRepo = EmailRepository();
            final result = await emailRepo.sendNewsletter(
              [recipientController.text],
              subjectController.text,
              contentController.text,
            );
            
            final success = (result['successful'] ?? 0) > 0;

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Email enviado')),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('❌ Error al enviar')),
              );
            }

            subjectController.dispose();
            contentController.dispose();
            recipientController.dispose();
          },
          child: const Text('Enviar'),
        ),
      ],
    ),
  );
}

/// Service locator para acceder fácilmente a funciones de email
class EmailService {
  static final _instance = EmailService._();

  factory EmailService() => _instance;

  EmailService._();

  final _emailRepo = EmailRepository();
  final _adminFunctions = AdminEmailFunctions();

  Future<bool> sendWelcome(String email, String name) =>
      _emailRepo.sendWelcome(email, name);

  Future<bool> sendOrderConfirmation(
    String email,
    String orderId,
    double total,
    List<Map<String, dynamic>> items,
  ) =>
      _emailRepo.sendOrderConfirmation(email, orderId, total, items);

  Future<bool> notifyAdminOrder(
    String orderId,
    String customerEmail,
    double totalAmount,
    List<Map<String, dynamic>> items,
  ) =>
      _emailRepo.notifyAdminNewOrder(orderId, customerEmail, totalAmount, items);

  Future<bool> sendOrderStatus(
    String email,
    String orderId,
    String status,
    String? trackingUrl,
  ) =>
      _emailRepo.sendOrderStatusUpdate(email, orderId, status, trackingUrl);

  Future<bool> sendPasswordReset(
    String email,
    String name,
    String resetLink,
  ) =>
      _emailRepo.sendPasswordReset(email, name, resetLink);

  Future<bool> sendContactForm(
    String name,
    String email,
    String subject,
    String message,
  ) =>
      _emailRepo.sendContactForm(name, email, subject, message);

  Future<bool> sendProblemReport(
    String email,
    String name,
    String problem,
    String? attachmentUrl,
  ) =>
      _emailRepo.sendProblemReport(email, name, problem, attachmentUrl);

  Future<Map<String, int>> sendPromotion({
    required List<String> recipients,
    required String name,
    required String discount,
    required String validUntil,
  }) =>
      _adminFunctions.sendPromotion(
        recipients: recipients,
        promotionName: name,
        discountPercent: discount,
        validUntil: validUntil,
      );

  Future<Map<String, int>> sendEvent({
    required List<String> recipients,
    required String name,
    required String date,
    required String description,
  }) =>
      _adminFunctions.sendEvent(
        recipients: recipients,
        eventName: name,
        eventDate: date,
        eventDescription: description,
      );

  Future<Map<String, int>> sendNewsletter({
    required List<String> recipients,
    required String subject,
    required String content,
  }) =>
      _emailRepo.sendNewsletter(recipients, subject, content);
}

/// Extension para String - validar email
extension EmailValidator on String {
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }
}

/// Builder para crear emails fácilmente
class EmailBuilder {
  String _subject = '';
  String _htmlContent = '';
  final List<String> _recipients = [];
  String? _cc;

  EmailBuilder withSubject(String subject) {
    _subject = subject;
    return this;
  }

  EmailBuilder withHtmlContent(String content) {
    _htmlContent = content;
    return this;
  }

  EmailBuilder addRecipient(String email) {
    if (email.isValidEmail()) {
      _recipients.add(email);
    }
    return this;
  }

  EmailBuilder addRecipients(List<String> emails) {
    _recipients.addAll(
      emails.where((email) => email.isValidEmail()),
    );
    return this;
  }

  EmailBuilder withCc(String email) {
    if (email.isValidEmail()) {
      _cc = email;
    }
    return this;
  }

  String get subject => _subject;
  String get htmlContent => _htmlContent;
  List<String> get recipients => _recipients;
  String? get cc => _cc;

  bool isValid() {
    return _subject.isNotEmpty &&
        _htmlContent.isNotEmpty &&
        _recipients.isNotEmpty;
  }

  Future<Map<String, int>> send() async {
    if (!isValid()) {
      throw Exception('Email incompleto');
    }

    final emailRepo = EmailRepository();
    return emailRepo.sendNewsletter(_recipients, _subject, _htmlContent);
  }
}
