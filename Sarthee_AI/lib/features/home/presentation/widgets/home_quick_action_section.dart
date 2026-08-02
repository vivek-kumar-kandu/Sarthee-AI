import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';

/// Reusable 4-Card Quick Action Grid Widget.
class HomeQuickActionSection extends StatelessWidget {
  const HomeQuickActionSection({
    required this.actions,
    required this.onActionPressed,
    super.key,
  });

  final List<HomeQuickAction> actions;
  final ValueChanged<HomeQuickAction> onActionPressed;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildActionTile(context, action),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionTile(BuildContext context, HomeQuickAction action) {
    return Semantics(
      button: true,
      label: action.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onActionPressed(action),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    action.icon,
                    size: 20,
                    color: action.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
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
