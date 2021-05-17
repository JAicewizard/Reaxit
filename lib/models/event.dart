import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models/event_registration.dart';

part 'event.g.dart';

enum EventCategory { alumni, education, career, leisure, association, other }

@JsonSerializable(fieldRename: FieldRename.snake)
class Event {
  final int pk;
  final String title;

  // TODO: set empty string defaults if necessary:
  // @JsonKey(defaultValue: '')
  final String description;
  final DateTime start;
  final DateTime end;
  final EventCategory category;
  final DateTime? registrationStart;
  final DateTime? registrationEnd;
  final DateTime? cancelDeadline;
  final String location;
  final double price;
  final double fine;
  final int numParticipants;
  final int? maxParticipants;
  final String? noRegistrationMessage;
  final bool hasFields;
  @JsonKey(defaultValue: false)
  final bool hasFoodEvent;
  final int? foodEventPk;
  final String mapsUrl;
  final EventPermissions userPermissions;
  final AdminRegistration? userRegistration;
  // final Commitee organiser;
  // final Slide? slide;

  bool get isRegistered => userRegistration != null;
  bool get registrationIsRequired => registrationStart != null;

  bool get canCreateRegistration => userPermissions.createRegistration;
  bool get canUpdateRegistration => userPermissions.updateRegistration;
  bool get canCancelRegistration => userPermissions.cancelRegistration;
  bool get canManageEvent => userPermissions.manageEvent;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  const Event(
    this.pk,
    this.title,
    this.description,
    this.start,
    this.end,
    this.category,
    this.registrationStart,
    this.registrationEnd,
    this.cancelDeadline,
    this.location,
    this.price,
    this.fine,
    this.numParticipants,
    this.maxParticipants,
    this.noRegistrationMessage,
    this.hasFields,
    this.hasFoodEvent,
    this.foodEventPk,
    this.mapsUrl,
    this.userPermissions,
    this.userRegistration,
  ) : assert(
          hasFoodEvent == (foodEventPk != null),
          'There should be a `foodEventPk` iff the event has a food event',
        );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EventPermissions {
  final bool createRegistration;
  final bool cancelRegistration;
  final bool updateRegistration;
  final bool manageEvent;

  const EventPermissions(
    this.createRegistration,
    this.cancelRegistration,
    this.updateRegistration,
    this.manageEvent,
  );

  factory EventPermissions.fromJson(Map<String, dynamic> json) =>
      _$EventPermissionsFromJson(json);
}
