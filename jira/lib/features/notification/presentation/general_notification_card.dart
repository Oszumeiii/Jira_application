import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GeneralNotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final Timestamp? timestamp;
  final bool isRead;
  final VoidCallback onTap;

  const GeneralNotificationCard({
    super.key,
    required this.title,
    required this.body,
    this.timestamp,
    required this.isRead,
    required this.onTap,
  });

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    String plural(int value, String word) {
      return value == 1 ? '$value $word ago' : '$value ${word}s ago';
    }

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) return 'Just now';
        return plural(difference.inMinutes, 'minute');
      }
      return plural(difference.inHours, 'hour');
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return plural(difference.inDays, 'day');
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isRead
              ? null
              : Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  if (!isRead)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (timestamp != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(timestamp),
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
