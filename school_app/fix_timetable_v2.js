const fs = require('fs');
let code = fs.readFileSync('lib/screens/admin/manage_timetable.dart', 'utf-8');

const oldMethod = /Widget _buildTimetableList\(\) \{[\s\S]*?\}\s*\}\s*class SlidableSlotCard/m;

const newTimetableLogic = `Widget _buildTimetableList() {
    if (selectedSectionId == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF673AB7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
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
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
                  ),
                  child: Row(
                    children: [
                      // Time/Period Column
                      Container(
                        width: 100,
                        height: 110,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.1))),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color(0xFF673AB7),
                              child: Text("\${pNum}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Text("\${p["start_time"]}-\${p["end_time"]}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                      ),
                      // Day Columns
                      ...days.map((d) {
                        final slot = timetable.firstWhere(
                          (t) => t["day"] == d && t["period"] == pNum,
                          orElse: () => null,
                        );
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
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildSlotCell(String day, int period, Map? slot) {
    if (slot == null) {
      return Container(
        width: 140,
        height: 110,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.1))),
        ),
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
        width: 140,
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.1))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(subIcon, size: 18, color: subColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    slot["subject"],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: subColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    slot["teacher_name"],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SlidableSlotCard`;

code = code.replace(oldMethod, newTimetableLogic);
fs.writeFileSync('lib/screens/admin/manage_timetable.dart', code);
