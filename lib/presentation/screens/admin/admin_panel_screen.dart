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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎛️ Panel de Administrador'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.grey[900],
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  _buildSidebarItem(0, Icons.dashboard, 'Dashboard'),
                  _buildSidebarItem(1, Icons.shopping_bag, 'Pedidos'),
                  _buildSidebarItem(2, Icons.inventory, 'Productos'),
                  _buildSidebarItem(3, Icons.people, 'Usuarios'),
                  _buildSidebarItem(4, Icons.email, 'Emails'),
                  _buildSidebarItem(5, Icons.bar_chart, 'Reportes'),
                  const Divider(color: Colors.grey),
                  _buildSidebarItem(6, Icons.settings, 'Configuración'),
                ],
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.amber[700] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.black : Colors.white),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return const AdminDashboard();
      case 1:
        return const AdminOrdersScreen();
      case 2:
        return const AdminProductsScreen();
      case 3:
        return const AdminUsersScreen();
      case 4:
        return const AdminEmailsScreen();
      case 5:
        return const AdminReportsScreen();
      case 6:
        return const AdminSettingsScreen();
      default:
        return const AdminDashboard();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
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
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ========== DASHBOARD ==========
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard('Pedidos Hoy', '24', Colors.blue),
              _buildStatCard('Ingresos Hoy', '\$2,450', Colors.green),
              _buildStatCard('Usuarios Nuevos', '12', Colors.purple),
              _buildStatCard('Productos', '156', Colors.orange),
            ],
          ),
          const SizedBox(height: 32),
          
          // Quick Email Access Section
          Text(
            'Acceso Rápido a Correos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEmailQuickAccessCard(
                  context,
                  icon: Icons.shopping_cart,
                  title: 'Correos de Compras',
                  description: 'Confirmación de pedidos',
                  color: Colors.green,
                  onTap: () {
                    // Navegar a la sección de emails de compras
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo correos de compras...')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEmailQuickAccessCard(
                  context,
                  icon: Icons.cancel,
                  title: 'Correos de Cancelación',
                  description: 'Cancelaciones y reembolsos',
                  color: Colors.red,
                  onTap: () {
                    // Navegar a la sección de emails de cancelación
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo correos de cancelación...')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEmailQuickAccessCard(
                  context,
                  icon: Icons.update,
                  title: 'Actualizaciones de Pedido',
                  description: 'Estado del pedido',
                  color: Colors.orange,
                  onTap: () {
                    // Navegar a la sección de actualizaciones
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo actualizaciones de pedido...')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          Text(
            'Actividad Reciente',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) => ListTile(
                title: Text('Nuevo pedido #${1000 + index}'),
                subtitle: Text('Hace ${(index + 1) * 10} minutos'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ========== ORDERS MANAGEMENT ==========
class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestión de Pedidos',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                itemCount: 8,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) => _buildOrderListTile(
                  orderId: '#${1000 + index}',
                  customerName: 'Cliente ${index + 1}',
                  status: ['Pendiente', 'Confirmado', 'Enviado'][index % 3],
                  amount: '\$${(100 + index * 50).toStringAsFixed(2)}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListTile({
    required String orderId,
    required String customerName,
    required String status,
    required String amount,
  }) {
    Color statusColor = status == 'Enviado'
        ? Colors.green
        : status == 'Confirmado'
            ? Colors.blue
            : Colors.orange;

    return ListTile(
      title: Text('Pedido $orderId'),
      subtitle: Text(customerName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ========== PRODUCTS MANAGEMENT ==========
class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestión de Productos',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Producto'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: List.generate(
                12,
                (index) => _buildProductCard(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zapatilla ${index + 1}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('\$199.99', style: TextStyle(color: Colors.amber)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
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
}

// ========== USERS MANAGEMENT ==========
class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de Usuarios',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text('Usuario ${index + 1}'),
                  subtitle: Text('usuario${index + 1}@example.com'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(child: Text('Ver Perfil')),
                      const PopupMenuItem(child: Text('Editar')),
                      const PopupMenuItem(child: Text('Suspender')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== EMAILS MANAGEMENT ==========
class AdminEmailsScreen extends ConsumerStatefulWidget {
  const AdminEmailsScreen({super.key});

  @override
  ConsumerState<AdminEmailsScreen> createState() => _AdminEmailsScreenState();
}

class _AdminEmailsScreenState extends ConsumerState<AdminEmailsScreen> {
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedTemplate = 'newsletter';
  List<String> _selectedRecipients = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campañas de Email',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildEmailTemplateButton('newsletter', '📬 Newsletter'),
                          _buildEmailTemplateButton('promotion', '🎉 Promoción'),
                          _buildEmailTemplateButton('event', '🎊 Evento'),
                          _buildEmailTemplateButton('announcement', '📢 Anuncio'),
                          _buildEmailTemplateButton('abandoned_cart', '🛒 Carrito Abandonado'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Campaña',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Asunto del Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Contenido del Email (HTML)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: null,
                    expands: true,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showRecipientSelector();
                      },
                      child: const Text('Seleccionar Destinatarios'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        _showPreview();
                      },
                      child: const Text('Previsualizar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        _sendCampaign();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Enviar'),
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

  Widget _buildEmailTemplateButton(String id, String label) {
    bool isSelected = _selectedTemplate == id;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.amber[700] : Colors.transparent,
      ),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
        onTap: () {
          setState(() => _selectedTemplate = id);
        },
      ),
    );
  }

  void _showRecipientSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Destinatarios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Todos los usuarios'),
              value: _selectedRecipients.contains('all'),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedRecipients.add('all');
                  } else {
                    _selectedRecipients.remove('all');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Usuarios activos'),
              value: _selectedRecipients.contains('active'),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedRecipients.add('active');
                  } else {
                    _selectedRecipients.remove('active');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Suscriptores newsletter'),
              value: _selectedRecipients.contains('newsletter'),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedRecipients.add('newsletter');
                  } else {
                    _selectedRecipients.remove('newsletter');
                  }
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Previsualización'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Asunto: ${_subjectController.text}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(_contentController.text.isEmpty
                    ? 'Sin contenido'
                    : _contentController.text),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _sendCampaign() {
    if (_subjectController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Campaña de email enviada correctamente')),
    );

    _subjectController.clear();
    _contentController.clear();
    _selectedRecipients.clear();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

// ========== REPORTS ==========
class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reportes',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildReportCard(
                  'Ventas Mensuales',
                  '\$45,230',
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildReportCard(
                  'Clientes Nuevos',
                  '342',
                  Icons.people,
                  Colors.blue,
                ),
                _buildReportCard(
                  'Productos Vendidos',
                  '1,240',
                  Icons.shopping_bag,
                  Colors.purple,
                ),
                _buildReportCard(
                  'Tasa de Conversión',
                  '3.8%',
                  Icons.percent,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ========== SETTINGS ==========
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _emailNotifications = true;
  bool _maintenanceMode = false;
  bool _stockAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Text(
            'Configuración',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Notificaciones',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Notificaciones de Email'),
            subtitle: const Text('Recibir emails de nuevos pedidos'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
            },
          ),
          SwitchListTile(
            title: const Text('Alertas de Stock'),
            subtitle: const Text('Notificar cuando el stock sea bajo'),
            value: _stockAlerts,
            onChanged: (value) {
              setState(() => _stockAlerts = value);
            },
          ),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Sistema',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Modo de Mantenimiento'),
            subtitle: const Text('Desactiva la tienda para usuarios'),
            value: _maintenanceMode,
            onChanged: (value) {
              setState(() => _maintenanceMode = value);
            },
          ),
          const Divider(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Cambios guardados')),
              );
            },
            child: const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }
}
