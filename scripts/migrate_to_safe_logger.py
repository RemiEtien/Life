#!/usr/bin/env python3
"""
Script to migrate debugPrint and print statements to SafeLogger.
Usage: python migrate_to_safe_logger.py <file_path>
"""

import re
import sys
from pathlib import Path

def migrate_file(file_path):
    """Migrate a single Dart file to use SafeLogger"""

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = []

    # Check if SafeLogger is already imported
    has_safe_logger_import = "import '../utils/safe_logger.dart'" in content or \
                             'import "../../utils/safe_logger.dart"' in content or \
                             'import "../../../utils/safe_logger.dart"' in content

    # Pattern 1: if (kDebugMode) { debugPrint('message'); }
    pattern1 = r"if\s*\(kDebugMode\)\s*\{\s*debugPrint\(([^)]+)\);\s*\}"
    matches1 = re.findall(pattern1, content)
    if matches1:
        content = re.sub(pattern1, r"SafeLogger.debug(\1, tag: 'SERVICE_NAME')", content)
        changes.append(f"Replaced {len(matches1)} kDebugMode wrapped debugPrint statements")

    # Pattern 2: if (kDebugMode) debugPrint('message');
    pattern2 = r"if\s*\(kDebugMode\)\s+debugPrint\(([^)]+)\);"
    matches2 = re.findall(pattern2, content)
    if matches2:
        content = re.sub(pattern2, r"SafeLogger.debug(\1, tag: 'SERVICE_NAME');", content)
        changes.append(f"Replaced {len(matches2)} inline kDebugMode debugPrint statements")

    # Pattern 3: Standalone debugPrint (not wrapped in kDebugMode)
    # Be careful not to match already migrated SafeLogger calls
    pattern3 = r"(?<!SafeLogger\.)debugPrint\(([^)]+)\);"
    matches3 = re.findall(pattern3, content)
    if matches3:
        # For standalone debugPrint, use SafeLogger.debug
        content = re.sub(pattern3, r"SafeLogger.debug(\1, tag: 'SERVICE_NAME');", content)
        changes.append(f"Replaced {len(matches3)} standalone debugPrint statements")

    # Pattern 4: print() statements
    pattern4 = r"(?<!Safe)(?<!debug)print\(([^)]+)\);"
    matches4 = re.findall(pattern4, content)
    if matches4:
        content = re.sub(pattern4, r"SafeLogger.debug(\1, tag: 'SERVICE_NAME');", content)
        changes.append(f"Replaced {len(matches4)} print statements")

    # Add SafeLogger import if needed and changes were made
    if changes and not has_safe_logger_import:
        # Determine correct import path depth
        depth = len(Path(file_path).relative_to(Path(file_path).parts[0]).parts) - 2
        prefix = '../' * depth
        safe_logger_import = f"import '{prefix}utils/safe_logger.dart';\n"

        # Insert after last import statement
        import_pattern = r"(import\s+['\"].*?['\"];)"
        imports = re.findall(import_pattern, content)
        if imports:
            last_import = imports[-1]
            content = content.replace(last_import, last_import + '\n' + safe_logger_import)
            changes.append("Added SafeLogger import")

    # Check if kDebugMode can be removed from imports
    if 'kDebugMode' in content:
        # Count remaining usages (excluding imports)
        kDebugMode_usage = len(re.findall(r'\bkDebugMode\b', content))
        import_kDebugMode = len(re.findall(r'import.*kDebugMode', content))

        if kDebugMode_usage == import_kDebugMode:
            # Only in imports, can remove
            content = re.sub(r',?\s*kDebugMode', '', content)
            content = re.sub(r'show\s*,', 'show', content)
            content = re.sub(r'show\s*;', ';', content)
            changes.append("Removed unused kDebugMode import")

    # Write back if changes were made
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True, changes

    return False, []

def main():
    if len(sys.argv) < 2:
        print("Usage: python migrate_to_safe_logger.py <file_path>")
        sys.exit(1)

    file_path = Path(sys.argv[1])

    if not file_path.exists():
        print(f"Error: File {file_path} does not exist")
        sys.exit(1)

    if file_path.suffix != '.dart':
        print(f"Error: {file_path} is not a Dart file")
        sys.exit(1)

    print(f"Migrating {file_path}...")
    modified, changes = migrate_file(file_path)

    if modified:
        print(f"✓ Successfully migrated {file_path}")
        for change in changes:
            print(f"  - {change}")
        print("\n⚠️  IMPORTANT: Please manually update 'SERVICE_NAME' tags with the actual service name!")
    else:
        print(f"No changes needed for {file_path}")

if __name__ == '__main__':
    main()
