import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

/// Modelo de Factura de Abono (Credit Note)
/// Representa una devolución/reembolso con importe negativo
class CreditNote {
  final String creditNoteNumber;
  final String originalInvoiceNumber;
  final String orderId;
  final DateTime createdAt;
  final String customerName;
  final String customerEmail;
  final double refundAmount; // Siempre positivo, pero se mostrará como negativo
  final String reason;
  final List<CreditNoteItem> items;

  CreditNote({
    required this.creditNoteNumber,
    required this.originalInvoiceNumber,
    required this.orderId,
    required this.createdAt,
    required this.customerName,
    required this.customerEmail,
    required this.refundAmount,
    required this.reason,
    required this.items,
  });

  /// Genera un número de factura de abono único
  static String generateCreditNoteNumber(String orderId) {
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    final shortId = orderId.length > 6 ? orderId.substring(0, 6) : orderId;
    return 'KP-AB-$date-$shortId';
  }

  /// El importe como valor negativo para cuadrar la caja
  double get negativeAmount => -refundAmount;

  /// Importe formateado con signo negativo
  String get formattedAmount => '-€${(refundAmount / 100).toStringAsFixed(2)}';
}

class CreditNoteItem {
  final String productName;
  final String size;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  CreditNoteItem({
    required this.productName,
    required this.size,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

/// Servicio para generar y gestionar facturas de abono
class CreditNoteService {
  /// Genera una factura de abono para una devolución
  static CreditNote createCreditNote({
    required String orderId,
    required String orderDisplayId,
    required String customerName,
    required String customerEmail,
    required double refundAmount,
    required String reason,
    required List<Map<String, dynamic>> items,
  }) {
    final creditNoteItems = items.map((item) => CreditNoteItem(
      productName: item['name'] ?? 'Producto',
      size: item['size'] ?? '-',
      quantity: item['quantity'] ?? 1,
      unitPrice: (item['price'] ?? 0).toDouble(),
      totalPrice: ((item['price'] ?? 0) * (item['quantity'] ?? 1)).toDouble(),
    )).toList();

    return CreditNote(
      creditNoteNumber: CreditNote.generateCreditNoteNumber(orderId),
      originalInvoiceNumber: 'KP-$orderDisplayId',
      orderId: orderId,
      createdAt: DateTime.now(),
      customerName: customerName,
      customerEmail: customerEmail,
      refundAmount: refundAmount,
      reason: reason,
      items: creditNoteItems,
    );
  }

  /// Genera el PDF de la factura de abono
  static Future<void> generateAndPrintCreditNote(
    BuildContext context,
    CreditNote creditNote,
  ) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('KICKS PREMIUM',
                            style: pw.TextStyle(
                                fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('Sneakers de Lujo',
                            style: const pw.TextStyle(color: PdfColors.grey)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.red100,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('FACTURA DE ABONO',
                              style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.red800)),
                          pw.SizedBox(height: 4),
                          pw.Text(creditNote.creditNoteNumber,
                              style: pw.TextStyle(
                                  fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Info boxes
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Customer info
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('DATOS DEL CLIENTE',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                    color: PdfColors.grey600)),
                            pw.SizedBox(height: 8),
                            pw.Text(creditNote.customerName),
                            pw.Text(creditNote.customerEmail),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    // Credit note info
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('DATOS DEL ABONO',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                    color: PdfColors.grey600)),
                            pw.SizedBox(height: 8),
                            pw.Text('Fecha: ${dateFormat.format(creditNote.createdAt)}'),
                            pw.Text('Factura original: ${creditNote.originalInvoiceNumber}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Reason
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber50,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('MOTIVO DEL ABONO',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                              color: PdfColors.grey600)),
                      pw.SizedBox(height: 4),
                      pw.Text(creditNote.reason),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Items header
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  color: PdfColors.grey200,
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 4, child: pw.Text('Producto',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      pw.Expanded(flex: 1, child: pw.Text('Talla',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                          textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 1, child: pw.Text('Cant.',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                          textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('Precio',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                          textAlign: pw.TextAlign.right)),
                      pw.Expanded(flex: 2, child: pw.Text('Importe',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                          textAlign: pw.TextAlign.right)),
                    ],
                  ),
                ),

                // Items
                ...creditNote.items.map((item) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 4, child: pw.Text(item.productName, style: const pw.TextStyle(fontSize: 10))),
                      pw.Expanded(flex: 1, child: pw.Text(item.size, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 1, child: pw.Text('${item.quantity}', style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text(currencyFormat.format(item.unitPrice / 100), style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                      pw.Expanded(flex: 2, child: pw.Text(
                        '-${currencyFormat.format(item.totalPrice / 100)}',  // Negativo
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.red700),
                        textAlign: pw.TextAlign.right,
                      )),
                    ],
                  ),
                )),

                pw.SizedBox(height: 20),

                // Totals
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 250,
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.red50,
                      border: pw.Border.all(color: PdfColors.red200),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Base Imponible:', style: const pw.TextStyle(fontSize: 11)),
                            pw.Text('-${currencyFormat.format((creditNote.refundAmount / 100) / 1.21)}',
                                style: pw.TextStyle(fontSize: 11, color: PdfColors.red700)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('IVA (21%):', style: const pw.TextStyle(fontSize: 11)),
                            pw.Text('-${currencyFormat.format(((creditNote.refundAmount / 100) / 1.21) * 0.21)}',
                                style: pw.TextStyle(fontSize: 11, color: PdfColors.red700)),
                          ],
                        ),
                        pw.Divider(color: PdfColors.red200),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('TOTAL ABONO:',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                            pw.Text('-${currencyFormat.format(creditNote.refundAmount / 100)}',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                    color: PdfColors.red800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                pw.SizedBox(height: 30),

                // Footer note
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('INFORMACIÓN IMPORTANTE',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Este documento es una factura rectificativa (abono) que anula total o parcialmente la factura original indicada. '
                        'El importe se reembolsará en un plazo de 5-7 días hábiles mediante el mismo método de pago utilizado en la compra.',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Company footer
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('KICKS PREMIUM S.L.',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('CIF: B12345678 | www.kickspremium.es | support@kickspremium.es',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Show print/save dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Abono_${creditNote.creditNoteNumber}.pdf',
    );
  }
}

/// Widget de botón para descargar factura de abono
class CreditNoteButton extends StatelessWidget {
  final String orderId;
  final String orderDisplayId;
  final String customerName;
  final String customerEmail;
  final double refundAmount;
  final String reason;
  final List<Map<String, dynamic>> items;

  const CreditNoteButton({
    super.key,
    required this.orderId,
    required this.orderDisplayId,
    required this.customerName,
    required this.customerEmail,
    required this.refundAmount,
    required this.reason,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        final creditNote = CreditNoteService.createCreditNote(
          orderId: orderId,
          orderDisplayId: orderDisplayId,
          customerName: customerName,
          customerEmail: customerEmail,
          refundAmount: refundAmount,
          reason: reason,
          items: items,
        );
        CreditNoteService.generateAndPrintCreditNote(context, creditNote);
      },
      icon: const Icon(Icons.receipt_long, size: 18),
      label: const Text('Descargar Abono'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red[300],
        side: BorderSide(color: Colors.red[300]!),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
