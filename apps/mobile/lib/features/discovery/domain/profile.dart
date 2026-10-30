import 'package:flutter/foundation.dart';

/// Domain entity representing a discoverable user profile.
@immutable
class Profile {
  final String id;
  final String name;
  final int age;
  final String bio;
  final String occupation;
  final int distanceKm;
  final List<String> interests;
  final List<String> imageUrls;

  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.occupation,
    required this.distanceKm,
    this.interests = const [],
    this.imageUrls = const [],
  });

  Profile copyWith({
    String? id,
    String? name,
    int? age,
    String? bio,
    String? occupation,
    int? distanceKm,
    List<String>? interests,
    List<String>? imageUrls,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      occupation: occupation ?? this.occupation,
      distanceKm: distanceKm ?? this.distanceKm,
      interests: interests ?? this.interests,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      bio: json['bio'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toInt() ?? 0,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'bio': bio,
      'occupation': occupation,
      'distanceKm': distanceKm,
      'interests': interests,
      'imageUrls': imageUrls,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          age == other.age &&
          bio == other.bio &&
          occupation == other.occupation &&
          distanceKm == other.distanceKm &&
          listEquals(interests, other.interests) &&
          listEquals(imageUrls, other.imageUrls);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      age.hashCode ^
      bio.hashCode ^
      occupation.hashCode ^
      distanceKm.hashCode ^
      interests.hashCode ^
      imageUrls.hashCode;

  @override
  String toString() {
    return 'Profile(id: $id, name: $name, age: $age, occupation: $occupation, distanceKm: $distanceKm)';
  }
}
