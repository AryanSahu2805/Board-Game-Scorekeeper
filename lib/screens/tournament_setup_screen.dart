import 'package:flutter/material.dart';

class TournamentSetupScreen extends StatefulWidget {
  static const routeName = '/tournament-setup';

  @override
  _TournamentSetupScreenState createState() => _TournamentSetupScreenState();
}

class _TournamentSetupScreenState extends State<TournamentSetupScreen> {
  final _nameCtrl = TextEditingController();
  String _mode = 'Swiss';
  List<String> participants = [];

  void _addParticipant() {
    setState(() => participants.add('Player ${participants.length + 1}'));
  }

  void _createTournament() {
    // static demo action
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tournament Created'),
        content: Text('Name: ${_nameCtrl.text.isEmpty ? 'Untitled' : _nameCtrl.text}\nMode: $_mode\nParticipants: ${participants.length}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('OK')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Tournament'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g., Weekly Catan Championship',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text('Tournament Mode:'),
                    SizedBox(width: 12),
                    ChoiceChip(
                      label: Text('Swiss'),
                      selected: _mode == 'Swiss',
                      onSelected: (_) => setState(() => _mode = 'Swiss'),
                    ),
                    SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('Round-Robin'),
                      selected: _mode == 'Round-Robin',
                      onSelected: (_) => setState(() => _mode = 'Round-Robin'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Participants', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Expanded(
                    child: participants.isEmpty
                        ? Center(child: Text('No participants yet', style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                      itemCount: participants.length,
                      itemBuilder: (ctx, i) => Card(
                        child: ListTile(
                          tileColor: Color(0xFF131516),
                          title: Text(participants[i]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => setState(() => participants.removeAt(i)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addParticipant,
                        icon: Icon(Icons.add),
                        label: Text('Add Participant'),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: _createTournament,
                        child: Text('Create Tournament'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
