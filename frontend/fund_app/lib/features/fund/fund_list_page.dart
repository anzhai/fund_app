import 'package:flutter/material.dart';

class FundListPage extends StatefulWidget {
  const FundListPage({super.key});

  @override
  State<FundListPage> createState() => _FundListPageState();
}

class _FundListPageState extends State<FundListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fund List')),
      body: const Center(child: Text('Fund List Page')),
    );
  }
}
