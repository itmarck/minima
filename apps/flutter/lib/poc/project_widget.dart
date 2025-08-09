import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'project_provider.dart';

class ProjectWidget extends StatefulWidget {
  const ProjectWidget({super.key});

  @override
  State<ProjectWidget> createState() => _ProjectWidgetState();
}

class _ProjectWidgetState extends State<ProjectWidget> {
  final _title = TextEditingController();
  final _desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    final model = context.read<ProjectModel>();
    model.load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _title,
                decoration: const InputDecoration(hintText: 'Project title...'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _desc,
                decoration: const InputDecoration(hintText: 'Description...'),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _submit, child: const Text('Add project')),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Consumer<ProjectModel>(
            builder: (context, model, _) {
              if (model.items.isEmpty) {
                return const Center(child: Text('No projects'));
              }
              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 8),
                  ...model.items.map(
                    (p) => Container(
                      width: 260,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(p.description),
                          const SizedBox(height: 8),
                          Text(
                            p.id.value,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          Text(
                            '${p.createdAt.toLocal()}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _submit() async {
    final t = _title.text.trim();
    final d = _desc.text.trim();
    if (t.isEmpty) return;
    await context.read<ProjectModel>().addProject(t, d);
    _title.clear();
    _desc.clear();
  }
}
