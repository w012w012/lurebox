import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/onboarding_provider.dart';
import '../../core/design/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Widget> get _pages => [
        _WelcomePage(),
        _FeaturesPage(),
        _PermissionsPage(),
        _SettingsPage(),
        _CompletePage(),
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
    if (mounted) context.go('/');
  }

  void _skip() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _skip, child: const Text('跳过')),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: _pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primaryLight
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child:
                      Text(_currentPage == _pages.length - 1 ? '开始使用' : '下一步'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.water_drop,
              size: 100, color: AppColors.primaryLight),
          const SizedBox(height: 24),
          Text('欢迎使用路亚鱼护', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text('记录每一次出钓的渔获', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _FeaturesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('功能介绍', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: const [
                _FeatureCard(
                    icon: Icons.camera_alt, title: '拍照记录', desc: '快速拍摄鱼获照片'),
                _FeatureCard(
                    icon: Icons.inventory_2, title: '装备管理', desc: '管理鱼竿、鱼轮、鱼饵'),
                _FeatureCard(
                    icon: Icons.bar_chart, title: '统计分析', desc: '查看捕获数据趋势'),
                _FeatureCard(
                    icon: Icons.backup, title: '数据备份', desc: '云端备份永不丢失'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureCard(
      {required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.primaryLight),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(desc,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('权限说明', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 32),
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _PermissionCard(
                    icon: Icons.camera_alt,
                    title: '相机权限',
                    desc: '用于拍摄鱼获照片',
                    example: '示例: 拍照记录渔获精彩瞬间',
                  ),
                  SizedBox(height: 16),
                  _PermissionCard(
                    icon: Icons.location_on,
                    title: '位置权限',
                    desc: '记录钓点位置信息',
                    example: '示例: 自动记录钓点坐标',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('我们不会收集或上传您的隐私数据'),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String example;
  const _PermissionCard(
      {required this.icon,
      required this.title,
      required this.desc,
      required this.example});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryLight, size: 32),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(desc, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(example,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    )),
          ],
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('个性化设置', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text('可以在设置中随时调整', style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text('单位制、主题、语言', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
        ],
      ),
    );
  }
}

class _CompletePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle,
              size: 100, color: AppColors.primaryLight),
          const SizedBox(height: 24),
          Text('准备就绪!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text('开始记录您的第一个渔获吧', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
