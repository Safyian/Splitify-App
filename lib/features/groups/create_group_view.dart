import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../friends/friends_controller.dart';
import '../friends/friends_model.dart';
import '../groups/groups_controller.dart';
import '../navigation/nav_controller.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen>
    with TickerProviderStateMixin {
  final groupCtrl = Get.find<GroupsController>();
  final friendsCtrl = Get.find<FriendsController>(tag: 'friends');

  final RxInt _step = 1.obs;
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final RxString _selectedEmoji = '🏠'.obs;
  final RxBool _nameError = false.obs;
  final RxSet<String> _selectedFriendIds = <String>{}.obs;
  final RxString _searchQuery = ''.obs;
  final _searchCtrl = TextEditingController();
  final RxBool _isCreating = false.obs;

  late final AnimationController _slideCtrl;
  late final Animation<double> _slideAnim;

  static const _emojis = [
    '🏠',
    '🏖️',
    '✈️',
    '🍕',
    '🎉',
    '💼',
    '🎓',
    '🏋️',
    '🛒',
    '🎮',
    '🚗',
    '🏕️',
    '🎵',
    '💰',
    '🌍',
    '🐾',
    '🍻',
    '❤️',
    '🏡',
    '📦',
    '🎁',
    '🤝',
    '🌴',
    '⚽',
  ];

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slideAnim =
        CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    _searchCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  List<Friend> get _filteredFriends {
    final q = _searchQuery.value.toLowerCase();
    return friendsCtrl.friends
        .where((f) =>
            q.isEmpty ||
            f.name.toLowerCase().contains(q) ||
            f.email.toLowerCase().contains(q))
        .toList();
  }

  void _nextStep() {
    if (_nameCtrl.text.trim().isEmpty) {
      _nameError.value = true;
      HapticFeedback.lightImpact();
      return;
    }
    _nameError.value = false;
    FocusScope.of(context).unfocus();
    _step.value = 2;
    _slideCtrl.forward(from: 0);
  }

  Future<void> _createGroup() async {
    HapticFeedback.mediumImpact();
    _isCreating.value = true;
    final selectedFriends = friendsCtrl.friends
        .where((f) => _selectedFriendIds.contains(f.id))
        .toList();
    await groupCtrl.createGroupWithFriends(
      name: _nameCtrl.text.trim(),
      emoji: _selectedEmoji.value,
      friends: selectedFriends,
    );
    _isCreating.value = false;

    // Clear fields
    _nameCtrl.clear();
    _selectedEmoji.value = '🏠';
    _selectedFriendIds.clear();
    _searchQuery.value = '';
    _searchCtrl.clear();

    // Close screen then switch to Groups tab
    Get.back();
    Get.find<NavigationController>().currentIndex.value = 1;
  }

  void _showEmojiPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F7FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text("Pick an emoji",
                style: AppTheme.subHeadingText.copyWith(fontSize: 15)),
            const SizedBox(height: 16),
            Obx(() => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _emojis.map((e) {
                    final isSel = _selectedEmoji.value == e;
                    return GestureDetector(
                      onTap: () {
                        _selectedEmoji.value = e;
                        HapticFeedback.selectionClick();
                        Get.back();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSel
                              ? Constants.activeColor.withAlpha(22)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel
                                ? Constants.activeColor
                                : Colors.grey.shade200,
                            width: isSel ? 2 : 1,
                          ),
                          boxShadow: isSel
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(8),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        alignment: Alignment.center,
                        child: Text(e, style: GoogleFonts.inter(fontSize: 26)),
                      ),
                    );
                  }).toList(),
                )),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: Obx(() => _step.value == 1 ? _buildStep1() : _buildStep2()),
    );
  }

  // ── STEP 1 ──────────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.black87, size: 22),
                  onPressed: () => Get.back(),
                ),
                const Spacer(),
                Row(
                  children: [
                    _StepDot(active: true),
                    const SizedBox(width: 6),
                    _StepDot(active: false),
                  ],
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── Hero emoji ──────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _showEmojiPicker,
                      child: Column(
                        children: [
                          Obx(() => AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Container(
                                  key: ValueKey(_selectedEmoji.value),
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: Constants.bgColorLight,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(12),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(_selectedEmoji.value,
                                      style: GoogleFonts.inter(fontSize: 46)),
                                ),
                              )),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 13, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Text("Change emoji",
                                  style: AppTheme.normalText.copyWith(
                                      color: Colors.grey.shade400,
                                      fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Heading ─────────────────────────────────────
                  Text("Name your group",
                      style: AppTheme.headingText.copyWith(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text("You can always change this later",
                      style: AppTheme.normalText
                          .copyWith(color: Colors.grey.shade400, fontSize: 13)),
                  const SizedBox(height: 20),

                  // ── Name input ──────────────────────────────────
                  Obx(() => TextField(
                        controller: _nameCtrl,
                        focusNode: _nameFocus,
                        autofocus: true,
                        style: AppTheme.headingText.copyWith(fontSize: 18),
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) {
                          if (_nameError.value) _nameError.value = false;
                        },
                        decoration: InputDecoration(
                          hintText: "e.g. Bali Trip, Flatmates...",
                          hintStyle: AppTheme.headingText.copyWith(
                              fontSize: 18, color: Colors.grey.shade300),
                          errorText:
                              _nameError.value ? "Please enter a name" : null,
                          filled: true,
                          fillColor: Constants.bgColorLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.15)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: Constants.activeColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Constants.redColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 18),
                        ),
                      )),
                  const SizedBox(height: 48),

                  // ── Quick picks ─────────────────────────────────
                  Text("Quick picks",
                      style: AppTheme.normalText
                          .copyWith(color: Colors.grey.shade400, fontSize: 12)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      "🏠  Flatmates",
                      "✈️  Trip",
                      "🍕  Dinner",
                      "💼  Work",
                      "🎉  Party",
                      "🛒  Groceries",
                    ].map((label) {
                      return GestureDetector(
                        onTap: () {
                          final name = label.split("  ")[1];
                          _nameCtrl.text = name;
                          _nameError.value = false;
                          HapticFeedback.selectionClick();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Constants.bgColorLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.15)),
                          ),
                          child: Text(label,
                              style:
                                  AppTheme.normalText.copyWith(fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // ── CTA ──────────────────────────────────────────────────
          _CTAButton(
            label: "Continue",
            icon: Icons.arrow_forward_rounded,
            onTap: _nextStep,
          ),
        ],
      ),
    );
  }

  // ── STEP 2 ──────────────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return SafeArea(
      child: AnimatedBuilder(
        animation: _slideAnim,
        builder: (context, child) => Transform.translate(
          offset: Offset((1 - _slideAnim.value) * 60, 0),
          child: Opacity(opacity: _slideAnim.value, child: child),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.black87, size: 20),
                    onPressed: () {
                      _step.value = 1;
                      Future.delayed(const Duration(milliseconds: 50),
                          () => _nameFocus.requestFocus());
                    },
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _StepDot(active: false),
                      const SizedBox(width: 6),
                      _StepDot(active: true),
                    ],
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group preview chip
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Constants.activeColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Constants.activeColor.withAlpha(35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_selectedEmoji.value,
                                style: GoogleFonts.inter(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(_nameCtrl.text.trim(),
                                style: AppTheme.normalText.copyWith(
                                  color: Constants.activeColor,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                  Text("Who's joining?",
                      style: AppTheme.headingText.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text("Optional — you can add people later",
                      style: AppTheme.normalText
                          .copyWith(color: Colors.grey.shade400, fontSize: 13)),
                  const SizedBox(height: 16),

                  // ── Search ───────────────────────────────────────
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Constants.bgColorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => _searchQuery.value = v,
                      style: AppTheme.normalText,
                      decoration: InputDecoration(
                        hintText: "Search friends...",
                        hintStyle: AppTheme.normalText
                            .copyWith(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 18, color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Friends list ────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final friends = _filteredFriends;
                if (friends.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 42, color: Colors.grey.shade200),
                        const SizedBox(height: 10),
                        Text("No friends found",
                            style: AppTheme.normalText
                                .copyWith(color: Colors.grey.shade400)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: friends.length,
                  itemBuilder: (context, i) {
                    final friend = friends[i];
                    return Obx(() {
                      final isSel = _selectedFriendIds.contains(friend.id);
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          if (isSel) {
                            _selectedFriendIds.remove(friend.id);
                          } else {
                            _selectedFriendIds.add(friend.id);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSel
                                ? Constants.activeColor.withAlpha(12)
                                : Constants.bgColorLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel
                                  ? Constants.activeColor.withAlpha(70)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? Constants.activeColor
                                      : Constants.activeColor.withAlpha(22),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  friend.name[0].toUpperCase(),
                                  style: GoogleFonts.inter(
                                    color: isSel
                                        ? Colors.white
                                        : Constants.activeColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(friend.name,
                                        style: AppTheme.normalText.copyWith(
                                          fontWeight: FontWeight.w600,
                                        )),
                                    const SizedBox(height: 1),
                                    Text(friend.email,
                                        style: AppTheme.normalText.copyWith(
                                          color: Colors.grey.shade400,
                                          fontSize: 11,
                                        )),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? Constants.activeColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: isSel
                                        ? Constants.activeColor
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: isSel
                                    ? const Icon(Icons.check_rounded,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),

            // ── Selected count strip ────────────────────────────────
            Obx(() {
              final count = _selectedFriendIds.length;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Constants.activeColor.withAlpha(12),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Constants.activeColor.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Constants.activeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text("$count",
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "friend${count > 1 ? 's' : ''} will be added",
                      style: AppTheme.normalText.copyWith(
                          color: Constants.activeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ],
                ),
              );
            }),

            // ── CTA ────────────────────────────────────────────────
            Obx(() => _CTAButton(
                  label: _selectedFriendIds.isEmpty
                      ? "Create Group"
                      : "Create Group & Add ${_selectedFriendIds.length} Friend${_selectedFriendIds.length > 1 ? 's' : ''}",
                  icon: Icons.check_rounded,
                  isLoading: _isCreating.value,
                  onTap: _isCreating.value ? null : _createGroup,
                  sublabel: _selectedFriendIds.isEmpty
                      ? "You can add friends after creating"
                      : null,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Step Dot ───────────────────────────────────────────────────────────────────
class _StepDot extends StatelessWidget {
  const _StepDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 20 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? Constants.activeColor : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ── CTA Button ─────────────────────────────────────────────────────────────────
class _CTAButton extends StatelessWidget {
  const _CTAButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
    this.sublabel,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sublabel != null) ...[
            Text(sublabel!,
                style: AppTheme.normalText
                    .copyWith(color: Colors.grey.shade400, fontSize: 12)),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: onTap == null
                    ? Constants.activeColor.withAlpha(120)
                    : Constants.activeColor,
                foregroundColor: Colors.white,
                elevation: onTap == null ? 0 : 2,
                shadowColor: Constants.activeColor.withAlpha(80),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onTap,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(label,
                            style: AppTheme.subHeadingText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Icon(icon, size: 18, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
