import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/api_service.dart';

class ManageSubstitutionsScreen extends StatefulWidget {
  const ManageSubstitutionsScreen({super.key});
  @override
  State<ManageSubstitutionsScreen> createState() => _ManageSubstitutionsScreenState();
}

class _ManageSubstitutionsScreenState extends State<ManageSubstitutionsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;

  // ── State ──────────────────────────────────────────────────────
  List _teachers = [];
  List _activeSubs = [];
  bool _isLoadingTeachers = true;
  bool _isLoadingSubs = true;

  // Find-sub form
  int? _selectedTeacherId;
  String? _selectedTeacherName;
  bool _wholeDayMode = false;

  // Whole-day flow
  List _teacherPeriods = [];
  bool _isLoadingPeriods = false;

  // Single-period flow
  String? _selectedPeriod;
  List _suggestions = [];
  bool _isLoadingSuggestions = false;
  bool _noClassWarning = false;

  final List<String> _periods = ['1','2','3','4','5','6','7','8'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTeachers();
    _loadActiveSubs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Data fetchers ──────────────────────────────────────────────
  Future<void> _loadTeachers() async {
    try {
      final res = await _api.get('/api/v1/admin/teachers');
      if (mounted) setState(() { _teachers = res['data'] ?? []; _isLoadingTeachers = false; });
    } catch (_) { if (mounted) setState(() => _isLoadingTeachers = false); }
  }

  Future<void> _loadActiveSubs() async {
    setState(() => _isLoadingSubs = true);
    try {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final res = await _api.get('/api/v2/admin/substitutions/list?date=$date');
      if (mounted) setState(() { _activeSubs = res['data'] ?? []; _isLoadingSubs = false; });
    } catch (_) { if (mounted) setState(() => _isLoadingSubs = false); }
  }

  Future<void> _deleteSub(dynamic subId, String info) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Substitution', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Remove substitution for $info?\nThe substitute teacher will no longer be assigned.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.delete('/api/v2/admin/substitutions/$subId');
      _snack('Substitution removed', success: true);
      _loadActiveSubs();
    } catch (e) { _snack('Error: $e'); }
  }

  Future<void> _loadTeacherPeriods() async {
    if (_selectedTeacherId == null) return;
    setState(() { _isLoadingPeriods = true; _teacherPeriods = []; });
    try {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final res = await _api.get(
          '/api/v2/admin/substitutions/teacher-timetable?teacher_id=$_selectedTeacherId&date=$date');
      if (mounted) setState(() { _teacherPeriods = res['data'] ?? []; _isLoadingPeriods = false; });
    } catch (_) { if (mounted) setState(() => _isLoadingPeriods = false); }
  }

  Future<void> _findSinglePeriodSubs() async {
    if (_selectedTeacherId == null || _selectedPeriod == null) {
      _snack('Please select a teacher and period');
      return;
    }
    setState(() { _isLoadingSuggestions = true; _noClassWarning = false; _suggestions = []; });

    // 1. Validate timetable
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final day  = DateFormat('EEEE').format(DateTime.now());
    try {
      final ttRes = await _api.get(
          '/api/v2/admin/substitutions/teacher-timetable?teacher_id=$_selectedTeacherId&date=$date');
      final periods = ttRes['data'] as List? ?? [];
      final hasClass = periods.any((p) => p['period'].toString() == _selectedPeriod);
      if (!hasClass) {
        setState(() { _noClassWarning = true; _isLoadingSuggestions = false; });
        return;
      }
    } catch (_) {}

    // 2. Fetch substitutes
    try {
      final res = await _api.get(
          '/api/v2/admin/substitutions/suggestions?day=$day&period=$_selectedPeriod&subject=&date=$date&absent_teacher_id=$_selectedTeacherId');
      if (mounted) setState(() { _suggestions = res['data'] ?? []; _isLoadingSuggestions = false; });
    } catch (e) {
      if (mounted) { setState(() => _isLoadingSuggestions = false); _snack('Error: $e'); }
    }
  }

  Future<void> _assign(int subId, String subName, String period) async {
    try {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _api.post('/api/v2/admin/substitutions/assign', {
        'date': date,
        'period': period,
        'absent_teacher_id': _selectedTeacherId,
        'substitute_teacher_id': subId,
        'remarks': 'Admin Assigned',
      });
      if (mounted) {
        _snack('$subName assigned for Period $period ✓', success: true);
        _loadActiveSubs();
        if (!_wholeDayMode) _tabController.animateTo(1);
      }
    } catch (e) { _snack('Error: $e'); }
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green.shade600 : null,
    ));
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Substitution Manager',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.person_search), text: 'Assign Sub'),
            Tab(icon: Icon(Icons.list_alt), text: 'Active Today'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAssignTab(), _buildActiveTab()],
      ),
    );
  }

  // ── TAB 1: Assign ──────────────────────────────────────────────
  Widget _buildAssignTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTeacherCard(),
          const SizedBox(height: 16),
          if (_selectedTeacherId != null) ...[
            _buildModeToggle(),
            const SizedBox(height: 16),
            if (_wholeDayMode) _buildWholeDaySection()
            else _buildSinglePeriodSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildTeacherCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF673AB7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_off_rounded, color: Color(0xFF673AB7), size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Absent Teacher', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B))),
          ]),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            value: _selectedTeacherId,
            decoration: _inputDecoration('Select teacher', Icons.person_rounded),
            items: _isLoadingTeachers
                ? []
                : _teachers.map<DropdownMenuItem<int>>((t) =>
                    DropdownMenuItem(value: t['id'] as int, child: Text(t['name']))).toList(),
            onChanged: (v) {
              setState(() {
                _selectedTeacherId = v;
                _selectedTeacherName = _teachers.firstWhere((t) => t['id'] == v)['name'];
                _teacherPeriods = [];
                _suggestions = [];
                _noClassWarning = false;
              });
              if (_wholeDayMode) _loadTeacherPeriods();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return _card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Whole Day Absent', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(
                  _wholeDayMode
                      ? 'Shows all periods from timetable'
                      : 'Assign for a specific period only',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _wholeDayMode,
            activeColor: const Color(0xFF673AB7),
            onChanged: (v) {
              setState(() {
                _wholeDayMode = v;
                _suggestions = [];
                _noClassWarning = false;
                _teacherPeriods = [];
              });
              if (v) _loadTeacherPeriods();
            },
          ),
        ],
      ),
    );
  }

  // ── Whole-day section ──────────────────────────────────────────
  Widget _buildWholeDaySection() {
    if (_isLoadingPeriods) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Color(0xFF673AB7))));
    }
    if (_teacherPeriods.isEmpty) {
      return _card(child: const Center(
        child: Padding(padding: EdgeInsets.all(20), child: Text('No classes scheduled today for this teacher.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))));
    }
    return Column(
      children: _teacherPeriods.map<Widget>((p) => _periodCard(p)).toList(),
    );
  }

  Widget _periodCard(Map p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        child: Row(
          children: [
            // Period badge
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF673AB7), Color(0xFF9C27B0)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text('P${p['period']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B))),
                  const SizedBox(height: 3),
                  Text('Class ${p['class_name'] ?? ''}-${p['section_name'] ?? ''}  •  ${p['start_time'] ?? ''}–${p['end_time'] ?? ''}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _showSubstitutesSheet(p['period'].toString()),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7).withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Assign', style: TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Single-period section ──────────────────────────────────────
  Widget _buildSinglePeriodSection() {
    return Column(
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.schedule_rounded, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Select Period', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B))),
              ]),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedPeriod,
                decoration: _inputDecoration('Period', Icons.access_time_rounded),
                items: _periods.map((p) => DropdownMenuItem(value: p, child: Text('Period $p'))).toList(),
                onChanged: (v) => setState(() { _selectedPeriod = v; _noClassWarning = false; _suggestions = []; }),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _findSinglePeriodSubs,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text('Find Substitutes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_noClassWarning)
          _card(
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(child: Text(
                '${_selectedTeacherName ?? 'This teacher'} has no class scheduled at Period $_selectedPeriod today.',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
              )),
            ]),
          ),
        if (_isLoadingSuggestions)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: Color(0xFF673AB7)))),
        if (_suggestions.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Available Substitutes (${_suggestions.length})',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B))),
            ),
          ),
          ..._suggestions.map<Widget>((t) => _suggestionCard(t, _selectedPeriod ?? '1')),
        ],
      ],
    );
  }

  Widget _suggestionCard(Map t, String period) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _card(
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFF3E5F5),
              child: Text(t['name'][0].toUpperCase(),
                  style: const TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(t['subject'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () => _assign(t['id'], t['name'], period),
              child: const Text('Assign', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Substitutes bottom sheet for whole-day mode ────────────────
  void _showSubstitutesSheet(String period) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final day  = DateFormat('EEEE').format(DateTime.now());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubstituteSheet(
        api: _api,
        period: period,
        day: day,
        date: date,
        absentTeacherId: _selectedTeacherId!,
        onAssign: (subId, subName) => _assign(subId, subName, period),
      ),
    );
  }

  // ── TAB 2: Active subs ─────────────────────────────────────────
  Widget _buildActiveTab() {
    if (_isLoadingSubs) return const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)));
    if (_activeSubs.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green.shade300),
          const SizedBox(height: 12),
          const Text('No substitutions assigned today.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadActiveSubs,
      color: const Color(0xFF673AB7),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _activeSubs.length,
        itemBuilder: (_, i) {
          final sub = _activeSubs[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _card(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.sync_alt_rounded, color: Colors.orange.shade400, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Absent: ${sub['original_teacher'] ?? ''}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B))),
                        const SizedBox(height: 3),
                        Text('Sub: ${sub['substitute_teacher'] ?? ''}  •  Period ${sub['period'] ?? ''}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Active', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  // Delete button
                  GestureDetector(
                    onTap: () => _deleteSub(
                      sub['id'],
                      'Period ${sub['period']} — ${sub['substitute_teacher'] ?? ''}',
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: child,
  );

  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: const Color(0xFF673AB7)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF673AB7))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF673AB7))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF673AB7), width: 2)),
  );
}

// ── Substitute picker bottom sheet ─────────────────────────────────
class _SubstituteSheet extends StatefulWidget {
  final ApiService api;
  final String period, day, date;
  final int absentTeacherId;
  final void Function(int id, String name) onAssign;

  const _SubstituteSheet({
    required this.api, required this.period, required this.day,
    required this.date, required this.absentTeacherId, required this.onAssign,
  });

  @override
  State<_SubstituteSheet> createState() => _SubstituteSheetState();
}

class _SubstituteSheetState extends State<_SubstituteSheet> {
  List _suggestions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await widget.api.get(
          '/api/v2/admin/substitutions/suggestions?day=${widget.day}&period=${widget.period}&subject=&date=${widget.date}&absent_teacher_id=${widget.absentTeacherId}');
      if (mounted) setState(() { _suggestions = res['data'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF673AB7).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text('Period ${widget.period}', style: const TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 10),
                const Text('Available Substitutes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ]),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
                  : _suggestions.isEmpty
                      ? const Center(child: Text('No available substitutes for this period.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _suggestions.length,
                          itemBuilder: (_, i) {
                            final t = _suggestions[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F5FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF673AB7).withOpacity(0.1)),
                              ),
                              child: Row(children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(0xFFEDE7F6),
                                  child: Text(t['name'][0].toUpperCase(),
                                      style: const TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.bold, fontSize: 18)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                    Text(t['subject'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                )),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF673AB7),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onAssign(t['id'], t['name']);
                                  },
                                  child: const Text('Assign', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ]),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
