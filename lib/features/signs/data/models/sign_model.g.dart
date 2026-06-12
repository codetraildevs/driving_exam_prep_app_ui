// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrafficSignModel _$TrafficSignModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TrafficSignModel', json, ($checkedConvert) {
      final val = TrafficSignModel(
        id: $checkedConvert('id', (v) => v as String? ?? ''),
        title: $checkedConvert('title', (v) => v as String? ?? ''),
        description: $checkedConvert('description', (v) => v as String? ?? ''),
        category: $checkedConvert('category', (v) => v as String? ?? ''),
        imageUrl: $checkedConvert('image_url', (v) => v as String?),
        scenario: $checkedConvert('scenario', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'imageUrl': 'image_url'});

Map<String, dynamic> _$TrafficSignModelToJson(TrafficSignModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'image_url': ?instance.imageUrl,
      'scenario': ?instance.scenario,
    };
