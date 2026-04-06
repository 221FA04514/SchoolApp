import 'dart:io';

void resolveFile(String filepath) {
  try {
    final file = File(filepath);
    if (!file.existsSync()) {
      print('File not found: $filepath');
      return;
    }

    final lines = file.readAsLinesSync();
    final newLines = <String>[];

    bool inConflict = false;
    bool inHead = false;
    bool inIncoming = false;
    bool resolvedAny = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('<<<<<<< HEAD')) {
        inConflict = true;
        inHead = true;
        inIncoming = false;
        resolvedAny = true;
        continue;
      }

      if (trimmed.startsWith('=======')) {
        inHead = false;
        inIncoming = true;
        continue;
      }

      if (trimmed.startsWith('>>>>>>>')) {
        inConflict = false;
        inHead = false;
        inIncoming = false;
        continue;
      }

      if (inConflict) {
        if (inHead) {
          newLines.add(line);
        } else if (inIncoming) {
          // Discard incoming
        }
      } else {
        newLines.add(line);
      }
    }

    if (resolvedAny) {
      print('Resolving conflicts in: $filepath');
      file.writeAsStringSync(newLines.join('\n') + '\n');
    } else {
      print('No conflicts found in: $filepath');
    }
  } catch (e) {
    print('Error processing $filepath: $e');
  }
}

void main() {
  final files = [
    r'c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\admin\manage_teachers.dart',
    r'c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\admin\manage_students.dart',
    r'c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\admin\manage_sections.dart',
    r'c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\admin\manage_period_settings.dart',
    r'c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\resources\resource_library_screen.dart',
    r'c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\announcements\teacher_announcements_screen.dart',
    r'c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\announcements\teacher_create_announcement_screen.dart',
    r'c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\attendance\attendance_summary_card.dart',
    r'c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\attendance\attendance_screen.dart',
    r'c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\ai\teacher_homework_gen_screen.dart',
    r'c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\admin\manage_substitutions.dart',
  ];

  for (final f in files) {
    resolveFile(f);
  }
}
