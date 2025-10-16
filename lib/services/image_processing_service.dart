import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../utils/safe_logger.dart';

/// Результат обработки изображения.
class ProcessedImageResult {
  final String compressedImagePath;
  final String thumbnailPath;

  ProcessedImageResult({
    required this.compressedImagePath,
    required this.thumbnailPath,
  });
}

/// Сервис для обработки изображений: сжатие и создание миниатюр.
class ImageProcessingService {
  /// Обрабатывает выбранное изображение.
  ///
  /// Сжимает изображение, конвертирует в WebP, создает миниатюру
  /// и возвращает пути к новым файлам.
  Future<ProcessedImageResult?> processPickedImage(XFile pickedFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final uuid = const Uuid().v4();

      // --- 1. Обработка основного изображения ---
      final compressedImagePath = p.join(tempDir.path, '$uuid.webp');
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        compressedImagePath,
        quality: 85,
        minWidth: 1920,
        minHeight: 1080,
        format: CompressFormat.webp,
      );

      // --- 2. Создание миниатюры ---
      final thumbnailPath = p.join(tempDir.path, '${uuid}_thumb.webp');
      final thumbnailFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        thumbnailPath,
        quality: 80,
        minWidth: 300,
        minHeight: 300,
        format: CompressFormat.webp,
      );

      if (compressedFile == null || thumbnailFile == null) {
        SafeLogger.warning('Failed to compress one or both images', tag: 'ImageProcessingService');
        return null;
      }

      return ProcessedImageResult(
        compressedImagePath: compressedFile.path,
        thumbnailPath: thumbnailFile.path,
      );
    } catch (e) {
      SafeLogger.error('Error processing image', error: e, tag: 'ImageProcessingService');
      return null;
    }
  }
}
