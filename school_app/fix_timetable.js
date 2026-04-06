const fs = require('fs');
let code = fs.readFileSync('lib/screens/admin/manage_timetable.dart', 'utf-8');

// 1. Update primary color to the correct deep purple
code = code.replace(/final Color primaryColor = const Color\(0xFF673AB7\);/, 'final Color primaryColor = const Color(0xFF673AB7);');

// 2. Update _buildSliverAppBar to higher height and custom clipper
const oldSliver = /Widget _buildSliverAppBar\(\) \{[\s\S]*?return SliverAppBar\([\s\S]*?expandedHeight.*?120,[\s\S]*?flexibleSpace: FlexibleSpaceBar\([\s\S]*?background: Stack\([\s\S]*?children: \[[\s\S]*?Container\([\s\S]*?decoration: const BoxDecoration\([\s\S]*?gradient: LinearGradient\([\s\S]*?colors: \[Color\(0xFF1A4DFF\), Color\(0xFF0031D1\)\],[\s\S]*?\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?Positioned\([\s\S]*?child: CircleAvatar\([\s\S]*?backgroundColor: Colors\.white\.withOpacity\(0\.05\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),[\s\S]*?\),[\s\S]*?\);[\s\S]*?\}/m;

const newSliver = `Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: const Text(
          "Timetable Studio",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -50, top: -50,
              child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.05)),
            ),
          ],
        ),
      ),
    );
  }`;

code = code.replace(oldSliver, newSliver);

// 3. Update _buildSectionHub for better pills
const oldSectionHub = /Widget _buildSectionHub\(\) \{[\s\S]*?return SliverToBoxAdapter\([\s\S]*?height: 60,[\s\S]*?itemBuilder: \(context, index\) \{[\s\S]*?final isSelected = s\["id"\] == selectedSectionId;[\s\S]*?return GestureDetector\([\s\S]*?duration: const Duration\(milliseconds: 200\),[\s\S]*?color: isSelected \? const Color\(0xFF1A4DFF\) : Colors\.white,[\s\S]*?child: Center\([\s\S]*?child: Text\([\s\S]*?color: isSelected \? Colors\.white : Colors\.grey\.shade700,[\s\S]*?\),[\s\S]*?\),[\s\S]*?\);[\s\S]*?\},[\s\S]*?\),[\s\S]*?\);[\s\S]*?\}/m;

const newSectionHub = `Widget _buildSectionHub() {
    if (sections.isEmpty && !isLoadingInit) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Icon(Icons.folder_open_rounded, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text("Classes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal,
              itemCount: sections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final s = sections[index];
                final isSelected = s["id"] == selectedSectionId;
                return GestureDetector(
                  onTap: () { setState(() => selectedSectionId = s["id"]); fetchTimetable(s["id"]); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF673AB7) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
                      boxShadow: [if (isSelected) BoxShadow(color: const Color(0xFF673AB7).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: Text(s["name"], style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade700, fontSize: 15)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }`;

code = code.replace(oldSectionHub, newSectionHub);

// 4. Update the actual timetable list to the grid/table design
const oldTimetableList = /Widget _buildTimetableList\(\) \{[\s\S]*?return SliverList\([\s\S]*?ExpansionTile\([\s\S]*?children: \[[\s\S]*?\][\s\S]*?\);[\s\S]*?\}, childCount: days\.length\);[\s\S]*?\}/m;

const newTimetableList = `Widget _buildTimetableList() {
    if (selectedSectionId == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1))),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Container(
                decoration: const BoxDecoration(color: Color(0xFF673AB7), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                child: Row(
                  children: [
                    _buildHeaderCell("Time Hub ⏱", width: 100),
                    ...days.map((d) => _buildHeaderCell(d, width: 140)),
                  ],
                ),
              ),
              // Body Rows
              ...periodSettings.map((p) {
                final pNum = p["period_number"] as int;
                return Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1)))),
                  child: Row(
                    children: [
                      // Time/Period Column
                      Container(
                        width: 100, height: 110,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.1)))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(radius: 14, backgroundColor: const Color(0xFF673AB7), child: Text("$pNum", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                            const SizedBox(height: 8),
                            Text("\${p["start_time"]}-\${p["end_time"]}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                      ),
                      // Day Columns
                      ...days.map((d) {
                        final slot = timetable.firstWhere((t) => t["day"] == d && t["period"] == pNum, orElse: () => null);
                        return _buildSlotCell(d, pNum, slot);
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label, {double width = 100}) {
    return Container(
      width: width, padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  Widget _buildSlotCell(String day, int period, Map? slot) {
    if (slot == null) {
      return Container(
        width: 140, height: 110,
        decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.1)))),
        child: Center(
          child: IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: Colors.grey.withOpacity(0.3), size: 32),
            onPressed: () => _showAddSlotDialog(period: period, day: day),
          ),
        ),
      );
    }
    
    // Icon logic based on subject
    IconData subIcon = Icons.subject_rounded;
    Color subColor = const Color(0xFF673AB7);
    final sub = slot["subject"].toString().toLowerCase();
    if (sub.contains("sci")) { subIcon = Icons.science_outlined; subColor = Colors.teal; }
    else if (sub.contains("math")) { subIcon = Icons.calculate_outlined; subColor = Colors.orange; }
    else if (sub.contains("comp") || sub.contains("py") || sub.contains("c ")) { subIcon = Icons.computer_rounded; subColor = Colors.blueGrey; }
    else if (sub.contains("eng")) { subIcon = Icons.translate_rounded; subColor = Colors.indigo; }

    return InkWell(
      onTap: () => _showAddSlotDialog(period: period, day: day),
      child: Container(
        width: 140, height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.1)))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(subIcon, size: 18, color: subColor),
                const SizedBox(width: 8),
                Expanded(child: Text(slot["subject"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: subColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(slot["teacher_name"], style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
      ),
    );
  }`;

code = code.replace(oldTimetableList, newTimetableList);

// 5. Update FAB and dialog colors
code = code.replace(/backgroundColor: const Color\(0xFF1A4DFF\),/g, 'backgroundColor: const Color(0xFF673AB7),');

// 6. Add Header Clipper and helpers
if (!code.includes('class _HeaderClipper')) {
    code += `
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height + 40, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
`;
}

fs.writeFileSync('lib/screens/admin/manage_timetable.dart', code);
