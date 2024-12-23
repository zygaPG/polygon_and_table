import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:polgon_and_table/pages/map_page.dart';
import 'package:polgon_and_table/pages/table_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
  MapboxOptions.setAccessToken(ACCESS_TOKEN);

  runApp(MaterialApp(home: MyMenuePage()));
}

class MyMenuePage extends StatefulWidget {
  const MyMenuePage({super.key});

  @override
  State<MyMenuePage> createState() => _MyMenue();
}

class _MyMenue extends State<MyMenuePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapPage(),
                      ),
                    );
                  },
                  child: const Text('Map Page'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TablePage(),
                      ),
                    );
                  },
                  child: const Text('Table Page'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
