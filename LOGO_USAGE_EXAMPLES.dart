// ============================================================
// EJEMPLOS DE USO DEL LOGO DE KICKSPREMIUM EN LA APLICACIÓN
// ============================================================

// 1. EN HOME_SCREEN.dart - En el Hero Banner
// Reemplaza el contenedor gris actual con:

/*
  // Hero Banner con Logo
  SliverToBoxAdapter(
    child: Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.grey[900]!, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Pattern background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Opacity(
                opacity: 0.1,
                child: Image.network(
                  "https://images.unsplash.com/photo-1552346154-21d32810aba3?w=800&q=80",
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
          ),
          // Logo centrado
          Center(
            child: AppLogo(
              height: 120,
              width: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          // Botón de CTA
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shopping_bag),
              label: const Text('EXPLORAR'),
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
*/

// 2. EN LOGIN_SCREEN - En la parte superior

/*
  Column(
    children: [
      const SizedBox(height: 40),
      const AppLogo(height: 100),
      const SizedBox(height: 40),
      // ... resto del login
    ],
  )
*/

// 3. EN APP BAR - Para usar en AppBar

/*
  AppBar(
    centerTitle: true,
    title: const AppLogoSmall(size: 50),
    elevation: 0,
    backgroundColor: Colors.transparent,
  )
*/

// 4. EN PROFILE_SCREEN - Encabezado del perfil

/*
  Container(
    padding: const EdgeInsets.symmetric(vertical: 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.grey[900]!, Colors.black],
      ),
    ),
    child: Column(
      children: [
        const AppLogo(height: 80),
        const SizedBox(height: 16),
        Text(
          'Mi Perfil',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    ),
  )
*/

// 5. EN SPLASH SCREEN - Pantalla de carga

/*
  Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLogo(height: 150),
          const SizedBox(height: 40),
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Cargando KicksPremium...',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    ),
  )
*/

// 6. IMPORTAR EL WIDGET EN LOS ARCHIVOS DONDE QUIERAS USARLO

/*
  import '../widgets/app_logo.dart';
  
  // Luego usar:
  AppLogo()              // Logo estándar
  AppLogoSmall()         // Logo pequeño para app bar
  AppLogo(height: 150)   // Logo personalizado
*/

// ============================================================
// ESTRUCTURA DE CARPETAS CORRECTA
// ============================================================

/*
assets/
├── env
├── LOGO.png              ← El logo principal
└── images/               ← Para otros assets de imagen
    ├── banner.png
    ├── icon.png
    └── ...

lib/
└── presentation/
    └── widgets/
        └── app_logo.dart ← Widget reutilizable
*/

// ============================================================
// USO EN PUBSPEC.yaml
// ============================================================

/*
flutter:
  uses-material-design: true

  assets:
    - assets/env
    - assets/images/
    - assets/LOGO.png      ← Agregado para acceso directo al logo
*/
