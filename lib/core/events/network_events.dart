// Sự kiện cơ bản cho trạng thái mạng
abstract class NetworkEvent {}

// Sự kiện kích hoạt khi kết nối mạng được thiết lập
class NetworkConnectedEvent extends NetworkEvent {
  @override
  String toString() => 'NetworkConnectedEvent';
}

// Sự kiện kích hoạt khi mất kết nối mạng
class NetworkDisconnectedEvent extends NetworkEvent {
  @override
  String toString() => 'NetworkDisconnectedEvent';
}

// Sự kiện cho các lỗi API request có thể do vấn đề về mạng
class ApiErrorEvent extends NetworkEvent {
  final String message;
  final String endpoint;
  final dynamic error;

  ApiErrorEvent({
    required this.message,
    required this.endpoint,
    this.error,
  });

  @override
  String toString() => 'ApiErrorEvent: $message, Endpoint: $endpoint';
}

// Sự kiện cho các hành động thử lại sau khi khôi phục mạng
class RetryActionEvent extends NetworkEvent {
  final Function action;
  
  RetryActionEvent(this.action);
  
  @override
  String toString() => 'RetryActionEvent';
}
