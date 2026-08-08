// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mls_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceWelcomeDto _$DeviceWelcomeDtoFromJson(Map<String, dynamic> json) =>
    _DeviceWelcomeDto(
      deviceId: json['deviceId'] as String,
      userId: json['userId'] as String,
      welcome: json['welcome'] as String,
    );

Map<String, dynamic> _$DeviceWelcomeDtoToJson(_DeviceWelcomeDto instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'userId': instance.userId,
      'welcome': instance.welcome,
    };

_PendingWelcomeDto _$PendingWelcomeDtoFromJson(Map<String, dynamic> json) =>
    _PendingWelcomeDto(
      id: json['id'] as String,
      contextId: json['contextId'] as String,
      conversationId: json['conversationId'] as String?,
      channelId: json['channelId'] as String?,
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      welcome: json['welcome'] as String,
      generation: (json['generation'] as num).toInt(),
      epoch: (json['epoch'] as num).toInt(),
      consumedAt: _$JsonConverterFromJson<String, DateTime>(
        json['consumedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const ApiDateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$PendingWelcomeDtoToJson(_PendingWelcomeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contextId': instance.contextId,
      'conversationId': instance.conversationId,
      'channelId': instance.channelId,
      'userId': instance.userId,
      'deviceId': instance.deviceId,
      'welcome': instance.welcome,
      'generation': instance.generation,
      'epoch': instance.epoch,
      'consumedAt': _$JsonConverterToJson<String, DateTime>(
        instance.consumedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_MlsCommitDto _$MlsCommitDtoFromJson(Map<String, dynamic> json) =>
    _MlsCommitDto(
      id: json['id'] as String,
      contextId: json['contextId'] as String,
      conversationId: json['conversationId'] as String?,
      channelId: json['channelId'] as String?,
      generation: (json['generation'] as num).toInt(),
      epoch: (json['epoch'] as num).toInt(),
      commit: json['commit'] as String,
      senderUserId: json['senderUserId'] as String,
      senderDeviceId: json['senderDeviceId'] as String,
      isProposal: json['isProposal'] as bool? ?? false,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const ApiDateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$MlsCommitDtoToJson(_MlsCommitDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contextId': instance.contextId,
      'conversationId': instance.conversationId,
      'channelId': instance.channelId,
      'generation': instance.generation,
      'epoch': instance.epoch,
      'commit': instance.commit,
      'senderUserId': instance.senderUserId,
      'senderDeviceId': instance.senderDeviceId,
      'isProposal': instance.isProposal,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
    };

_PublishMlsCommitDto _$PublishMlsCommitDtoFromJson(Map<String, dynamic> json) =>
    _PublishMlsCommitDto(
      epoch: (json['epoch'] as num).toInt(),
      commit: json['commit'] as String,
      senderDeviceId: json['senderDeviceId'] as String,
      isProposal: json['isProposal'] as bool? ?? false,
      generation: (json['generation'] as num?)?.toInt(),
      groupInfo: json['groupInfo'] as String?,
      welcomes:
          (json['welcomes'] as List<dynamic>?)
              ?.map((e) => DeviceWelcomeDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DeviceWelcomeDto>[],
      fulfilledJoinRequestIds:
          (json['fulfilledJoinRequestIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$PublishMlsCommitDtoToJson(
  _PublishMlsCommitDto instance,
) => <String, dynamic>{
  'epoch': instance.epoch,
  'commit': instance.commit,
  'senderDeviceId': instance.senderDeviceId,
  'isProposal': instance.isProposal,
  'generation': instance.generation,
  'groupInfo': instance.groupInfo,
  'welcomes': instance.welcomes,
  'fulfilledJoinRequestIds': instance.fulfilledJoinRequestIds,
};

_MlsCommitPublishedDto _$MlsCommitPublishedDtoFromJson(
  Map<String, dynamic> json,
) => _MlsCommitPublishedDto(
  contextId: json['contextId'] as String,
  conversationId: json['conversationId'] as String?,
  generation: (json['generation'] as num).toInt(),
  epoch: (json['epoch'] as num).toInt(),
  isProposal: json['isProposal'] as bool? ?? false,
  duplicate: json['duplicate'] as bool? ?? false,
);

Map<String, dynamic> _$MlsCommitPublishedDtoToJson(
  _MlsCommitPublishedDto instance,
) => <String, dynamic>{
  'contextId': instance.contextId,
  'conversationId': instance.conversationId,
  'generation': instance.generation,
  'epoch': instance.epoch,
  'isProposal': instance.isProposal,
  'duplicate': instance.duplicate,
};

_MlsGenerationDto _$MlsGenerationDtoFromJson(Map<String, dynamic> json) =>
    _MlsGenerationDto(
      id: json['id'] as String,
      contextId: json['contextId'] as String,
      generation: (json['generation'] as num).toInt(),
      mlsGroupId: json['mlsGroupId'] as String?,
      mlsGroupInfo: json['mlsGroupInfo'] as String?,
      epoch: (json['epoch'] as num).toInt(),
      state: $enumDecode(
        _$MlsGenerationStateEnumMap,
        json['state'],
        unknownValue: MlsGenerationState.active,
      ),
      activatedAt: _$JsonConverterFromJson<String, DateTime>(
        json['activatedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      activatedByUserId: json['activatedByUserId'] as String?,
      terminatedAt: _$JsonConverterFromJson<String, DateTime>(
        json['terminatedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      terminatedByUserId: json['terminatedByUserId'] as String?,
    );

Map<String, dynamic> _$MlsGenerationDtoToJson(_MlsGenerationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contextId': instance.contextId,
      'generation': instance.generation,
      'mlsGroupId': instance.mlsGroupId,
      'mlsGroupInfo': instance.mlsGroupInfo,
      'epoch': instance.epoch,
      'state': _$MlsGenerationStateEnumMap[instance.state]!,
      'activatedAt': _$JsonConverterToJson<String, DateTime>(
        instance.activatedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'activatedByUserId': instance.activatedByUserId,
      'terminatedAt': _$JsonConverterToJson<String, DateTime>(
        instance.terminatedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'terminatedByUserId': instance.terminatedByUserId,
    };

const _$MlsGenerationStateEnumMap = {
  MlsGenerationState.active: 'Active',
  MlsGenerationState.terminated: 'Terminated',
};

_MlsContextStateDto _$MlsContextStateDtoFromJson(Map<String, dynamic> json) =>
    _MlsContextStateDto(
      contextId: json['contextId'] as String,
      encrypted: json['encrypted'] as bool? ?? false,
      activeGeneration: (json['activeGeneration'] as num?)?.toInt(),
      epoch: (json['epoch'] as num?)?.toInt(),
      mlsGroupId: json['mlsGroupId'] as String?,
      mlsGroupInfo: json['mlsGroupInfo'] as String?,
      generations:
          (json['generations'] as List<dynamic>?)
              ?.map((e) => MlsGenerationDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MlsGenerationDto>[],
    );

Map<String, dynamic> _$MlsContextStateDtoToJson(_MlsContextStateDto instance) =>
    <String, dynamic>{
      'contextId': instance.contextId,
      'encrypted': instance.encrypted,
      'activeGeneration': instance.activeGeneration,
      'epoch': instance.epoch,
      'mlsGroupId': instance.mlsGroupId,
      'mlsGroupInfo': instance.mlsGroupInfo,
      'generations': instance.generations,
    };

_EnableMlsDto _$EnableMlsDtoFromJson(Map<String, dynamic> json) =>
    _EnableMlsDto(
      mlsGroupId: json['mlsGroupId'] as String,
      epoch: (json['epoch'] as num).toInt(),
      mlsGroupInfo: json['mlsGroupInfo'] as String?,
      welcomes:
          (json['welcomes'] as List<dynamic>?)
              ?.map((e) => DeviceWelcomeDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DeviceWelcomeDto>[],
    );

Map<String, dynamic> _$EnableMlsDtoToJson(_EnableMlsDto instance) =>
    <String, dynamic>{
      'mlsGroupId': instance.mlsGroupId,
      'epoch': instance.epoch,
      'mlsGroupInfo': instance.mlsGroupInfo,
      'welcomes': instance.welcomes,
    };

_MlsToggleResultDto _$MlsToggleResultDtoFromJson(Map<String, dynamic> json) =>
    _MlsToggleResultDto(
      contextId: json['contextId'] as String,
      encrypted: json['encrypted'] as bool? ?? false,
      generation: (json['generation'] as num?)?.toInt(),
      terminatedGeneration: (json['terminatedGeneration'] as num?)?.toInt(),
      alreadyInRequestedState:
          json['alreadyInRequestedState'] as bool? ?? false,
    );

Map<String, dynamic> _$MlsToggleResultDtoToJson(_MlsToggleResultDto instance) =>
    <String, dynamic>{
      'contextId': instance.contextId,
      'encrypted': instance.encrypted,
      'generation': instance.generation,
      'terminatedGeneration': instance.terminatedGeneration,
      'alreadyInRequestedState': instance.alreadyInRequestedState,
    };

_MlsEpochConflictDto _$MlsEpochConflictDtoFromJson(Map<String, dynamic> json) =>
    _MlsEpochConflictDto(
      currentEpoch: (json['currentEpoch'] as num?)?.toInt() ?? 0,
      rejectedEpoch: (json['rejectedEpoch'] as num?)?.toInt() ?? 0,
      currentGeneration: (json['currentGeneration'] as num?)?.toInt() ?? 0,
      rejectedGeneration: (json['rejectedGeneration'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
    );

Map<String, dynamic> _$MlsEpochConflictDtoToJson(
  _MlsEpochConflictDto instance,
) => <String, dynamic>{
  'currentEpoch': instance.currentEpoch,
  'rejectedEpoch': instance.rejectedEpoch,
  'currentGeneration': instance.currentGeneration,
  'rejectedGeneration': instance.rejectedGeneration,
  'reason': instance.reason,
};

_MlsToggleConflictDto _$MlsToggleConflictDtoFromJson(
  Map<String, dynamic> json,
) => _MlsToggleConflictDto(
  contextId: json['contextId'] as String? ?? '',
  encrypted: json['encrypted'] as bool? ?? false,
  reason: json['reason'] as String? ?? '',
  retryAfterSeconds: (json['retryAfterSeconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$MlsToggleConflictDtoToJson(
  _MlsToggleConflictDto instance,
) => <String, dynamic>{
  'contextId': instance.contextId,
  'encrypted': instance.encrypted,
  'reason': instance.reason,
  'retryAfterSeconds': instance.retryAfterSeconds,
};

_AckWelcomesResultDto _$AckWelcomesResultDtoFromJson(
  Map<String, dynamic> json,
) => _AckWelcomesResultDto(
  acknowledged: (json['acknowledged'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AckWelcomesResultDtoToJson(
  _AckWelcomesResultDto instance,
) => <String, dynamic>{'acknowledged': instance.acknowledged};

_MlsDeviceTokenDto _$MlsDeviceTokenDtoFromJson(Map<String, dynamic> json) =>
    _MlsDeviceTokenDto(
      deviceId: json['deviceId'] as String,
      userId: json['userId'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$MlsDeviceTokenDtoToJson(_MlsDeviceTokenDto instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'userId': instance.userId,
      'token': instance.token,
    };

_UnreachableDeviceDto _$UnreachableDeviceDtoFromJson(
  Map<String, dynamic> json,
) => _UnreachableDeviceDto(
  userId: json['userId'] as String,
  deviceId: json['deviceId'] as String,
  deviceName: json['deviceName'] as String?,
);

Map<String, dynamic> _$UnreachableDeviceDtoToJson(
  _UnreachableDeviceDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'deviceId': instance.deviceId,
  'deviceName': instance.deviceName,
};

_MlsDeviceCoverageDto _$MlsDeviceCoverageDtoFromJson(
  Map<String, dynamic> json,
) => _MlsDeviceCoverageDto(
  deviceId: json['deviceId'] as String,
  deviceName: json['deviceName'] as String?,
  covered: json['covered'] as bool?,
);

Map<String, dynamic> _$MlsDeviceCoverageDtoToJson(
  _MlsDeviceCoverageDto instance,
) => <String, dynamic>{
  'deviceId': instance.deviceId,
  'deviceName': instance.deviceName,
  'covered': instance.covered,
};

_MlsCoverageDto _$MlsCoverageDtoFromJson(
  Map<String, dynamic> json,
) => _MlsCoverageDto(
  contextId: json['contextId'] as String,
  encrypted: json['encrypted'] as bool? ?? false,
  generation: (json['generation'] as num?)?.toInt(),
  ownDevices:
      (json['ownDevices'] as List<dynamic>?)
          ?.map((e) => MlsDeviceCoverageDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MlsDeviceCoverageDto>[],
  unreachableDevices:
      (json['unreachableDevices'] as List<dynamic>?)
          ?.map((e) => UnreachableDeviceDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <UnreachableDeviceDto>[],
  coverageUnavailable: json['coverageUnavailable'] as bool? ?? false,
);

Map<String, dynamic> _$MlsCoverageDtoToJson(_MlsCoverageDto instance) =>
    <String, dynamic>{
      'contextId': instance.contextId,
      'encrypted': instance.encrypted,
      'generation': instance.generation,
      'ownDevices': instance.ownDevices,
      'unreachableDevices': instance.unreachableDevices,
      'coverageUnavailable': instance.coverageUnavailable,
    };

_ConsumeTokensResultDto _$ConsumeTokensResultDtoFromJson(
  Map<String, dynamic> json,
) => _ConsumeTokensResultDto(
  deviceTokens:
      (json['deviceTokens'] as List<dynamic>?)
          ?.map((e) => MlsDeviceTokenDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MlsDeviceTokenDto>[],
  unreachableDevices:
      (json['unreachableDevices'] as List<dynamic>?)
          ?.map((e) => UnreachableDeviceDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <UnreachableDeviceDto>[],
);

Map<String, dynamic> _$ConsumeTokensResultDtoToJson(
  _ConsumeTokensResultDto instance,
) => <String, dynamic>{
  'deviceTokens': instance.deviceTokens,
  'unreachableDevices': instance.unreachableDevices,
};

_MlsJoinRequestDto _$MlsJoinRequestDtoFromJson(Map<String, dynamic> json) =>
    _MlsJoinRequestDto(
      id: json['id'] as String,
      contextId: json['contextId'] as String,
      channelId: json['channelId'] as String?,
      conversationId: json['conversationId'] as String?,
      generation: (json['generation'] as num).toInt(),
      requesterUserId: json['requesterUserId'] as String,
      requesterDeviceId: json['requesterDeviceId'] as String,
      keyPackageHash: json['keyPackageHash'] as String,
      keyPackage: json['keyPackage'] as String?,
      signatureKeyFingerprint: json['signatureKeyFingerprint'] as String,
      state: $enumDecode(
        _$MlsJoinRequestStateEnumMap,
        json['state'],
        unknownValue: MlsJoinRequestState.pending,
      ),
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      expiresAt: _$JsonConverterFromJson<String, DateTime>(
        json['expiresAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      requiredApprovals: (json['requiredApprovals'] as num?)?.toInt() ?? 0,
      approverUserIds:
          (json['approverUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      requiresManualApproval: json['requiresManualApproval'] as bool? ?? false,
      requesterDeviceName: json['requesterDeviceName'] as String?,
    );

Map<String, dynamic> _$MlsJoinRequestDtoToJson(_MlsJoinRequestDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contextId': instance.contextId,
      'channelId': instance.channelId,
      'conversationId': instance.conversationId,
      'generation': instance.generation,
      'requesterUserId': instance.requesterUserId,
      'requesterDeviceId': instance.requesterDeviceId,
      'keyPackageHash': instance.keyPackageHash,
      'keyPackage': instance.keyPackage,
      'signatureKeyFingerprint': instance.signatureKeyFingerprint,
      'state': _$MlsJoinRequestStateEnumMap[instance.state]!,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
      'expiresAt': _$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const ApiDateTimeConverter().toJson,
      ),
      'requiredApprovals': instance.requiredApprovals,
      'approverUserIds': instance.approverUserIds,
      'requiresManualApproval': instance.requiresManualApproval,
      'requesterDeviceName': instance.requesterDeviceName,
    };

const _$MlsJoinRequestStateEnumMap = {
  MlsJoinRequestState.pending: 'Pending',
  MlsJoinRequestState.denied: 'Denied',
  MlsJoinRequestState.fulfilled: 'Fulfilled',
  MlsJoinRequestState.cancelled: 'Cancelled',
};

_MlsJoinRequestApprovalResultDto _$MlsJoinRequestApprovalResultDtoFromJson(
  Map<String, dynamic> json,
) => _MlsJoinRequestApprovalResultDto(
  requestId: json['requestId'] as String,
  approvals: (json['approvals'] as num?)?.toInt() ?? 0,
  requiredApprovals: (json['requiredApprovals'] as num?)?.toInt() ?? 0,
  thresholdMet: json['thresholdMet'] as bool? ?? false,
  keyPackage: json['keyPackage'] as String?,
  keyPackageHash: json['keyPackageHash'] as String? ?? '',
  generation: (json['generation'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MlsJoinRequestApprovalResultDtoToJson(
  _MlsJoinRequestApprovalResultDto instance,
) => <String, dynamic>{
  'requestId': instance.requestId,
  'approvals': instance.approvals,
  'requiredApprovals': instance.requiredApprovals,
  'thresholdMet': instance.thresholdMet,
  'keyPackage': instance.keyPackage,
  'keyPackageHash': instance.keyPackageHash,
  'generation': instance.generation,
};

_GenerateKeyPackagesDto _$GenerateKeyPackagesDtoFromJson(
  Map<String, dynamic> json,
) => _GenerateKeyPackagesDto(
  count: (json['count'] as num?)?.toInt() ?? 0,
  needsLastResort: json['needsLastResort'] as bool? ?? false,
);

Map<String, dynamic> _$GenerateKeyPackagesDtoToJson(
  _GenerateKeyPackagesDto instance,
) => <String, dynamic>{
  'count': instance.count,
  'needsLastResort': instance.needsLastResort,
};

_MlsAdmissionChallengeDto _$MlsAdmissionChallengeDtoFromJson(
  Map<String, dynamic> json,
) => _MlsAdmissionChallengeDto(
  id: json['id'] as String,
  requestId: json['requestId'] as String,
  challenge: json['challenge'] as String,
  issuedByDeviceId: json['issuedByDeviceId'] as String?,
  expiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['expiresAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$MlsAdmissionChallengeDtoToJson(
  _MlsAdmissionChallengeDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'requestId': instance.requestId,
  'challenge': instance.challenge,
  'issuedByDeviceId': instance.issuedByDeviceId,
  'expiresAt': _$JsonConverterToJson<String, DateTime>(
    instance.expiresAt,
    const ApiDateTimeConverter().toJson,
  ),
};

_MlsAdmissionProofDto _$MlsAdmissionProofDtoFromJson(
  Map<String, dynamic> json,
) => _MlsAdmissionProofDto(
  challengeId: json['challengeId'] as String,
  requestId: json['requestId'] as String,
  proof: json['proof'] as String,
);

Map<String, dynamic> _$MlsAdmissionProofDtoToJson(
  _MlsAdmissionProofDto instance,
) => <String, dynamic>{
  'challengeId': instance.challengeId,
  'requestId': instance.requestId,
  'proof': instance.proof,
};
