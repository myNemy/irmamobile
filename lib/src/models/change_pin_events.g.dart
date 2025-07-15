// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_pin_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePinEvent _$ChangePinEventFromJson(Map<String, dynamic> json) => ChangePinEvent(
      oldPin: json['OldPin'] as String,
      newPin: json['NewPin'] as String,
    );

Map<String, dynamic> _$ChangePinEventToJson(ChangePinEvent instance) => <String, dynamic>{
      'OldPin': instance.oldPin,
      'NewPin': instance.newPin,
    };

ChangePinErrorEvent _$ChangePinErrorEventFromJson(Map<String, dynamic> json) => ChangePinErrorEvent(
      schemeManagerID: json['SchemeManagerID'] as String,
      error: SessionError.fromJson(json['Error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChangePinErrorEventToJson(ChangePinErrorEvent instance) => <String, dynamic>{
      'SchemeManagerID': instance.schemeManagerID,
      'Error': instance.error,
    };

ChangePinSuccessEvent _$ChangePinSuccessEventFromJson(Map<String, dynamic> json) => ChangePinSuccessEvent();

Map<String, dynamic> _$ChangePinSuccessEventToJson(ChangePinSuccessEvent instance) => <String, dynamic>{};

ChangePinFailedEvent _$ChangePinFailedEventFromJson(Map<String, dynamic> json) => ChangePinFailedEvent(
      schemeManagerID: json['SchemeManagerID'] as String,
      remainingAttempts: (json['RemainingAttempts'] as num).toInt(),
      timeout: (json['Timeout'] as num).toInt(),
    );

Map<String, dynamic> _$ChangePinFailedEventToJson(ChangePinFailedEvent instance) => <String, dynamic>{
      'SchemeManagerID': instance.schemeManagerID,
      'RemainingAttempts': instance.remainingAttempts,
      'Timeout': instance.timeout,
    };
