// ============================================================================
// EJEMPLOS DE USO - ADMIN PANEL SINCRONIZADO
// ============================================================================

// IMPORTANTE: Estos ejemplos muestran cómo usar los nuevos providers y métodos

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickspremium_mobile/logic/providers.dart';

// ============================================================================
// EJEMPLO 1: OBTENER ESTADÍSTICAS DEL DASHBOARD
// ============================================================================

class DashboardExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return statsAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) {
        print('❌ Error: $err');
        return Text('Error al cargar estadísticas');
      },
      data: (stats) {
        return Column(
          children: [
            Text('Órdenes hoy: ${stats['ordersToday']}'),
            Text('Ingresos hoy: \$${stats['revenueToday']}'),
            Text('Productos: ${stats['totalProducts']}'),
            Text('Stock bajo: ${stats['lowStockProducts']}'),
            Text('Actualizado: ${stats['lastUpdated']}'),
          ],
        );
      },
    );
  }
}

// ============================================================================
// EJEMPLO 2: OBTENER ÓRDENES FILTRADAS POR ESTADO
// ============================================================================

class OrdersByStatusExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener solo órdenes procesando
    final ordersAsync = ref.watch(
      adminOrdersByStatusProvider('processing'),
    );

    return ordersAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (orders) {
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return ListTile(
              title: Text('Orden ${order.id.substring(0, 8)}'),
              subtitle: Text('Total: \$${order.totalPrice / 100}'),
              trailing: Text(order.status),
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// EJEMPLO 3: ACTUALIZAR ESTADO DE ORDEN Y SINCRONIZAR
// ============================================================================

class UpdateOrderStatusExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // Actualizar orden
        final success = await ref.read(adminRepositoryProvider).updateOrderStatus(
          'orden-id-aqui',
          'shipped',
        );

        if (success) {
          // Invalidar providers para forzar recarga
          ref.invalidate(adminDashboardStatsProvider);
          ref.invalidate(adminAllOrdersProvider);
          ref.invalidate(adminOrderStatsProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Orden actualizada')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al actualizar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Text('Actualizar a Enviado'),
    );
  }
}

// ============================================================================
// EJEMPLO 4: PRODUCTOS CON BAJO STOCK
// ============================================================================

class LowStockAlertsExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockAsync = ref.watch(adminLowStockProductsProvider);

    return lowStockAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (lowStockProducts) {
        if (lowStockProducts.isEmpty) {
          return Text('✅ Todo el stock está bien');
        }

        return Column(
          children: lowStockProducts.map((product) {
            return Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Stock: ${product.stock}', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Editar producto
                    },
                    child: Text('Reponer'),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ============================================================================
// EJEMPLO 5: CREAR NUEVO PRODUCTO
// ============================================================================

class CreateProductExample extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateProductExample> createState() => _CreateProductExampleState();
}

class _CreateProductExampleState extends ConsumerState<CreateProductExample> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Nombre'),
        ),
        TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Precio'),
        ),
        TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Stock'),
        ),
        ElevatedButton(
          onPressed: () async {
            final product = Product(
              id: '',
              name: nameController.text,
              slug: nameController.text.toLowerCase().replaceAll(' ', '-'),
              price: (double.parse(priceController.text) * 100).toInt(),
              stock: int.parse(stockController.text),
              categoryId: '',
              description: '',
              images: [],
              sizesAvailable: {},
              tags: [],
              isFeatured: false,
              isLimitedEdition: false,
              isActive: true,
              createdAt: DateTime.now(),
            );

            final success = await ref.read(adminRepositoryProvider).upsertProduct(product);

            if (success && mounted) {
              // Invalidar para recargar lista
              ref.invalidate(adminAllProductsProvider);
              ref.invalidate(adminDashboardStatsProvider);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ Producto creado')),
              );

              // Limpiar
              nameController.clear();
              priceController.clear();
              stockController.clear();
            }
          },
          child: Text('Crear Producto'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }
}

// ============================================================================
// EJEMPLO 6: ANÁLISIS DE INGRESOS POR PERÍODO
// ============================================================================

class RevenueAnalyticsExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = DateTime(2026, 1, 1);
    final endDate = DateTime(2026, 1, 31);

    final analyticsAsync = ref.watch(
      adminRevenueAnalyticsProvider((startDate, endDate)),
    );

    return analyticsAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (analytics) {
        return Column(
          children: [
            Text(
              'Ingresos totales: \$${analytics['totalRevenue']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Órdenes: ${analytics['totalOrders']}'),
            Text(
              'Promedio por orden: \$${analytics['averageOrderValue']}',
            ),
            // dailyRevenue es Map<String, double>
            Text('Ingresos por día:'),
            ...(analytics['dailyRevenue'] as Map<String, double>)
                .entries
                .map((e) => Text('${e.key}: \$${e.value}'))
                .toList(),
          ],
        );
      },
    );
  }
}

// ============================================================================
// EJEMPLO 7: SINCRONIZACIÓN CON STRIPE - ÓRDENES PAGADAS
// ============================================================================

class StripePaidOrdersExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paidOrdersAsync = ref.watch(stripePaidOrdersProvider);

    return paidOrdersAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error sincronizando con Stripe: $err'),
      data: (paidOrders) {
        return Column(
          children: [
            Text('Órdenes pagadas: ${paidOrders.length}'),
            ListView.builder(
              itemCount: paidOrders.length,
              itemBuilder: (context, index) {
                final order = paidOrders[index];
                return ListTile(
                  title: Text('Orden ${order['id'].toString().substring(0, 8)}'),
                  subtitle: Text(
                    'Total: \$${(order['total_price'] as num) / 100}',
                  ),
                  trailing: Chip(label: Text('✅ Pagada')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// EJEMPLO 8: RESUMEN DE PAGOS DESDE STRIPE
// ============================================================================

class StripePaymentSummaryExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = DateTime(2026, 1, 1);
    final endDate = DateTime(2026, 1, 31);

    final summaryAsync = ref.watch(
      stripePaymentSummaryProvider((startDate, endDate)),
    );

    return summaryAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (summary) {
        return Column(
          children: [
            Text(
              'Pagos Exitosos: \$${summary['totalPaid']}',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            Text('Órdenes: ${summary['paidOrderCount']}'),
            SizedBox(height: 16),
            Text(
              'Pagos Fallidos: \$${summary['totalFailed']}',
              style: TextStyle(color: Colors.red),
            ),
            Text('Órdenes: ${summary['failedOrderCount']}'),
            SizedBox(height: 16),
            Text(
              'Promedio por orden: \$${summary['averageOrderValue']}',
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// EJEMPLO 9: SOLICITUDES DE DEVOLUCIÓN
// ============================================================================

class ReturnRequestsExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnsAsync = ref.watch(adminReturnRequestsProvider);

    return returnsAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (returns) {
        if (returns.isEmpty) {
          return Text('Sin solicitudes de devolución');
        }

        return Column(
          children: returns.map((order) {
            return Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Orden #${order.id.substring(0, 8)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Estado devolución: ${order.returnStatus}'),
                  Text('Total: \$${order.totalPrice / 100}'),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(adminRepositoryProvider)
                              .updateReturnStatus(order.id, 'approved');
                          ref.invalidate(adminReturnRequestsProvider);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: Text('Aprobar'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(adminRepositoryProvider)
                              .updateReturnStatus(order.id, 'rejected');
                          ref.invalidate(adminReturnRequestsProvider);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text('Rechazar'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ============================================================================
// EJEMPLO 10: ESTADÍSTICAS DE ÓRDENES POR ESTADO
// ============================================================================

class OrderStatsExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminOrderStatsProvider);

    return statsAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (stats) {
        return Column(
          children: stats.entries.map((entry) {
            final statusLabel = _getStatusLabel(entry.key);
            final count = entry.value;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(statusLabel),
                  Chip(
                    label: Text(count.toString()),
                    backgroundColor: _getStatusColor(entry.key),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _getStatusLabel(String status) {
    const labels = {
      'pending': 'Pendientes',
      'processing': 'Procesando',
      'shipped': 'Enviadas',
      'delivered': 'Entregadas',
      'cancelled': 'Canceladas',
    };
    return labels[status] ?? status;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'processing':
      case 'shipped':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ============================================================================
// EJEMPLO 11: REFRESH MANUAL DE TODOS LOS DATOS
// ============================================================================

class RefreshAllDataExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      icon: Icon(Icons.refresh),
      label: Text('Actualizar Todo'),
      onPressed: () {
        // Invalidar todos los providers de admin
        ref.invalidate(adminDashboardStatsProvider);
        ref.invalidate(adminAllOrdersProvider);
        ref.invalidate(adminAllProductsProvider);
        ref.invalidate(adminAllCategoriesProvider);
        ref.invalidate(adminAllUsersProvider);
        ref.invalidate(adminAllDiscountCodesProvider);
        ref.invalidate(adminOrderStatsProvider);
        ref.invalidate(stripePaidOrdersProvider);
        ref.invalidate(adminReturnRequestsProvider);
        ref.invalidate(adminLowStockProductsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Sincronizando datos...')),
        );
      },
    );
  }
}

// ============================================================================
// NOTAS IMPORTANTES
// ============================================================================

/*
1. TODOS LOS PROVIDERS USAN AUTOINVALIDATE:
   - Se invalidan automáticamente al cambiar datos
   - Usa ref.invalidate() para forzar recarga

2. ERROR HANDLING:
   - Siempre usa .when() para manejar loading/error/data
   - Muestra mensajes de error al usuario
   - Ofrece opción para reintentar

3. SINCRONIZACIÓN:
   - Stripe se sincroniza automáticamente
   - Usa webhooks para actualizaciones en tiempo real
   - BD siempre es fuente de verdad

4. PERFORMANCE:
   - No regeneres providers innecesariamente
   - Usa autoDispose para liberar memoria
   - Cachea resultados cuando puedas

5. SEGURIDAD:
   - Todos los providers validan is_admin
   - RLS policies protegen en BD
   - Logs registran cambios importantes
*/
