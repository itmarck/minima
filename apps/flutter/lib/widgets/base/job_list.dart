import 'package:flutter/material.dart';
import 'package:core/core.dart';

class JobList extends StatelessWidget {
  final List<Job> jobs;
  const JobList({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (jobs.isEmpty) {
      return Center(child: Text('No hay jobs', style: TextStyle(color: scheme.onSurfaceVariant)));
    }

    return ListView.separated(
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final j = jobs[index];
        return ListTile(
          title: Text(j.title),
          subtitle: Text(j.id.value),
        );
      },
    );
  }
}

