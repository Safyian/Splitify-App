// lib/features/expenses/charts_view.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splitify/core/constants/constants.dart';
import 'package:splitify/core/theme/app_themes.dart';

import '../groups/groups_controller.dart';
import '../profile/profile_controller.dart';
import 'chart_helpers.dart';

class ChartsView extends StatefulWidget {
  const ChartsView({super.key, required this.index});
  final int index;

  @override
  State<ChartsView> createState() => _ChartsViewState();
}

class _ChartsViewState extends State<ChartsView> {
  final groupCtrl = Get.find<GroupsController>();
  bool _showMonthly = true; // ← toggle state

  static const _colors = [
    Color(0xFF00C9A7),
    Color(0xFF4D96FF),
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFFA29BFE),
    Color(0xFFFF9F43),
  ];

  static Color _colorAt(int i) => _colors[i % _colors.length];

  @override
  Widget build(BuildContext context) {
    final expenses = groupCtrl.groupExpenses.value.expenses ?? [];
    final memberData = ChartHelpers.spendingByMember(expenses);
    final monthlyData = ChartHelpers.spendingByMonth(expenses);
    final weeklyData = ChartHelpers.spendingByWeek(expenses);
    final totalSpend = expenses
        .where((e) => e.description != "Settlement")
        .fold(0.0, (sum, e) => sum + (e.amount ?? 0));

    // At the top of build() alongside other data fetches
    final profileCtrl = Get.find<ProfileController>();
    final myId = profileCtrl.user.value.user?.id ?? '';
    final myShare = ChartHelpers.myShareData(expenses, myId);

    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        title: Text("Charts", style: AppTheme.headingText),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryCard(
              totalSpend: totalSpend,
              expenseCount:
                  expenses.where((e) => e.description != "Settlement").length,
            ),
            const SizedBox(height: 24),

            // ── Donut ────────────────────────────────────────
            const _SectionTitle(title: "Spending by Member"),
            const SizedBox(height: 12),
            memberData.isEmpty
                ? const _EmptyChart(message: "No expense data yet")
                : _DonutChart(data: memberData, colors: _colors),
            const SizedBox(height: 32),

            // ── Bar with toggle ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle(
                  title: _showMonthly ? "Monthly Spending" : "Weekly Spending",
                ),
                // ── Toggle switch ──
                Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: Constants.bgColorLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ToggleTab(
                        label: "Monthly",
                        isSelected: _showMonthly,
                        onTap: () => setState(() => _showMonthly = true),
                      ),
                      _ToggleTab(
                        label: "Weekly",
                        isSelected: !_showMonthly,
                        onTap: () => setState(() => _showMonthly = false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Animated chart swap ───────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: _showMonthly
                  ? (monthlyData.isEmpty
                      ? const _EmptyChart(
                          key: ValueKey('empty_monthly'),
                          message: "No monthly data yet",
                        )
                      : _BarChart(
                          key: const ValueKey('monthly'),
                          data: monthlyData
                              .map((e) =>
                                  _BarEntry(label: e.month, amount: e.amount))
                              .toList(),
                        ))
                  : (weeklyData.isEmpty
                      ? const _EmptyChart(
                          key: ValueKey('empty_weekly'),
                          message: "No weekly data yet",
                        )
                      : _BarChart(
                          key: const ValueKey('weekly'),
                          data: weeklyData
                              .map((e) =>
                                  _BarEntry(label: e.label, amount: e.amount))
                              .toList(),
                        )),
            ),

            // Add after the bar chart section
            const SizedBox(height: 32),
            const _SectionTitle(title: "My Share vs Others"),
            const SizedBox(height: 12),
            (myShare.iPaid == 0 && myShare.iOwe == 0)
                ? const _EmptyChart(message: "No personal data yet")
                : _MyShareChart(data: myShare),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Summary Card ───────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalSpend, required this.expenseCount});
  final double totalSpend;
  final int expenseCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: "Total Spent",
            value: "\$${totalSpend.toStringAsFixed(2)}",
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _StatItem(
            label: "Expenses",
            value: "$expenseCount",
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.headingText),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.normalText),
      ],
    );
  }
}

// ── Donut Chart ────────────────────────────────────────────────────────────────
class _DonutChart extends StatefulWidget {
  const _DonutChart({required this.data, required this.colors});
  final List<MemberSpending> data;
  final List<Color> colors;

  @override
  State<_DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<_DonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.data.fold(0.0, (s, e) => s + e.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220.h,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex = (event.isInterestedForInteractions &&
                              response?.touchedSection != null)
                          ? response!.touchedSection!.touchedSectionIndex
                          : -1;
                    });
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 55,
                sections: widget.data.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final isTouched = i == _touchedIndex;
                  final pct = (item.amount / total * 100).toStringAsFixed(1);

                  return PieChartSectionData(
                    color: widget.colors[i % widget.colors.length],
                    value: item.amount,
                    title: isTouched
                        ? "\$${item.amount.toStringAsFixed(0)}"
                        : "$pct%",
                    radius: isTouched ? 60 : 50,
                    titleStyle: GoogleFonts.inter(
                      fontSize: isTouched ? 13 : 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Legend ──
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: widget.data.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.colors[i % widget.colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${item.name}  \$${item.amount.toStringAsFixed(2)}",
                    style: AppTheme.normalText,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Bar Chart ──────────────────────────────────────────────────────────────────
class _BarChart extends StatelessWidget {
  const _BarChart({super.key, required this.data});
  final List<_BarEntry> data; // ← changed from MonthlySpending

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 220.h,
        child: BarChart(
          BarChartData(
            maxY: maxY * 1.2,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                    BarTooltipItem(
                  "\$${rod.toY.toStringAsFixed(0)}",
                  GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) => Text(
                    "\$${value.toInt()}",
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= data.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        data[i].label,
                        style:
                            GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.amount,
                    color: Constants.activeColor,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Constants.activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) =>
      Text(title, style: AppTheme.subHeadingText);
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(message, style: AppTheme.normalText),
    );
  }
}

//
class _BarEntry {
  final String label;
  final double amount;
  _BarEntry({required this.label, required this.amount});
}

//
class _MyShareChart extends StatefulWidget {
  const _MyShareChart({required this.data});
  final MyShareData data;

  @override
  State<_MyShareChart> createState() => _MyShareChartState();
}

class _MyShareChartState extends State<_MyShareChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.data.iPaid + widget.data.iOwe;
    final hasData = total > 0;

    // Slices: [I paid for others, I owe others]
    final slices = [
      _SliceData(
        label: "I paid for others",
        amount: widget.data.iPaid,
        color: const Color(0xFF00C9A7), // green — positive
      ),
      _SliceData(
        label: "I owe others",
        amount: widget.data.iOwe,
        color: const Color(0xFFFF6B6B), // red — negative
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // ── Center label on touch ──────────────────────────
          SizedBox(
            height: 220.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          _touchedIndex = (event.isInterestedForInteractions &&
                                  response?.touchedSection != null)
                              ? response!.touchedSection!.touchedSectionIndex
                              : -1;
                        });
                      },
                    ),
                    sectionsSpace: 3,
                    centerSpaceRadius: 60,
                    sections: slices.asMap().entries.map((entry) {
                      final i = entry.key;
                      final slice = entry.value;
                      final isTouched = i == _touchedIndex;
                      final pct = hasData
                          ? (slice.amount / total * 100).toStringAsFixed(1)
                          : '0';

                      return PieChartSectionData(
                        color: slice.color,
                        value: slice.amount == 0 ? 0.001 : slice.amount,
                        title: "$pct%",
                        radius: isTouched ? 62 : 52,
                        titleStyle: GoogleFonts.inter(
                          fontSize: isTouched ? 13 : 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // ── Center text: net balance ──────────────────
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _touchedIndex == -1
                          ? "Net"
                          : slices[_touchedIndex].label.split(" ").first,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      _touchedIndex == -1
                          ? _netText(widget.data)
                          : "\$${slices[_touchedIndex].amount.toStringAsFixed(2)}",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _touchedIndex == -1
                            ? _netColor(widget.data)
                            : slices[_touchedIndex].color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Legend with amounts ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: slices.map((slice) {
              return Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: slice.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(slice.label, style: AppTheme.normalText),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${slice.amount.toStringAsFixed(2)}",
                    style: AppTheme.subHeadingText.copyWith(color: slice.color),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _netText(MyShareData data) {
    final net = data.iPaid - data.iOwe;
    if (net == 0) return "Settled";
    return net > 0
        ? "+\$${net.toStringAsFixed(2)}"
        : "-\$${net.abs().toStringAsFixed(2)}";
  }

  Color _netColor(MyShareData data) {
    final net = data.iPaid - data.iOwe;
    if (net == 0) return Colors.grey;
    return net > 0 ? const Color(0xFF00C9A7) : const Color(0xFFFF6B6B);
  }
}

// ── Simple slice model ─────────────────────────────────────────────────────────
class _SliceData {
  final String label;
  final double amount;
  final Color color;

  _SliceData({
    required this.label,
    required this.amount,
    required this.color,
  });
}
