class EventItem {
  final String image;
  final String title;
  final String date;
  final String location;
  final String price;
  final String url;
  final String? distance; 

  EventItem({
    required this.image,
    required this.title,
    required this.date,
    required this.location,
    required this.price,
    required this.url,
    this.distance,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      image: json['img_url'] ?? 'null',
      title: json['name'] ?? 'null',
      date: json['start_date'] ?? 'null',
      location: json['city'] ?? 'null',
      price: json['price'] ?? 'null',
      url: json['event_url']  ?? 'null',
      distance: json['distance'] ?? 'null',
    );
  }

  String get displayPrice {
    return price.toLowerCase() == 'gratis' ? price : '$price€';
  }
}
