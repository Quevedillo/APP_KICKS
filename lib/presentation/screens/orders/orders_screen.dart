import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../logic/providers.dart';
import '../../../data/models/order.dart';
import '../../widgets/credit_note.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MIS PEDIDOS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: !isLoggedIn
          ? _buildNotLoggedIn(context)
          : ordersAsync.when(
              data: (orders) => orders.isEmpty
                  ? _buildNoOrders(context)
                  : _buildOrdersList(context, ref, orders),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => _buildError(context, ref, err.toString()),
            ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 24),
            Text(
              'Inicia sesión para ver tus pedidos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/login?redirect=/orders'),
              child: const Text('INICIAR SESIÓN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoOrders(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes pedidos aún',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Es hora de conseguir tus kicks!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('EXPLORAR PRODUCTOS'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error cargando pedidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.refresh(userOrdersProvider),
              child: const Text('REINTENTAR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, WidgetRef ref, List<Order> orders) {
    if (orders.isEmpty) {
      return _buildNoOrders(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userOrdersProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _OrderCard(order: orders[index], ref: ref);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final WidgetRef ref;

  const _OrderCard({required this.order, required this.ref});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'es_ES');
    final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PEDIDO #${order.displayId}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(order.createdAt),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusBadge(status: order.status),
                    if (order.returnStatus != null) ...[
                      const SizedBox(height: 4),
                      _ReturnStatusBadge(status: order.returnStatus!),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(order.totalPrice / 100),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (order.discountAmount != null && order.discountAmount! > 0)
                      Text(
                        'Descuento: -${currencyFormat.format(order.discountAmount! / 100)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRODUCTOS (${order.items.length})',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.map((item) => _OrderItemRow(item: item)),
              ],
            ),
          ),

          // Shipping info
          if (order.shippingName != null || order.shippingEmail != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: order.canCancel 
                    ? BorderRadius.zero 
                    : const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.shippingName != null) ...[
                    const Text(
                      'ENVÍO A:',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.shippingName!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (order.shippingAddress != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatAddress(order.shippingAddress!),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ],
                  if (order.shippingEmail != null) ...[
                    if (order.shippingName != null) const SizedBox(height: 12),
                    const Text(
                      'EMAIL:',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.shippingEmail!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Download Invoice Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadInvoice(context, asPdf: true),
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: const Text('PDF', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber,
                          side: const BorderSide(color: Colors.amber),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadInvoice(context, asPdf: false),
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('Imprimir', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[300],
                          side: BorderSide(color: Colors.grey[600]!),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Cancel Order Button (only if cancellable)
                    if (order.canCancel)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showCancelDialog(context),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Cancelar', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      )
                    // Refund Request Button (only if shipped/delivered)
                    else if (order.canRequestRefund)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showReturnDialog(context),
                          icon: const Icon(Icons.assignment_return, size: 18),
                          label: const Text('Reembolso', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: null,
                          icon: Icon(
                            order.status == 'cancelled' ? Icons.cancel : Icons.check_circle,
                            size: 18,
                          ),
                          label: Text(
                            order.status == 'cancelled' ? 'Cancelado' : order.statusLabel,
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                  ],
                ),
                // Credit Note Button - for refunded orders
                if (order.status == 'refunded' || order.status == 'returned') ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: CreditNoteButton(
                      orderId: order.id,
                      orderDisplayId: order.displayId,
                      customerName: order.shippingName?.isNotEmpty == true
                          ? order.shippingName!
                          : 'Cliente',
                      customerEmail: order.shippingEmail?.isNotEmpty == true
                          ? order.shippingEmail!
                          : 'N/A',
                      refundAmount: order.totalPrice.toDouble(),
                      reason: order.status == 'returned' 
                          ? 'Devolución del pedido' 
                          : 'Reembolso del pedido',
                      items: order.items.map((item) => {
                        'name': item.productName,
                        'size': item.size,
                        'quantity': item.quantity,
                        'price': item.price,
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReturnDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.assignment_return, color: Colors.orange, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Solicitar Reembolso',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reason field (required)
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Motivo del reembolso *',
                  hintText: 'Ej: Producto defectuoso, no coincide con la descripción...',
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),

              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Información importante',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tu solicitud de reembolso quedará pendiente hasta que un administrador la revise y apruebe. '
                      'Una vez aprobada, el reembolso se procesará automáticamente en tu método de pago original.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Debes indicar un motivo para el reembolso'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    await _requestReturn(context, reason);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SOLICITAR REEMBOLSO',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestReturn(BuildContext context, String reason) async {
    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      final emailRepo = ref.read(emailRepositoryProvider);
      
      final success = await orderRepo.requestReturn(
        order.id,
        reason,
      );
      
      if (success) {
        // Enviar email de confirmación
        await emailRepo.sendOrderStatusUpdate(
          order.shippingEmail ?? '',
          order.displayId,
          'reembolso solicitado',
          null,
        );

        ref.invalidate(userOrdersProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitud de reembolso enviada. Quedará pendiente de aprobación.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('No se pudo procesar la solicitud');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadInvoice(BuildContext context, {bool asPdf = true}) async {
    try {
      final pdf = pw.Document();
      final invoiceData = order.toInvoiceData();
      final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€');

      // Precargar imágenes de productos
      final items = invoiceData['items'] as List;
      final Map<int, pw.ImageProvider> productImages = {};
      for (int i = 0; i < items.length; i++) {
        final imageUrl = items[i]['image'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          try {
            final netImage = await networkImage(imageUrl);
            productImages[i] = netImage;
          } catch (_) {
            // Si no se puede cargar la imagen, se omite
          }
        }
      }
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('KICKSPREMIUM', 
                          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Factura de Compra', style: const pw.TextStyle(color: PdfColors.grey)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Factura: ${invoiceData['invoiceNumber']}', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Fecha: ${DateFormat('dd/MM/yyyy').format(order.createdAt)}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                
                // Customer Info
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Datos del Cliente', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text('Nombre: ${invoiceData['customerName']}'),
                      pw.Text('Email: ${invoiceData['customerEmail']}'),
                      if (invoiceData['customerPhone'].isNotEmpty)
                        pw.Text('Teléfono: ${invoiceData['customerPhone']}'),
                      if (invoiceData['shippingAddress'].isNotEmpty)
                        pw.Text('Dirección: ${invoiceData['shippingAddress']}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // Items Table Header
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  color: PdfColors.amber,
                  child: pw.Row(
                    children: [
                      pw.SizedBox(width: 45),
                      pw.Expanded(flex: 3, child: pw.Text('Producto', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(child: pw.Text('Talla', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), 
                        textAlign: pw.TextAlign.center)),
                      pw.Expanded(child: pw.Text('Cant.', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), 
                        textAlign: pw.TextAlign.center)),
                      pw.Expanded(child: pw.Text('Precio', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), 
                        textAlign: pw.TextAlign.right)),
                      pw.Expanded(child: pw.Text('Total', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), 
                        textAlign: pw.TextAlign.right)),
                    ],
                  ),
                ),
                
                // Items
                ...((invoiceData['items'] as List).asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 45,
                        height: 45,
                        child: productImages.containsKey(idx)
                          ? pw.Image(productImages[idx]!, fit: pw.BoxFit.contain)
                          : pw.Container(
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey200,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text('N/A', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                            ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Expanded(flex: 3, child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(item['name'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(item['brand'], style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                        ],
                      )),
                      pw.Expanded(child: pw.Text(item['size'], textAlign: pw.TextAlign.center)),
                      pw.Expanded(child: pw.Text('${item['quantity']}', textAlign: pw.TextAlign.center)),
                      pw.Expanded(child: pw.Text(currencyFormat.format(item['unitPrice']), 
                        textAlign: pw.TextAlign.right)),
                      pw.Expanded(child: pw.Text(currencyFormat.format(item['total']), 
                        textAlign: pw.TextAlign.right)),
                    ],
                  ),
                );
                })),
                
                pw.SizedBox(height: 20),
                
                // Totals
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      if ((invoiceData['discount'] as double) > 0) ...[
                        pw.Text('Subtotal: ${currencyFormat.format(invoiceData['subtotal'] + invoiceData['discount'])}'),
                        pw.Text('Descuento (${invoiceData['discountCode']}): -${currencyFormat.format(invoiceData['discount'])}',
                          style: const pw.TextStyle(color: PdfColors.green)),
                      ],
                      pw.SizedBox(height: 8),
                      pw.Text('TOTAL: ${currencyFormat.format(invoiceData['total'])}',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 40),
                
                // Footer
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('¡Gracias por tu compra!', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('Si tienes alguna pregunta, contáctanos en support@kickspremium.com',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final fileName = 'Factura_${invoiceData['invoiceNumber']}.pdf';

      if (asPdf) {
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF generado'), backgroundColor: Colors.green),
          );
        }
      } else {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: fileName,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generando factura: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cancelar Pedido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas cancelar el pedido #${order.displayId}?\n\n'
              'El reembolso se procesará automáticamente.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Ej: Ya no lo necesito, pedí la talla incorrecta...',
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, mantener'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _cancelOrder(context, reasonController.text.trim());
            },
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(BuildContext context, [String? reason]) async {
    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      final emailRepo = ref.read(emailRepositoryProvider);
      
      final success = await orderRepo.cancelOrder(order.id, reason: reason);
      
      if (success) {
        // Enviar email con factura de cancelación/reembolso
        await emailRepo.sendCancellationInvoice(
          order.shippingEmail ?? '',
          order.displayId,
          order.totalPrice / 100,
          order.shippingName ?? 'Cliente',
          order.items.map((item) => {
            'name': item.productName,
            'size': item.size,
            'quantity': item.quantity,
            'price': item.price / 100,
          }).toList(),
          reason: reason,
        );

        ref.invalidate(userOrdersProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pedido cancelado y reembolsado. Recibirás la factura por email.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('No se pudo cancelar el pedido');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatAddress(Map<String, dynamic> address) {
    final parts = <String>[];
    if (address['line1'] != null) parts.add(address['line1']);
    if (address['line2'] != null) parts.add(address['line2']);
    if (address['city'] != null) parts.add(address['city']);
    if (address['state'] != null) parts.add(address['state']);
    if (address['postal_code'] != null) parts.add(address['postal_code']);
    if (address['country'] != null) parts.add(address['country']);
    return parts.join(', ');
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Image
          if (item.productImage.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image.network(
                  item.productImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.image, size: 20),
                  ),
                ),
              ),
            ),
          
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productBrand.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Talla: ${item.size} | Cantidad: ${item.quantity}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),

          // Price
          Text(
            currencyFormat.format((item.price * item.quantity) / 100),
            style: TextStyle(
              color: Colors.orange[300],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.2),
        border: Border.all(color: config.color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'completed':
        return _StatusConfig(Colors.green, 'Completado');
      case 'pending':
        return _StatusConfig(Colors.yellow, 'Pendiente');
      case 'paid':
        return _StatusConfig(Colors.blue, 'Pagado');
      case 'processing':
        return _StatusConfig(Colors.cyan, 'Procesando');
      case 'shipped':
        return _StatusConfig(Colors.indigo, 'Enviado');
      case 'delivered':
        return _StatusConfig(Colors.teal, 'Entregado');
      case 'failed':
        return _StatusConfig(Colors.red, 'Fallido');
      case 'cancelled':
        return _StatusConfig(Colors.grey, 'Cancelado');
      case 'refunded':
        return _StatusConfig(Colors.purple, 'Reembolsado');
      default:
        return _StatusConfig(Colors.grey, status);
    }
  }
}

class _ReturnStatusBadge extends StatelessWidget {
  final String status;

  const _ReturnStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (status) {
      case 'requested':
        label = 'Devolución Solicitada';
        break;
      case 'approved':
        label = 'Devolución Aprobada';
        break;
      case 'received':
        label = 'Devolución Recibida';
        break;
      case 'refunded':
        label = 'Reembolsado';
        break;
      default:
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusConfig {
  final Color color;
  final String label;

  _StatusConfig(this.color, this.label);
}
