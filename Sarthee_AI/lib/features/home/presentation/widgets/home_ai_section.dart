import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';

/// "Ask Sarthee AI" Starter Prompts Widget preventing blank-screen syndrome.
class HomeAISection extends StatelessWidget {
  const HomeAISection({
    required this.prompts,
    required this.onPromptSelected,
    super.key,
  });

  final List<HomeAiPrompt> prompts;
  final ValueChanged<HomeAiPrompt> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    if (prompts.isEmpty) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Section Header
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: Color(0xFF7C3AED), // AI Violet
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Ask Sarthee AI',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Horizontal Prompt Cards List
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: prompts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final prompt = prompts[index];
              return _buildPromptCard(context, prompt);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromptCard(BuildContext context, HomeAiPrompt prompt) {
    return Semantics(
      button: true,
      label: 'Ask AI prompt: ${prompt.title}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPromptSelected(prompt),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  const Color(0xFFF5F3FF),
                  const Color(0xFFEFF6FF),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFDDD6FE),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      prompt.iconEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        prompt.title,
                        style: const TextStyle(
                          color: Color(0xFF5B21B6),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  prompt.promptText,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
