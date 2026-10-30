import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/profile.dart';
import '../domain/swipe_type.dart';

/// Provider for DiscoveryRepository.
final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return MockDiscoveryRepository();
});

/// Contract for discovery data operations.
abstract class DiscoveryRepository {
  Future<List<Profile>> getProfiles();
  Future<void> recordSwipe({
    required String profileId,
    required SwipeType swipeType,
  });
}

/// Mock implementation of DiscoveryRepository providing sample profiles.
class MockDiscoveryRepository implements DiscoveryRepository {
  final Duration delay;
  final bool shouldFail;
  final bool returnEmpty;
  final List<Profile>? customProfiles;

  MockDiscoveryRepository({
    this.delay = const Duration(milliseconds: 300),
    this.shouldFail = false,
    this.returnEmpty = false,
    this.customProfiles,
  });

  static const List<Profile> sampleProfiles = [
    Profile(
      id: 'usr_01',
      name: 'Alex Chen',
      age: 27,
      bio:
          'Software engineer & amateur photographer. Passionate about mountain biking and artisanal coffee roasts.',
      occupation: 'Mobile Architect',
      distanceKm: 4,
      interests: ['Coding', 'Photography', 'Cycling', 'Coffee'],
      imageUrls: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
      ],
    ),
    Profile(
      id: 'usr_02',
      name: 'Elena Rostova',
      age: 25,
      bio:
          'Graphic designer living in the city. Always looking for indie bookstores, rooftop gardens, and art gallery openings.',
      occupation: 'Visual Designer',
      distanceKm: 7,
      interests: ['Art', 'Design', 'Reading', 'Indie Music'],
      imageUrls: [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
      ],
    ),
    Profile(
      id: 'usr_03',
      name: 'Marcus Vance',
      age: 29,
      bio:
          'Founder & trail runner. Believer in great conversation, vinyl records, and outdoor weekend getaways.',
      occupation: 'Product Strategist',
      distanceKm: 12,
      interests: ['Startups', 'Running', 'Vinyl', 'Hiking'],
      imageUrls: [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
      ],
    ),
    Profile(
      id: 'usr_04',
      name: 'Sophia Lin',
      age: 26,
      bio:
          'Architectural illustrator. Sketching cityscapes, exploring ceramic studios, and perfecting sourdough recipes.',
      occupation: 'Architect',
      distanceKm: 3,
      interests: ['Architecture', 'Sketching', 'Baking', 'Travel'],
      imageUrls: [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
      ],
    ),
    Profile(
      id: 'usr_05',
      name: 'David Kim',
      age: 28,
      bio:
          "Jazz pianist and data analyst. Let's debate sci-fi novels or check out a live concert downtown.",
      occupation: 'Data Analyst & Musician',
      distanceKm: 9,
      interests: ['Jazz', 'Piano', 'Sci-Fi', 'Chess'],
      imageUrls: [
        'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=800',
      ],
    ),
  ];

  @override
  Future<List<Profile>> getProfiles() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (shouldFail) {
      throw Exception(
          'Failed to load discovery profiles. Please check connection.');
    }

    if (returnEmpty) {
      return const [];
    }

    return customProfiles ?? List.from(sampleProfiles);
  }

  @override
  Future<void> recordSwipe({
    required String profileId,
    required SwipeType swipeType,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (shouldFail) {
      throw Exception('Failed to record swipe.');
    }
  }
}
