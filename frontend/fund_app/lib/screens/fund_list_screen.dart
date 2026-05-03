import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FundListScreen extends StatefulWidget {
  const FundListScreen({Key? key}) : super(key: key);

  @override
  State<FundListScreen> createState() => _FundListScreenState();
}

class _FundListScreenState extends State<FundListScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _funds = [];
  bool _isLoading = true;
  String? _selectedType;
  String? _selectedRisk;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _loadFunds();
  }

  Future<void> _loadFunds() async {
    setState(() => _isLoading = true);
    try {
      final funds = await _apiService.listFunds(
        fundType: _selectedType,
        riskLevel: _selectedRisk,
        keyword: _searchKeyword.isEmpty ? null : _searchKeyword,
      );
      setState(() => _funds = funds);
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选基金'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: '基金类型'),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部')),
                const DropdownMenuItem(value: 'money_market', child: Text('货币基金')),
                const DropdownMenuItem(value: 'bond', child: Text('债券基金')),
                const DropdownMenuItem(value: 'hybrid', child: Text('混合基金')),
                const DropdownMenuItem(value: 'fof', child: Text('FOF基金')),
                const DropdownMenuItem(value: 'stock', child: Text('股票基金')),
              ],
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRisk,
              decoration: const InputDecoration(labelText: '风险等级'),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部')),
                const DropdownMenuItem(value: 'R1', child: Text('低风险 R1')),
                const DropdownMenuItem(value: 'R2', child: Text('中低风险 R2')),
                const DropdownMenuItem(value: 'R3', child: Text('中风险 R3')),
                const DropdownMenuItem(value: 'R4', child: Text('中高风险 R4')),
                const DropdownMenuItem(value: 'R5', child: Text('高风险 R5')),
              ],
              onChanged: (value) => setState(() => _selectedRisk = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedRisk = null;
              });
              Navigator.pop(context);
              _loadFunds();
            },
            child: const Text('重置'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadFunds();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基金超市'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索基金代码或名称',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                _searchKeyword = value;
              },
              onSubmitted: (_) => _loadFunds(),
            ),
          ),
          
          // Fund list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadFunds,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _funds.length,
                      itemBuilder: (context, index) {
                        final fund = _funds[index];
                        return _FundListItem(fund: fund);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FundListItem extends StatelessWidget {
  final Map<String, dynamic> fund;

  const _FundListItem({required this.fund});

  String _getTypeName(String type) {
    switch (type) {
      case 'money_market': return '货币';
      case 'bond': return '债券';
      case 'hybrid': return '混合';
      case 'fof': return 'FOF';
      case 'stock': return '股票';
      default: return type;
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'R1': return Colors.green;
      case 'R2': return Colors.lightGreen;
      case 'R3': return Colors.orange;
      case 'R4': return Colors.deepOrange;
      case 'R5': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/fund-detail', arguments: fund['fund_code']);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund['fund_name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          fund['fund_code'] ?? '',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getTypeName(fund['fund_type'] ?? ''),
                            style: TextStyle(color: Colors.blue[700], fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRiskColor(fund['risk_level'] ?? '').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            fund['risk_level'] ?? '',
                            style: TextStyle(
                              color: _getRiskColor(fund['risk_level'] ?? ''),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${fund['nav']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+2.04%',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
