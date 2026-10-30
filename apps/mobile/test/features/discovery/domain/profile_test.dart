import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/discovery/domain/profile.dart';

void main() {
  group('Profile model', () {
    const profile = Profile(
      id: 'usr_01',
      name: 'Alex Chen',
      age: 27,
      bio: 'Software engineer',
      occupation: 'Mobile Architect',
      distanceKm: 4,
      interests: ['Coding', 'Cycling'],
      imageUrls: ['https://example.com/photo.jpg'],
    );

    test('should support value equality', () {
      const sameProfile = Profile(
        id: 'usr_01',
        name: 'Alex Chen',
        age: 27,
        bio: 'Software engineer',
        occupation: 'Mobile Architect',
        distanceKm: 4,
        interests: ['Coding', 'Cycling'],
        imageUrls: ['https://example.com/photo.jpg'],
      );

      expect(profile, equals(sameProfile));
      expect(profile.hashCode, equals(sameProfile.hashCode));
    });

    test('should create modified copy via copyWith', () {
      final updated = profile.copyWith(
        occupation: 'Lead Mobile Architect',
        distanceKm: 5,
      );

      expect(updated.id, 'usr_01');
      expect(updated.occupation, 'Lead Mobile Architect');
      expect(updated.distanceKm, 5);
      expect(updated.name, 'Alex Chen');
    });

    test('should serialize to and from JSON', () {
      final json = profile.toJson();
      final parsed = Profile.fromJson(json);

      expect(parsed, equals(profile));
    });
  });
}
