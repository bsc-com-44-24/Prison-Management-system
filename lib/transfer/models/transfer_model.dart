
class TransferRequestPayload {
  final String inmateId;
  final String inmateName;
  final String sourcePrisonId;
  final String sourcePrisonName;
  final String destinationPrisonId;
  final String destinationPrisonName;
  final String reason;
  final String status;

  TransferRequestPayload({
    required this.inmateId,
    required this.inmateName,
    required this.sourcePrisonId,
    required this.sourcePrisonName,
    required this.destinationPrisonId,
    required this.destinationPrisonName,
    required this.reason,
    this.status = 'PENDING',
  });

  Map<String, dynamic> toJson() {
    return {
      "inmateId": inmateId,
      "inmateName": inmateName,
      "sourcePrisonId": sourcePrisonId,
      "sourcePrisonName": sourcePrisonName,
      "destinationPrisonId": destinationPrisonId,
      "destinationPrisonName": destinationPrisonName,
      "reason": reason,
      "status": status,
    };
  }

  factory TransferRequestPayload.fromJson(Map<String, dynamic> json) {
    return TransferRequestPayload(
      inmateId: json['inmateId'] ?? '',
      inmateName: json['inmateName'] ?? '',
      sourcePrisonId: json['sourcePrisonId'] ?? '',
      sourcePrisonName: json['sourcePrisonName'] ?? '',
      destinationPrisonId: json['destinationPrisonId'] ?? '',
      destinationPrisonName: json['destinationPrisonName'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING',
    );
  }
}