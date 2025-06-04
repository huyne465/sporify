class AppUrls {
  // List of sample music cover images from public URLs
  static const List<String> sampleCovers = [
    'https://th.bing.com/th/id/OIP.pUEXyAP0k4dkkFZ5j4tU3gHaFj?rs=1&pid=ImgDetMain',
    'https://th.bing.com/th/id/OIP.pUEXyAP0k4dkkFZ5j4tU3gHaFj?rs=1&pid=ImgDetMain',
  ];

  // Function to get a consistent image URL for a particular song
  static String getImageUrl(String artist, String title) {
    // Create a simple hash from artist and title to select a consistent image
    int hash = (artist.length + title.length) % sampleCovers.length;
    return sampleCovers[hash];
  }
}
