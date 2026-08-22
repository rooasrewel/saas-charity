class DonorProfileModel {
  final String? country;
  final String? city;
  final List<String>? causes;
  final bool isAnonymous;
  final String? profileImage;

  DonorProfileModel({
    this.country,
    this.city,
    this.causes,
    this.isAnonymous = false,
    this.profileImage,
  });

  factory DonorProfileModel.fromJson(Map<String, dynamic> json) {
    return DonorProfileModel(
      country: json['country'],
      city: json['city'],
      causes: json['causes'] != null ? List<String>.from(json['causes']) : [],
      isAnonymous: json['is_anonymous'] == 1 || json['is_anonymous'] == true,
      profileImage: json['profile_image'] ?? json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'city': city,
      'causes': causes,
      'is_anonymous': isAnonymous ? 1 : 0,
      'profile_image': profileImage,
    };
  }
}