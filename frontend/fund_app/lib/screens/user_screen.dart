import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Map<String, dynamic>? _accountInfo;
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
      final account = await apiService.getAccountInfo().catchError((_) => null);
      final wallet = await apiService.getWallet();
      setState(() {
        _accountInfo = account;
        _walletData = wallet;
      });
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
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: [
                  // User profile header
                  Container(
                    padding: const EdgeInsets.all(24),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            (user?['phone'] ?? 'U')[0],
                            style: const TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?['phone'] ?? '未登录',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _accountInfo != null ? '已开户' : '未开户',
                                style: TextStyle(
                                  color: _accountInfo != null ? Colors.green : Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Wallet section
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('钱包余额', style: TextStyle(fontSize: 16)),
                              Text(
                                '¥${_walletData != null ? double.parse(_walletData!['balance'].toString()).toStringAsFixed(2) : '0.00'}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('充值'),
                                  onPressed: () => Navigator.pushNamed(context, '/recharge'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.remove),
                                  label: const Text('取现'),
                                  onPressed: () => Navigator.pushNamed(context, '/withdraw'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Menu items
                  _buildMenuItem(
                    icon: Icons.person,
                    title: '个人信息',
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  _buildMenuItem(
                    icon: Icons.credit_card,
                    title: '银行卡管理',
                    onTap: () => Navigator.pushNamed(context, '/bank-cards'),
                  ),
                  _buildMenuItem(
                    icon: Icons.assessment,
                    title: '风险测评',
                    subtitle: _accountInfo?['risk_level'] != null 
                        ? '等级: ${_accountInfo!['risk_level']}' 
                        : '未测评',
                    onTap: () => Navigator.pushNamed(context, '/risk-assessment'),
                  ),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: '交易记录',
                    onTap: () => Navigator.pushNamed(context, '/trade-history'),
                  ),
                  _buildMenuItem(
                    icon: Icons.repeat,
                    title: '我的定投',
                    onTap: () => Navigator.pushNamed(context, '/my-sip'),
                  ),
                  _buildMenuItem(
                    icon: Icons.help,
                    title: '帮助中心',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.info,
                    title: '关于我们',
                    onTap: () {},
                  ),

                  const Divider(),

                  // Logout button
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('退出登录', style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('确认退出'),
                          content: const Text('确定要退出登录吗？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('取消'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('退出'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
