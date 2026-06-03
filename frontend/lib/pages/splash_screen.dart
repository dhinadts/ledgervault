part of 'screens.dart';

const _tourSeenKey = 'ledger_has_seen_app_tour';

bool _usesMobileLaunchFlow(BuildContext context) {
  if (kIsWeb) {
    return false;
  }

  final size = MediaQuery.sizeOf(context);
  return size.shortestSide < 600;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _continueAfterLaunch();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continueAfterLaunch() async {
    final mobileLaunch = _usesMobileLaunchFlow(context);
    if (mobileLaunch) {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
    }

    if (!mounted) {
      return;
    }

    if (!mobileLaunch) {
      _goToNextScreen(skipSetup: true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasSeenTour = prefs.getBool(_tourSeenKey) ?? false;
    if (!hasSeenTour) {
      context.go('/app-tour');
      return;
    }

    _goToNextScreen();
  }

  void _goToNextScreen({bool skipSetup = false}) {
    if (!AuthSession.isAuthenticated) {
      context.go('/login');
      return;
    }

    if (skipSetup || BankAccountSetupSession.isComplete) {
      context.go('/dashboard');
      return;
    }

    context.go('/bank-details');
  }

  @override
  Widget build(BuildContext context) {
    if (!_usesMobileLaunchFlow(context)) {
      return Scaffold(backgroundColor: _appBackground(context));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B100D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B100D),
              Color(0xFF0B3D2E),
              Color(0xFF145A32),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _opacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: const LedgerBrandLockup(
                      logoSize: 142,
                      titleSize: 30,
                      subtitleSize: 12,
                      center: true,
                      titleColor: Colors.white,
                      subtitleColor: Color(0xFFF4C430),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: 320,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const DhinadtsCompanyMark(
                      height: 58,
                      center: true,
                    ),
                  ),
                  const SizedBox(height: 34),
                  const SizedBox(
                    width: 180,
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      color: Color(0xFFF4C430),
                      backgroundColor: Color(0x332E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppTourScreen extends StatefulWidget {
  const AppTourScreen({super.key});

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _items = [
    _AppTourItem(
      title: 'Track Every Account',
      description:
          'Manage company, individual, joint, trust, and partnership accounts in one ledger workspace.',
      imagePath: 'assets/images/onboarding/asset_tracking.png',
    ),
    _AppTourItem(
      title: 'Real-Time Ledger',
      description:
          'Record receipts, payments, receivables, and payables with clear cash-flow visibility.',
      imagePath: 'assets/images/onboarding/real_time.png',
    ),
    _AppTourItem(
      title: 'Secure Records',
      description:
          'Keep account details, IFSC, opening balances, and profile information organized securely.',
      imagePath: 'assets/images/onboarding/secure.png',
    ),
    _AppTourItem(
      title: 'Reports & Balance Sheet',
      description:
          'Review bank balances, export statements, and prepare audit-ready business reports.',
      imagePath: 'assets/images/onboarding/analytics.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourSeenKey, true);

    if (!mounted) {
      return;
    }

    final mobileLaunch = _usesMobileLaunchFlow(context);
    if (!AuthSession.isAuthenticated) {
      context.go('/login');
      return;
    }

    if (!mobileLaunch || BankAccountSetupSession.isComplete) {
      context.go('/dashboard');
      return;
    }

    context.go('/bank-details');
  }

  @override
  Widget build(BuildContext context) {
    final lastPage = _currentPage == _items.length - 1;
    return Scaffold(
      backgroundColor: const Color(0xFF0B100D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B100D), Color(0xFF0B3D2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: LedgerBrandLockup(
                        logoSize: 44,
                        titleSize: 18,
                        subtitleSize: 8,
                        dense: true,
                        titleColor: Colors.white,
                        subtitleColor: Color(0xFFF4C430),
                      ),
                    ),
                    if (!lastPage)
                      TextButton(
                        onPressed: _finishTour,
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Color(0xFFF4C430)),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) =>
                      _AppTourPage(item: _items[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _items.length,
                        (index) =>
                            _TourIndicator(active: index == _currentPage),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF4C430),
                          foregroundColor: const Color(0xFF0B3D2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (lastPage) {
                            _finishTour();
                            return;
                          }

                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Text(
                          lastPage ? 'GET STARTED' : 'NEXT',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppTourPage extends StatelessWidget {
  final _AppTourItem item;

  const _AppTourPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = constraints.maxHeight < 560 ? 250.0 : 340.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(65),
                        blurRadius: 34,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(item.imagePath, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TourIndicator extends StatelessWidget {
  final bool active;

  const _TourIndicator({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF4C430) : Colors.white24,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _AppTourItem {
  final String title;
  final String description;
  final String imagePath;

  const _AppTourItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
