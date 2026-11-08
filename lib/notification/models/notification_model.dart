class AppNotification {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String category; // 'release', 'visitor', 'alert', 'rehabilitation'
  bool isRead;
  final bool isHighPriority;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.category,
    required this.isRead,
    this.isHighPriority = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      category: json['category'] ?? 'general',
      isRead: json['isRead'] ?? false,
      isHighPriority: json['isHighPriority'] ?? false,
    );
  }
}