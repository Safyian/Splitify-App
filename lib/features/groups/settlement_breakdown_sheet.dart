import 'package:flutter/material.dart';

import 'group_balances_model.dart';

// ─────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────

class SettlementMember {
  final String id;
  final String name;
  final String initials;
  final Color color;

  const SettlementMember({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
  });
}

class NetBalance {
  final SettlementMember member;
  final double net; // positive = owed to, negative = owes

  const NetBalance({required this.member, required this.net});
  bool get isCreditor => net >= 0;
}

class PairwiseDebt {
  final SettlementMember from;
  final SettlementMember to;
  final double amount;
  final String reason;

  const PairwiseDebt({
    required this.from,
    required this.to,
    required this.amount,
    required this.reason,
  });
}

class SimplifiedDebt {
  final SettlementMember from;
  final SettlementMember to;
  final double amount;

  const SimplifiedDebt({
    required this.from,
    required this.to,
    required this.amount,
  });
}

class SettlementBreakdownData {
  final List<NetBalance> netBalances;
  final List<PairwiseDebt> pairwise;
  final List<SimplifiedDebt> simplified;
  final int beforeCount;
  final int afterCount;

  const SettlementBreakdownData({
    required this.netBalances,
    required this.pairwise,
    required this.simplified,
    required this.beforeCount,
    required this.afterCount,
  });

  // ── Bridge: converts API model → UI model ──────────────────
  factory SettlementBreakdownData.fromBalancesModel(
    GroupBalancesModel model,
    String currentUserId,
  ) {
    const colors = [
      Color(0xFF6366F1), // indigo
      Color(0xFFEC4899), // pink
      Color(0xFF14B8A6), // teal
      Color(0xFFF97316), // orange
      Color(0xFF8B5CF6), // violet
    ];

    // Build id → SettlementMember map
    final memberMap = <String, SettlementMember>{};
    for (var i = 0; i < model.balances.length; i++) {
      final b = model.balances[i];
      final initials = b.name
          .trim()
          .split(RegExp(r'\s+'))
          .take(2)
          .map((w) => w[0].toUpperCase())
          .join();
      memberMap[b.userId] = SettlementMember(
        id: b.userId,
        name: b.userId == currentUserId ? 'You' : b.name,
        initials: initials,
        color: colors[i % colors.length],
      );
    }

    SettlementMember resolve(String id, String name, int fallbackIndex) {
      return memberMap[id] ??
          SettlementMember(
            id: id,
            name: id == currentUserId ? 'You' : name,
            initials: name.isNotEmpty ? name[0].toUpperCase() : '?',
            color: colors[fallbackIndex % colors.length],
          );
    }

    final netBalances = model.balances
        .map((b) => NetBalance(member: memberMap[b.userId]!, net: b.net))
        .toList();

    final pairwise = model.pairwise.asMap().entries.map((e) {
      final p = e.value;
      final from = resolve(p.from, p.fromName, e.key);
      final to = resolve(p.to, p.toName, e.key + 1);
      return PairwiseDebt(
        from: from,
        to: to,
        amount: p.amount,
        reason: '${p.fromName} owes ${p.toName} from shared expenses.',
      );
    }).toList();

    final simplified = model.settlements.asMap().entries.map((e) {
      final s = e.value;
      final from = resolve(s.from, s.fromName, e.key);
      final to = resolve(s.to, s.toName, e.key + 1);
      return SimplifiedDebt(from: from, to: to, amount: s.amount);
    }).toList();

    return SettlementBreakdownData(
      netBalances: netBalances,
      pairwise: pairwise,
      simplified: simplified,
      beforeCount: model.pairwise.length,
      afterCount: model.settlements.length,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// THEME CONSTANTS
// ─────────────────────────────────────────────────────────────

class _T {
  static const bg = Color(0xFFF2F1F8);
  static const bgCard = Color(0xFFFFFFFF);
  static const bgCard2 = Color(0xFFF2F1F8);
  static const accent = Color(0xFF0DAD85);
  static const green = Color(0xFF0DAD85);
  static const red = Color(0xFFE56D39);
  static const text = Color(0xFF1A1A1A);
  static const muted = Color(0xFF8A8A9A);
  static const border = Color(0xFFE5E5EF);
}

// ─────────────────────────────────────────────────────────────
// ENTRY POINT — call this to show the sheet
// ─────────────────────────────────────────────────────────────

void showSettlementBreakdown(
    BuildContext context, SettlementBreakdownData data) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SettlementBreakdownSheet(data: data),
  );
}

// ─────────────────────────────────────────────────────────────
// MAIN SHEET
// ─────────────────────────────────────────────────────────────

class _SettlementBreakdownSheet extends StatefulWidget {
  final SettlementBreakdownData data;
  const _SettlementBreakdownSheet({required this.data});

  @override
  State<_SettlementBreakdownSheet> createState() =>
      _SettlementBreakdownSheetState();
}

class _SettlementBreakdownSheetState extends State<_SettlementBreakdownSheet>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _steps = const [
    {'label': 'Net Balances', 'icon': '⚖️'},
    {'label': 'Who owes Who', 'icon': '🔗'},
    {'label': 'Simplified', 'icon': '✨'},
    {'label': 'Result', 'icon': '✅'},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    _animCtrl.reset();
    setState(() => _step = step);
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _T.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            _Header(
                debtorName: widget.data.netBalances
                    .firstWhere((b) => !b.isCreditor)
                    .member
                    .name),
            const SizedBox(height: 20),

            // Step selector tabs
            _StepTabs(steps: _steps, current: _step, onTap: _goTo),
            const SizedBox(height: 16),

            // Animated content
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildStepContent(),
              ),
            ),
            const SizedBox(height: 20),

            // Progress dots
            _ProgressDots(count: _steps.length, current: _step, onTap: _goTo),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _Step0NetBalances(data: widget.data, onNext: () => _goTo(1));
      case 1:
        return _Step1Pairwise(data: widget.data, onNext: () => _goTo(2));
      case 2:
        return _Step2Simplified(data: widget.data, onNext: () => _goTo(3));
      case 3:
        return _Step3Result(data: widget.data, onRestart: () => _goTo(0));
      default:
        return const SizedBox();
    }
  }
}

// ─────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String debtorName;
  const _Header({required this.debtorName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _T.accent.withOpacity(0.12),
            border: Border.all(color: _T.accent.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'How is this calculated?',
            style: TextStyle(
                color: _T.accent, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Settlement Breakdown',
          style: TextStyle(
              color: _T.text, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          "Tap through each step to see how $debtorName's debt is calculated",
          textAlign: TextAlign.center,
          style: const TextStyle(color: _T.muted, fontSize: 13),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP TABS
// ─────────────────────────────────────────────────────────────

class _StepTabs extends StatelessWidget {
  final List<Map<String, String>> steps;
  final int current;
  final ValueChanged<int> onTap;

  const _StepTabs(
      {required this.steps, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i == current;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < steps.length - 1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? _T.accent.withOpacity(0.15) : _T.bgCard,
                border: Border.all(
                  color: isActive ? _T.accent : _T.border,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(steps[i]['icon']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 3),
                  Text(
                    steps[i]['label']!,
                    style: TextStyle(
                      color: isActive ? _T.accent : _T.muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROGRESS DOTS
// ─────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  final int count;
  final int current;
  final ValueChanged<int> onTap;

  const _ProgressDots(
      {required this.count, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == current ? _T.accent : _T.border,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final SettlementMember member;
  final double size;

  const _Avatar({required this.member, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: member.color.withOpacity(0.15),
        border: Border.all(color: member.color.withOpacity(0.4), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        member.initials,
        style: TextStyle(
          color: member.color,
          fontSize: size * 0.3,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final String label;
  const _StepBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
          color: _T.accent, borderRadius: BorderRadius.circular(14)),
      alignment: Alignment.center,
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  final Color color;
  const _ArrowIcon({this.color = _T.muted});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_forward_rounded, color: color, size: 18);
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NextButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _T.bgCard,
          border: Border.all(color: _T.border),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: const TextStyle(
                color: _T.text, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _T.bgCard2,
        border: Border.all(color: _T.border, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text.rich(
        TextSpan(text: text),
        style: const TextStyle(color: _T.muted, fontSize: 12, height: 1.6),
      ),
    );
  }
}

Widget _sectionCard({required Widget header, required Widget body}) {
  return Container(
    decoration: BoxDecoration(
      color: _T.bgCard,
      border: Border.all(color: _T.border),
      borderRadius: BorderRadius.circular(16),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(children: [header, body]),
  );
}

Widget _cardHeader({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _T.border))),
    child: child,
  );
}

// ─────────────────────────────────────────────────────────────
// STEP 0 — NET BALANCES
// ─────────────────────────────────────────────────────────────

class _Step0NetBalances extends StatelessWidget {
  final SettlementBreakdownData data;
  final VoidCallback onNext;

  const _Step0NetBalances({required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sectionCard(
          header: _cardHeader(
            child: const Row(children: [
              _StepBadge(label: '1'),
              SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Calculate Net Balances',
                    style: TextStyle(
                        color: _T.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('Total paid − Total owed across all expenses',
                    style: TextStyle(color: _T.muted, fontSize: 12)),
              ]),
            ]),
          ),
          body: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                ...data.netBalances.map((b) => _BalanceRow(balance: b)),
                const SizedBox(height: 6),
                _InfoBox(
                  text:
                      '💡 Only ${data.netBalances.firstWhere((b) => !b.isCreditor).member.name} has a negative balance — they\'re the only one who owes money.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _NextButton(label: 'Next: See who owes who directly →', onTap: onNext),
      ],
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final NetBalance balance;
  const _BalanceRow({required this.balance});

  @override
  Widget build(BuildContext context) {
    final color = balance.isCreditor ? _T.green : _T.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        border: Border.all(color: color.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        _Avatar(member: balance.member),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(balance.member.name,
                style: const TextStyle(
                    color: _T.text, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              balance.isCreditor ? 'Is owed by others' : 'Owes others',
              style: const TextStyle(color: _T.muted, fontSize: 12),
            ),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '${balance.isCreditor ? '+' : ''}\$${balance.net.abs().toStringAsFixed(2)}',
            style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace'),
          ),
          const SizedBox(height: 4),
          _Tag(label: balance.isCreditor ? 'creditor' : 'debtor', color: color),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 1 — PAIRWISE
// ─────────────────────────────────────────────────────────────

class _Step1Pairwise extends StatelessWidget {
  final SettlementBreakdownData data;
  final VoidCallback onNext;

  const _Step1Pairwise({required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sectionCard(
          header: _cardHeader(
            child: const Row(children: [
              _StepBadge(label: '2'),
              SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Direct Pairwise Debts',
                    style: TextStyle(
                        color: _T.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('How much each pair owes each other directly',
                    style: TextStyle(color: _T.muted, fontSize: 12)),
              ]),
            ]),
          ),
          body: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                ...data.pairwise.map((p) => _PairwiseCard(debt: p)),
                const SizedBox(height: 6),
                _InfoBox(
                  text:
                      '💡 This would need ${data.beforeCount} separate payments. We can simplify!',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _NextButton(label: 'Next: See the simplification →', onTap: onNext),
      ],
    );
  }
}

class _PairwiseCard extends StatelessWidget {
  final PairwiseDebt debt;
  const _PairwiseCard({required this.debt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _T.bgCard2,
        border: Border.all(color: _T.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Avatar(member: debt.from, size: 32),
          const SizedBox(width: 8),
          const _ArrowIcon(color: _T.red),
          const SizedBox(width: 8),
          _Avatar(member: debt.to, size: 32),
          const Spacer(),
          Text(
            '\$${debt.amount.toStringAsFixed(2)}',
            style: const TextStyle(
                color: _T.red,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace'),
          ),
        ]),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 12, color: _T.muted, height: 1.5),
            children: [
              TextSpan(
                  text: debt.from.name,
                  style: TextStyle(
                      color: debt.from.color, fontWeight: FontWeight.w600)),
              const TextSpan(text: ' owes '),
              TextSpan(
                  text: debt.to.name,
                  style: TextStyle(
                      color: debt.to.color, fontWeight: FontWeight.w600)),
              TextSpan(text: ' — ${debt.reason}'),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 2 — SIMPLIFIED
// ─────────────────────────────────────────────────────────────

class _Step2Simplified extends StatelessWidget {
  final SettlementBreakdownData data;
  final VoidCallback onNext;

  const _Step2Simplified({required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sectionCard(
          header: _cardHeader(
            child: const Row(children: [
              _StepBadge(label: '3'),
              SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Simplify Debts',
                    style: TextStyle(
                        color: _T.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('Reduce to fewest possible transactions',
                    style: TextStyle(color: _T.muted, fontSize: 12)),
              ]),
            ]),
          ),
          body: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // BEFORE
              Text('BEFORE (${data.beforeCount} transactions)',
                  style: const TextStyle(
                      color: _T.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              ...data.pairwise.map((p) => Opacity(
                    opacity: 0.6,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _T.red.withOpacity(0.08),
                        border: Border.all(color: _T.red.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        Text(p.from.name,
                            style: TextStyle(
                                color: p.from.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        const _ArrowIcon(color: _T.red),
                        const SizedBox(width: 6),
                        Text(p.to.name,
                            style: TextStyle(
                                color: p.to.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('\$${p.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: _T.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  )),
              const SizedBox(height: 12),

              // Simplify badge
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _T.green.withOpacity(0.1),
                    border: Border.all(color: _T.green.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('✨', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Only ${data.netBalances.firstWhere((b) => !b.isCreditor).member.name} owes — routing everything through them',
                        style: const TextStyle(
                            color: _T.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 12),

              // AFTER
              Text('AFTER (${data.afterCount} transactions)',
                  style: const TextStyle(
                      color: _T.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              ...data.simplified.map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _T.green.withOpacity(0.1),
                      border: Border.all(color: _T.green.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      _Avatar(member: s.from, size: 30),
                      const SizedBox(width: 8),
                      const _ArrowIcon(color: _T.green),
                      const SizedBox(width: 8),
                      _Avatar(member: s.to, size: 30),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${s.from.name} pays ${s.to.name}',
                            style:
                                const TextStyle(color: _T.muted, fontSize: 12)),
                      ),
                      Text('\$${s.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: _T.green,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace')),
                    ]),
                  )),
              const SizedBox(height: 6),
              const _InfoBox(
                  text:
                      '💡 The debtor pays the largest creditor first. Any remaining amount flows to the next creditor, minimising total transactions for everyone.'),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        _NextButton(label: 'See final result ✅', onTap: onNext),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP 3 — RESULT
// ─────────────────────────────────────────────────────────────

class _Step3Result extends StatelessWidget {
  final SettlementBreakdownData data;
  final VoidCallback onRestart;

  const _Step3Result({required this.data, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: _T.bgCard,
            border: Border.all(color: _T.green.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            // Header
            _cardHeader(
              child: Row(children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: _T.green, borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child: const Text('✓',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
                const SizedBox(width: 10),
                const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Final Settlement Plan',
                          style: TextStyle(
                              color: _T.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('Minimum transactions to settle all debts',
                          style: TextStyle(color: _T.muted, fontSize: 12)),
                    ]),
              ]),
            ),

            // Settlement cards
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                ...List.generate(data.simplified.length, (i) {
                  final s = data.simplified[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _T.green.withOpacity(0.08),
                      border: Border.all(color: _T.green.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(children: [
                      Row(children: [
                        _Avatar(member: s.from, size: 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(s.from.name,
                                      style: const TextStyle(
                                          color: _T.text,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 6),
                                  const _ArrowIcon(color: _T.green),
                                  const SizedBox(width: 6),
                                  Text(s.to.name,
                                      style: const TextStyle(
                                          color: _T.text,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                ]),
                                Text('Settlement #${i + 1}',
                                    style: const TextStyle(
                                        color: _T.muted, fontSize: 12)),
                              ]),
                        ),
                        _Avatar(member: s.to, size: 40),
                      ]),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _T.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '\$${s.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: _T.green,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace'),
                        ),
                      ),
                    ]),
                  );
                }),

                // Summary row
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _T.accent.withOpacity(0.1),
                    border: Border.all(color: _T.accent.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('All debts settled with',
                                style: TextStyle(
                                    color: _T.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            Text(
                                'vs ${data.beforeCount} without simplification',
                                style: const TextStyle(
                                    color: _T.muted, fontSize: 12)),
                          ]),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: _T.accent,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w800,
                            fontSize: 28),
                        children: [
                          TextSpan(text: '${data.afterCount}'),
                          const TextSpan(
                              text: ' txns', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onRestart,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _T.bgCard,
              border: Border.all(color: _T.border),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text('↩ Start over',
                style: TextStyle(
                    color: _T.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// USAGE
// ─────────────────────────────────────────────────────────────
//
// In balances_view.dart, inside your settlements section:
//
//   GestureDetector(
//     onTap: () {
//       final data = SettlementBreakdownData.fromBalancesModel(
//         groupCtrl.groupBalances.value,
//         myId,
//       );
//       showSettlementBreakdown(context, data);
//     },
//     child: ...,
//   )
