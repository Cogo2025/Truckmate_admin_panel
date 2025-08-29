class Driver {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? licensePhotoFront;
  final String? licensePhotoBack;
  final bool isAvailable;
  final DateTime createdAt;
  final DriverProfile? profile;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.licensePhotoFront,
    this.licensePhotoBack,
    required this.isAvailable,
    required this.createdAt,
    this.profile,
  });

  factory Driver.fromJson(Map json) {
    return Driver(
      id: json['id'] ?? json['googleId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      licensePhotoFront: json['licensePhotoFront'] as String?,
      licensePhotoBack: json['licensePhotoBack'] as String?,
      isAvailable: json['isAvailable'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      profile: json['profile'] != null ? DriverProfile.fromJson(json['profile']) : null,
    );
  }
}

class DriverProfile {
  final String? licensePhoto;
  final String? profilePhoto;
  final String? licenseNumber;
  final String? licenseType;
  final String? experience;
  final String? location;
  final int? age;
  final String? gender;
  final List? knownTruckTypes;
  final String? verificationStatus; // e.g. "approved", "pending", "rejected"
  final DateTime? verificationRequested;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;

  DriverProfile({
    this.licensePhoto,
    this.profilePhoto,
    this.licenseNumber,
    this.licenseType,
    this.experience,
    this.location,
    this.age,
    this.gender,
    this.knownTruckTypes,
    this.verificationStatus,
    this.verificationRequested,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
  });

  factory DriverProfile.fromJson(Map json) {
    return DriverProfile(
      licensePhoto: json['licensePhoto'],
      profilePhoto: json['profilePhoto'],
      licenseNumber: json['licenseNumber'],
      licenseType: json['licenseType'],
      experience: json['experience'],
      location: json['location'],
      age: json['age'],
      gender: json['gender'],
      knownTruckTypes: json['knownTruckTypes'] != null ? List.from(json['knownTruckTypes']) : null,
      verificationStatus: json['verificationStatus'],
      verificationRequested: json['verificationRequested'] != null ? DateTime.parse(json['verificationRequested']) : null,
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      rejectionReason: json['rejectionReason'],
    );
  }
}

class Owner {
  final String googleId;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;
  final OwnerProfile? profile;

  Owner({
    required this.googleId,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.createdAt,
    this.profile,
  });

  factory Owner.fromJson(Map json) {
    return Owner(
      googleId: json['id'] ?? json['googleId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      photoUrl: json['photoUrl'] ?? json['profile']?['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      profile: json['profile'] != null ? OwnerProfile.fromJson(json['profile']) : null,
    );
  }
}

class OwnerProfile {
  final String? companyName;
  final String? companyLocation;
  final String? gender;
  final bool? companyInfoCompleted;
  final String? photoUrl;

  OwnerProfile({
    this.companyName,
    this.companyLocation,
    this.gender,
    this.companyInfoCompleted,
    this.photoUrl,
  });

  factory OwnerProfile.fromJson(Map json) {
    return OwnerProfile(
      companyName: json['companyName'],
      companyLocation: json['companyLocation'],
      gender: json['gender'],
      companyInfoCompleted: json['companyInfoCompleted'],
      photoUrl: json['photoUrl'],
    );
  }
}
