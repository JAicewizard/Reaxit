// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbumPhoto _$AlbumPhotoFromJson(Map<String, dynamic> json) => AlbumPhoto(
      json['pk'] as int,
      json['rotation'] as int,
      json['hidden'] as bool,
      Photo.fromJson(json['file'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AlbumPhotoToJson(AlbumPhoto instance) =>
    <String, dynamic>{
      'pk': instance.pk,
      'rotation': instance.rotation,
      'hidden': instance.hidden,
      'file': instance.file,
    };

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
      json['full'] as String,
      json['small'] as String,
      json['medium'] as String,
      json['large'] as String,
    );

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'full': instance.full,
      'small': instance.small,
      'medium': instance.medium,
      'large': instance.large,
    };
