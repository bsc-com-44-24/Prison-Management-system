class TrackingItem {
  final String title;          // e.g. Visitor Name or Inmate Name or Activity Name
  final String subtitle;       // e.g. Relationship, Cell/Block, or Facility
  final String dateOrDuration; // e.g. Visit Date or Sentence Duration
  final String status;         // e.g. Approved, Pending, Logged, Completed
  final String detailInfo;     // e.g. ID Number, Escort, Offence category
  final String category;       // 'Visitors', 'Activities', or 'Inmate'

  TrackingItem({
    required this.title,
    required this.subtitle,
    required this.dateOrDuration,
    required this.status,
    required this.detailInfo,
    required this.category,
  });
}