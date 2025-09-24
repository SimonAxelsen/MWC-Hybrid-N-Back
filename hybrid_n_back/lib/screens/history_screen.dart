import 'package:flutter/material.dart';
import 'package:hybrid_n_back/models/game_session.dart';
import 'package:hybrid_n_back/screens/summary_screen.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  // In a real app, this would load from persistent storage
  final List<GameSession> _sessions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Progress'),
      ),
      body: _sessions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No sessions yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Start playing to see your history',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final dateFormat = DateFormat('MMM dd, yyyy - h:mm a');
                
                return ListTile(
                  title: Text(
                    'N-Level ${session.nLevel} Session',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${dateFormat.format(session.timestamp)}\n'
                    'Score: ${session.score} | Accuracy: ${session.accuracy.toStringAsFixed(1)}%',
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SummaryScreen(
                          session: session,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}