// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unused_element, unused_element_parameter

part of 'screens.dart';

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _appSurface(context),
        border: Border.all(color: _appBorder(context)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: padding,
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? note;
  final IconData? icon;
  final Color? accent;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    this.note,
    this.icon,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: Container(
        decoration: BoxDecoration(
          color: _appSurface(context),
          border: Border.all(
            color: accent ?? _appBorder(context),
            width: accent == null ? 1 : 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // ← distributes space evenly
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color:
                          _appMuted(context), // ← muted label, value pops more
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 26,
              child: note != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _appMuted(context).withAlpha(18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        note!,
                        style: TextStyle(
                          color: _appMuted(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final Widget child;

  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = _appSoftSurface(context);
    final highlight = _appSurface(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final width = bounds.width;
            final slide = (width * 2) * _controller.value - width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(
              Rect.fromLTWH(slide, 0, width, bounds.height),
            );
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadiusGeometry borderRadius;

  const _SkeletonBox({
    required this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: _appSoftSurface(context),
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class _MetricCardSkeleton extends StatelessWidget {
  const _MetricCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: Container(
        decoration: BoxDecoration(
          color: _appSurface(context),
          border: Border.all(color: _appBorder(context)),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(24),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SkeletonBox(height: 16, width: 130),
            _SkeletonBox(height: 36, width: 190),
            _SkeletonBox(height: 24, width: 150),
          ],
        ),
      ),
    );
  }
}

class _MetricGridSkeleton extends StatelessWidget {
  final int count;
  final double minTileWidth;

  const _MetricGridSkeleton({
    this.count = 3,
    this.minTileWidth = 260,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      minTileWidth: minTileWidth,
      children: List.generate(count, (_) => const _MetricCardSkeleton()),
    );
  }
}

class _PanelSkeleton extends StatelessWidget {
  final int rows;
  final bool table;

  const _PanelSkeleton({
    this.rows = 4,
    this.table = false,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SkeletonBox(height: 22, width: 220),
            const SizedBox(height: 22),
            ...List.generate(rows, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: index == rows - 1 ? 0 : 14),
                child: Row(
                  children: [
                    if (table) ...[
                      const _SkeletonBox(height: 18, width: 110),
                      const SizedBox(width: 18),
                    ],
                    Expanded(
                      child: _SkeletonBox(
                        height: table ? 18 : 24,
                      ),
                    ),
                    const SizedBox(width: 18),
                    _SkeletonBox(
                      height: table ? 18 : 24,
                      width: table ? 120 : 180,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _VoucherPrefixHelpButton extends StatelessWidget {
  const _VoucherPrefixHelpButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Voucher prefix help',
      icon: Icon(Icons.help_outline, color: _appText(context)),
      onPressed: () => _showVoucherPrefixHelp(context),
    );
  }
}

void _showVoucherPrefixHelp(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Voucher Prefix Guide'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _VoucherHelpRow(
              prefix: 'GV',
              title: 'General Voucher',
              description:
                  'Use GV for journal/general adjustments, opening entries, transfers, and entries that are not direct payments or sales invoices.',
            ),
            SizedBox(height: 14),
            _VoucherHelpRow(
              prefix: 'PV',
              title: 'Payment Voucher',
              description:
                  'Use PV for money paid out, such as vendor payments, rent, GST payment, advance payments, and other credit-side cash movement.',
            ),
            SizedBox(height: 14),
            _VoucherHelpRow(
              prefix: 'SI',
              title: 'Sales Invoice',
              description:
                  'Use SI for customer billing and sales income. If payment is not received yet, mark the status as To Receive.',
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

class _VoucherHelpRow extends StatelessWidget {
  final String prefix;
  final String title;
  final String description;

  const _VoucherHelpRow({
    required this.prefix,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Chip(label: prefix, color: _appAccent(context), filled: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: _appMuted(context))),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyPanelMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyPanelMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _appMuted(context), size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: _appMuted(context)),
          ),
        ],
      ),
    );
  }
}

class _LedgerLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LedgerLoadError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: _InlineErrorMessage(
        message: message,
        onRetry: onRetry,
      ),
    );
  }
}

class _InlineErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineErrorMessage({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_outlined, color: _red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _appMuted(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _appAccent(context),
              side: BorderSide(color: _appAccent(context)),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _DataPanel extends StatelessWidget {
  final String? title;
  final String? action;
  final List<String> columns;
  final List<List<Widget>> rows;
  final Widget? footer;

  const _DataPanel({
    required this.columns,
    required this.rows,
    this.title,
    // Kept for existing/common table callers; page-specific tables can ignore it.
    this.action,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableMinWidth =
              constraints.maxWidth < 900 ? 900.0 : constraints.maxWidth;

          return Column(
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title!,
                          style: TextStyle(
                              color: _appAccent(context),
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (action != null)
                        Text(
                          action!,
                          style: TextStyle(
                            color: _appAccent(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      if (action != null)
                        const Icon(Icons.arrow_forward, color: _primary),
                    ],
                  ),
                ),
              _HorizontalScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: tableMinWidth),
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(_appHeaderSurface(context)),
                    border: TableBorder(
                        horizontalInside:
                            BorderSide(color: _appBorder(context))),
                    columnSpacing: 20,
                    headingTextStyle: TextStyle(
                      color: _appText(context),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      fontSize: 14,
                    ),
                    dataTextStyle:
                        TextStyle(color: _appText(context), fontSize: 15),
                    columns: columns
                        .map((column) => DataColumn(
                            label: Expanded(
                                child: Text(column,
                                    overflow: TextOverflow.ellipsis))))
                        .toList(),
                    rows: rows
                        .map((row) => DataRow(
                            cells: row.map((cell) => DataCell(cell)).toList()))
                        .toList(),
                  ),
                ),
              ),
              if (footer != null) footer!,
            ],
          );
        },
      ),
    );
  }
}

class _HorizontalScrollView extends StatefulWidget {
  final Widget child;

  const _HorizontalScrollView({required this.child});

  @override
  State<_HorizontalScrollView> createState() => _HorizontalScrollViewState();
}

class _HorizontalScrollViewState extends State<_HorizontalScrollView> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      notificationPredicate: (notification) => notification.depth == 0,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: widget.child,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final bool large;

  const _Chip({
    required this.label,
    required this.color,
    this.filled = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 9 : 5,
      ),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(85) : color.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: large ? 16 : 12,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;

  const _Label(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.8),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 7, backgroundColor: color),
        const SizedBox(width: 7),
        Text(label),
      ],
    );
  }
}

class _KpiBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiBlock(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 18),
      decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label),
          Text(value,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OutlineAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: _appAccent(context),
        side: const BorderSide(color: _primary),
        minimumSize: const Size(150, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
