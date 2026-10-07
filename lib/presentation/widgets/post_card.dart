import 'package:connectme_app/domain/entities/post.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  String _formatTimestamp(DateTime time) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(time.day)}/${twoDigits(time.month)}/${time.year}'
        '  ${twoDigits(time.hour)}:${twoDigits(time.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    // Responsive: margins scale with the screen width.
    final horizontalMargin = MediaQuery.of(context).size.width * 0.04;
    final authorInitial = post.authorName.isEmpty
        ? '?'
        : post.authorName[0].toUpperCase();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF5151C6),
                  child: Text(
                    authorInitial,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTimestamp(post.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content),
          ],
        ),
      ),
    );
  }
}
