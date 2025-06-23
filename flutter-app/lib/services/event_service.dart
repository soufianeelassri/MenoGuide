import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'events';

  // Récupérer tous les événements
  Stream<List<Event>> getEvents() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final events =
          snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

      // Si aucun événement, créer des événements de test
      if (events.isEmpty) {
        return _createTestEvents();
      }

      return events;
    });
  }

  // Créer des événements de test pour la démonstration
  List<Event> _createTestEvents() {
    final now = DateTime.now();
    return [
      Event(
        id: 'test_webinar_001',
        title: 'Webinaire: Nutrition et ménopause',
        description:
            'Découvrez les meilleures pratiques alimentaires pour gérer les symptômes de la ménopause.',
        type: EventType.webinar,
        category: 'nutrition',
        date: now.add(const Duration(days: 1)),
        duration: 90,
        maxAttendees: 50,
        currentAttendees: 25,
        host: const EventHost(
          name: 'Dr. Marie Dubois',
          title: 'Nutritionniste spécialisée',
        ),
        tags: ['nutrition', 'ménopause', 'alimentation'],
        status: EventStatus.upcoming,
        isFree: true,
        createdAt: now,
        updatedAt: now,
      ),
      Event(
        id: 'test_support_001',
        title: 'Groupe de soutien virtuel',
        description:
            'Échangez avec d\'autres femmes dans la même situation. Espace sécurisé et confidentiel.',
        type: EventType.support_group,
        category: 'soutien',
        date: now.add(const Duration(days: 3)),
        duration: 120,
        maxAttendees: 20,
        currentAttendees: 12,
        host: const EventHost(
          name: 'Sophie Martin',
          title: 'Psychologue clinicienne',
        ),
        tags: ['soutien', 'groupe', 'échange'],
        status: EventStatus.upcoming,
        isFree: true,
        createdAt: now,
        updatedAt: now,
      ),
      Event(
        id: 'test_workshop_001',
        title: 'Atelier Yoga: Équilibre Hormonal',
        description:
            'Séance de yoga spécialement conçue pour équilibrer vos hormones.',
        type: EventType.workshop,
        category: 'activite_physique',
        date: now.subtract(const Duration(days: 1)),
        duration: 120,
        maxAttendees: 30,
        currentAttendees: 28,
        host: const EventHost(
          name: 'Claire Rousseau',
          title: 'Professeure de yoga certifiée',
        ),
        tags: ['yoga', 'équilibre hormonal', 'relaxation'],
        status: EventStatus.completed,
        isFree: false,
        price: 25.0,
        currency: 'EUR',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Event(
        id: 'test_meditation_001',
        title: 'Méditation guidée: Gestion du stress',
        description:
            'Séance de méditation spécialement conçue pour les femmes en période de ménopause.',
        type: EventType.meditation,
        category: 'bien_etre',
        date: now.add(const Duration(hours: 2)),
        duration: 60,
        maxAttendees: 40,
        currentAttendees: 15,
        host: const EventHost(
          name: 'Isabelle Moreau',
          title: 'Instructrice de méditation',
        ),
        tags: ['méditation', 'stress', 'relaxation'],
        status: EventStatus.upcoming,
        isFree: true,
        createdAt: now,
        updatedAt: now,
      ),
      Event(
        id: 'test_conference_001',
        title: 'Conférence: Innovations en santé féminine',
        description:
            'Découvrez les dernières avancées médicales pour la santé des femmes.',
        type: EventType.conference,
        category: 'education',
        date: now.add(const Duration(days: 7)),
        duration: 180,
        maxAttendees: 100,
        currentAttendees: 45,
        host: const EventHost(
          name: 'Dr. Anne Laurent',
          title: 'Gynécologue spécialisée',
        ),
        tags: ['conférence', 'santé', 'innovation'],
        status: EventStatus.upcoming,
        isFree: false,
        price: 15.0,
        currency: 'EUR',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Récupérer les événements à venir
  Stream<List<Event>> getUpcomingEvents() {
    final now = DateTime.now();
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final allEvents =
          snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

      // Si aucun événement, créer des événements de test
      if (allEvents.isEmpty) {
        return _createTestEvents();
      }

      // Retourner tous les événements ordonnés par date (plus récents en premier)
      return allEvents..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  // Récupérer les événements passés
  Stream<List<Event>> getPastEvents() {
    final now = DateTime.now();
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .where((event) => event.date.isBefore(now))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  // Récupérer un événement par ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(eventId).get();
      if (doc.exists) {
        return Event.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting event: $e');
      return null;
    }
  }

  // Récupérer les événements par type
  Stream<List<Event>> getEventsByType(EventType type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type.name)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    });
  }

  // Récupérer les événements par catégorie
  Stream<List<Event>> getEventsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    });
  }

  // Rejoindre un événement
  Future<bool> joinEvent(String eventId, String userId) async {
    try {
      final eventRef = _firestore.collection(_collection).doc(eventId);

      await _firestore.runTransaction((transaction) async {
        final eventDoc = await transaction.get(eventRef);
        final currentAttendees = eventDoc.data()?['currentAttendees'] ?? 0;
        final maxAttendees = eventDoc.data()?['maxAttendees'] ?? 0;

        if (currentAttendees >= maxAttendees) {
          throw Exception('Event is full');
        }

        transaction.update(eventRef, {
          'currentAttendees': currentAttendees + 1,
          'updatedAt': Timestamp.now(),
        });
      });

      return true;
    } catch (e) {
      print('Error joining event: $e');
      return false;
    }
  }

  // Quitter un événement
  Future<bool> leaveEvent(String eventId, String userId) async {
    try {
      final eventRef = _firestore.collection(_collection).doc(eventId);

      await _firestore.runTransaction((transaction) async {
        final eventDoc = await transaction.get(eventRef);
        final currentAttendees = eventDoc.data()?['currentAttendees'] ?? 0;

        if (currentAttendees > 0) {
          transaction.update(eventRef, {
            'currentAttendees': currentAttendees - 1,
            'updatedAt': Timestamp.now(),
          });
        }
      });

      return true;
    } catch (e) {
      print('Error leaving event: $e');
      return false;
    }
  }

  // Créer un nouvel événement
  Future<String?> createEvent(Event event) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(event.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  // Mettre à jour un événement
  Future<bool> updateEvent(Event event) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(event.id)
          .update(event.toFirestore());
      return true;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  // Supprimer un événement
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).delete();
      return true;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }
}
