const fs = require('fs');
const path = require('path');
const adminDir = 'lib/screens/admin';
const fixList = [
    { file: 'manage_sections.dart', title: 'Sections Hub 📁' },
    { file: 'manage_period_settings.dart', title: 'Time Management' },
    { file: 'manage_mappings.dart', title: 'Mapping Center' },
    { file: 'manage_substitutions.dart', title: 'Substitution Hub' },
    { file: 'notification_center.dart', title: 'Notify Hub' }
];

fixList.forEach(item => {
    const filePath = path.join(adminDir, item.file);
    if (!fs.existsSync(filePath)) return;

    let code = fs.readFileSync(filePath, 'utf-8');

    // Extreme cleanup: remove everything from the first occurrence of _buildSliverAppBar
    // to the start of the next known method, and replace it with a clean one.
    // Known next methods vary:
    let nextMethod = '';
    if (item.file === 'manage_sections.dart') nextMethod = 'Widget _buildSectionList() {';
    if (item.file === 'manage_period_settings.dart') nextMethod = 'Widget _buildPeriodList() {';
    if (item.file === 'manage_mappings.dart') nextMethod = 'Widget _buildMappingList() {';
    if (item.file === 'manage_substitutions.dart') nextMethod = 'Widget _buildSubstitutionList() {';
    if (item.file === 'notification_center.dart') nextMethod = 'Widget _buildSectionHeader(';

    if (!nextMethod) return;

    const parts = code.split('Widget _buildSliverAppBar() {');
    const head = parts[0];
    const tailParts = code.split(nextMethod);
    const tail = tailParts[1];

    const cleanAppBar = `Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF673AB7),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          "${item.title}",
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
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
              right: -30,
              top: -30,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  `;

    code = head + cleanAppBar + nextMethod + tail;

    // Also cleanup _HeaderClipper duplicates at the very end
    if (code.match(/class _HeaderClipper/g).length > 1) {
        const clipperParts = code.split('class _HeaderClipper');
        code = clipperParts[0] + `class _HeaderClipper extends CustomClipper<Path> {
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

    fs.writeFileSync(filePath, code);
    console.log(`Cleaned up ${item.file}`);
});
