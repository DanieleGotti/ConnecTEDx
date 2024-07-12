class VideoItem {
  final String urlImage;
  final String title;
  final String speakers;
  final String url;

  VideoItem({
    required this.urlImage,
    required this.title,
    required this.speakers,
    required this.url,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      urlImage: json['url_image'] ?? 'null',
      title: json['title'] ?? 'null',
      speakers: json['speakers'] ?? 'null',
      url: json['url'] ?? 'null',
    );
  }
}
