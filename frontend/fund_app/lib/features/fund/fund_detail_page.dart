import 'package:flutter/material.dart';

class FundDetailPage extends StatefulWidget {
  final String fundCode;

  const FundDetailPage({super.key, required this.fundCode});

  @override
  State<FundDetailPage> createState() => _FundDetailPageState();
}

class _FundDetailPageState extends State<FundDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fund Detail')),
      body: Center(child: Text('Fund Detail: ${widget.fundCode}')),
    );
  }
}
