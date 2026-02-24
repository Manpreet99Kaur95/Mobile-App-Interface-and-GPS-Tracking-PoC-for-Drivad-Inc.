import 'package:flutter/material.dart';

class FindYourCarPage extends StatelessWidget {
  const FindYourCarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: const Center(
        child: Text('Profile / Find Your Car Page'),
      ),
    );
  }
}
