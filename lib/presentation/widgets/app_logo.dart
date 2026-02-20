import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar el logo de KicksPremium
class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.width,
    this.height = 80,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width * 0.6,
      height: height,
      child: Image.asset(
        'assets/LOGO.png',
        fit: fit,
        semanticLabel: 'KicksPremium Logo',
      ),
    );
  }
}

/// Variante del logo para uso en app bar
class AppLogoSmall extends StatelessWidget {
  final double size;

  const AppLogoSmall({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/LOGO.png',
        fit: BoxFit.contain,
        semanticLabel: 'KicksPremium Logo',
      ),
    );
  }
}
