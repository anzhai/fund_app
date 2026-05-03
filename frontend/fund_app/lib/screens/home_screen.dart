import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _walletData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final wallet = await apiService.getWallet();
      setState(() => _walletData = wallet);
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Asset card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('总资产', style: TextStyle(color: Colors.grey)),
                                TextButton.icon(
                                  icon: const Icon(Icons.visibility, size: 18),
                                  label: const Text('隐藏'),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '¥ ${_walletData != null ? double.parse(_walletData!['balance'].toString()).toStringAsFixed(2) : '0.00'}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('昨日收益', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      const Text('+¥0.00', style: TextStyle(fontSize: 16, color: Colors.red)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('累计收益', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      const Text('+¥0.00', style: TextStyle(fontSize: 16, color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick actions
                    const Text('快捷操作', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _QuickActionButton(
                          icon: Icons.account_balance_wallet,
                          label: '充值',
                          onTap: () => _navigateToRecharge(context),
                        ),
                        _QuickActionButton(
                          icon: Icons.shopping_cart,
                          label: '买基金',
                          onTap: () => _navigateToFundList(context),
                        ),
                        _QuickActionButton(
                          icon: Icons.repeat,
                          label: '定投',
                          onTap: () => _navigateToSIP(context),
                        ),
                        _QuickActionButton(
                          icon: Icons.history,
                          label: '交易记录',
                          onTap: () => _navigateToTradeHistory(context),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Fund recommendations
                    const Text('热门基金', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    FutureBuilder<List<dynamic>>(
                      future: ApiService().getFundRanking(period: '1m'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('加载失败: ${snapshot.error}'));
                        }
                        final funds = snapshot.data ?? [];
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: funds.length > 5 ? 5 : funds.length,
                          itemBuilder: (context, index) {
                            final fund = funds[index];
                            return _FundCard(fund: fund);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _navigateToRecharge(BuildContext context) {
    Navigator.pushNamed(context, '/recharge');
  }

  void _navigateToFundList(BuildContext context) {
    Navigator.pushNamed(context, '/funds');
  }

  void _navigateToSIP(BuildContext context) {
    Navigator.pushNamed(context, '/sip');
  }

  void _navigateToTradeHistory(BuildContext context) {
    Navigator.pushNamed(context, '/trade-history');
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FundCard extends StatelessWidget {
  final Map<String, dynamic> fund;

  const _FundCard({required this.fund});

  String _getTypeName(String type) {
    switch (type) {
      case 'money_market': return '货币';
      case 'stock': return '股票';
      case 'hybrid': return '混合';
      case 'fof': return 'FOF';
      case 'bond': return '债券';
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(fund['fund_name'] ?? ''),
        subtitle: Text('${fund['fund_code']} | ${_getTypeName(fund['fund_type'] ?? '')}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('¥${fund['nav']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '+2.04%',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/fund-detail', arguments: fund['fund_code']);
        },
      ),
    );
  }
}
