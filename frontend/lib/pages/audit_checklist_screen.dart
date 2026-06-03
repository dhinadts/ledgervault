part of 'screens.dart';

class AuditChecklistScreen extends StatelessWidget {
  const AuditChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/audit-checklist',
      searchHint: 'Search audit checklist...',
      floatingIcon: Icons.fact_check_outlined,
      child: _AuditChecklistContent(),
    );
  }
}

class _AuditChecklistContent extends StatefulWidget {
  const _AuditChecklistContent();

  @override
  State<_AuditChecklistContent> createState() => _AuditChecklistContentState();
}

class _AuditChecklistContentState extends State<_AuditChecklistContent> {
  bool _loadingDocuments = true;
  bool _uploading = false;
  List<Map<String, dynamic>> _documents = const [];

  static const _sections = [
    _AuditChecklistSection(
      title: 'Ledger Readiness',
      subtitle: 'Core books and transaction status checks.',
      icon: Icons.menu_book_outlined,
      items: [
        _AuditChecklistItem('Receipt vouchers reviewed', true),
        _AuditChecklistItem('Payment vouchers reviewed', true),
        _AuditChecklistItem('Pending receivables marked', false),
        _AuditChecklistItem('Pending payables marked', false),
      ],
    ),
    _AuditChecklistSection(
      title: 'Bank Reconciliation',
      subtitle: 'Managed accounts and balance verification.',
      icon: Icons.account_balance_outlined,
      items: [
        _AuditChecklistItem('Opening balances captured', true),
        _AuditChecklistItem('Primary account selected', true),
        _AuditChecklistItem('Statement import checked', false),
        _AuditChecklistItem('Ledger balance matched', false),
      ],
    ),
    _AuditChecklistSection(
      title: 'Compliance Review',
      subtitle: 'Documents, approvals, and report handoff.',
      icon: Icons.verified_outlined,
      items: [
        _AuditChecklistItem('Company profile verified', true),
        _AuditChecklistItem('GST notes reviewed', false),
        _AuditChecklistItem('Open approvals checked', false),
        _AuditChecklistItem('Audit events exported', false),
      ],
    ),
  ];

  static const _requiredDocuments = [
    _AuditDocumentRequirement(
      section: 'Ledger Readiness',
      checklistItem: 'Receipt vouchers reviewed',
      title: 'Receipt voucher samples',
      description:
          'Upload receipts, invoices, or supporting transaction proof.',
    ),
    _AuditDocumentRequirement(
      section: 'Ledger Readiness',
      checklistItem: 'Payment vouchers reviewed',
      title: 'Payment voucher samples',
      description: 'Upload payment proofs for reviewed debit transactions.',
    ),
    _AuditDocumentRequirement(
      section: 'Bank Reconciliation',
      checklistItem: 'Ledger balance matched',
      title: 'Bank statement / reconciliation',
      description: 'Upload statement, reconciliation sheet, or balance proof.',
    ),
    _AuditDocumentRequirement(
      section: 'Compliance Review',
      checklistItem: 'GST notes reviewed',
      title: 'GST and compliance notes',
      description: 'Upload GST worksheet, notes, or approval document.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final documents = await _backendApi.fetchAuditDocuments();
      if (!mounted) {
        return;
      }
      setState(() {
        _documents = documents;
        _loadingDocuments = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loadingDocuments = false);
    }
  }

  Future<void> _uploadDocument(_AuditDocumentRequirement requirement) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await pickAuditDocument();
    if (picked == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No document selected.')),
      );
      return;
    }

    setState(() => _uploading = true);
    try {
      await _backendApi.uploadAuditDocument(
        section: requirement.section,
        checklistItem: requirement.checklistItem,
        fileName: picked.fileName,
        contentType: picked.contentType,
        base64Data: picked.base64Data,
      );
      await _loadDocuments();
      messenger.showSnackBar(
        SnackBar(content: Text('${picked.fileName} uploaded.')),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PageTitle(
          title: 'Audit Checklist',
          subtitle:
              'Demo-ready checklist for ledger, bank, and compliance review.',
        ),
        const SizedBox(height: 24),
        _ResponsiveGrid(
          minTileWidth: 280,
          children: _sections
              .map((section) => _AuditChecklistCard(section: section))
              .toList(),
        ),
        const SizedBox(height: 24),
        _AuditDocumentsPanel(
          requirements: _requiredDocuments,
          documents: _documents,
          loading: _loadingDocuments,
          uploading: _uploading,
          onUpload: _uploadDocument,
        ),
        const SizedBox(height: 24),
        _Panel(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final summary = _AuditSummaryCopy();
              final button = OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _appAccent(context),
                ),
                onPressed: () => context.go('/reports'),
                icon: const Icon(Icons.assessment_outlined),
                label: const Text('Open Reports'),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    summary,
                    const SizedBox(height: 16),
                    button,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: summary),
                  const SizedBox(width: 18),
                  button,
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AuditDocumentsPanel extends StatelessWidget {
  final List<_AuditDocumentRequirement> requirements;
  final List<Map<String, dynamic>> documents;
  final bool loading;
  final bool uploading;
  final ValueChanged<_AuditDocumentRequirement> onUpload;

  const _AuditDocumentsPanel({
    required this.requirements,
    required this.documents,
    required this.loading,
    required this.uploading,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.upload_file_outlined, color: _appAccent(context)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Required Audit Documents',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          ...requirements.map((requirement) {
            final uploaded = documents.where((document) {
              return document['section'] == requirement.section &&
                  document['checklistItem'] == requirement.checklistItem;
            }).toList();

            return _AuditDocumentTile(
              requirement: requirement,
              uploadedCount: uploaded.length,
              latestFileName: uploaded.isEmpty
                  ? null
                  : uploaded.first['fileName']?.toString(),
              uploading: uploading,
              onUpload: () => onUpload(requirement),
            );
          }),
        ],
      ),
    );
  }
}

class _AuditDocumentTile extends StatelessWidget {
  final _AuditDocumentRequirement requirement;
  final int uploadedCount;
  final String? latestFileName;
  final bool uploading;
  final VoidCallback onUpload;

  const _AuditDocumentTile({
    required this.requirement,
    required this.uploadedCount,
    required this.latestFileName,
    required this.uploading,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final uploaded = uploadedCount > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _appBorder(context))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    uploaded ? Icons.check_circle : Icons.description_outlined,
                    color: uploaded ? _green : _appMuted(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      requirement.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                latestFileName ?? requirement.description,
                style: TextStyle(color: _appMuted(context)),
              ),
            ],
          );
          final button = OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _appAccent(context),
            ),
            onPressed: uploading ? null : onUpload,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(uploaded ? 'Replace' : 'Upload'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                copy,
                const SizedBox(height: 12),
                button,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 16),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _AuditChecklistCard extends StatelessWidget {
  final _AuditChecklistSection section;

  const _AuditChecklistCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final completed = section.items.where((item) => item.done).length;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(section.icon, color: _appAccent(context), size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.subtitle,
                      style: TextStyle(color: _appMuted(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: completed / section.items.length,
            minHeight: 6,
            color: _green,
            backgroundColor: _appSoftSurface(context),
          ),
          const SizedBox(height: 14),
          Text(
            '$completed of ${section.items.length} completed',
            style: TextStyle(
              color: _appMuted(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          ...section.items.map((item) => _AuditChecklistTile(item: item)),
        ],
      ),
    );
  }
}

class _AuditChecklistTile extends StatelessWidget {
  final _AuditChecklistItem item;

  const _AuditChecklistTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            item.done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: item.done ? _green : _appMuted(context),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                color: _appText(context),
                fontWeight: item.done ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditSummaryCopy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audit Preparation',
          style: TextStyle(
            color: _appAccent(context),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Use this demo checklist before sharing ledger reports, balance sheet figures, and managed account details with the auditor.',
          style: TextStyle(color: _appMuted(context)),
        ),
      ],
    );
  }
}

class _AuditChecklistSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_AuditChecklistItem> items;

  const _AuditChecklistSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
  });
}

class _AuditChecklistItem {
  final String label;
  final bool done;

  const _AuditChecklistItem(this.label, this.done);
}

class _AuditDocumentRequirement {
  final String section;
  final String checklistItem;
  final String title;
  final String description;

  const _AuditDocumentRequirement({
    required this.section,
    required this.checklistItem,
    required this.title,
    required this.description,
  });
}
