import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/providers.dart';
import '../../../data/models/order.dart';
import '../../../data/models/product.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/discount_code.dart';
import '../../../data/models/category.dart';
import 'package:intl/intl.dart';

// ============================================================================
// PANTALLA PRINCIPAL - ADMIN PANEL
// ============================================================================

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  late final PageController _pageController;

  final List<AdminSection> _sections = [
    AdminSection(icon: Icons.dashboard, label: 'Dashboard', key: 'dash'),
    AdminSection(icon: Icons.shopping_bag, label: 'Órdenes', key: 'orders'),
    AdminSection(icon: Icons.inventory, label: 'Productos', key: 'products'),
    AdminSection(icon: Icons.category, label: 'Categorías', key: 'categories'),
    AdminSection(icon: Icons.local_offer, label: 'Cupones', key: 'coupons'),
    AdminSection(icon: Icons.people, label: 'Usuarios', key: 'users'),
    AdminSection(icon: Icons.email, label: 'Email', key: 'email'),
    AdminSection(icon: Icons.bar_chart, label: 'Finanzas', key: 'finance'),
    AdminSection(icon: Icons.settings, label: 'Config', key: 'settings'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(adminSelectedSectionProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildMainContent(selectedIndex),
      bottomNavigationBar: _buildBottomNav(selectedIndex),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 2,
      title: const Text(
        'KICKSPREMIUM ADMIN',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.blue),
          tooltip: 'Actualizar datos',
          onPressed: _refreshAllData,
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.red),
          tooltip: 'Cerrar sesión',
          onPressed: _showLogoutDialog,
        ),
      ],
    );
  }

  Widget _buildMainContent(int selectedIndex) {
    final screens = [
      const AdminDashboardMobile(),
      const AdminOrdersMobile(),
      const AdminProductsMobile(),
      const AdminCategoriesMobile(),
      const AdminCouponsMobile(),
      const AdminUsersMobile(),
      const AdminEmailsMobile(),
      const AdminFinanceMobile(),
      const AdminSettingsMobile(),
    ];

    if (selectedIndex < 0 || selectedIndex >= screens.length) {
      return const AdminDashboardMobile();
    }

    return screens[selectedIndex];
  }

  Widget _buildBottomNav(int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_sections.length, (index) {
                final section = _sections[index];
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    ref.read(adminSelectedSectionProvider.notifier).setSection(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          section.icon,
                          color: isSelected ? Colors.blue : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section.label,
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.grey,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _refreshAllData() {
    // Invalidar todos los providers de admin para forzar recarga
    ref.invalidate(adminDashboardStatsProvider);
    ref.invalidate(adminAllOrdersProvider);
    ref.invalidate(adminAllProductsProvider);
    ref.invalidate(adminAllCategoriesProvider);
    ref.invalidate(adminAllUsersProvider);
    ref.invalidate(adminAllDiscountCodesProvider);
    ref.invalidate(adminOrderStatsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Datos sincronizados con el servidor'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Deseas cerrar la sesión?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(supabaseClientProvider).auth.signOut();
              context.go('/');
            },
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Modelo de sección del admin
class AdminSection {
  final IconData icon;
  final String label;
  final String key;

  AdminSection({
    required this.icon,
    required this.label,
    required this.key,
  });
}

// ============================================================================
// DASHBOARD - ESTADÍSTICAS EN TIEMPO REAL
// ============================================================================

class AdminDashboardMobile extends ConsumerWidget {
  const AdminDashboardMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final orderStatsAsync = ref.watch(adminOrderStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('❌ Error: $err', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(adminDashboardStatsProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjetas de estadísticas principales
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _StatCard(
                  title: 'Órdenes Hoy',
                  value: stats['ordersToday'].toString(),
                  icon: Icons.shopping_bag,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Ingresos Hoy',
                  value: '\$${(stats['revenueToday'] as num).toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'Usuarios Nuevos',
                  value: stats['newUsersToday'].toString(),
                  icon: Icons.person_add,
                  color: Colors.purple,
                ),
                _StatCard(
                  title: 'Productos',
                  value: stats['totalProducts'].toString(),
                  icon: Icons.inventory,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Stock Bajo',
                  value: stats['lowStockProducts'].toString(),
                  icon: Icons.warning,
                  color: Colors.red,
                ),
                _StatCard(
                  title: 'Por Enviar',
                  value: stats['pendingShipments'].toString(),
                  icon: Icons.local_shipping,
                  color: Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sección de ingresos totales
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingresos Totales',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${(stats['totalRevenue'] as num).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Actualizado: ${_formatDateTime(stats['lastUpdated'])}',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Estado de Órdenes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Estadísticas de órdenes
            orderStatsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
              data: (orderStats) => Column(
                children: orderStats.entries
                    .map((e) => _OrderStatusRow(status: e.key, count: e.value))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) {
      return 'N/A';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusRow extends StatelessWidget {
  final String status;
  final int count;

  const _OrderStatusRow({
    required this.status,
    required this.count,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'shipped':
        return Colors.cyan;
      case 'delivered':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    const labels = {
      'completed': 'Completadas',
      'processing': 'Procesando',
      'pending': 'Pendientes',
      'cancelled': 'Canceladas',
      'shipped': 'Enviadas',
      'delivered': 'Entregadas',
    };
    return labels[status] ?? status;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getStatusLabel(status),
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ÓRDENES - SINCRONIZADAS CON STRIPE
// ============================================================================

class AdminOrdersMobile extends ConsumerWidget {
  const AdminOrdersMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminAllOrdersProvider);

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('❌ Error: $err', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(adminAllOrdersProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (orders) => orders.isEmpty
          ? const Center(
              child: Text(
                'Sin órdenes',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
      case 'paid':
        return Colors.green;
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      case 'shipped':
      case 'delivered':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getStatusColor(order.status).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Orden #${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${(order.totalPrice / 100).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showOrderDetails(context, ref, order),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 32),
            ),
            child: const Text('Ver Detalles'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, WidgetRef ref, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailSheet(order: order),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}

class _OrderDetailSheet extends ConsumerWidget {
  final Order order;

  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Orden #${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'Estado',
                    value: order.status.toUpperCase(),
                    valueColor: Colors.blue,
                    isBold: true,
                  ),
                  _InfoRow(
                    label: 'Total',
                    value: '\$${(order.totalPrice / 100).toStringAsFixed(2)}',
                    valueColor: Colors.green,
                    isBold: true,
                  ),
                  _InfoRow(
                    label: 'Fecha',
                    value: DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                  ),
                  _InfoRow(
                    label: 'Stripe Session',
                    value: order.stripeSessionId?.substring(0, 20) ?? 'N/A',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cambiar Estado',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['processing', 'shipped', 'delivered', 'cancelled'].map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await ref
                                  .read(adminRepositoryProvider)
                                  .updateOrderStatus(order.id, status);

                              if (success && context.mounted) {
                                ref.invalidate(adminAllOrdersProvider);
                                ref.invalidate(adminDashboardStatsProvider);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Orden actualizada a $status')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: order.status == status
                                  ? Colors.blue
                                  : Colors.grey[800],
                            ),
                            child: Text(status),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PRODUCTOS - CON SINCRONIZACIÓN DE STOCK
// ============================================================================

class AdminProductsMobile extends ConsumerWidget {
  const AdminProductsMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminAllProductsProvider);
    final lowStockAsync = ref.watch(adminLowStockProductsProvider);

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
      ),
      data: (products) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Todos los Productos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showProductForm(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            lowStockAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (lowStockProducts) => lowStockProducts.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${lowStockProducts.length} productos con stock bajo (< 5)',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(product: product, onTap: () {
                  _showProductDetails(context, ref, product);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProductForm(BuildContext context, WidgetRef ref, {Product? product}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Product Form',
      pageBuilder: (context, _, __) => _ProductFormDialog(product: product),
    ).then((value) {
      if (value == true) {
        ref.invalidate(adminAllProductsProvider);
        ref.invalidate(adminDashboardStatsProvider);
      }
    });
  }

  void _showProductDetails(BuildContext context, WidgetRef ref, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailSheet(product: product),
    ).then((value) {
      if (value == true) {
        ref.invalidate(adminAllProductsProvider);
        ref.invalidate(adminDashboardStatsProvider);
      }
    });
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stock < 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLowStock ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowStock ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Stock: ${product.stock}',
                  style: TextStyle(
                    color: isLowStock ? Colors.red : Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${(product.price / 100).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              Text(
                product.brand,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 32),
            ),
            child: const Text('Ver Detalles'),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailSheet extends ConsumerWidget {
  final Product product;

  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Precio', value: '\$${(product.price / 100).toStringAsFixed(2)}', valueColor: Colors.green, isBold: true),
                  _InfoRow(label: 'Stock', value: product.stock.toString()),
                  _InfoRow(label: 'Brand', value: product.brand),
                  _InfoRow(label: 'SKU', value: product.sku),
                  _InfoRow(label: 'Categoría', value: product.categoryId),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showProductForm(context, ref, product: product);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              ElevatedButton.icon(
                onPressed: () => _confirmDeleteProduct(context, ref, product),
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context, WidgetRef ref, {Product? product}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Product Form',
      pageBuilder: (context, _, __) => _ProductFormDialog(product: product),
    ).then((value) {
      if (value == true) {
        ref.invalidate(adminAllProductsProvider);
        ref.invalidate(adminDashboardStatsProvider);
        Navigator.pop(context, true);
      }
    });
  }

  void _confirmDeleteProduct(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Eliminar Producto', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref.read(adminRepositoryProvider).deleteProduct(product.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context, true);
                ref.invalidate(adminAllProductsProvider);
                ref.invalidate(adminDashboardStatsProvider);
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product;

  const _ProductFormDialog({this.product});

  @override
  ConsumerState<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<_ProductFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _brandController;
  late final TextEditingController _skuController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product != null ? (widget.product!.price / 100).toStringAsFixed(2) : '',
    );
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _brandController = TextEditingController(text: widget.product?.brand ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final price = (double.parse(_priceController.text) * 100).toInt();
      final stock = int.parse(_stockController.text);

      final newProduct = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        price: price,
        stock: stock,
        brand: _brandController.text,
        sku: _skuController.text,
        categoryId: widget.product?.categoryId ?? '',
        slug: widget.product?.slug ?? _nameController.text.toLowerCase().replaceAll(' ', '-'),
        description: widget.product?.description ?? '',
        images: widget.product?.images ?? [],
        sizesAvailable: widget.product?.sizesAvailable ?? {},
        isFeatured: widget.product?.isFeatured ?? false,
        isLimitedEdition: widget.product?.isLimitedEdition ?? false,
        isActive: widget.product?.isActive ?? true,
        costPrice: widget.product?.costPrice,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref.read(adminRepositoryProvider).upsertProduct(newProduct);
      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.product == null ? 'Nuevo Producto' : 'Editar Producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FormEditField(label: 'Nombre', controller: _nameController, validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null),
            _FormEditField(label: 'Precio', controller: _priceController, keyboardType: TextInputType.number, validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null),
            _FormEditField(label: 'Stock', controller: _stockController, keyboardType: TextInputType.number, validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null),
            _FormEditField(label: 'Brand', controller: _brandController),
            _FormEditField(label: 'SKU', controller: _skuController),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isSaving ? const CircularProgressIndicator() : const Text('Guardar Producto'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormEditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _FormEditField({
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PLACEHOLDERS PARA OTRAS SECCIONES (COMPLETA SEGÚN NECESITES)
// ============================================================================

class AdminCategoriesMobile extends ConsumerWidget {
  const AdminCategoriesMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text('Categorías - En desarrollo', style: TextStyle(color: Colors.grey)),
    );
  }
}

class AdminCouponsMobile extends ConsumerWidget {
  const AdminCouponsMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text('Cupones - En desarrollo', style: TextStyle(color: Colors.grey)),
    );
  }
}

class AdminUsersMobile extends ConsumerWidget {
  const AdminUsersMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text('Usuarios - En desarrollo', style: TextStyle(color: Colors.grey)),
    );
  }
}

class AdminEmailsMobile extends StatelessWidget {
  const AdminEmailsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Email - En desarrollo', style: TextStyle(color: Colors.grey)),
    );
  }
}

class AdminFinanceMobile extends StatelessWidget {
  const AdminFinanceMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Finanzas - En desarrollo', style: TextStyle(color: Colors.grey)),
    );
  }
}

class AdminSettingsMobile extends StatefulWidget {
  const AdminSettingsMobile({super.key});

  @override
  State<AdminSettingsMobile> createState() => _AdminSettingsMobileState();
}

class _AdminSettingsMobileState extends State<AdminSettingsMobile> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Configuración - En desarrollo', style: TextStyle(color: Colors.grey)),
    );
  }
}
