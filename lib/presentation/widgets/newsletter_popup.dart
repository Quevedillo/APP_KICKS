import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logic/providers.dart';

class NewsletterPopup extends ConsumerStatefulWidget {
  final VoidCallback? onDismiss;
  
  const NewsletterPopup({super.key, this.onDismiss});

  @override
  ConsumerState<NewsletterPopup> createState() => _NewsletterPopupState();

  /// Mostrar el popup si el usuario no lo ha visto antes
  static Future<void> showIfNeeded(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenPopup = prefs.getBool('newsletter_popup_seen') ?? false;
    final lastShown = prefs.getInt('newsletter_popup_last_shown') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Mostrar solo si no lo ha visto o ha pasado más de 7 días
    final sevenDays = 7 * 24 * 60 * 60 * 1000;
    
    if (!hasSeenPopup || (now - lastShown > sevenDays)) {
      await Future.delayed(const Duration(seconds: 3)); // Esperar 3 segundos
      
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => NewsletterPopup(
            onDismiss: () async {
              await prefs.setBool('newsletter_popup_seen', true);
              await prefs.setInt('newsletter_popup_last_shown', now);
            },
          ),
        );
      }
    }
  }
}

class _NewsletterPopupState extends ConsumerState<NewsletterPopup>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isSubscribed = false;
  String? _promoCode;
  String? _errorMessage;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
    
    // Pre-llenar email si está logueado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userEmail = ref.read(userEmailProvider);
      if (userEmail.isNotEmpty) {
        _emailController.text = userEmail;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final email = _emailController.text.trim().toLowerCase();
      
      // Verificar si ya existe
      final existing = await supabase
          .from('newsletter_subscribers')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      
      if (existing != null) {
        throw Exception('Este email ya está suscrito');
      }
      
      // Generar código promocional único
      final promoCode = _generatePromoCode();
      
      // Insertar en newsletter_subscribers
      await supabase.from('newsletter_subscribers').insert({
        'email': email,
        'verified': true,
        'metadata': {
          'promo_code': promoCode,
          'subscribed_from': 'app_popup',
        },
      });
      
      // Crear código de descuento en la tabla discount_codes
      await supabase.from('discount_codes').insert({
        'code': promoCode,
        'description': 'Código de bienvenida newsletter',
        'discount_type': 'percentage',
        'discount_value': 10, // 10% de descuento
        'min_purchase': 5000, // Mínimo 50€
        'max_uses': 1,
        'max_uses_per_user': 1,
        'is_active': true,
        'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });
      
      // Enviar email de bienvenida con código
      final emailRepo = ref.read(emailRepositoryProvider);
      await emailRepo.sendWelcome(email, 'Nuevo Suscriptor');
      
      setState(() {
        _isSubscribed = true;
        _promoCode = promoCode;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generatePromoCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = 'WELCOME';
    for (int i = 0; i < 4; i++) {
      code += chars[(random ~/ (i + 1)) % chars.length];
    }
    return code;
  }

  void _dismiss() {
    widget.onDismiss?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[900]!,
                Colors.black,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.amber.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: _isSubscribed ? _buildSuccessContent() : _buildFormContent(),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: _dismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_offer,
                size: 48,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            const Text(
              '¡OBTÉN UN 10% DE DESCUENTO!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Subtitle
            Text(
              'Suscríbete a nuestra newsletter y recibe un código de descuento exclusivo para tu primera compra',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Tu email',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduce tu email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Email no válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Subscribe button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _subscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'OBTENER MI DESCUENTO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Skip button
            TextButton(
              onPressed: _dismiss,
              child: Text(
                'No, gracias',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            
            // Privacy note
            Text(
              'Al suscribirte aceptas recibir ofertas y novedades. Puedes darte de baja en cualquier momento.',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          const Text(
            '¡BIENVENIDO!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            'Ya estás suscrito a nuestra newsletter',
            style: TextStyle(color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Promo code box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.2),
                  Colors.orange.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Column(
              children: [
                const Text(
                  'TU CÓDIGO DE DESCUENTO',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _promoCode ?? '',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '10% DE DESCUENTO',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[300],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Válido por 30 días • Compra mínima 50€',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Copy hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'Mantén presionado para copiar el código',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _dismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'EMPEZAR A COMPRAR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
