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

  factory Driver.fromJson(Map<String, dynamic> json) {
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
  final List<String>? knownTruckTypes;
  final String? verificationStatus; // ✅ NEW: Add verification status
  final DateTime? verificationRequestedAt; // ✅ NEW: Add verification timestamp
  final String? approvedBy; // ✅ NEW: Add approved by admin
  final DateTime? approvedAt; // ✅ NEW: Add approval timestamp
  final String? rejectionReason; // ✅ NEW: Add rejection reason

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
    this.verificationRequestedAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      licensePhoto: json['licensePhoto'],
      profilePhoto: json['profilePhoto'],
      licenseNumber: json['licenseNumber'],
      licenseType: json['licenseType'],
      experience: json['experience'],
      location: json['location'],
      age: json['age'],
      gender: json['gender'],
      knownTruckTypes: json['knownTruckTypes'] != null
          ? List<String>.from(json['knownTruckTypes'])
          : null,
      verificationStatus: json['verificationStatus'],
      verificationRequestedAt: json['verificationRequestedAt'] != null
          ? DateTime.parse(json['verificationRequestedAt'])
          : null,
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      rejectionReason: json['rejectionReason'],
    );
  }
}

// Owner classes remain the same...
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

  factory Owner.fromJson(Map<String, dynamic> json) {
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

  factory OwnerProfile.fromJson(Map<String, dynamic> json) {
    return OwnerProfile(
      companyName: json['companyName'],
      companyLocation: json['companyLocation'],
      gender: json['gender'],
      companyInfoCompleted: json['companyInfoCompleted'],
      photoUrl: json['photoUrl'],
    );
  }
}
