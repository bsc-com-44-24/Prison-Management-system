class ReleaseModel {
final int? id;
final String inmateId;
final String releaseDate;
final String verificationStatus;
final String clearanceStatus;
final String approvalStatus;
final String releaseStatus;

ReleaseModel({
this.id,
required this.inmateId,
required this.releaseDate,
this.verificationStatus = 'Pending',
this.clearanceStatus = 'Pending',
this.approvalStatus = 'Pending',
this.releaseStatus = 'Upcoming',
});

Map<String, dynamic> toMap() {
return {
'id': id,
'inmate_id': inmateId,
'release_date': releaseDate,
'verification_status': verificationStatus,
'clearance_status': clearanceStatus,
'approval_status': approvalStatus,
'release_status': releaseStatus,
};
}

factory ReleaseModel.fromMap(Map<String, dynamic> map) {
return ReleaseModel(
id: map['id'] as int?,
inmateId: map['inmate_id'] as String,
releaseDate: map['release_date'] as String,
verificationStatus: map['verification_status'] as String,
clearanceStatus: map['clearance_status'] as String,
approvalStatus: map['approval_status'] as String,
releaseStatus: map['release_status'] as String,
);
}
}
