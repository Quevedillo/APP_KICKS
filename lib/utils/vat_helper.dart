/// Utilidad centralizada para cálculos de IVA (21% España)
///
/// Los precios en la BD están en céntimos y son precios BASE (sin IVA).
/// Al usuario se le muestra siempre con IVA incluido.
/// Al admin en finanzas se le muestra sin IVA.
class VatHelper {
  VatHelper._();

  /// Tipo de IVA general (España)
  static const double kVatRate = 0.21;

  /// Porcentaje de IVA como entero (21)
  static const int kVatPercent = 21;

  // ─── Cálculos en céntimos ────────────────────────────────────────

  /// Precio con IVA incluido (céntimos)
  static int priceWithVat(int baseCents) {
    return (baseCents * (1 + kVatRate)).round();
  }

  /// Importe del IVA (céntimos)
  static int vatAmount(int baseCents) {
    return (baseCents * kVatRate).round();
  }

  /// Precio base desde un precio con IVA (céntimos)
  static int priceWithoutVat(int priceWithVatCents) {
    return (priceWithVatCents / (1 + kVatRate)).round();
  }

  // ─── Formateo ────────────────────────────────────────────────────

  /// Formatea céntimos → "€XX.XX"
  static String formatEur(int cents) {
    final euros = cents / 100;
    return '€${euros.toStringAsFixed(2)}';
  }

  /// Formatea céntimos → "€XX" (sin decimales, para precios redondos)
  static String formatEurShort(int cents) {
    final euros = cents / 100;
    if (euros == euros.roundToDouble()) {
      return '€${euros.toInt()}';
    }
    return '€${euros.toStringAsFixed(2)}';
  }

  /// Formatea un double en euros → "€XX.XX"
  static String formatEurDouble(double euros) {
    return '€${euros.toStringAsFixed(2)}';
  }

  /// Formatea céntimos con IVA → "€XX.XX" (conveniencia)
  static String formatWithVat(int baseCents) {
    return formatEur(priceWithVat(baseCents));
  }
}
