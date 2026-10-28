class TrackingItem {
  final String title;
  final String subtitle;
  final String date;
  final String status;
  final String detailInfo;
  final String category; // 'Visitors', 'Activities', or 'Inmates'

  TrackingItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
    required this.detailInfo,
    required this.category,
  });
}