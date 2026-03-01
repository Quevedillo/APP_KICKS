import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Servicio para subir imágenes a Cloudinary.
///
/// Usa la API de upload "unsigned" (con upload_preset) o "signed" según config.
/// El cloud name se pasa vía --dart-define o --dart-define-from-file.
class CloudinaryService {
  static String get cloudName =>
      const String.fromEnvironment('PUBLIC_CLOUDINARY_CLOUD_NAME');

  /// Sube un archivo de imagen a Cloudinary y devuelve la URL pública.
  ///
  /// [imageFile] - El archivo a subir.
  /// [folder] - Carpeta dentro de Cloudinary (ej: 'products').
  /// Devuelve la URL segura de la imagen o null si falla.
  static Future<String?> uploadImage(File imageFile, {String folder = 'products'}) async {
    if (cloudName.isEmpty) {
      debugPrint('❌ PUBLIC_CLOUDINARY_CLOUD_NAME no configurado');
      return null;
    }

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'ml_default'  // Preset por defecto de Cloudinary
        ..fields['folder'] = folder
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final secureUrl = data['secure_url'] as String?;
        debugPrint('✅ Imagen subida a Cloudinary: $secureUrl');
        return secureUrl;
      } else {
        debugPrint('❌ Error Cloudinary (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error subiendo a Cloudinary: $e');
      return null;
    }
  }

  /// Sube bytes de imagen directamente (útil cuando ya tienes los bytes procesados).
  static Future<String?> uploadBytes(List<int> bytes, {
    String folder = 'products',
    String fileName = 'image.jpg',
  }) async {
    if (cloudName.isEmpty) {
      debugPrint('❌ PUBLIC_CLOUDINARY_CLOUD_NAME no configurado');
      return null;
    }

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'ml_default'
        ..fields['folder'] = folder
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final secureUrl = data['secure_url'] as String?;
        debugPrint('✅ Imagen subida a Cloudinary: $secureUrl');
        return secureUrl;
      } else {
        debugPrint('❌ Error Cloudinary (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error subiendo bytes a Cloudinary: $e');
      return null;
    }
  }
}
