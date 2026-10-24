import 'package:flutter/material.dart';

import 'college_data.dart';
import 'map_viewer_screen.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

class StartNavigationScreen extends StatefulWidget {
  const StartNavigationScreen({super.key});

  @override
  State<StartNavigationScreen> createState() => _StartNavigationScreenState();
}

class _StartNavigationScreenState extends State<StartNavigationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  College? _selectedCollege;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<College> get _destinations {
    final unique = <String, College>{};
    for (final college in colleges) {
      unique.putIfAbsent(college.nameAr, () => college);
    }

    final query = _query.trim().toLowerCase();
    return unique.values.where((college) {
      return query.isEmpty ||
          college.nameAr.toLowerCase().contains(query) ||
          college.nameEn.toLowerCase().contains(query) ||
          college.building.toString() == query;
    }).toList();
  }

  void _startNavigation() {
    final destination = _selectedCollege;
    if (destination == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapViewerScreen(
          destination: destination.nameAr,
          buildingNumber: destination.building,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF01181E)
        : const Color(0xFFF2FFFB);
    final surface = isDark ? const Color(0xFF042A33) : Colors.white;
    final titleColor = isDark ? _aquaFoam : _cyberTeal;
    final secondaryColor = isDark
        ? _aquaFoam.withAlpha(175)
        : const Color(0xFF568187);
    final borderColor = isDark
        ? _aquaFoam.withAlpha(45)
        : const Color(0xFFD7F4EC);
    final destinations = _destinations;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 8, 20, 26),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [_cyberTeal, Color(0xFF0A6475)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'رجوع',
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: _aquaFoam,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ابدأ الملاحة',
                          style: TextStyle(
                            color: _aquaFoam,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'إلى أين تريد الذهاب؟',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'اختر وجهتك داخل جامعة مؤتة',
                      style: TextStyle(
                        color: _aquaFoam.withAlpha(220),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      textDirection: TextDirection.rtl,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) => setState(() {
                        _query = value;
                        if (_selectedCollege != null &&
                            !_destinations.contains(_selectedCollege)) {
                          _selectedCollege = null;
                        }
                      }),
                      style: TextStyle(color: titleColor),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن كلية أو مبنى...',
                        hintStyle: TextStyle(color: secondaryColor),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: secondaryColor,
                        ),
                        filled: true,
                        fillColor: surface,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 23, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.place_outlined, color: titleColor, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'الوجهات المتاحة',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${destinations.length} وجهة',
                      style: TextStyle(color: secondaryColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: destinations.isEmpty
                    ? Center(
                        child: Text(
                          'ما لقينا وجهة بهذا الاسم',
                          style: TextStyle(color: secondaryColor),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        itemCount: destinations.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final college = destinations[index];
                          final isSelected = college == _selectedCollege;
                          return Material(
                            color: surface,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () =>
                                  setState(() => _selectedCollege = college),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? titleColor
                                        : borderColor,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? _aquaFoam.withAlpha(24)
                                            : const Color(0xFFE7FBF5),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        college.icon,
                                        color: titleColor,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            college.nameAr,
                                            style: TextStyle(
                                              color: titleColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            college.building == 0
                                                ? 'مبنى غير محدد • جامعة مؤتة'
                                                : 'مبنى ${college.building} • جامعة مؤتة',
                                            style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.chevron_left_rounded,
                                      color: isSelected
                                          ? titleColor
                                          : secondaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: surface,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed:
                    _selectedCollege == null || _selectedCollege!.building == 0
                    ? null
                    : _startNavigation,
                icon: const Icon(Icons.navigation_rounded),
                label: Text(
                  _selectedCollege == null
                      ? 'اختر وجهتك أولاً'
                      : _selectedCollege!.building == 0
                      ? 'موقع هذه الكلية غير محدد على الخريطة'
                      : 'ابدأ الملاحة إلى ${_selectedCollege!.nameAr}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _cyberTeal,
                  foregroundColor: _aquaFoam,
                  disabledBackgroundColor: isDark
                      ? const Color(0xFF17424A)
                      : const Color(0xFFDDEBE7),
                  disabledForegroundColor: isDark
                      ? _aquaFoam.withAlpha(120)
                      : Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
