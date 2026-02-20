import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/providers.dart';
import '../../../data/models/order.dart';
import '../../../data/models/product.dart';
import '../../../data/models/category.dart';
import '../../../data/models/discount_code.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;


class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {

  final List<_AdminSection> _sections = [
    _AdminSection(icon: Icons.dashboard, label: 'Dash'),
    _AdminSection(icon: Icons.shopping_bag, label: 'Pedidos'),
    _AdminSection(icon: Icons.inventory, label: 'Prod'),
    _AdminSection(icon: Icons.category, label: 'Cat'),
    _AdminSection(icon: Icons.local_offer, label: 'Cupones'),
    _AdminSection(icon: Icons.people, label: 'Users'),
    _AdminSection(icon: Icons.bar_chart, label: 'Finanzas'),
    _AdminSection(icon: Icons.settings, label: 'Config'),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(adminSelectedSectionProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('KICKSPREMIUM ADMIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _buildMainContent(selectedIndex),
      bottomNavigationBar: _buildBottomNav(selectedIndex),
    );
  }

  Widget _buildMainContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const AdminDashboardMobile();
      case 1:
        return const AdminOrdersMobile();
      case 2:
        return const AdminProductsMobile();
      case 3:
        return const AdminCategoriesMobile();
      case 4:
        return const AdminCouponsMobile();
      case 5:
        return const AdminUsersMobile();
      case 6:
        return const AdminFinanceMobile();
      case 7:
        return const AdminSettingsMobile();
      default:
        return const AdminDashboardMobile();
    }
  }

  Widget _buildBottomNav(int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(_sections.length, (index) {
              final section = _sections[index];
              final isSelected = selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(adminSelectedSectionProvider.notifier).setSection(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber[700] : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          section.icon,
                          color: isSelected ? Colors.black : Colors.grey[400],
                          size: 18,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          section.label,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey[400],
                            fontSize: 8,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Salir del panel de administrador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AdminSection {
  final IconData icon;
  final String label;
  _AdminSection({required this.icon, required this.label});
}

// ========== DASHBOARD MOBILE ==========
class AdminDashboardMobile extends ConsumerWidget {
  const AdminDashboardMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Stats Grid 2x2
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              children: [
                _StatCard(
                  title: 'Pedidos Hoy', 
                  value: stats['ordersToday'].toString(), 
                  icon: Icons.shopping_bag, 
                  color: Colors.blue
                ),
                _StatCard(
                  title: 'Ingresos', 
                  value: '€${stats['revenueToday'].toStringAsFixed(2)}', 
                  icon: Icons.euro, 
                  color: Colors.green
                ),
                _StatCard(
                  title: 'Usuarios Nv.', 
                  value: stats['newUsersToday'].toString(), 
                  icon: Icons.people, 
                  color: Colors.purple
                ),
                _StatCard(
                  title: 'Prod. Totales', 
                  value: stats['totalProducts'].toString(), 
                  icon: Icons.inventory, 
                  color: Colors.orange
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // KPI Cards Row
            Row(
              children: [
                Expanded(
                  child: _KPICard(
                    title: 'Ventas del Mes',
                    value: '€${stats['monthlyRevenue']?.toStringAsFixed(2) ?? '0.00'}',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KPICard(
                    title: 'Pedidos Pendientes',
                    value: '${stats['pendingOrders'] ?? 0}',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _KPICard(
              title: 'Producto Más Vendido',
              value: stats['topProduct'] ?? 'Sin datos',
              icon: Icons.star,
              color: Colors.amber,
            ),
            
            const SizedBox(height: 24),
            
            // Sales Chart - Last 7 Days
            const Text(
              'Ventas Últimos 7 Días',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: _SalesChart(salesData: stats['salesLast7Days'] ?? []),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Email Access
            const Text(
              'Acceso Rápido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            const SizedBox(height: 12),
            
            _QuickActionCard(
              icon: Icons.add_box,
              title: 'Nuevo Producto',
              subtitle: 'Añadir sneaker al catálogo',
              color: Colors.pink,
              onTap: () => _showProductForm(context, ref),
            ),
            const SizedBox(height: 8),
            _QuickActionCard(
              icon: Icons.category,
              title: 'Gestionar Categorías',
              subtitle: 'Organizar colecciones',
              color: Colors.purple,
              onTap: () => ref.read(adminSelectedSectionProvider.notifier).setSection(3),
            ),
            const SizedBox(height: 8),
            _QuickActionCard(
              icon: Icons.shopping_bag,
              title: 'Ver Pedidos',
              subtitle: 'Gestionar órdenes',
              color: Colors.green,
              onTap: () => ref.read(adminSelectedSectionProvider.notifier).setSection(1),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Activity
            const Text(
              'Actividad Reciente (Pedidos)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            ref.watch(adminAllOrdersProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (orders) => Column(
                children: orders.take(5).map((order) => _ActivityItem(
                  title: 'Pedido #${order.displayId}',
                  subtitle: '${DateFormat('dd/MM HH:mm').format(order.createdAt)} - €${(order.totalPrice / 100).toStringAsFixed(2)}',
                  icon: Icons.receipt,
                  onTap: () => _showOrderDetails(context, order),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailSheet(order: order),
    );
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

// ========== ORDERS MOBILE ==========
class AdminOrdersMobile extends ConsumerWidget {
  const AdminOrdersMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminAllOrdersProvider);

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (orders) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return GestureDetector(
            onTap: () => _showOrderDetails(context, order),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pedido #${order.displayId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Cliente: ${order.shippingName ?? order.userId}', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  Text('Total: €${(order.totalPrice / 100).toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailSheet(order: order),
    );
  }

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
}

// ========== PRODUCTS MOBILE ==========
class AdminProductsMobile extends ConsumerWidget {
  const AdminProductsMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminAllProductsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text('Productos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () => _showProductForm(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nuevo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (products) => GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () => _showProductDetails(context, product),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: product.images.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(product.images.first, fit: BoxFit.cover, width: double.infinity),
                                  )
                                : const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text('€${(product.price / 100).toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                                Text(
                                  '${product.sizesAvailable.values.fold<int>(0, (sum, v) => sum + (v is int ? v : int.tryParse(v.toString()) ?? 0))} pares',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailSheet(product: product),
    );
  }
}

// ========== USERS MOBILE ==========
class AdminUsersMobile extends ConsumerWidget {
  const AdminUsersMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminAllUsersProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (users) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.isAdmin ? Colors.red[700] : Colors.amber[700],
                  child: Text(
                    user.fullName != null && user.fullName!.isNotEmpty 
                        ? user.fullName![0].toUpperCase() 
                        : 'U', 
                    style: const TextStyle(color: Colors.black)
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(user.email, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                      if (user.isAdmin)
                        Text('ADMINISTRADOR', style: TextStyle(fontSize: 9, color: Colors.red[400], fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (context) => [
                    const PopupMenuItem(child: Text('Ver Perfil')),
                    const PopupMenuItem(child: Text('Editar')),
                    const PopupMenuItem(child: Text('Suspender')),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ========== EMAILS MOBILE ==========
class AdminEmailsMobile extends StatelessWidget {
  const AdminEmailsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enviar Emails', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _EmailTypeCard(
            icon: Icons.shopping_cart,
            title: 'Confirmación de Compra',
            color: Colors.green,
            onTap: () {},
          ),
          _EmailTypeCard(
            icon: Icons.cancel,
            title: 'Cancelación de Pedido',
            color: Colors.red,
            onTap: () {},
          ),
          _EmailTypeCard(
            icon: Icons.local_shipping,
            title: 'Actualización de Envío',
            color: Colors.blue,
            onTap: () {},
          ),
          _EmailTypeCard(
            icon: Icons.campaign,
            title: 'Newsletter',
            color: Colors.purple,
            onTap: () {},
          ),
          _EmailTypeCard(
            icon: Icons.local_offer,
            title: 'Promoción',
            color: Colors.orange,
            onTap: () {},
          ),
          _EmailTypeCard(
            icon: Icons.shopping_basket,
            title: 'Carrito Abandonado',
            color: Colors.amber,
            onTap: () {},
          ),
          
          const SizedBox(height: 24),
          const Text('Historial Reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          ...List.generate(5, (index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.email, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email enviado a usuario${index + 1}@email.com', 
                        style: const TextStyle(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('Hace ${(index + 1) * 2} horas', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _EmailTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _EmailTypeCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.send, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

// ========== CATEGORIES MOBILE ==========
class AdminCategoriesMobile extends ConsumerWidget {
  const AdminCategoriesMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminAllCategoriesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text('Categorías', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCategoryForm(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nueva'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (categories) => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber[700],
                      child: Text(category.icon ?? '?', style: const TextStyle(color: Colors.black)),
                    ),
                    title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(category.slug, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                      onPressed: () => _showCategoryForm(context, ref, category: category),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ========== COUPONS MOBILE ==========
class AdminCouponsMobile extends ConsumerWidget {
  const AdminCouponsMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(adminAllDiscountCodesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text('Cupones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCouponForm(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nuevo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: couponsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (coupons) => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.local_offer, color: coupon.isActive ? Colors.green : Colors.grey),
                    title: Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    subtitle: Text(
                      coupon.discountType == 'percentage' 
                        ? '${coupon.discountValue}% de descuento'
                        : '€${(coupon.discountValue / 100).toStringAsFixed(2)} de descuento',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    trailing: Text(
                      coupon.isActive ? 'ACTIVO' : 'INACTIVO',
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                        color: coupon.isActive ? Colors.green : Colors.red
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ========== FINANCE MOBILE ==========
class AdminFinanceMobile extends ConsumerStatefulWidget {
  const AdminFinanceMobile({super.key});

  @override
  ConsumerState<AdminFinanceMobile> createState() => _AdminFinanceMobileState();
}

class _AdminFinanceMobileState extends ConsumerState<AdminFinanceMobile> {
  int _selectedPeriod = 1; // 0=24h, 1=7d, 2=1m, 3=total

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (stats) {
        // Period-based revenue
        final revenue24h = (stats['revenue24h'] as num?)?.toDouble() ?? 0.0;
        final revenue7d = (stats['revenue7d'] as num?)?.toDouble() ?? 0.0;
        final monthlyRevenue = (stats['monthlyRevenue'] as num?)?.toDouble() ?? 0.0;
        final totalRevenue = (stats['totalRevenue'] as num?)?.toDouble() ?? 0.0;

        final orders24h = stats['orders24h'] ?? 0;
        final orders7d = stats['orders7d'] ?? 0;
        final pendingOrders = stats['pendingOrders'] ?? 0;
        final totalOrdersAll = stats['totalOrdersAllTime'] ?? 0;
        final totalCost = (stats['totalCost'] as num?)?.toDouble() ?? 0.0;
        final totalProfit = (stats['totalProfit'] as num?)?.toDouble() ?? 0.0;

        // Select values based on period
        final periodLabels = ['24 Horas', '7 Días', '1 Mes', 'Total'];
        double periodRevenue;
        int periodOrders;
        switch (_selectedPeriod) {
          case 0: periodRevenue = revenue24h; periodOrders = orders24h; break;
          case 1: periodRevenue = revenue7d; periodOrders = orders7d; break;
          case 2: periodRevenue = monthlyRevenue; periodOrders = totalOrdersAll; break;
          case 3: periodRevenue = totalRevenue; periodOrders = totalOrdersAll; break;
          default: periodRevenue = revenue7d; periodOrders = orders7d;
        }
        final avgTicket = periodOrders > 0 ? periodRevenue / periodOrders : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Finanzas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Period selector
              Row(
                children: List.generate(4, (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = i),
                    child: Container(
                      margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedPeriod == i ? Colors.amber : Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _selectedPeriod == i ? Colors.amber : Colors.grey[700]!),
                      ),
                      child: Center(
                        child: Text(
                          periodLabels[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _selectedPeriod == i ? Colors.black : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 16),

              // Revenue & Orders cards
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ReportCard(title: 'Ingresos ${periodLabels[_selectedPeriod]}', value: '€${periodRevenue.toStringAsFixed(2)}', icon: Icons.trending_up, color: Colors.green),
                  _ReportCard(title: 'Pedidos', value: '$periodOrders', icon: Icons.shopping_bag, color: Colors.blue),
                  _ReportCard(title: 'Ticket Medio', value: '€${avgTicket.toStringAsFixed(2)}', icon: Icons.shopping_cart, color: Colors.purple),
                  _ReportCard(title: 'Pendientes', value: '$pendingOrders', icon: Icons.pending_actions, color: Colors.orange),
                ],
              ),

              const SizedBox(height: 20),

              // Cost & Profit section (compra-venta)
              const Text('Compra / Venta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _KPICard(
                      title: 'Coste Total',
                      value: '€${totalCost.toStringAsFixed(2)}',
                      icon: Icons.money_off,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KPICard(
                      title: 'Beneficio',
                      value: '€${totalProfit.toStringAsFixed(2)}',
                      icon: Icons.savings,
                      color: totalProfit >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _KPICard(
                      title: 'Ingresos Totales',
                      value: '€${totalRevenue.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KPICard(
                      title: 'Margen (%)',
                      value: totalRevenue > 0 ? '${(totalProfit / totalRevenue * 100).toStringAsFixed(1)}%' : '0%',
                      icon: Icons.pie_chart,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text('Ventas Últimos 7 Días', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                padding: const EdgeInsets.all(16),
                child: _SalesChart(salesData: stats['salesLast7Days'] ?? []),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[400]), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ========== SETTINGS MOBILE ==========
class AdminSettingsMobile extends StatefulWidget {
  const AdminSettingsMobile({super.key});

  @override
  State<AdminSettingsMobile> createState() => _AdminSettingsMobileState();
}

class _AdminSettingsMobileState extends State<AdminSettingsMobile> {
  bool _emailNotifications = true;
  bool _maintenanceMode = false;
  bool _stockAlerts = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Configuración', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        
        _SettingSwitch(
          title: 'Notificaciones por Email',
          subtitle: 'Recibir alertas de pedidos',
          value: _emailNotifications,
          onChanged: (v) => setState(() => _emailNotifications = v),
        ),
        _SettingSwitch(
          title: 'Modo Mantenimiento',
          subtitle: 'Desactivar la tienda',
          value: _maintenanceMode,
          onChanged: (v) => setState(() => _maintenanceMode = v),
        ),
        _SettingSwitch(
          title: 'Alertas de Stock',
          subtitle: 'Avisar cuando hay poco stock',
          value: _stockAlerts,
          onChanged: (v) => setState(() => _stockAlerts = v),
        ),
        
        const SizedBox(height: 24),
        const Text('General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        
        _SettingItem(title: 'Datos de la Tienda', icon: Icons.store, onTap: () {}),
        _SettingItem(title: 'Métodos de Pago', icon: Icons.payment, onTap: () {}),
        _SettingItem(title: 'Opciones de Envío', icon: Icons.local_shipping, onTap: () {}),
        _SettingItem(title: 'Impuestos', icon: Icons.receipt, onTap: () {}),
      ],
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.amber[700],
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(child: Text(title)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
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
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Detalle Pedido #${order.displayId}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: ListView(
              children: [
                _InfoRow(label: 'Estado', value: order.statusLabel, valueColor: _getStatusColor(order.status)),
                _InfoRow(label: 'Fecha', value: DateFormat('dd MMM yyyy HH:mm').format(order.createdAt)),
                _InfoRow(label: 'Cliente', value: order.shippingName ?? 'Desconocido'),
                _InfoRow(label: 'Email', value: order.shippingEmail ?? 'N/A'),
                _InfoRow(label: 'Teléfono', value: order.shippingPhone ?? 'N/A'),
                if (order.status == 'cancelled' && order.cancelledReason != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Motivo de cancelación', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(order.cancelledReason!, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Text('Productos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ...order.items.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productName, style: const TextStyle(fontSize: 14)),
                  subtitle: Text('Talla: ${item.size} x ${item.quantity}'),
                  trailing: Text('€${(item.price / 100).toStringAsFixed(2)}'),
                )),
                const Divider(color: Colors.grey),
                _InfoRow(label: 'Subtotal', value: '€${(order.totalPrice / 100).toStringAsFixed(2)}'),
                _InfoRow(label: 'Envío', value: '€0.00'),
                _InfoRow(label: 'Total', value: '€${(order.totalPrice / 100).toStringAsFixed(2)}', isBold: true),
                const SizedBox(height: 30),
                const Text('Dirección de Envío', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Text(order.shippingAddress?.toString() ?? 'No especificada', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 30),
                // Descargar factura
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadAdminInvoice(context, asPdf: true),
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: const Text('Guardar PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber,
                          side: const BorderSide(color: Colors.amber),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadAdminInvoice(context, asPdf: false),
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('Imprimir'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[300],
                          side: BorderSide(color: Colors.grey[600]!),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ===== CAMBIAR ESTADO =====
                if (order.status != 'completed' && order.status != 'cancelled' && order.status != 'refunded') ...[
                  const SizedBox(height: 8),
                  const Text('Cambiar Estado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _StatusChangeDropdown(
                    currentStatus: order.status,
                    onChanged: (newStatus) {
                      if (newStatus == 'cancelled') {
                        _showCancelWithReasonDialog(context, ref);
                      } else {
                        _updateStatus(context, ref, newStatus);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // ===== SOLICITUD DE REEMBOLSO =====
                if (order.returnStatus == 'requested') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.orange, size: 22),
                            const SizedBox(width: 8),
                            const Text(
                              'Solicitud de Reembolso Pendiente',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        if (order.cancelledReason != null && order.cancelledReason!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Motivo del cliente:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(order.cancelledReason!, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () => _approveRefund(context, ref),
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: const Text('Aprobar Reembolso'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () => _rejectRefund(context, ref),
                                icon: const Icon(Icons.cancel, size: 18),
                                label: const Text('Rechazar'),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Future<void> _approveRefund(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Aprobar Reembolso'),
        content: Text(
          '¿Aprobar el reembolso de €${(order.totalPrice / 100).toStringAsFixed(2)} '
          'para el pedido #${order.displayId}?\n\n'
          'Se procesará el reembolso en Stripe y se enviará la factura de cancelación al cliente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, aprobar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref.read(adminRepositoryProvider).approveRefundRequest(order.id);
    if (success) {
      // Enviar email con factura de cancelación
      final emailRepo = ref.read(emailRepositoryProvider);
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
        reason: order.cancelledReason,
      );
    }

    if (context.mounted) {
      Navigator.pop(context);
      ref.invalidate(adminAllOrdersProvider);
      ref.invalidate(adminReturnRequestsProvider);
      ref.invalidate(adminDashboardStatsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Reembolso aprobado y procesado. Factura enviada al cliente.'
              : 'Error al procesar el reembolso'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectRefund(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Rechazar Reembolso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Rechazar la solicitud de reembolso del pedido #${order.displayId}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Motivo del rechazo (opcional)',
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref.read(adminRepositoryProvider).rejectRefundRequest(
      order.id,
      reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
    );
    if (context.mounted) {
      Navigator.pop(context);
      ref.invalidate(adminAllOrdersProvider);
      ref.invalidate(adminReturnRequestsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Solicitud de reembolso rechazada' : 'Error al rechazar'),
          backgroundColor: success ? Colors.orange : Colors.red,
        ),
      );
    }
  }

  void _showCancelWithReasonDialog(BuildContext context, WidgetRef ref) {
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
            Text('¿Cancelar el pedido #${order.displayId}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Ej: Sin stock, solicitud del cliente...',
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
            onPressed: () {
              Navigator.pop(ctx);
              _cancelWithReason(context, ref, reasonController.text.trim());
            },
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelWithReason(BuildContext context, WidgetRef ref, String reason) async {
    final success = await ref.read(adminRepositoryProvider).cancelOrderWithReason(
      order.id, 
      reason.isEmpty ? null : reason,
    );
    if (success && context.mounted) {
      Navigator.pop(context);
      ref.invalidate(adminAllOrdersProvider);
      ref.invalidate(adminDashboardStatsProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido cancelado')));
    }
  }

  Future<void> _downloadAdminInvoice(BuildContext context, {bool asPdf = true}) async {
    try {
      final pdf = pw.Document();
      final invoiceData = order.toInvoiceData();
      final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€');

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('KICKSPREMIUM', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Factura de Compra', style: const pw.TextStyle(color: PdfColors.grey)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Factura: ${invoiceData['invoiceNumber']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Fecha: ${DateFormat('dd/MM/yyyy').format(order.createdAt)}'),
                        pw.Text('Estado: ${order.statusLabel}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Datos del Cliente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text('Nombre: ${invoiceData['customerName']}'),
                      pw.Text('Email: ${invoiceData['customerEmail']}'),
                      if ((invoiceData['customerPhone'] as String).isNotEmpty)
                        pw.Text('Teléfono: ${invoiceData['customerPhone']}'),
                      if ((invoiceData['shippingAddress'] as String).isNotEmpty)
                        pw.Text('Dirección: ${invoiceData['shippingAddress']}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  color: PdfColors.amber,
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text('Producto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(child: pw.Text('Talla', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      pw.Expanded(child: pw.Text('Cant.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      pw.Expanded(child: pw.Text('Precio', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                      pw.Expanded(child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                ),
                ...((invoiceData['items'] as List).map((item) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text(item['name'].toString(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(child: pw.Text(item['size'].toString(), textAlign: pw.TextAlign.center)),
                      pw.Expanded(child: pw.Text('${item['quantity']}', textAlign: pw.TextAlign.center)),
                      pw.Expanded(child: pw.Text(currencyFormat.format(item['unitPrice']), textAlign: pw.TextAlign.right)),
                      pw.Expanded(child: pw.Text(currencyFormat.format(item['total']), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                ))),
                pw.SizedBox(height: 20),
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
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('¡Gracias por tu compra!', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
        // Save PDF to device and share
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF generado'), backgroundColor: Colors.green),
          );
        }
      } else {
        // Print
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: fileName,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generando factura: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String status) async {
    final success = await ref.read(adminRepositoryProvider).updateOrderStatus(order.id, status);
    if (success && context.mounted) {
      Navigator.pop(context);
      ref.invalidate(adminAllOrdersProvider);
      ref.invalidate(adminDashboardStatsProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pedido $status')));
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.blue;
    }
  }
}

class _StatusChangeDropdown extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onChanged;

  const _StatusChangeDropdown({
    required this.currentStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Definir transiciones válidas de estado
    final validTransitions = _getValidTransitions(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: null,
          hint: const Text('Seleccionar nuevo estado...'),
          isExpanded: true,
          dropdownColor: Colors.grey[850],
          items: validTransitions.map((status) {
            final config = _getStatusConfig(status);
            return DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: config.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(config.label),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }

  List<String> _getValidTransitions(String status) {
    switch (status) {
      case 'paid':
        return ['processing', 'shipped', 'cancelled'];
      case 'processing':
        return ['shipped', 'cancelled'];
      case 'shipped':
        return ['delivered', 'cancelled'];
      case 'delivered':
        return ['completed', 'cancelled'];
      case 'pending':
        return ['processing', 'cancelled'];
      default:
        return [];
    }
  }

  _StatusConfigData _getStatusConfig(String status) {
    switch (status) {
      case 'processing':
        return _StatusConfigData(Colors.cyan, 'Procesando');
      case 'shipped':
        return _StatusConfigData(Colors.indigo, 'Enviado');
      case 'delivered':
        return _StatusConfigData(Colors.teal, 'Entregado');
      case 'completed':
        return _StatusConfigData(Colors.green, 'Completado');
      case 'cancelled':
        return _StatusConfigData(Colors.red, 'Cancelado');
      default:
        return _StatusConfigData(Colors.grey, status);
    }
  }
}

class _StatusConfigData {
  final Color color;
  final String label;
  _StatusConfigData(this.color, this.label);
}

class _ProductDetailSheet extends ConsumerWidget {
  final Product product;

  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Editar Producto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: ListView(
              children: [
                if (product.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(product.images.first, height: 200, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 20),
                _InfoRow(label: 'Nombre', value: product.name),
                _InfoRow(label: 'Precio (€)', value: (product.price / 100).toStringAsFixed(2)),
                _InfoRow(label: 'Stock', value: product.stock.toString()),
                _InfoRow(label: 'Marca', value: product.brand ?? 'N/A'),
                _InfoRow(label: 'SKU', value: product.sku ?? 'N/A'),
                const SizedBox(height: 20),
                const Text('Tallas Disponibles', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: product.sizesAvailable.entries.map((e) => Chip(
                    label: Text('${e.key}: ${e.value}'),
                    backgroundColor: Colors.grey[800],
                  )).toList(),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showProductForm(context, ref, product: product);
                        },
                        child: const Text('EDITAR', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[900],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _confirmDeleteProduct(context, ref, product),
                        child: const Text('ELIMINAR', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de que quieres eliminar "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar dialogo
              final success = await ref.read(adminRepositoryProvider).deleteProduct(product.id);
              if (success) {
                if (context.mounted) Navigator.pop(context); // Cerrar ficha
                ref.invalidate(adminAllProductsProvider);
                ref.invalidate(adminDashboardStatsProvider);
              }
            }, 
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red))
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

  const _InfoRow({required this.label, required this.value, this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          Text(value, style: TextStyle(
            color: valueColor ?? Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          )),
        ],
      ),
    );
  }
}

// ========== FORM FUNCTIONS ==========

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

void _showCategoryForm(BuildContext context, WidgetRef ref, {Category? category}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Category Form',
    pageBuilder: (context, _, __) => _CategoryFormDialog(category: category),
  ).then((value) {
    if (value == true) {
      ref.invalidate(adminAllCategoriesProvider);
      ref.invalidate(adminDashboardStatsProvider);
    }
  });
}

void _showCouponForm(BuildContext context, WidgetRef ref, {DiscountCode? coupon}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Coupon Form',
    pageBuilder: (context, _, __) => _CouponFormDialog(coupon: coupon),
  ).then((value) {
    if (value == true) {
      ref.invalidate(adminAllDiscountCodesProvider);
    }
  });
}

// ========== FORM DIALOGS ==========

class _ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product;
  const _ProductFormDialog({this.product});

  @override
  ConsumerState<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _brandController;
  late TextEditingController _skuController;
  bool _isSaving = false;
  
  // Gestión de fotos
  List<String> _existingImages = [];
  final List<File> _newImages = [];
  
  // Inventario por talla (zapatos exclusivos)
  final Map<String, TextEditingController> _sizeControllers = {};
  static const List<String> _shoesSizes = [
    '36', '36.5', '37', '37.5', '38', '38.5', '39', '39.5',
    '40', '40.5', '41', '41.5', '42', '42.5', '43', '43.5',
    '44', '44.5', '45', '45.5', '46', '47', '48',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product != null ? (widget.product!.price / 100).toStringAsFixed(2) : '');
    _costPriceController = TextEditingController(text: widget.product?.costPrice != null ? (widget.product!.costPrice! / 100).toStringAsFixed(2) : '');
    _brandController = TextEditingController(text: widget.product?.brand ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _existingImages = List<String>.from(widget.product?.images ?? []);
    
    // Inicializar controladores de tallas
    for (final size in _shoesSizes) {
      final currentStock = widget.product?.sizesAvailable[size];
      final stockValue = currentStock != null ? currentStock.toString() : '0';
      _sizeControllers[size] = TextEditingController(text: stockValue == '0' ? '' : stockValue);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    for (final c in _sizeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      setState(() {
        _newImages.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Map<String, dynamic> _buildSizesAvailable() {
    final Map<String, dynamic> sizes = {};
    for (final size in _shoesSizes) {
      final value = int.tryParse(_sizeControllers[size]?.text ?? '') ?? 0;
      if (value > 0) {
        sizes[size] = value;
      }
    }
    return sizes;
  }

  int _calculateTotalStock() {
    int total = 0;
    for (final size in _shoesSizes) {
      total += int.tryParse(_sizeControllers[size]?.text ?? '') ?? 0;
    }
    return total;
  }

  Future<void> _uploadAndSave() async {
    if (!_formKey.currentState!.validate()) return;

    final sizesAvailable = _buildSizesAvailable();
    if (sizesAvailable.isEmpty && _existingImages.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añade al menos una talla con stock')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Subir nuevas imágenes a Supabase Storage
      final List<String> uploadedUrls = List.from(_existingImages);
      final supabase = ref.read(supabaseClientProvider);
      
      for (final file in _newImages) {
        // Read bytes and resize to reasonable max width to avoid heavy thumbnails/errors
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        List<int> encoded = bytes;

        if (decoded != null) {
          final maxWidth = 1200;
          img.Image resized = decoded;
          if (decoded.width > maxWidth) {
            resized = img.copyResize(decoded, width: maxWidth);
          }
          encoded = img.encodeJpg(resized, quality: 85);
        }

        // Write temp file
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/prod_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(encoded, flush: true);

        final fileName = 'products/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        try {
          await supabase.storage.from('product-images').upload(fileName, tempFile);
          final url = supabase.storage.from('product-images').getPublicUrl(fileName);
          uploadedUrls.add(url);
        } catch (storageErr) {
          print('⚠️ Error subiendo imagen: $storageErr');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al subir imagen. Crea el bucket "product-images" en Supabase Storage con acceso público.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
        try { await tempFile.delete(); } catch (_) {}
      }

      final name = _nameController.text;
      final price = (double.parse(_priceController.text) * 100).toInt();
      final costPriceText = _costPriceController.text.trim();
      final costPrice = costPriceText.isNotEmpty ? (double.parse(costPriceText) * 100).toInt() : null;
      final brand = _brandController.text;
      final sku = _skuController.text;
      final slug = widget.product?.slug ?? name.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');
      final totalStock = _calculateTotalStock();

      final newProduct = Product(
        id: widget.product?.id ?? '',
        name: name,
        slug: slug,
        price: price,
        costPrice: costPrice,
        stock: totalStock,
        brand: brand,
        sku: sku,
        isLimitedEdition: widget.product?.isLimitedEdition ?? false,
        isFeatured: widget.product?.isFeatured ?? false,
        isActive: widget.product?.isActive ?? true,
        sizesAvailable: sizesAvailable,
        images: uploadedUrls,
        tags: widget.product?.tags ?? [],
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      final success = await ref.read(adminRepositoryProvider).upsertProduct(newProduct);
      if (success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        title: Text(widget.product == null ? 'Nuevo Producto' : 'Editar Producto'),
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _uploadAndSave),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Sección de fotos ---
            const Text('FOTOS DEL PRODUCTO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 14)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Imágenes existentes
                  ..._existingImages.asMap().entries.map((entry) => _ImageTile(
                    imageWidget: Image.network(entry.value, fit: BoxFit.cover, width: 100, height: 100),
                    onRemove: () => _removeExistingImage(entry.key),
                  )),
                  // Nuevas imágenes locales
                  ..._newImages.asMap().entries.map((entry) => _ImageTile(
                    imageWidget: Image.file(entry.value, fit: BoxFit.cover, width: 100, height: 100),
                    onRemove: () => _removeNewImage(entry.key),
                  )),
                  // Botón añadir
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: Colors.amber, size: 28),
                          SizedBox(height: 4),
                          Text('Añadir', style: TextStyle(color: Colors.amber, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            _FormEditField(label: 'Nombre', controller: _nameController, validator: (v) => v!.isEmpty ? 'Requerido' : null),
            _FormEditField(label: 'Precio Venta (€)', controller: _priceController, keyboardType: TextInputType.number),
            _FormEditField(label: 'Precio Coste (€)', controller: _costPriceController, keyboardType: TextInputType.number),
            _FormEditField(label: 'Marca', controller: _brandController),
            _FormEditField(label: 'SKU', controller: _skuController),
            
            const SizedBox(height: 20),
            
            // --- Inventario por talla ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('INVENTARIO POR TALLA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 14)),
                Text('Total: ${_calculateTotalStock()} pares', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Indica los pares disponibles de cada talla', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 12),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.3,
              ),
              itemCount: _shoesSizes.length,
              itemBuilder: (context, index) {
                final size = _shoesSizes[index];
                final controller = _sizeControllers[size]!;
                final hasStock = (int.tryParse(controller.text) ?? 0) > 0;
                
                return Container(
                  decoration: BoxDecoration(
                    color: hasStock ? Colors.amber.withOpacity(0.1) : Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasStock ? Colors.amber.withOpacity(0.5) : Colors.grey[700]!,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(size, style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 12,
                        color: hasStock ? Colors.amber : Colors.grey[400],
                      )),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: 40,
                        height: 28,
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.white),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para miniatura de imagen con botón eliminar
class _ImageTile extends StatelessWidget {
  final Widget imageWidget;
  final VoidCallback onRemove;

  const _ImageTile({required this.imageWidget, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 100, height: 100, child: imageWidget),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFormDialog extends ConsumerStatefulWidget {
  final Category? category;
  const _CategoryFormDialog({this.category});

  @override
  ConsumerState<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _orderController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _iconController = TextEditingController(text: widget.category?.icon ?? '👟');
    _orderController = TextEditingController(text: widget.category?.displayOrder.toString() ?? '0');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    
    try {
      final name = _nameController.text;
      final icon = _iconController.text;
      final order = int.tryParse(_orderController.text) ?? 0;
      final slug = widget.category?.slug ?? name.toLowerCase().replaceAll(' ', '-');

      final newCat = Category(
        id: widget.category?.id ?? '',
        name: name,
        slug: slug,
        icon: icon,
        displayOrder: order,
        description: widget.category?.description,
      );

      final success = await ref.read(adminRepositoryProvider).upsertCategory(newCat);
      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(title: const Text('Categoría')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FormEditField(label: 'Nombre', controller: _nameController),
            _FormEditField(label: 'Icono (Emoji)', controller: _iconController),
            _FormEditField(label: 'Orden', controller: _orderController, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _isSaving ? null : _save, child: const Text('GUARDAR')),
          ],
        ),
      ),
    );
  }
}

// ========== COUPON FORM DIALOG ==========
class _CouponFormDialog extends ConsumerStatefulWidget {
  final DiscountCode? coupon;
  const _CouponFormDialog({this.coupon});

  @override
  ConsumerState<_CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends ConsumerState<_CouponFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late TextEditingController _valueController;
  late TextEditingController _minPurchaseController;
  late TextEditingController _maxUsesController;
  late TextEditingController _maxUsesPerUserController;
  String _discountType = 'percentage';
  bool _isActive = true;
  DateTime? _expiresAt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.coupon?.code ?? '');
    _descriptionController = TextEditingController(text: widget.coupon?.description ?? '');
    _valueController = TextEditingController(
      text: widget.coupon != null
          ? (widget.coupon!.discountType == 'fixed'
              ? (widget.coupon!.discountValue / 100).toStringAsFixed(2)
              : widget.coupon!.discountValue.toString())
          : '',
    );
    _minPurchaseController = TextEditingController(
      text: widget.coupon != null ? (widget.coupon!.minPurchase / 100).toStringAsFixed(2) : '0',
    );
    _maxUsesController = TextEditingController(text: widget.coupon?.maxUses?.toString() ?? '');
    _maxUsesPerUserController = TextEditingController(text: widget.coupon?.maxUsesPerUser.toString() ?? '1');
    _discountType = widget.coupon?.discountType ?? 'percentage';
    _isActive = widget.coupon?.isActive ?? true;
    _expiresAt = widget.coupon?.expiresAt;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _minPurchaseController.dispose();
    _maxUsesController.dispose();
    _maxUsesPerUserController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _expiresAt = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final code = _codeController.text.toUpperCase().trim();
      final discountValue = _discountType == 'percentage'
          ? int.parse(_valueController.text)
          : (double.parse(_valueController.text) * 100).toInt();
      final minPurchase = (double.tryParse(_minPurchaseController.text) ?? 0) * 100;
      final maxUses = int.tryParse(_maxUsesController.text);
      final maxUsesPerUser = int.tryParse(_maxUsesPerUserController.text) ?? 1;

      final coupon = DiscountCode(
        id: widget.coupon?.id ?? '',
        code: code,
        description: _descriptionController.text,
        discountType: _discountType,
        discountValue: discountValue,
        minPurchase: minPurchase.toInt(),
        maxUses: maxUses,
        maxUsesPerUser: maxUsesPerUser,
        currentUses: widget.coupon?.currentUses ?? 0,
        isActive: _isActive,
        expiresAt: _expiresAt,
      );

      final success = await ref.read(adminRepositoryProvider).upsertDiscountCode(coupon);
      if (success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar cupón')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        title: Text(widget.coupon == null ? 'Nuevo Cupón' : 'Editar Cupón'),
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FormEditField(
              label: 'Código',
              controller: _codeController,
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            _FormEditField(label: 'Descripción', controller: _descriptionController),
            
            const SizedBox(height: 8),
            Text('Tipo de descuento', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _discountType = 'percentage'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _discountType == 'percentage' ? Colors.amber[700] : Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Porcentaje (%)',
                        style: TextStyle(
                          color: _discountType == 'percentage' ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _discountType = 'fixed'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _discountType == 'fixed' ? Colors.amber[700] : Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Fijo (€)',
                        style: TextStyle(
                          color: _discountType == 'fixed' ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _FormEditField(
              label: _discountType == 'percentage' ? 'Valor (%)' : 'Valor (€)',
              controller: _valueController,
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            _FormEditField(
              label: 'Compra mínima (€)',
              controller: _minPurchaseController,
              keyboardType: TextInputType.number,
            ),
            _FormEditField(
              label: 'Usos máximos (vacío = ilimitados)',
              controller: _maxUsesController,
              keyboardType: TextInputType.number,
            ),
            _FormEditField(
              label: 'Usos máximos por usuario',
              controller: _maxUsesPerUserController,
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            // Fecha de expiración
            GestureDetector(
              onTap: _selectExpiryDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.amber, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _expiresAt != null
                            ? 'Expira: ${DateFormat('dd/MM/yyyy').format(_expiresAt!)}'
                            : 'Sin fecha de expiración',
                        style: TextStyle(color: _expiresAt != null ? Colors.white : Colors.grey[400]),
                      ),
                    ),
                    if (_expiresAt != null)
                      GestureDetector(
                        onTap: () => setState(() => _expiresAt = null),
                        child: const Icon(Icons.close, color: Colors.grey, size: 18),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            // Estado activo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cupón activo', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('Los clientes pueden usar este cupón', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    activeThumbColor: Colors.amber[700],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.coupon == null ? 'CREAR CUPÓN' : 'GUARDAR CAMBIOS',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

// KPI Card Widget
class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sales Chart Widget using fl_chart
class _SalesChart extends StatelessWidget {
  final List<dynamic> salesData;

  const _SalesChart({required this.salesData});

  @override
  Widget build(BuildContext context) {
    // Generate chart data - if no data, use sample days
    final List<BarChartGroupData> barGroups = [];
    final weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    
    if (salesData.isEmpty) {
      // Sample data for empty state
      for (int i = 0; i < 7; i++) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (i + 1) * 50.0,
                color: Colors.amber,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
        );
      }
    } else {
      for (int i = 0; i < salesData.length && i < 7; i++) {
        final value = (salesData[i]['total'] ?? 0).toDouble();
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: value,
                color: Colors.amber,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
        );
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '€${rod.toY.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < weekDays.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      weekDays[index],
                      style: TextStyle(color: Colors.grey[400], fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '€${value.toInt()}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[800]!,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  double _getMaxY() {
    if (salesData.isEmpty) return 400;
    double maxVal = 0;
    for (var item in salesData) {
      final val = (item['total'] ?? 0).toDouble();
      if (val > maxVal) maxVal = val;
    }
    return maxVal == 0 ? 400 : maxVal * 1.2;
  }
}

