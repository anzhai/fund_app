import 'package:flutter/material.dart';

class PurchasePage extends StatefulWidget {
  final String fundCode;

  const PurchasePage({super.key, required this.fundCode});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase')),
      body: Center(child: Text('Purchase: ${widget.fundCode}')),
    );
  }
}
