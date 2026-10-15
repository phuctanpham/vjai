from app.models.profile import Profile

SAMPLE_PROFILES: list[Profile] = [
    Profile(
        id="usr_01",
        name="Alex Chen",
        age=27,
        bio="Software engineer & amateur photographer. Passionate about mountain biking and artisanal coffee roasts.",
        occupation="Mobile Architect",
        distanceKm=4,
        interests=["Coding", "Photography", "Cycling", "Coffee"],
        imageUrls=[
            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800",
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800",
        ],
    ),
    Profile(
        id="usr_02",
        name="Elena Rostova",
        age=25,
        bio="Graphic designer living in the city. Always looking for indie bookstores, rooftop gardens, and art gallery openings.",
        occupation="Visual Designer",
        distanceKm=7,
        interests=["Art", "Design", "Reading", "Indie Music"],
        imageUrls=[
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800",
        ],
    ),
    Profile(
        id="usr_03",
        name="Marcus Vance",
        age=29,
        bio="Founder & trail runner. Believer in great conversation, vinyl records, and outdoor weekend getaways.",
        occupation="Product Strategist",
        distanceKm=12,
        interests=["Startups", "Running", "Vinyl", "Hiking"],
        imageUrls=[
            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800",
        ],
    ),
    Profile(
        id="usr_04",
        name="Sophia Lin",
        age=26,
        bio="Architectural illustrator. Sketching cityscapes, exploring ceramic studios, and perfecting sourdough recipes.",
        occupation="Architect",
        distanceKm=3,
        interests=["Architecture", "Sketching", "Baking", "Travel"],
        imageUrls=[
            "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800",
        ],
    ),
    Profile(
        id="usr_05",
        name="David Kim",
        age=28,
        bio="Jazz pianist and data analyst. Let's debate sci-fi novels or check out a live concert downtown.",
        occupation="Data Analyst & Musician",
        distanceKm=9,
        interests=["Jazz", "Piano", "Sci-Fi", "Chess"],
        imageUrls=[
            "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=800",
        ],
    ),
]

