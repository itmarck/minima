import 'package:flutter/material.dart';
import 'package:minima/packages/bundle/bundle.dart';
import 'package:minima/packages/bundle/package.dart';

class Apps extends StatefulWidget {
  const Apps({super.key});

  @override
  State<Apps> createState() => _AppsState();
}

class _AppsState extends State<Apps> {
  List<Package> packages = [];

  @override
  void initState() {
    super.initState();

    Bundle().getInstalledPackages().then((value) {
      setState(() {
        packages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 64.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              child: Text('Apps'),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final p in packages)
                    ListTile(
                      title: Text(p.title),
                      onTap: () => Bundle().launch(p.name),
                    ),
                ],
              ),
            ),
            Container(
              height: 64.0,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Text('<'), Text('Finance'), Text('Lists')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
