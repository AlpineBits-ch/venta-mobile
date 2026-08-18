import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/features/guild_voice/data/models/voice_state_dto.dart';
import 'package:venta_mobile/features/voice/bloc/voice_resume_cubit.dart';
import 'package:venta_mobile/features/voice/data/models/ongoing_call_dto.dart';

const _channelState = VoiceStateDto(
  guildId: 'guild-1',
  channelId: 'channel-1',
  channelName: 'General',
  deviceId: 'device-1',
);

const _call = OngoingCallDto(callId: 'call-1', conversationId: 'conv-1');

void main() {
  group('toResumeOffer', () {
    test('nothing to offer when the server places this account nowhere', () {
      expect(toResumeOffer(null, null), isNull);
    });

    test('a held channel seat becomes a channel offer', () {
      final offer = toResumeOffer(_channelState, null);
      expect(
        offer,
        const ChannelResumeOffer(
          guildId: 'guild-1',
          channelId: 'channel-1',
          channelName: 'General',
          deviceId: 'device-1',
        ),
      );
    });

    test('a call that carried on without us becomes a call offer', () {
      expect(
        toResumeOffer(null, _call),
        const CallResumeOffer(callId: 'call-1', conversationId: 'conv-1'),
      );
    });

    /// Both cannot be true of a well-behaved server. If they somehow are, the
    /// channel is the one carrying a seat other people can see, so it is the
    /// one worth asking about.
    test('the channel wins a tie', () {
      expect(toResumeOffer(_channelState, _call), isA<ChannelResumeOffer>());
    });

    /// A deleted channel leaves a roster entry behind with no name to show. The
    /// offer still has to be made - the seat is exactly as stale - so the
    /// banner falls back to unnamed wording rather than the offer vanishing.
    test('a seat in a deleted channel is still offered, unnamed', () {
      final offer = toResumeOffer(
        const VoiceStateDto(
          guildId: 'guild-1',
          channelId: 'channel-1',
          channelName: null,
          deviceId: 'device-1',
        ),
        null,
      );
      expect(offer, isA<ChannelResumeOffer>());
      expect((offer! as ChannelResumeOffer).channelName, isNull);
    });

    /// The device id decides whether the seat may be released on its behalf, so
    /// it has to survive the trip from the wire into the offer intact - a
    /// dropped one would be read as "not ours" and leave the ghost in place.
    test('a seat held by another device carries that id through', () {
      final offer =
          toResumeOffer(
                const VoiceStateDto(
                  guildId: 'guild-1',
                  channelId: 'channel-1',
                  channelName: 'General',
                  deviceId: 'someone-elses-phone',
                ),
                null,
              )!
              as ChannelResumeOffer;
      expect(offer.deviceId, 'someone-elses-phone');
    });
  });

  group('VoiceStateDto', () {
    test('parses the wire shape', () {
      final dto = VoiceStateDto.fromJson(const {
        'guildId': 'guild-1',
        'channelId': 'channel-1',
        'channelName': 'General',
        'deviceId': 'device-1',
        'joinedAt': '2026-08-18T07:09:12.481Z',
      });
      expect(dto.guildId, 'guild-1');
      expect(dto.deviceId, 'device-1');
      expect(dto.joinedAt?.isUtc, isTrue);
    });

    /// The backend is not consistent about time-zone designators, and a
    /// designator-less stamp read as local time is silently hours out. See
    /// `ApiDateTimeConverter`.
    test('a joinedAt without a Z is still read as UTC', () {
      final dto = VoiceStateDto.fromJson(const {
        'guildId': 'g',
        'channelId': 'c',
        'joinedAt': '2026-08-18T07:09:12.481',
      });
      expect(dto.joinedAt, DateTime.utc(2026, 8, 18, 7, 9, 12, 481));
    });

    test('a channel deleted under an unswept roster parses with no name', () {
      final dto = VoiceStateDto.fromJson(const {
        'guildId': 'g',
        'channelId': 'c',
        'channelName': null,
        'deviceId': null,
      });
      expect(dto.channelName, isNull);
      expect(dto.deviceId, isNull);
    });
  });
}
