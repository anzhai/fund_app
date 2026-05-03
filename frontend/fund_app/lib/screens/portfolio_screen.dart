import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _portfolios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPortfolios();
  }

  Future<void> _loadPortfolios() async {
    setState(() => _isLoading = true);
    try {
      final portfolios = await _apiService.listPortfolios();
      setState(() => _portfolios = portfolios);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _createPortfolio() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final descController = TextEditingController();
        
        return AlertDialog(
          title: const Text('创建组合'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '组合名称'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: '描述（可选）'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _apiService.createPortfolio(
                    name: nameController.text,
                    description: descController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadPortfolios();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('创建成功')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('创建失败: $e')),
                    );
                  }
                }
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的组合'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createPortfolio,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _portfolios.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('暂无组合', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('创建组合'),
                        onPressed: _createPortfolio,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPortfolios,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _portfolios.length,
                    itemBuilder: (context, index) {
                      final portfolio = _portfolios[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(portfolio['portfolio_name'] ?? ''),
                          subtitle: Text(portfolio['description'] ?? ''),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Navigate to portfolio detail
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
