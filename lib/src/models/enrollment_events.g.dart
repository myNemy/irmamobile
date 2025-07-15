// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollment_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnrollmentStatusEvent _$EnrollmentStatusEventFromJson(Map<String, dynamic> json) => EnrollmentStatusEvent(
      enrolledSchemeManagerIds: (json['EnrolledSchemeManagerIds'] as List<dynamic>).map((e) => e as String).toList(),
      unenrolledSchemeManagerIds:
          (json['UnenrolledSchemeManagerIds'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$EnrollmentStatusEventToJson(EnrollmentStatusEvent instance) => <String, dynamic>{
      'EnrolledSchemeManagerIds': instance.enrolledSchemeManagerIds,
      'UnenrolledSchemeManagerIds': instance.unenrolledSchemeManagerIds,
    };

EnrollEvent _$EnrollEventFromJson(Map<String, dynamic> json) => EnrollEvent(
      email: json['Email'] as String,
      pin: json['Pin'] as String,
      language: json['Language'] as String,
      schemeId: json['SchemeID'] as String,
    );

Map<String, dynamic> _$EnrollEventToJson(EnrollEvent instance) => <String, dynamic>{
      'Email': instance.email,
      'Pin': instance.pin,
      'Language': instance.language,
      'SchemeID': instance.schemeId,
    };

EnrollmentFailureEvent _$EnrollmentFailureEventFromJson(Map<String, dynamic> json) => EnrollmentFailureEvent(
      schemeManagerID: json['SchemeManagerID'] as String,
      error: SessionError.fromJson(json['Error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EnrollmentFailureEventToJson(EnrollmentFailureEvent instance) => <String, dynamic>{
      'SchemeManagerID': instance.schemeManagerID,
      'Error': instance.error,
    };

EnrollmentSuccessEvent _$EnrollmentSuccessEventFromJson(Map<String, dynamic> json) => EnrollmentSuccessEvent(
      schemeManagerID: json['SchemeManagerID'] as String,
    );

Map<String, dynamic> _$EnrollmentSuccessEventToJson(EnrollmentSuccessEvent instance) => <String, dynamic>{
      'SchemeManagerID': instance.schemeManagerID,
    };
