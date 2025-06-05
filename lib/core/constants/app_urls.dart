class AppUrls {
  // List of sample music cover images as fallbacks
  static const List<String> sampleCovers = [
    'https://i.pinimg.com/originals/8d/64/e9/8d64e974c03c6fceab52772289a9c8f7.jpg',
    'https://i.pinimg.com/originals/f5/82/47/f58247463e38a536fa9a9964a7f1506f.jpg',
    'https://i.pinimg.com/originals/31/a0/d7/31a0d77f7151e625707630979f8f0d2a.jpg',
    'https://i.pinimg.com/originals/4c/75/99/4c7599dfc5b1126136aad6007760c705.jpg',
    'https://i.pinimg.com/originals/93/32/7d/93327dd3a7331ffdc07007226e9d774d.jpg',
    'https://i.pinimg.com/originals/2a/9f/da/2a9fdacc7b952c4048761a43229e2756.jpg',
  ];

  // Function to get image URL, prioritizing Firebase stored URLs
  static String getImageUrl(String artist, String title, String? imageUrl) {
    // If the song has a valid URL stored in Firebase, use that
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Check if it's a valid URL
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return imageUrl;
      }
    }

    // Fall back to sample covers if no valid URL exists
    int hash = (artist.length + title.length) % sampleCovers.length;
    return sampleCovers[hash];
  }
}
