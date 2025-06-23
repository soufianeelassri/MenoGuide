import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/event.dart';
import '../services/event_service.dart';

// Events
abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventEvent {}

class LoadUpcomingEvents extends EventEvent {}

class LoadPastEvents extends EventEvent {}

class LoadEventById extends EventEvent {
  final String eventId;

  const LoadEventById(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class JoinEvent extends EventEvent {
  final String eventId;
  final String userId;

  const JoinEvent(this.eventId, this.userId);

  @override
  List<Object?> get props => [eventId, userId];
}

class LeaveEvent extends EventEvent {
  final String eventId;
  final String userId;

  const LeaveEvent(this.eventId, this.userId);

  @override
  List<Object?> get props => [eventId, userId];
}

// States
abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<Event> events;
  final List<Event> upcomingEvents;
  final List<Event> pastEvents;

  const EventsLoaded({
    required this.events,
    required this.upcomingEvents,
    required this.pastEvents,
  });

  @override
  List<Object?> get props => [events, upcomingEvents, pastEvents];
}

class EventLoaded extends EventState {
  final Event event;

  const EventLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}

class EventActionSuccess extends EventState {
  final String message;

  const EventActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EventActionLoading extends EventState {}

// Bloc
class EventBloc extends Bloc<EventEvent, EventState> {
  final EventService _eventService;

  EventBloc(this._eventService) : super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<LoadUpcomingEvents>(_onLoadUpcomingEvents);
    on<LoadPastEvents>(_onLoadPastEvents);
    on<LoadEventById>(_onLoadEventById);
    on<JoinEvent>(_onJoinEvent);
    on<LeaveEvent>(_onLeaveEvent);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await emit.forEach<List<Event>>(
        _eventService.getEvents(),
        onData: (List<Event> events) {
          final upcomingEvents = events.where((e) => e.isUpcoming).toList();
          final pastEvents = events.where((e) => e.isPast).toList();
          return EventsLoaded(
            events: events,
            upcomingEvents: upcomingEvents,
            pastEvents: pastEvents,
          );
        },
      );
    } catch (e) {
      emit(EventError('Erreur lors du chargement des événements: $e'));
    }
  }

  Future<void> _onLoadUpcomingEvents(
      LoadUpcomingEvents event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await emit.forEach<List<Event>>(
        _eventService.getUpcomingEvents(),
        onData: (List<Event> upcomingEvents) {
          return EventsLoaded(
            events: upcomingEvents,
            upcomingEvents: upcomingEvents,
            pastEvents: [],
          );
        },
      );
    } catch (e) {
      emit(EventError('Erreur lors du chargement des événements à venir: $e'));
    }
  }

  Future<void> _onLoadPastEvents(
      LoadPastEvents event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await emit.forEach<List<Event>>(
        _eventService.getPastEvents(),
        onData: (List<Event> pastEvents) {
          return EventsLoaded(
            events: pastEvents,
            upcomingEvents: [],
            pastEvents: pastEvents,
          );
        },
      );
    } catch (e) {
      emit(EventError('Erreur lors du chargement des événements passés: $e'));
    }
  }

  Future<void> _onLoadEventById(
      LoadEventById event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final eventData = await _eventService.getEventById(event.eventId);
      if (eventData != null) {
        emit(EventLoaded(eventData));
      } else {
        emit(const EventError('Événement non trouvé'));
      }
    } catch (e) {
      emit(EventError('Erreur lors du chargement de l\'événement: $e'));
    }
  }

  Future<void> _onJoinEvent(JoinEvent event, Emitter<EventState> emit) async {
    emit(EventActionLoading());
    try {
      final success =
          await _eventService.joinEvent(event.eventId, event.userId);
      if (success) {
        emit(const EventActionSuccess(
            'Vous avez rejoint l\'événement avec succès'));
      } else {
        emit(const EventError('Impossible de rejoindre l\'événement'));
      }
    } catch (e) {
      emit(EventError('Erreur lors de la participation: $e'));
    }
  }

  Future<void> _onLeaveEvent(LeaveEvent event, Emitter<EventState> emit) async {
    emit(EventActionLoading());
    try {
      final success =
          await _eventService.leaveEvent(event.eventId, event.userId);
      if (success) {
        emit(const EventActionSuccess('Vous avez quitté l\'événement'));
      } else {
        emit(const EventError('Impossible de quitter l\'événement'));
      }
    } catch (e) {
      emit(EventError('Erreur lors du retrait: $e'));
    }
  }
}
