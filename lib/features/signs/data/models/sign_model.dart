class TrafficSignModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? imageUrl;
  final String? scenario;

  const TrafficSignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    this.scenario,
  });

  factory TrafficSignModel.fromJson(Map<String, dynamic> json) {
    return TrafficSignModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String?,
      scenario: json['scenario'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'image_url': imageUrl,
    'scenario': scenario,
  };
}
