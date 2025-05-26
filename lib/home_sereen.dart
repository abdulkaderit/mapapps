import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              Navigator.pushNamed(context,'/gps');
            },
                child: Text('GPS Screen')),
            SizedBox(height: 20),

            ElevatedButton(onPressed: (){
              Navigator.pushNamed(context, '/map');
            },
                child: Text('Google Map With GPS')),
          ],
        ),
      ),
    );
  }
}