import '../models/message.dart';
import '../models/agent.dart';
import '../models/resource.dart';

class ChatService {
  Future<Message> getAgentResponse(
    String userMessage,
    Agent agent,
    MessageType messageType,
  ) async {
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

    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      type: responseType,
      sender: agent,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  String _getMaestroResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! I\'m Maestro, your wellness orchestrator. I\'m here to help you navigate your menopause journey. How are you feeling today?';
    } else if (lowerMessage.contains('nutrition') ||
        lowerMessage.contains('diet') ||
        lowerMessage.contains('food')) {
      return 'I think our nutrition expert, Dr. Sarah, would be perfect to help you with that. Would you like me to connect you with her?';
    } else if (lowerMessage.contains('stress') ||
        lowerMessage.contains('anxiety') ||
        lowerMessage.contains('mood')) {
      return 'It sounds like you might benefit from talking to our life coach, Maria. She specializes in emotional support and stress management. Should I introduce you?';
    } else if (lowerMessage.contains('community') ||
        lowerMessage.contains('group') ||
        lowerMessage.contains('support')) {
      return 'Our community connector, Lisa, can help you find local support groups and resources. Would you like to connect with her?';
    } else {
      return 'Thank you for sharing that with me. I\'m here to help you find the right support. What specific aspect of your wellness would you like to focus on today?';
    }
  }

  String _getNutritionResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hot flash') ||
        lowerMessage.contains('night sweat')) {
      return 'Hot flashes can be challenging! I recommend incorporating more phytoestrogens into your diet. Try adding flaxseeds, soy products, and legumes. Also, avoid spicy foods and caffeine, especially in the evening. Would you like some specific recipe suggestions?';
    } else if (lowerMessage.contains('weight') ||
        lowerMessage.contains('gain')) {
      return 'Metabolism changes during menopause are common. Focus on protein-rich foods, fiber, and healthy fats. Consider smaller, more frequent meals and stay hydrated. I can suggest some meal planning strategies if you\'d like.';
    } else if (lowerMessage.contains('bone') ||
        lowerMessage.contains('calcium')) {
      return 'Bone health is crucial during menopause. Ensure you\'re getting enough calcium from dairy, leafy greens, and fortified foods. Vitamin D is also essential - consider spending time outdoors and eating fatty fish.';
    } else {
      return 'Nutrition plays a vital role in managing menopause symptoms. I\'d be happy to create a personalized meal plan for you. What specific symptoms are you experiencing?';
    }
  }

  String _getCoachResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('stress') || lowerMessage.contains('anxiety')) {
      return 'Stress and anxiety are very common during this transition. Let\'s start with some breathing exercises. Try the 4-7-8 technique: inhale for 4, hold for 7, exhale for 8. How does that feel? We can also explore mindfulness practices together.';
    } else if (lowerMessage.contains('sleep') ||
        lowerMessage.contains('insomnia')) {
      return 'Sleep disturbances are challenging. Let\'s create a calming bedtime routine. Try to go to bed and wake up at the same time daily, avoid screens an hour before bed, and create a cool, dark sleep environment. What\'s your current sleep routine like?';
    } else if (lowerMessage.contains('confidence') ||
        lowerMessage.contains('self-esteem')) {
      return 'Your feelings are valid, and this transition is a natural part of life. Let\'s focus on your strengths and what you\'ve accomplished. What are three things you\'re proud of today? We can work on building self-compassion together.';
    } else {
      return 'I\'m here to support you emotionally through this journey. Every woman\'s experience is unique, and it\'s okay to have ups and downs. What would be most helpful for you right now?';
    }
  }

  String _getCommunityResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('group') || lowerMessage.contains('support')) {
      return 'I can help you find local support groups! There are several options in your area, including online communities and in-person meetups. Would you like me to share some specific groups that focus on menopause support?';
    } else if (lowerMessage.contains('doctor') ||
        lowerMessage.contains('specialist')) {
      return 'Finding the right healthcare provider is important. I can recommend menopause specialists in your area who are experienced with hormone therapy and symptom management. Would you like some referrals?';
    } else if (lowerMessage.contains('exercise') ||
        lowerMessage.contains('fitness')) {
      return 'There are great fitness classes and wellness programs specifically designed for women in menopause. Many local gyms and community centers offer specialized programs. Would you like me to find some options near you?';
    } else {
      return 'I\'m here to connect you with the resources and community you need. Whether it\'s support groups, healthcare providers, or wellness activities, I can help you find what works best for you. What type of support are you looking for?';
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
            title: 'Menopause-Friendly Meal Plan',
            description:
                'A 7-day meal plan designed to support hormone balance and reduce symptoms.',
            link: 'https://example.com/meal-plan',
            category: 'Nutrition',
            createdAt: DateTime.now(),
          ),
          Resource(
            id: '2',
            title: 'Phytoestrogen-Rich Foods Guide',
            description:
                'Complete guide to foods that naturally support estrogen levels.',
            link: 'https://example.com/phytoestrogens',
            category: 'Nutrition',
            createdAt: DateTime.now(),
          ),
        ];
      case AgentRole.coach:
        return [
          Resource(
            id: '3',
            title: 'Mindfulness Meditation for Menopause',
            description:
                'Guided meditation sessions specifically designed for menopause stress relief.',
            link: 'https://example.com/meditation',
            category: 'Wellness',
            createdAt: DateTime.now(),
          ),
          Resource(
            id: '4',
            title: 'Sleep Hygiene Checklist',
            description:
                'Practical tips for improving sleep quality during menopause.',
            link: 'https://example.com/sleep',
            category: 'Wellness',
            createdAt: DateTime.now(),
          ),
        ];
      case AgentRole.community:
        return [
          Resource(
            id: '5',
            title: 'Local Menopause Support Groups',
            description:
                'Find in-person and online support groups in your area.',
            link: 'https://example.com/groups',
            category: 'Community',
            createdAt: DateTime.now(),
          ),
          Resource(
            id: '6',
            title: 'Menopause Specialist Directory',
            description:
                'Verified healthcare providers specializing in menopause care.',
            link: 'https://example.com/specialists',
            category: 'Healthcare',
            createdAt: DateTime.now(),
          ),
        ];
      default:
        return [];
    }
  }
}
