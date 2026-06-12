import 'package:json_annotation/json_annotation.dart';

part 'sign_model.g.dart';

@JsonSerializable()
class TrafficSignModel {
  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String title;

  @JsonKey(defaultValue: '')
  final String description;

  @JsonKey(defaultValue: '')
  final String category;

  @JsonKey(name: 'image_url')
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

  factory TrafficSignModel.fromJson(Map<String, dynamic> json) =>
      _$TrafficSignModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrafficSignModelToJson(this);
}
