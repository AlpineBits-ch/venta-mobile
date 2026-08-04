// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrivacySettingsDto _$PrivacySettingsDtoFromJson(Map<String, dynamic> json) =>
    _PrivacySettingsDto(
      allowDataCollection: json['allowDataCollection'] as bool? ?? false,
      allowPersonalization: json['allowPersonalization'] as bool? ?? false,
      allowVoiceRecordingInClips:
          json['allowVoiceRecordingInClips'] as bool? ?? false,
      directMessagePolicy:
          $enumDecodeNullable(
            _$DirectMessagePolicyEnumMap,
            json['directMessagePolicy'],
            unknownValue: DirectMessagePolicy.friends,
          ) ??
          DirectMessagePolicy.friends,
      friendRequestPolicy:
          $enumDecodeNullable(
            _$FriendRequestPolicyEnumMap,
            json['friendRequestPolicy'],
            unknownValue: FriendRequestPolicy.nobody,
          ) ??
          FriendRequestPolicy.nobody,
      discoverableByUsername: json['discoverableByUsername'] as bool? ?? false,
      discoverableByEmail: json['discoverableByEmail'] as bool? ?? false,
      discoverableByPhone: json['discoverableByPhone'] as bool? ?? false,
      mutualServersVisibility:
          $enumDecodeNullable(
            _$ProfileVisibilityEnumMap,
            json['mutualServersVisibility'],
            unknownValue: ProfileVisibility.nobody,
          ) ??
          ProfileVisibility.nobody,
      mutualFriendsVisibility:
          $enumDecodeNullable(
            _$ProfileVisibilityEnumMap,
            json['mutualFriendsVisibility'],
            unknownValue: ProfileVisibility.nobody,
          ) ??
          ProfileVisibility.nobody,
      connectionsVisibility:
          $enumDecodeNullable(
            _$ProfileVisibilityEnumMap,
            json['connectionsVisibility'],
            unknownValue: ProfileVisibility.nobody,
          ) ??
          ProfileVisibility.nobody,
      birthdayVisibility:
          $enumDecodeNullable(
            _$ProfileVisibilityEnumMap,
            json['birthdayVisibility'],
            unknownValue: ProfileVisibility.nobody,
          ) ??
          ProfileVisibility.nobody,
      shareActivity: json['shareActivity'] as bool? ?? false,
      allowPositionalVoiceCapture:
          json['allowPositionalVoiceCapture'] as bool? ?? false,
      sendReadReceipts: json['sendReadReceipts'] as bool? ?? false,
      sendTypingIndicators: json['sendTypingIndicators'] as bool? ?? false,
      dmRetentionDays: (json['dmRetentionDays'] as num?)?.toInt(),
      explicitContentFilter:
          $enumDecodeNullable(
            _$ExplicitContentFilterEnumMap,
            json['explicitContentFilter'],
            unknownValue: ExplicitContentFilter.unknownSenders,
          ) ??
          ExplicitContentFilter.unknownSenders,
      hidePushContent: json['hidePushContent'] as bool? ?? true,
      version: (json['version'] as num?)?.toInt() ?? 0,
      isMinor: json['isMinor'] as bool? ?? false,
    );

Map<String, dynamic> _$PrivacySettingsDtoToJson(_PrivacySettingsDto instance) =>
    <String, dynamic>{
      'allowDataCollection': instance.allowDataCollection,
      'allowPersonalization': instance.allowPersonalization,
      'allowVoiceRecordingInClips': instance.allowVoiceRecordingInClips,
      'directMessagePolicy':
          _$DirectMessagePolicyEnumMap[instance.directMessagePolicy]!,
      'friendRequestPolicy':
          _$FriendRequestPolicyEnumMap[instance.friendRequestPolicy]!,
      'discoverableByUsername': instance.discoverableByUsername,
      'discoverableByEmail': instance.discoverableByEmail,
      'discoverableByPhone': instance.discoverableByPhone,
      'mutualServersVisibility':
          _$ProfileVisibilityEnumMap[instance.mutualServersVisibility]!,
      'mutualFriendsVisibility':
          _$ProfileVisibilityEnumMap[instance.mutualFriendsVisibility]!,
      'connectionsVisibility':
          _$ProfileVisibilityEnumMap[instance.connectionsVisibility]!,
      'birthdayVisibility':
          _$ProfileVisibilityEnumMap[instance.birthdayVisibility]!,
      'shareActivity': instance.shareActivity,
      'allowPositionalVoiceCapture': instance.allowPositionalVoiceCapture,
      'sendReadReceipts': instance.sendReadReceipts,
      'sendTypingIndicators': instance.sendTypingIndicators,
      'dmRetentionDays': instance.dmRetentionDays,
      'explicitContentFilter':
          _$ExplicitContentFilterEnumMap[instance.explicitContentFilter]!,
      'hidePushContent': instance.hidePushContent,
      'version': instance.version,
      'isMinor': instance.isMinor,
    };

const _$DirectMessagePolicyEnumMap = {
  DirectMessagePolicy.everyone: 'Everyone',
  DirectMessagePolicy.friendsAndServerMembers: 'FriendsAndServerMembers',
  DirectMessagePolicy.friends: 'Friends',
  DirectMessagePolicy.nobody: 'Nobody',
};

const _$FriendRequestPolicyEnumMap = {
  FriendRequestPolicy.everyone: 'Everyone',
  FriendRequestPolicy.friendsOfFriends: 'FriendsOfFriends',
  FriendRequestPolicy.serverMembers: 'ServerMembers',
  FriendRequestPolicy.nobody: 'Nobody',
};

const _$ProfileVisibilityEnumMap = {
  ProfileVisibility.everyone: 'Everyone',
  ProfileVisibility.friends: 'Friends',
  ProfileVisibility.nobody: 'Nobody',
};

const _$ExplicitContentFilterEnumMap = {
  ExplicitContentFilter.off: 'Off',
  ExplicitContentFilter.unknownSenders: 'UnknownSenders',
  ExplicitContentFilter.everyone: 'Everyone',
};
