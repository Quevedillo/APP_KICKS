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


class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  final int _selectedIndex = 0;

  final List<_AdminSection> _sections = [
    _AdminSection(icon: Icons.dashboard, label: 'Dash'),
    _AdminSection(icon: Icons.shopping_bag, label: 'Pedidos'),
    _AdminSection(icon: Icons.inventory, label: 'Prod'),
    _AdminSection(icon: Icons.category, label: 'Cat'),
    _AdminSection(icon: Icons.local_offer, label: 'Cupones'),
    _AdminSection(icon: Icons.people, label: 'Users'),
    _AdminSection(icon: Icons.email, label: 'Email'),
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
        return const AdminEmailsMobile();
      case 7:
        return const AdminFinanceMobile();
      case 8:
        return const AdminSettingsMobile();
      default:
        return const AdminDashboardMobile();
    }
  }

  Widget _buildBottomNav(int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_sections.length, (index) {
                final section = _sections[index];
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () => ref.read(adminSelectedSectionProvider.notifier).setSection(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber[700]!.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          section.icon,
                          color: isSelected ? Colors.amber[700] : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section.label,
                          style: TextStyle(
                            color: isSelected ? Colors.amber[700] : Colors.grey,
                            fontSize: 10,
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
                                Text('Stock: ${product.stock}', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
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
                onPressed: () {},
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
class AdminFinanceMobile extends StatelessWidget {
  const AdminFinanceMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Finanzas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ReportCard(title: 'Ventas Mensuales', value: '€45,230', icon: Icons.trending_up, color: Colors.green),
              _ReportCard(title: 'Bruto Total', value: '€128,450', icon: Icons.account_balance_wallet, color: Colors.blue),
              _ReportCard(title: 'Ticket Medio', value: '€245', icon: Icons.shopping_cart, color: Colors.purple),
              _ReportCard(title: 'Gastos Envío', value: '€1,240', icon: Icons.local_shipping, color: Colors.orange),
            ],
          ),
          
          const SizedBox(height: 24),
          const Text('Ingresos Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          // Dummy chart representation
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) => Container(
                width: 20,
                height: (index + 2) * 20.0,
                decoration: BoxDecoration(
                  color: Colors.amber[700]!.withOpacity(0.7),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              )),
            ),
          ),
        ],
      ),
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
                const SizedBox(height: 40),
                if (order.status != 'completed' && order.status != 'cancelled')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          onPressed: () => _updateStatus(context, ref, 'completed'),
                          child: const Text('Completar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          onPressed: () => _updateStatus(context, ref, 'cancelled'),
                          child: const Text('Cancelar'),
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
  late TextEditingController _stockController;
  late TextEditingController _brandController;
  late TextEditingController _skuController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product != null ? (widget.product!.price / 100).toStringAsFixed(2) : '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '10');
    _brandController = TextEditingController(text: widget.product?.brand ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final name = _nameController.text;
      final price = (double.parse(_priceController.text) * 100).toInt();
      final stock = int.parse(_stockController.text);
      final brand = _brandController.text;
      final sku = _skuController.text;
      final slug = widget.product?.slug ?? name.toLowerCase().replaceAll(' ', '-');

      final newProduct = Product(
        id: widget.product?.id ?? '',
        name: name,
        slug: slug,
        price: price,
        stock: stock,
        brand: brand,
        sku: sku,
        isLimitedEdition: widget.product?.isLimitedEdition ?? false,
        isFeatured: widget.product?.isFeatured ?? false,
        isActive: widget.product?.isActive ?? true,
        sizesAvailable: widget.product?.sizesAvailable ?? {'40': 5, '41': 5, '42': 5, '43': 5, '44': 5},
        images: widget.product?.images ?? [],
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
            IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FormEditField(label: 'Nombre', controller: _nameController, validator: (v) => v!.isEmpty ? 'Requerido' : null),
            _FormEditField(label: 'Precio (€)', controller: _priceController, keyboardType: TextInputType.number),
            _FormEditField(label: 'Stock', controller: _stockController, keyboardType: TextInputType.number),
            _FormEditField(label: 'Marca', controller: _brandController),
            _FormEditField(label: 'SKU', controller: _skuController),
          ],
        ),
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

