// main.dart
// Flutter single-file example app: Campus Hub
// Features included (mocked/simulated where real backends would be required):
// - Home page with Discover & Check-in to events
// - Report & Claim Lost & Found (simple form + list)
// - Cafeteria queue time in real-time (simulated Stream)
// - Campus navigation between buildings/rooms (mocked map + route list)
// - Event details page
// - Navigation page for in-app page transitions

import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const CampusHubApp());
}

class CampusHubApp extends StatelessWidget {
  const CampusHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const RootScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const NavigationPage(),
    const LostFoundPage(),
    const EventsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Nav'),
          NavigationDestination(icon: Icon(Icons.report), label: 'Lost/Found'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
        ],
      ),
    );
  }
}

// ---------------------- Home Page ----------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Simulated real-time queue streams for multiple cafeterias
  late final StreamController<Map<String, int>> _queueController;
  late final Timer _simTimer;
  final Map<String, int> _queues = {
    'Central Cafeteria': 5,
    'North Canteen': 2,
    'South Food Court': 8,
  };

  @override
  void initState() {
    super.initState();
    _queueController = StreamController.broadcast();
    // Emit initial state
    _queueController.add(Map<String, int>.from(_queues));
    // Simulate queue changes every 3 seconds
    _simTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _randomlyUpdateQueues();
      _queueController.add(Map<String, int>.from(_queues));
    });
  }

  void _randomlyUpdateQueues() {
    _queues.forEach((k, v) {
      final delta = (DateTime.now().millisecondsSinceEpoch % 7) - 3; // -3..3
      final newVal = (v + delta).clamp(0, 25);
      _queues[k] = newVal;
    });
  }

  @override
  void dispose() {
    _simTimer.cancel();
    _queueController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Campus Hub'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.indigo, Colors.indigoAccent]),
                ),
                child: const Center(child: Icon(Icons.school, size: 72, color: Colors.white70)),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildTopActions(context),
                  const SizedBox(height: 12),
                  _buildCafeteriaQueueCard(),
                  const SizedBox(height: 12),
                  _buildDiscoverEventsCard(),
                  const SizedBox(height: 12),
                  _buildCampusNavigationCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventsPage())),
            icon: const Icon(Icons.explore),
            label: const Text('Discover Events'),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LostFoundPage())),
          icon: const Icon(Icons.report_problem),
          label: const Text('Report/Claim'),
        ),
      ],
    );
  }

  Widget _buildCafeteriaQueueCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cafeteria Queue (real-time)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<Map<String, int>>(
              stream: _queueController.stream,
              builder: (context, snapshot) {
                final data = snapshot.data ?? _queues;
                return Column(
                  children: data.entries.map((e) => _buildQueueRow(e.key, e.value)).toList(),
                );
              },
            ),
            const SizedBox(height: 8),
            const Text('Tip: Tap a cafeteria to see more details.'),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueRow(String name, int count) {
    final eta = (count * 1.5).toStringAsFixed(0); // mock estimate
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Text('$count people waiting — est. $eta mins'),
      trailing: ElevatedButton(
        onPressed: () {
          // open details dialog
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(name),
              content: Text('Current queue: $count\nEstimated wait: $eta minutes.'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
              ],
            ),
          );
        },
        child: const Text('View'),
      ),
    );
  }

  Widget _buildDiscoverEventsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Discover Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('See upcoming campus events and check-in.'),
            const SizedBox(height: 8),
            const EventPreviewList(limit: 3),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventsPage())), child: const Text('See all')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusNavigationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Campus Navigation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Find routes between buildings and rooms.'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NavigationPage())),
            icon: const Icon(Icons.directions),
            label: const Text('Open Navigation'),
          ),
        ]),
      ),
    );
  }
}

// ---------------------- Event models & list ----------------------

class EventModel {
  final String id;
  final String title;
  final String place;
  final DateTime start;
  final String description;
  bool checkedIn;

  EventModel({
    required this.id,
    required this.title,
    required this.place,
    required this.start,
    required this.description,
    this.checkedIn = false,
  });
}

final List<EventModel> _sampleEvents = [
  EventModel(
    id: 'e1',
    title: 'Tech Talk: Flutter Futures',
    place: 'Auditorium A',
    start: DateTime.now().add(const Duration(hours: 6)),
    description: 'A deep dive into Flutter 4 and beyond: performance, plugins, and native integrations.',
  ),
  EventModel(
    id: 'e2',
    title: 'Art & Design Expo',
    place: 'Gallery Hall',
    start: DateTime.now().add(const Duration(days: 1, hours: 2)),
    description: 'Student exhibitions showcasing UI, UX and print design projects.',
  ),
  EventModel(
    id: 'e3',
    title: 'Cultural Night',
    place: 'Open Grounds',
    start: DateTime.now().add(const Duration(days: 2, hours: 5)),
    description: 'Music, food stalls and performances by student groups.',
  ),
];

class EventPreviewList extends StatefulWidget {
  final int limit;
  const EventPreviewList({super.key, this.limit = 3});

  @override
  State<EventPreviewList> createState() => _EventPreviewListState();
}

class _EventPreviewListState extends State<EventPreviewList> {
  late final List<EventModel> _events;

  @override
  void initState() {
    super.initState();
    _events = _sampleEvents.map((e) => EventModel(
      id: e.id,
      title: e.title,
      place: e.place,
      start: e.start,
      description: e.description,
      checkedIn: e.checkedIn,
    )).toList();
  }

  void _toggleCheckIn(EventModel event) {
    setState(() => event.checkedIn = !event.checkedIn);
    final snack = event.checkedIn ? 'Checked in to ${event.title}' : 'Checked out of ${event.title}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snack)));
  }

  @override
  Widget build(BuildContext context) {
    final list = _events.take(widget.limit).toList();
    return Column(
      children: list.map((e) => Card(
        child: ListTile(
          title: Text(e.title),
          subtitle: Text('${e.place} • ${_formatDate(e.start)}'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.info_outline), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventDetailsPage(event: e)))),
            ElevatedButton(onPressed: () => _toggleCheckIn(e), child: Text(e.checkedIn ? 'Checked' : 'Check-in')),
          ]),
        ),
      )).toList(),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ---------------------- Events Page ----------------------
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final List<EventModel> events;

  @override
  void initState() {
    super.initState();
    events = _sampleEvents;
  }

  void _toggleCheckIn(EventModel e) => setState(() => e.checkedIn = !e.checkedIn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: events.length,
        itemBuilder: (context, i) {
          final e = events[i];
          return Card(
            child: ListTile(
              title: Text(e.title),
              subtitle: Text('${e.place} • ${_formatDate(e.start)}'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventDetailsPage(event: e))),
              trailing: ElevatedButton(onPressed: () => _toggleCheckIn(e), child: Text(e.checkedIn ? 'Checked' : 'Check-in')),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ---------------------- Event Details ----------------------
class EventDetailsPage extends StatelessWidget {
  final EventModel event;
  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Location: ${event.place}'),
          const SizedBox(height: 4),
          Text('Starts: ${event.start}'),
          const SizedBox(height: 12),
          Text(event.description),
          const SizedBox(height: 20),
          ElevatedButton.icon(onPressed: () {
            // Mock check-in
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checked in to ${event.title}')));
          }, icon: const Icon(Icons.check), label: const Text('Check-in')),
        ]),
      ),
    );
  }
}

// ---------------------- Lost & Found ----------------------
class LostFoundItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  bool claimed;

  LostFoundItem({required this.id, required this.title, required this.description, required this.timestamp, this.claimed = false});
}

class LostFoundPage extends StatefulWidget {
  const LostFoundPage({super.key});

  @override
  State<LostFoundPage> createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage> {
  final List<LostFoundItem> _items = [];
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  void _reportItem() {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (title.isEmpty) return;
    final item = LostFoundItem(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title, description: desc, timestamp: DateTime.now());
    setState(() => _items.insert(0, item));
    _titleCtrl.clear();
    _descCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reported item successfully')));
  }

  void _claimItem(LostFoundItem item) {
    setState(() => item.claimed = !item.claimed);
    final msg = item.claimed ? 'Marked as claimed' : 'Marked as unclaimed';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost & Found')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(children: [
                TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Item title')),
                const SizedBox(height: 8),
                TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description (where found)'), minLines: 1, maxLines: 3),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [ElevatedButton(onPressed: _reportItem, child: const Text('Report'))]),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _items.isEmpty ? const Center(child: Text('No reports yet')) : ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, i) {
              final it = _items[i];
              return Card(
                child: ListTile(
                  title: Text(it.title),
                  subtitle: Text('${it.description}\n${it.timestamp}'),
                  isThreeLine: true,
                  trailing: ElevatedButton(onPressed: () => _claimItem(it), child: Text(it.claimed ? 'Claimed' : 'Claim')),
                ),
              );
            },
          ))
        ]),
      ),
    );
  }
}

// ---------------------- Navigation Page (Campus routing) ----------------------
class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final _fromCtrl = TextEditingController(text: 'Library');
  final _toCtrl = TextEditingController(text: 'Auditorium A');
  List<String> _routeSteps = [];

  void _calculateRoute() {
    final from = _fromCtrl.text.trim();
    final to = _toCtrl.text.trim();
    if (from.isEmpty || to.isEmpty) return;
    // Mocked route generation: in real app this would call a routing API or campus graph
    setState(() {
      _routeSteps = [
        'Start at $from',
        'Walk straight for 120 m',
        'Turn right at the Main Quad',
        'Pass the Canteen',
        'Enter $to',
      ];
    });
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Navigation')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _fromCtrl, decoration: const InputDecoration(labelText: 'From (building/room)')),
          const SizedBox(height: 8),
          TextField(controller: _toCtrl, decoration: const InputDecoration(labelText: 'To (building/room)')),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: ElevatedButton(onPressed: _calculateRoute, child: const Text('Find route')))]),
          const SizedBox(height: 12),
          if (_routeSteps.isEmpty) const Text('No route calculated yet'),
          if (_routeSteps.isNotEmpty) Expanded(child: ListView.separated(
            itemBuilder: (context, i) => ListTile(leading: CircleAvatar(child: Text('${i+1}')), title: Text(_routeSteps[i])),
            separatorBuilder: (_,__) => const Divider(),
            itemCount: _routeSteps.length,
          ))
        ]),
      ),
    );
  }
}

// End of file
