import 'package:flutter/material.dart';

class PageChat extends StatelessWidget {
  const PageChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1), 
      body: Center(
        child: Text(
          'Nuova funzionalità presto disponibile',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black, 
          ),
        ),
      ),
    );
  }
}
