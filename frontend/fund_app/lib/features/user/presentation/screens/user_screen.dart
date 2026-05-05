import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../providers/user_provider.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userProvider.notifier).loadUser());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : state.error != null
              ? AppErrorWidget(message: state.error!)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileCard(state),
                      const SizedBox(height: 24),
                      _buildMenuSection(context),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileCard(UserState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.user?.phone ?? '未登录',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${state.user?.id ?? 0}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: state.user?.hasFundAccount == true ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          state.user?.hasFundAccount == true ? '已开户' : '未开户',
                          style: TextStyle(
                            color: state.user?.hasFundAccount == true ? Colors.green : Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (state.user?.riskLevel != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '风险等级: ${state.user!.riskLevel}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.account_balance_wallet,
          title: '我的钱包',
          onTap: () => context.go('/wallet'),
        ),
        _MenuItem(
          icon: Icons.pie_chart,
          title: '我的组合',
          onTap: () => context.go('/portfolio'),
        ),
        _MenuItem(
          icon: Icons.swap_horiz,
          title: '交易记录',
          onTap: () => context.go('/trade/history'),
        ),
        _MenuItem(
          icon: Icons.credit_card,
          title: '银行卡管理',
          onTap: () => context.go('/account'),
        ),
        _MenuItem(
          icon: Icons.assessment,
          title: '风险评估',
          onTap: () => context.go('/account/risk-assessment'),
        ),
        const Divider(height: 32),
        _MenuItem(
          icon: Icons.help_outline,
          title: '帮助中心',
          onTap: () {},
        ),
        _MenuItem(
          icon: Icons.info_outline,
          title: '关于我们',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              final router = GoRouter.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('退出登录'),
                  content: const Text('确定要退出登录吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await ref.read(userProvider.notifier).logout();
                router.go('/login');
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('退出登录'),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}