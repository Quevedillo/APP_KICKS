import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  int _selectedIndex = 0;

  final List<_AdminSection> _sections = [
    _AdminSection(icon: Icons.dashboard, label: 'Dashboard'),
    _AdminSection(icon: Icons.shopping_bag, label: 'Pedidos'),
    _AdminSection(icon: Icons.inventory, label: 'Productos'),
    _AdminSection(icon: Icons.people, label: 'Usuarios'),
    _AdminSection(icon: Icons.email, label: 'Emails'),
    _AdminSection(icon: Icons.bar_chart, label: 'Reportes'),
    _AdminSection(icon: Icons.settings, label: 'Configuración'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _buildMainContent(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_sections.length, (index) {
              final section = _sections[index];
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber[700] : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        section.icon,
                        size: 22,
                        color: isSelected ? Colors.black : Colors.white70,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        section.label,
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected ? Colors.black : Colors.white70,
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
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return const AdminDashboardMobile();
      case 1:
        return const AdminOrdersMobile();
      case 2:
        return const AdminProductsMobile();
      case 3:
        return const AdminUsersMobile();
      case 4:
        return const AdminEmailsMobile();
      case 5:
        return const AdminReportsMobile();
      case 6:
        return const AdminSettingsMobile();
      default:
        return const AdminDashboardMobile();
    }
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
class AdminDashboardMobile extends StatelessWidget {
  const AdminDashboardMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              _StatCard(title: 'Pedidos Hoy', value: '24', icon: Icons.shopping_bag, color: Colors.blue),
              _StatCard(title: 'Ingresos', value: '€2,450', icon: Icons.euro, color: Colors.green),
              _StatCard(title: 'Usuarios', value: '12', icon: Icons.people, color: Colors.purple),
              _StatCard(title: 'Productos', value: '156', icon: Icons.inventory, color: Colors.orange),
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
            icon: Icons.shopping_cart,
            title: 'Correos de Compras',
            subtitle: 'Enviar confirmaciones',
            color: Colors.green,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _QuickActionCard(
            icon: Icons.cancel,
            title: 'Correos de Cancelación',
            subtitle: 'Gestionar reembolsos',
            color: Colors.red,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _QuickActionCard(
            icon: Icons.local_shipping,
            title: 'Actualizaciones de Envío',
            subtitle: 'Notificar estados',
            color: Colors.blue,
            onTap: () {},
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          const Text(
            'Actividad Reciente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          ...List.generate(5, (index) => _ActivityItem(
            title: 'Pedido #${1000 + index}',
            subtitle: 'Hace ${(index + 1) * 10} minutos',
            icon: Icons.receipt,
          )),
        ],
      ),
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

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

// ========== ORDERS MOBILE ==========
class AdminOrdersMobile extends StatelessWidget {
  const AdminOrdersMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
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
                    'Pedido #${1000 + index}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: index % 3 == 0 ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      index % 3 == 0 ? 'Completado' : 'Pendiente',
                      style: TextStyle(
                        fontSize: 11,
                        color: index % 3 == 0 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Cliente: Usuario ${index + 1}', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              Text('Total: €${(index + 1) * 99}.00', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}

// ========== PRODUCTS MOBILE ==========
class AdminProductsMobile extends StatelessWidget {
  const AdminProductsMobile({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              return Container(
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
                        child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
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
                              'Zapatilla ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text('€199.99', style: TextStyle(color: Colors.amber, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ========== USERS MOBILE ==========
class AdminUsersMobile extends StatelessWidget {
  const AdminUsersMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
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
                backgroundColor: Colors.amber[700],
                child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usuario ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('usuario${index + 1}@email.com', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
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

// ========== REPORTS MOBILE ==========
class AdminReportsMobile extends StatelessWidget {
  const AdminReportsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reportes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ReportCard(title: 'Ventas Mensuales', value: '€45,230', icon: Icons.trending_up, color: Colors.green),
              _ReportCard(title: 'Clientes Nuevos', value: '342', icon: Icons.people, color: Colors.blue),
              _ReportCard(title: 'Productos Vendidos', value: '1,240', icon: Icons.shopping_bag, color: Colors.purple),
              _ReportCard(title: 'Tasa Conversión', value: '3.8%', icon: Icons.percent, color: Colors.orange),
            ],
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
            activeColor: Colors.amber[700],
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
