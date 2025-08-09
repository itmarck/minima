import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

import 'database.dart';

class InspectorWidget extends StatelessWidget {
  const InspectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.db;

    final records = db.select('SELECT * FROM records ORDER BY created_at DESC');
    final events = db.select('SELECT * FROM events ORDER BY occurred_at DESC');

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Records'), Tab(text: 'Summary')]),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                _RecordsView(records: records),
                _SummaryView(db: db, records: records, events: events),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordsView extends StatelessWidget {
  final ResultSet records;
  const _RecordsView({required this.records});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final r = records[i];
        return ListTile(
          dense: true,
          title: Text('${r['entity_kind']} ${r['entity_id']}'),
          subtitle: Text('${r['key']} = ${r['value']}'),
          trailing: Text('${r['created_at']}'),
        );
      },
    );
  }
}

class _SummaryView extends StatelessWidget {
  final Database db;
  final ResultSet records;
  final ResultSet events;
  const _SummaryView({required this.db, required this.records, required this.events});

  @override
  Widget build(BuildContext context) {
    // Per entity_kind, entity_id -> latest values map
    final latestPerEntity = <String, Map<String, String>>{};
    for (final r in records) {
      final key = '${r['entity_kind']}::${r['entity_id']}';
      latestPerEntity.putIfAbsent(key, () => {});
      final map = latestPerEntity[key]!;
      map.putIfAbsent(r['key'] as String, () => r['value'] as String);
    }

    final entries = latestPerEntity.entries.toList();

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final e = entries[i];
        final kind = e.key.split('::').first;
        final id = e.key.split('::').last;
        final map = e.value;
        final props = map.entries.map((kv) => '${kv.key}: ${kv.value}').join(' | ');
        return ListTile(
          dense: true,
          title: Text('$kind $id'),
          subtitle: Text(props),
        );
      },
    );
  }
}

