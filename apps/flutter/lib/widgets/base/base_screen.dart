import 'package:flutter/material.dart';
import 'package:minima/providers/providers.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  @override
  void initState() {
    super.initState();
    ProjectProvider.of(context).load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
      ),
      drawer: Drawer(
        child: BaseDrawer(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          print('Add');
          await ProjectProvider.of(context).addProject('English', '');
        },
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: provider.items.map((p) => ListTile(title: Text(p.title))).toList(),
          );
        },
      ),
    );
  }
}

class BaseDrawer extends StatefulWidget {
  const BaseDrawer({super.key});

  @override
  State<BaseDrawer> createState() => _BaseDrawerState();
}

class _BaseDrawerState extends State<BaseDrawer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DrawerHeader(
          child: Text('Header'),
        ),
        Text('Search bar'),
        Expanded(
          child: ListView(
            children: [
              ListTile(title: Text('Projects')),
              ListTile(title: Text('Inbox')),
              ListTile(title: Text('Journal')),
            ],
          ),
        ),
        Text('Second menu'),
      ],
    );
  }
}
