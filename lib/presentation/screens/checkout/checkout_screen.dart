import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../logic/providers.dart';
import '../../../data/services/stripe_service.dart';
import '../../../data/models/discount_code.dart';
import '../../../utils/vat_helper.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> 
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  String? _error;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  
  // Discount code state
  final _discountCodeController = TextEditingController();
  bool _isValidatingCode = false;
  DiscountCode? _appliedDiscount;
  int _discountAmount = 0;
  String? _discountError;

  // Shipping address state
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  String _country = 'España';
  bool _shippingValidated = false;

  bool get _shippingComplete =>
      _fullNameController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty &&
      _cityController.text.trim().isNotEmpty &&
      _postalCodeController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initStripe();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _discountCodeController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initStripe() async {
    await StripeService.init();
  }

  Future<void> _validateDiscountCode() async {
    final code = _discountCodeController.text.trim();
    if (code.isEmpty) return;
    
    setState(() {
      _isValidatingCode = true;
      _discountError = null;
    });
    
    try {
      final cartTotal = ref.read(cartTotalProvider);
      final discountRepo = ref.read(discountRepositoryProvider);
      
      final result = await discountRepo.validateCode(code, cartTotal);
      
      if (result.valid && result.discountCode != null) {
        setState(() {
          _appliedDiscount = result.discountCode;
          _discountAmount = result.discountAmount ?? 0;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Código aplicado: -${NumberFormat.currency(locale: 'es_ES', symbol: '€').format(_discountAmount / 100)}'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _discountError = result.error;
        });
      }
    } catch (e) {
      setState(() {
        _discountError = 'Error validando código';
      });
    } finally {
      setState(() {
        _isValidatingCode = false;
      });
    }
  }

  void _removeDiscount() {
    setState(() {
      _appliedDiscount = null;
      _discountAmount = 0;
      _discountCodeController.clear();
      _discountError = null;
    });
  }

  /// Total final CON IVA 21%, menos descuento
  int get _finalTotal {
    final cartTotal = ref.read(cartTotalProvider); // base sin IVA
    final withVat = VatHelper.priceWithVat(cartTotal);
    return withVat - _discountAmount;
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    // Validate shipping address first
    setState(() => _shippingValidated = true);
    if (!_shippingComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Completa tu dirección de envío'),
          ]),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final cartItems = ref.read(cartProvider);
      final userEmail = ref.read(userEmailProvider);
      final finalAmount = _finalTotal;

      if (cartItems.isEmpty) throw Exception('Carrito vacío');
      if (userEmail.isEmpty) throw Exception('Usuario no autenticado');
      if (finalAmount <= 0) throw Exception('Monto inválido');

      // 1. Crear Payment Intent
      final paymentData = await StripeService.createPaymentIntent(
        amount: finalAmount,
        currency: 'eur',
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        metadata: {
          'itemCount': cartItems.length.toString(),
          'userEmail': userEmail,
          'discountCode': _appliedDiscount?.code ?? '',
          'discountAmount': _discountAmount.toString(),
        },
      );

      if (!mounted) return;

      final clientSecret = paymentData['clientSecret'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('clientSecret no recibido');
      }

      // 2. Init Payment Sheet
      await StripeService.initPaymentSheet(
        clientSecret: clientSecret,
        email: userEmail,
      );

      if (!mounted) return;

      // 3. Presentar y pagar
      final success = await StripeService.presentPaymentSheet();

      if (success && mounted) {
        // 4. Crear el pedido en la base de datos
        final orderRepo = ref.read(orderRepositoryProvider);
        final paymentIntentId = paymentData['paymentIntentId'] as String? ?? '';
        
        try {
          final order = await orderRepo.createOrder(
            stripePaymentIntentId: paymentIntentId,
            cartItems: cartItems,
            totalPrice: finalAmount,
            discountAmount: _discountAmount > 0 ? _discountAmount : null,
            discountCodeId: _appliedDiscount?.id,
            shippingEmail: userEmail,
            shippingName: _fullNameController.text.trim(),
            shippingPhone: _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
            shippingAddress: {
              'full_name': _fullNameController.text.trim(),
              'address': _addressController.text.trim(),
              'city': _cityController.text.trim(),
              'postal_code': _postalCodeController.text.trim(),
              'country': _country,
              'phone': _phoneController.text.trim(),
            },
          );

          // 4.1 Registrar uso del código de descuento
          if (_appliedDiscount != null && order != null) {
            final discountRepo = ref.read(discountRepositoryProvider);
            await discountRepo.recordCodeUse(
              codeId: _appliedDiscount!.id,
              orderId: order.id,
              discountAmount: _discountAmount,
            );
          }

          // 5. Enviar emails de confirmación
          if (order != null) {
            final emailRepo = ref.read(emailRepositoryProvider);
            
            // Email al cliente — precios CON IVA para el usuario
            await emailRepo.sendOrderConfirmation(
              userEmail,
              order.displayId,
              finalAmount / 100,
              cartItems.map((item) => {
                'name': item.product.name,
                'brand': item.product.brand ?? '',
                'size': item.size,
                'quantity': item.quantity,
                'price': VatHelper.priceWithVat(item.product.effectivePrice) / 100,
                'image': item.product.images.isNotEmpty ? item.product.images.first : '',
              }).toList(),
            );

            // Notificar al admin
            await emailRepo.notifyAdminNewOrder(
              order.displayId,
              userEmail,
              finalAmount / 100,
              cartItems.map((item) => {
                'name': item.product.name,
                'brand': item.product.brand,
                'size': item.size,
                'quantity': item.quantity,
                'price': item.product.price / 100,
              }).toList(),
            );
          }

          // Refrescar pedidos
          ref.invalidate(userOrdersProvider);
        } catch (e) {
          print('⚠️ Pago exitoso pero error guardando pedido: $e');
          // El pago fue exitoso, mostramos éxito aunque falle el guardado
        }

        ref.read(cartProvider.notifier).clearCart();

        if (mounted) {
          _showSuccessDialog();
        }
      }
    } on Exception catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      setState(() => _error = errorMsg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      final errorMsg = 'Error inesperado: $e';
      setState(() => _error = errorMsg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Pago Exitoso!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu pedido ha sido procesado correctamente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/orders');
                  },
                  child: const Text('VER MIS PEDIDOS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€');

    if (cartItems.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('CHECKOUT'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              const Text('Tu carrito está vacío', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => context.go('/'),
                child: const Text('EXPLORAR PRODUCTOS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: _isProcessing ? null : () => context.pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Order Summary Card
              _buildSectionCard(
                title: 'RESUMEN DE COMPRA',
                icon: Icons.receipt_long,
                child: Column(
                  children: [
                    ...cartItems.map((item) => _buildOrderItem(item, currencyFormat)),
                    const Divider(height: 24, color: Colors.grey),
                    
                    // Base (sin IVA)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal (sin IVA):', style: TextStyle(color: Colors.grey)),
                        Text(
                          VatHelper.formatEur(cartTotal),
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // IVA 21%
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('IVA (${VatHelper.kVatPercent}%):', style: const TextStyle(color: Colors.grey)),
                        Text(
                          VatHelper.formatEur(VatHelper.vatAmount(cartTotal)),
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Subtotal con IVA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal (IVA incl.):', style: TextStyle(color: Colors.white70)),
                        Text(
                          VatHelper.formatEur(VatHelper.priceWithVat(cartTotal)),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    
                    // Discount if applied
                    if (_discountAmount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_offer, color: Colors.green[400], size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Descuento (${_appliedDiscount?.code}):',
                                style: TextStyle(color: Colors.green[400]),
                              ),
                            ],
                          ),
                          Text(
                            '-${VatHelper.formatEur(_discountAmount)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          VatHelper.formatEur(_finalTotal),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Shipping address section
              _buildSectionCard(
                title: 'DIRECCIÓN DE ENVÍO',
                icon: Icons.local_shipping_outlined,
                child: _buildShippingForm(),
              ),

              // Discount Code Section
              _buildSectionCard(
                title: 'CÓDIGO DE DESCUENTO',
                icon: Icons.discount,
                child: Column(
                  children: [
                    if (_appliedDiscount != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _appliedDiscount!.code,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                  Text(
                                    _appliedDiscount!.discountType == 'percentage'
                                        ? '${_appliedDiscount!.discountValue}% de descuento'
                                        : '${currencyFormat.format(_appliedDiscount!.discountValue / 100)} de descuento',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: _removeDiscount,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _discountCodeController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Introduce tu código',
                                filled: true,
                                fillColor: Colors.grey[850],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                errorText: _discountError,
                              ),
                              enabled: !_isValidatingCode,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isValidatingCode ? null : _validateDiscountCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isValidatingCode
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('APLICAR'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Payment Method Card
              _buildSectionCard(
                title: 'MÉTODO DE PAGO',
                icon: Icons.payment,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[850]!, Colors.grey[900]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.credit_card, color: Colors.blue, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tarjeta de Crédito/Débito',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildCardBrand('VISA'),
                                const SizedBox(width: 8),
                                _buildCardBrand('MC'),
                                const SizedBox(width: 8),
                                _buildCardBrand('AMEX'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              ),

              // Error message
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red[400]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Payment button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      disabledBackgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: Colors.amber.withOpacity(0.4),
                    ),
                    child: _isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'PROCESANDO...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock, color: Colors.black, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'PAGAR ${currencyFormat.format(_finalTotal / 100)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // Security badge
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user, size: 18, color: Colors.green[400]),
                    const SizedBox(width: 8),
                    Text(
                      'Pago seguro con Stripe',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.lock_outline, size: 14, color: Colors.grey[600]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShippingForm() {
    InputDecoration fieldDecoration(String hint, {String? suffix}) =>
        InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: Colors.grey[850],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[700]!,
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          suffixText: suffix,
        );

    bool showError(TextEditingController c) =>
        _shippingValidated && c.text.trim().isEmpty;

    return Column(
      children: [
        // Full name
        TextField(
          controller: _fullNameController,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.words,
          decoration: fieldDecoration('Nombre y apellidos').copyWith(
            prefixIcon:
                const Icon(Icons.person_outline, color: Colors.grey, size: 20),
            errorText: showError(_fullNameController) ? 'Campo requerido' : null,
          ),
        ),
        const SizedBox(height: 12),
        // Address
        TextField(
          controller: _addressController,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDecoration('Calle y número').copyWith(
            prefixIcon:
                const Icon(Icons.home_outlined, color: Colors.grey, size: 20),
            errorText: showError(_addressController) ? 'Campo requerido' : null,
          ),
        ),
        const SizedBox(height: 12),
        // City + Postal code
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _cityController,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.words,
                decoration: fieldDecoration('Ciudad').copyWith(
                  errorText:
                      showError(_cityController) ? 'Requerido' : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _postalCodeController,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.number,
                decoration: fieldDecoration('C.P.').copyWith(
                  errorText:
                      showError(_postalCodeController) ? 'Requerido' : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Country dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!, width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _country,
              isExpanded: true,
              dropdownColor: Colors.grey[850],
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: const [
                DropdownMenuItem(value: 'España', child: Text('España 🇪🇸')),
                DropdownMenuItem(value: 'Portugal', child: Text('Portugal 🇵🇹')),
                DropdownMenuItem(value: 'Francia', child: Text('Francia 🇫🇷')),
                DropdownMenuItem(value: 'Italia', child: Text('Italia 🇮🇹')),
                DropdownMenuItem(value: 'Alemania', child: Text('Alemania 🇩🇪')),
                DropdownMenuItem(value: 'Reino Unido', child: Text('Reino Unido 🇬🇧')),
                DropdownMenuItem(value: 'Otro', child: Text('Otro país')),
              ],
              onChanged: (v) => setState(() => _country = v!),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Phone (optional)
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: fieldDecoration('Teléfono (opcional)').copyWith(
            prefixIcon:
                const Icon(Icons.phone_outlined, color: Colors.grey, size: 20),
            suffixText: 'Opcional',
          ),
        ),
        // Incomplete warning indicator
        if (_shippingValidated && !_shippingComplete) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Text(
                  'Completa todos los campos requeridos',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[800]!, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildCardBrand(String brand) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        brand,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOrderItem(dynamic item, NumberFormat format) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 65,
              height: 65,
              child: item.product.images.isNotEmpty
                  ? Image.network(
                      item.product.images.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Talla: ${item.size}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            format.format(item.totalPrice / 100),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.amber[700],
            ),
          ),
        ],
      ),
    );
  }
}
