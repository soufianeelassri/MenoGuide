import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/agent.dart';
import '../models/resource.dart';
import '../services/chat_service.dart';
import '../widgets/resource_card.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  final ChatService _chatService = ChatService();
  Agent _selectedAgent = Agent.maestro;
  List<Resource> _resources = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final resources = await _chatService.getResources(_selectedAgent);
      setState(() {
        _resources = resources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading resources: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources & Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => Navigator.pushReplacementNamed(context, '/chat'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAgentSelector(),
          Expanded(
            child: _buildResourcesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resources by Specialist',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Agent.nutrition,
                Agent.coach,
                Agent.community,
              ].map((agent) {
                final isSelected = _selectedAgent.role == agent.role;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAgent = agent;
                      });
                      _loadResources();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getAgentIcon(agent.role),
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF6B7280),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            agent.name,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getAgentIcon(_selectedAgent.role),
              size: 64,
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 16),
            Text(
              'No Resources Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedAgent.name} will suggest resources based on your conversations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/chat'),
              child: const Text('Start Chatting'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _resources.length,
      itemBuilder: (context, index) {
        final resource = _resources[index];
        return ResourceCard(
          resource: resource,
          onTap: () => _openResource(resource),
        );
      },
    );
  }

  IconData _getAgentIcon(AgentRole role) {
    switch (role) {
      case AgentRole.nutrition:
        return Icons.restaurant;
      case AgentRole.coach:
        return Icons.favorite;
      case AgentRole.community:
        return Icons.people;
      default:
        return Icons.psychology;
    }
  }

  Future<void> _openResource(Resource resource) async {
    try {
      final uri = Uri.parse(resource.link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening resource: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
