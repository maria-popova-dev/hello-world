import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import '../cloudinary_config.dart';

class CloudinaryService {
  // Грузчик (объект для работы с Cloudinary)
  static final Cloudinary _cloudinary = Cloudinary.signedConfig(
    cloudName: CloudinaryConfig.cloudName,
    apiKey: CloudinaryConfig.apiKey,
    apiSecret: CloudinaryConfig.apiSecret,
  );

  // Загружаем ФОТО на Cloudinary
  static Future<String?> uploadImage(String imagePath) async {
    try {
      print('🖼️  Начинаю ЗАГРУЗКУ фото на Cloudinary...');
      print('📁 Путь к файлу: $imagePath');

      // Проверяем что файл существует
      final file = File(imagePath);
      if (!await file.exists()) {
        print('❌ Файл не найден: $imagePath');
        return null;
      }

      // 1. ОТПРАВЛЯЕМ ФОТО НА CLOUDINARY
      final response = await _cloudinary.upload(
        file: imagePath,                     // Путь к фото на телефоне
        resourceType: CloudinaryResourceType.image,  // Это фото
        folder: 'posts',                     // Папка на Cloudinary
        fileName: 'post_${DateTime.now().millisecondsSinceEpoch}', // Уникальное имя
      );

      // 2. ПРОВЕРЯЕМ РЕЗУЛЬТАТ
      if (response.isSuccessful) {
        print('✅ УСПЕХ! Фото загружено на Cloudinary!');
        print('🔗 Новая ссылка: ${response.secureUrl}');
        return response.secureUrl; // Возвращаем НОВУЮ ссылку
      } else {
        print('❌ Ошибка Cloudinary: ${response.error}');
        return null;
      }

    } catch (e) {
      print('🔥 Ошибка при загрузке: $e');
      return null;
    }
  }

  // Загружаем ВИДЕО на Cloudinary
  static Future<String?> uploadVideo(String videoPath) async {
    try {
      print('🎥 Начинаю загрузку видео на Cloudinary...');

      final response = await _cloudinary.upload(
        file: videoPath,
        resourceType: CloudinaryResourceType.video,  // Это видео!
        folder: 'videos',
        fileName: 'video_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (response.isSuccessful) {
        print('✅ Видео загружено!');
        return response.secureUrl;
      } else {
        print('❌ Ошибка: ${response.error}');
        return null;
      }

    } catch (e) {
      print('🔥 Ошибка: $e');
      return null;
    }
  }
  static Future<String?> uploadAvatar(String imagePath) async {
    try{
      print('Загружаю аватар пользователя');
      final response = await _cloudinary.upload(
        file: imagePath,
        resourceType: CloudinaryResourceType.image,
        folder: 'avatars',
        fileName: 'avatar_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (response.isSuccessful) {
        print('✅ Аватар загружен!');
        return response.secureUrl;
      }
        return null;
    } catch (e) {
      print('🔥 Ошибка загрузки аватара: $e');
      return null;
    }
  }
}

