import 'package:flutter/material.dart';

/// Widget para recomendar talla basado en altura y peso
/// Reglas:
/// - Si peso < 70kg Y altura < 175cm -> Talla M
/// - Si peso > 90kg -> Talla XL
/// - Si peso 70-90kg Y altura >= 175cm -> Talla L
/// - Default -> Talla M
class SizeRecommenderWidget extends StatefulWidget {
  final Function(String size)? onSizeSelected;

  const SizeRecommenderWidget({super.key, this.onSizeSelected});

  @override
  State<SizeRecommenderWidget> createState() => _SizeRecommenderWidgetState();

  /// Muestra el modal de recomendador de tallas
  static void show(BuildContext context, {Function(String)? onSizeSelected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SizeRecommenderWidget(onSizeSelected: onSizeSelected),
    );
  }
}

class _SizeRecommenderWidgetState extends State<SizeRecommenderWidget> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String? _recommendedSize;
  String? _sizeExplanation;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  /// Algoritmo de recomendación de talla
  String _calculateSize(double height, double weight) {
    // Regla 1: Peso > 90kg -> XL
    if (weight > 90) {
      _sizeExplanation = 'Con tu peso de ${weight.toInt()}kg, te recomendamos una talla XL para mayor comodidad.';
      return 'XL';
    }
    
    // Regla 2: Peso < 70kg Y altura < 175cm -> M
    if (weight < 70 && height < 175) {
      _sizeExplanation = 'Con ${height.toInt()}cm y ${weight.toInt()}kg, la talla M es perfecta para ti.';
      return 'M';
    }
    
    // Regla 3: Peso < 60kg -> S
    if (weight < 60) {
      _sizeExplanation = 'Con tu peso de ${weight.toInt()}kg, te recomendamos la talla S.';
      return 'S';
    }
    
    // Regla 4: Altura >= 180cm Y peso 70-90kg -> L
    if (height >= 180 && weight >= 70 && weight <= 90) {
      _sizeExplanation = 'Con ${height.toInt()}cm y ${weight.toInt()}kg, la talla L te quedará genial.';
      return 'L';
    }
    
    // Regla 5: Peso 70-90kg Y altura 175-180cm -> L
    if (weight >= 70 && weight <= 90 && height >= 175) {
      _sizeExplanation = 'Con ${height.toInt()}cm y ${weight.toInt()}kg, te recomendamos la talla L.';
      return 'L';
    }
    
    // Default -> M
    _sizeExplanation = 'Basándonos en tus medidas (${height.toInt()}cm, ${weight.toInt()}kg), te recomendamos la talla M.';
    return 'M';
  }

  void _calculateRecommendation() {
    if (_formKey.currentState!.validate()) {
      final height = double.tryParse(_heightController.text) ?? 0;
      final weight = double.tryParse(_weightController.text) ?? 0;
      
      setState(() {
        _recommendedSize = _calculateSize(height, weight);
      });
    }
  }

  void _selectSize(String size) {
    widget.onSizeSelected?.call(size);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Title
              const Row(
                children: [
                  Icon(Icons.straighten, color: Colors.amber, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Recomendador de Talla',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              Text(
                'Introduce tu altura y peso para obtener una recomendación personalizada.',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              
              const SizedBox(height: 24),
              
              // Height input
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Altura (cm)',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.height, color: Colors.amber),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.amber),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce tu altura';
                  }
                  final height = double.tryParse(value);
                  if (height == null || height < 100 || height > 250) {
                    return 'Altura inválida (100-250 cm)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Weight input
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Peso (kg)',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.monitor_weight, color: Colors.amber),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.amber),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce tu peso';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 30 || weight > 200) {
                    return 'Peso inválido (30-200 kg)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Calculate button
              ElevatedButton(
                onPressed: _calculateRecommendation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Calcular Talla',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              
              // Result
              if (_recommendedSize != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.2),
                        Colors.orange.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Tu talla recomendada es:',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _recommendedSize!,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _sizeExplanation ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => _selectSize(_recommendedSize!),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber,
                          side: const BorderSide(color: Colors.amber),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Seleccionar esta talla'),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Size chart reference
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Ver guía de tallas completa',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                iconColor: Colors.grey[400],
                collapsedIconColor: Colors.grey[400],
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SizeRow(size: 'S', weight: '< 60kg', height: '< 170cm'),
                        const Divider(color: Colors.grey),
                        _SizeRow(size: 'M', weight: '60-70kg', height: '165-180cm'),
                        const Divider(color: Colors.grey),
                        _SizeRow(size: 'L', weight: '70-85kg', height: '175-185cm'),
                        const Divider(color: Colors.grey),
                        _SizeRow(size: 'XL', weight: '> 85kg', height: '> 180cm'),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeRow extends StatelessWidget {
  final String size;
  final String weight;
  final String height;

  const _SizeRow({
    required this.size,
    required this.weight,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                size,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peso: $weight',
                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                ),
                Text(
                  'Altura: $height',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
