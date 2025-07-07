import 'package:event_bus/event_bus.dart';

class EventBusService {
  // Mẫu Singleton
  static final EventBusService _instance = EventBusService._internal();
  factory EventBusService() => _instance;
  EventBusService._internal();

  // Thực thể EventBus
  final EventBus eventBus = EventBus();
}
