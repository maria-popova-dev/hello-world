// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
   // Проверка и запрос разрешений
   static Future<bool> _checkPermissions() async {
   // Проверяем, включена ли служба геолокации
   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
   if (!serviceEnabled) {
   print('📍 Служба геолокации отключена');
   return false;
   }

   // Проверяем текущие разрешения
   LocationPermission permission = await Geolocator.checkPermission();

   // Если разрешений нет - запрашиваем
   if (permission == LocationPermission.denied) {
   print('📍 Запрашиваю разрешение на геолокацию...');
   permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
   print('📍 Пользователь отказал в разрешении');
  return false;
   }
   }

   // Если разрешения отклонены навсегда
   if (permission == LocationPermission.deniedForever) {
   print('📍 Разрешение отклонено навсегда');
   return false;
   }

  print('📍 Разрешение на геолокацию получено');
   return true;
   }

   // Получение текущей позиции
   static Future<Position?> getCurrentPosition() async {
   try {
   print('📍 Пытаюсь получить текущую позицию...');
   bool hasPermission = await _checkPermissions();
   if (!hasPermission) {
   print('📍 Нет разрешений на использование геолокации');
   return null;
  }

   // Получаем позицию
   Position position = await Geolocator.getCurrentPosition(
   desiredAccuracy: LocationAccuracy.medium,
   );

   print('📍 Позиция получена: ${position.latitude}, ${position.longitude}');
  return position;
   } catch (e) {
   print('📍 Ошибка получения геолокации: $e');
   return null;
   }
   }

   // Преобразование координат в адрес
   static Future<String?> getAddressFromCoordinates(
   double lat,
   double lng
   ) async {
   try {
   print('📍 Преобразую координаты в адрес: $lat, $lng');
   List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

   if (placemarks.isEmpty) {
  print('📍 Не найдено адреса для координат');
  return null;
   }

   Placemark place = placemarks.first;
   print('📍 Найден адрес: ${place.toJson()}');

  // Форматируем адрес: "Город, Страна"
   List<String> parts = [];
   if (place.locality != null && place.locality!.isNotEmpty) {
   parts.add(place.locality!); // Город
   }
   if (place.country != null && place.country!.isNotEmpty) {
   parts.add(place.country!); // Страна
   }

  String address = parts.isNotEmpty ? parts.join(', ') : 'Неизвестное место';
   print('📍 Форматированный адрес: $address');

   return address;
   } catch (e) {
   print('📍 Ошибка преобразования адреса: $e');
   return null;
   }
   }

   // Получение местоположения с адресом (основной метод)
   static Future<Map<String, dynamic>?> getLocationWithAddress() async {
   print('📍 === НАЧАЛО getLocationWithAddress ===');

   final position = await getCurrentPosition();
   if (position == null) {
   print('📍 Не удалось получить позицию');
   return null;
   }

  final address = await getAddressFromCoordinates(
   position.latitude,
   position.longitude
   );

   print('📍 Успешно! Локация: ${position.latitude}, ${position.longitude}');
   print('📍 Адрес: $address');
   print('📍 === КОНЕЦ getLocationWithAddress ===');

   return {
   'latitude': position.latitude,
   'longitude': position.longitude,
   'address': address ?? 'Неизвестное место',
   'timestamp': DateTime.now().toIso8601String(),
   };
   }

   // Проверка расстояния между двумя точками (в метрах)
  static double calculateDistance(
   double lat1,
   double lng1,
  double lat2,
   double lng2
   ) {
   return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
   }
}