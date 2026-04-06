import os
import glob

def resolve_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        new_lines = []
        in_conflict = False
        in_head = False
        in_incoming = False
        resolved_any = False

        for line in lines:
            if line.strip().startswith('<<<<<<< HEAD'):
                in_conflict = True
                in_head = True
                in_incoming = False
                resolved_any = True
                continue
            
            if line.strip().startswith('======='):
                in_head = False
                in_incoming = True
                continue
            
            if line.strip().startswith('>>>>>>>'):
                in_conflict = False
                in_head = False
                in_incoming = False
                continue

            if in_conflict:
                if in_head:
                    new_lines.append(line)
                elif in_incoming:
                    pass # Discard incoming
            else:
                new_lines.append(line)
        
        if resolved_any:
            print(f"Resolving conflicts in: {filepath}")
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
        else:
            print(f"No conflicts found in: {filepath}")

    except Exception as e:
        print(f"Error processing {filepath}: {e}")

# List of files to process
files = [
    r"c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\admin\manage_teachers.dart",
    r"c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\admin\manage_students.dart",
    r"c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\admin\manage_sections.dart",
    r"c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\admin\manage_period_settings.dart",
    r"c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\resources\resource_library_screen.dart",
    r"c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\announcements\teacher_announcements_screen.dart",
    r"c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\announcements\teacher_create_announcement_screen.dart",
    r"c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\attendance\attendance_summary_card.dart",
    r"c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\attendance\attendance_screen.dart",
    r"c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\ai\teacher_homework_gen_screen.dart",
    r"c:\Users\Admin\Desktop\school1\SchoolApp\school_app\lib\screens\admin\manage_substitutions.dart"
]

for f in files:
    if os.path.exists(f):
        resolve_file(f)
    else:
        print(f"File not found: {f}")
