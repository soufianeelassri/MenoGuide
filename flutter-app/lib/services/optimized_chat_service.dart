import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../models/agent.dart';
import '../models/resource.dart';

class OptimizedChatService {
  static const String _chatHistoryKey = 'chat_history';
  static const String _agentResponsesKey = 'agent_responses';
  static const int _maxCacheAge = 24 * 60; // 24 heures en minutes

  /// Get agent response with caching
  Future<Message> getAgentResponse(
    String userMessage,
    Agent agent,
    MessageType messageType,
  ) async {
    try {
      // Vérifier le cache d'abord
      final cachedResponse = await _getCachedResponse(userMessage, agent);
      if (cachedResponse != null) {
        print('✅ Réponse agent récupérée du cache');
        return cachedResponse;
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      String response = '';
      MessageType responseType = MessageType.text;

      switch (agent.role) {
        case AgentRole.maestro:
          response = _getMaestroResponse(userMessage);
          break;
        case AgentRole.nutrition:
          response = _getNutritionResponse(userMessage);
          break;
        case AgentRole.coach:
          response = _getCoachResponse(userMessage);
          break;
        case AgentRole.community:
          response = _getCommunityResponse(userMessage);
          break;
      }

      final agentMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        type: responseType,
        sender: agent,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Sauvegarder en cache
      await _cacheResponse(userMessage, agent, agentMessage);

      return agentMessage;
    } catch (e) {
      print('❌ Erreur dans getAgentResponse: $e');
      return Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            'Désolé, je ne peux pas répondre pour le moment. Veuillez réessayer.',
        type: MessageType.text,
        sender: agent,
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Sauvegarder une réponse en cache
  Future<void> _cacheResponse(
      String userMessage, Agent agent, Message response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${agent.role.name}_${_hashMessage(userMessage)}';

      final cacheData = {
        'userMessage': userMessage,
        'agentRole': agent.role.name,
        'response': response.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Récupérer le cache existant
      final existingCache = prefs.getString(_agentResponsesKey);
      Map<String, dynamic> cache = {};

      if (existingCache != null) {
        cache = jsonDecode(existingCache);
      }

      // Ajouter la nouvelle réponse
      cache[cacheKey] = cacheData;

      // Nettoyer le cache ancien
      cache = _cleanOldCacheEntries(cache);

      // Sauvegarder
      await prefs.setString(_agentResponsesKey, jsonEncode(cache));
      print('✅ Réponse sauvegardée en cache');
    } catch (e) {
      print('❌ Erreur sauvegarde cache: $e');
    }
  }

  /// Récupérer une réponse du cache
  Future<Message?> _getCachedResponse(String userMessage, Agent agent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${agent.role.name}_${_hashMessage(userMessage)}';

      final existingCache = prefs.getString(_agentResponsesKey);
      if (existingCache == null) return null;

      final cache = jsonDecode(existingCache);
      final cachedData = cache[cacheKey];

      if (cachedData == null) return null;

      // Vérifier l'âge du cache
      final timestamp = cachedData['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final cacheAgeMinutes = cacheAge / (1000 * 60);

      if (cacheAgeMinutes > _maxCacheAge) {
        print('⚠️ Cache expiré (${cacheAgeMinutes.round()} minutes)');
        return null;
      }

      // Vérifier que le message correspond
      if (cachedData['userMessage'] != userMessage) {
        return null;
      }

      return Message.fromJson(cachedData['response']);
    } catch (e) {
      print('❌ Erreur récupération cache: $e');
      return null;
    }
  }

  /// Nettoyer les entrées anciennes du cache
  Map<String, dynamic> _cleanOldCacheEntries(Map<String, dynamic> cache) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final cleanedCache = <String, dynamic>{};

    cache.forEach((key, value) {
      final timestamp = value['timestamp'] as int;
      final cacheAge = now - timestamp;
      final cacheAgeMinutes = cacheAge / (1000 * 60);

      if (cacheAgeMinutes <= _maxCacheAge) {
        cleanedCache[key] = value;
      }
    });

    return cleanedCache;
  }

  /// Créer un hash simple du message
  String _hashMessage(String message) {
    return message
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .substring(0, 10);
  }

  /// Sauvegarder l'historique de chat
  Future<void> saveChatHistory(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((msg) => msg.toJson()).toList();

      await prefs.setString(_chatHistoryKey, jsonEncode(messagesJson));
      print('✅ Historique de chat sauvegardé');
    } catch (e) {
      print('❌ Erreur sauvegarde historique: $e');
    }
  }

  /// Charger l'historique de chat
  Future<List<Message>> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_chatHistoryKey);

      if (historyJson == null) return [];

      final messagesList = jsonDecode(historyJson) as List;
      return messagesList.map((msgJson) => Message.fromJson(msgJson)).toList();
    } catch (e) {
      print('❌ Erreur chargement historique: $e');
      return [];
    }
  }

  /// Effacer l'historique de chat
  Future<void> clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
      print('🗑️ Historique de chat effacé');
    } catch (e) {
      print('❌ Erreur effacement historique: $e');
    }
  }

  /// Obtenir les statistiques du cache
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final responsesCache = prefs.getString(_agentResponsesKey);
      final historyCache = prefs.getString(_chatHistoryKey);

      Map<String, dynamic> stats = {
        'responsesCacheExists': responsesCache != null,
        'historyCacheExists': historyCache != null,
      };

      if (responsesCache != null) {
        final cache = jsonDecode(responsesCache);
        stats['cachedResponsesCount'] = cache.length;
      }

      if (historyCache != null) {
        final history = jsonDecode(historyCache);
        stats['historyMessagesCount'] = history.length;
      }

      return stats;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Méthodes de réponse existantes (optimisées)
  String _getMaestroResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Bonjour ! Je suis Maestro, votre orchestrateur de bien-être. Je suis là pour vous aider dans votre parcours de ménopause. Comment vous sentez-vous aujourd\'hui ?';
    } else if (lowerMessage.contains('nutrition') ||
        lowerMessage.contains('diet') ||
        lowerMessage.contains('food')) {
      return 'Je pense que notre experte en nutrition, Dr. Sarah, serait parfaite pour vous aider. Voulez-vous que je vous connecte avec elle ?';
    } else if (lowerMessage.contains('stress') ||
        lowerMessage.contains('anxiety') ||
        lowerMessage.contains('mood')) {
      return 'Il semble que vous pourriez bénéficier d\'une conversation avec notre coach de vie, Maria. Elle se spécialise dans le soutien émotionnel et la gestion du stress. Dois-je vous présenter ?';
    } else if (lowerMessage.contains('community') ||
        lowerMessage.contains('group') ||
        lowerMessage.contains('support')) {
      return 'Notre connectrice communautaire, Lisa, peut vous aider à trouver des groupes de soutien locaux et des ressources. Voulez-vous vous connecter avec elle ?';
    } else {
      return 'Merci de partager cela avec moi. Je suis là pour vous aider à trouver le bon soutien. Sur quel aspect de votre bien-être souhaitez-vous vous concentrer aujourd\'hui ?';
    }
  }

  String _getNutritionResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hot flash') ||
        lowerMessage.contains('night sweat')) {
      return 'Les bouffées de chaleur peuvent être difficiles ! Je recommande d\'incorporer plus de phytoestrogènes dans votre alimentation. Essayez d\'ajouter des graines de lin, des produits à base de soja et des légumineuses. Évitez également les aliments épicés et la caféine, surtout le soir. Voulez-vous des suggestions de recettes spécifiques ?';
    } else if (lowerMessage.contains('weight') ||
        lowerMessage.contains('gain')) {
      return 'Les changements de métabolisme pendant la ménopause sont courants. Concentrez-vous sur les aliments riches en protéines, en fibres et en graisses saines. Considérez des repas plus petits et plus fréquents et restez hydratée. Je peux suggérer des stratégies de planification de repas si vous le souhaitez.';
    } else if (lowerMessage.contains('bone') ||
        lowerMessage.contains('calcium')) {
      return 'La santé osseuse est cruciale pendant la ménopause. Assurez-vous d\'obtenir suffisamment de calcium à partir des produits laitiers, des légumes verts et des aliments enrichis. La vitamine D est également essentielle - considérez passer du temps à l\'extérieur et manger du poisson gras.';
    } else {
      return 'La nutrition joue un rôle vital dans la gestion des symptômes de la ménopause. Je serais heureuse de créer un plan de repas personnalisé pour vous. Quels symptômes spécifiques ressentez-vous ?';
    }
  }

  String _getCoachResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('stress') || lowerMessage.contains('anxiety')) {
      return 'Le stress et l\'anxiété sont très courants pendant cette transition. Commençons par quelques exercices de respiration. Essayez la technique 4-7-8 : inspirez pendant 4, retenez pendant 7, expirez pendant 8. Comment cela vous fait-il ? Nous pouvons aussi explorer ensemble les pratiques de pleine conscience.';
    } else if (lowerMessage.contains('sleep') ||
        lowerMessage.contains('insomnia')) {
      return 'Les troubles du sommeil sont difficiles. Créons une routine apaisante au coucher. Essayez d\'aller au lit et de vous réveiller à la même heure quotidiennement, évitez les écrans une heure avant le coucher et créez un environnement de sommeil frais et sombre. À quoi ressemble votre routine de sommeil actuelle ?';
    } else if (lowerMessage.contains('confidence') ||
        lowerMessage.contains('self-esteem')) {
      return 'Vos sentiments sont valides, et cette transition est une partie naturelle de la vie. Concentrons-nous sur vos forces et ce que vous avez accompli. Quelles sont trois choses dont vous êtes fière aujourd\'hui ? Nous pouvons travailler ensemble à développer l\'auto-compassion.';
    } else {
      return 'Je suis là pour vous soutenir émotionnellement dans ce parcours. L\'expérience de chaque femme est unique, et il est normal d\'avoir des hauts et des bas. Qu\'est-ce qui vous serait le plus utile en ce moment ?';
    }
  }

  String _getCommunityResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('group') || lowerMessage.contains('support')) {
      return 'Je peux vous aider à trouver des groupes de soutien locaux ! Il y a plusieurs options dans votre région, y compris des communautés en ligne et des rencontres en personne. Voulez-vous que je partage des groupes spécifiques qui se concentrent sur le soutien à la ménopause ?';
    } else if (lowerMessage.contains('doctor') ||
        lowerMessage.contains('specialist')) {
      return 'Trouver le bon fournisseur de soins de santé est important. Je peux recommander des spécialistes de la ménopause dans votre région qui sont expérimentés avec l\'hormonothérapie et la gestion des symptômes. Voulez-vous des références ?';
    } else if (lowerMessage.contains('exercise') ||
        lowerMessage.contains('fitness')) {
      return 'Il y a d\'excellents cours de fitness et programmes de bien-être spécialement conçus pour les femmes en ménopause. De nombreuses salles de sport et centres communautaires offrent des programmes spécialisés. Voulez-vous que je trouve des options près de chez vous ?';
    } else {
      return 'Je suis là pour vous connecter avec les ressources et la communauté dont vous avez besoin. Que ce soit des groupes de soutien, des fournisseurs de soins de santé ou des activités de bien-être, je peux vous aider à trouver ce qui fonctionne le mieux pour vous. Quel type de soutien recherchez-vous ?';
    }
  }

  Future<List<Resource>> getResources(Agent agent) async {
    // Mock resources based on agent type
    await Future.delayed(const Duration(milliseconds: 500));

    switch (agent.role) {
      case AgentRole.nutrition:
        return [
          Resource(
            id: '1',
            title: 'Plan de repas adapté à la ménopause',
            description:
                'Un plan de repas de 7 jours conçu pour soutenir l\'équilibre hormonal et réduire les symptômes.',
            link: 'https://example.com/meal-plan',
            category: 'Nutrition',
            createdAt: DateTime.now(),
          ),
          Resource(
            id: '2',
            title: 'Guide des aliments riches en phytoestrogènes',
            description:
                'Guide complet des aliments qui soutiennent naturellement les niveaux d\'œstrogènes.',
            link: 'https://example.com/phytoestrogens',
            category: 'Nutrition',
            createdAt: DateTime.now(),
          ),
        ];
      case AgentRole.coach:
        return [
          Resource(
            id: '3',
            title: 'Méditation de pleine conscience pour la ménopause',
            description:
                'Sessions de méditation guidée spécialement conçues pour le soulagement du stress de la ménopause.',
            link: 'https://example.com/meditation',
            category: 'Bien-être',
            createdAt: DateTime.now(),
          ),
          Resource(
            id: '4',
            title: 'Liste de vérification de l\'hygiène du sommeil',
            description:
                'Conseils pratiques pour améliorer la qualité du sommeil pendant la ménopause.',
            link: 'https://example.com/sleep',
            category: 'Bien-être',
            createdAt: DateTime.now(),
          ),
        ];
      case AgentRole.community:
        return [
          Resource(
            id: '5',
            title: 'Groupes de soutien locaux pour la ménopause',
            description:
                'Trouvez des groupes de soutien en personne et en ligne dans votre région.',
            link: 'https://example.com/groups',
            category: 'Communauté',
            createdAt: DateTime.now(),
          ),
          Resource(
            id: '6',
            title: 'Répertoire des spécialistes de la ménopause',
            description:
                'Fournisseurs de soins de santé vérifiés spécialisés dans les soins de la ménopause.',
            link: 'https://example.com/specialists',
            category: 'Soins de santé',
            createdAt: DateTime.now(),
          ),
        ];
      default:
        return [];
    }
  }
}
