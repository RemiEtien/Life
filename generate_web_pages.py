#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generate HTML pages from markdown legal documents
Converts assets/legal/*.md to public/*.html
"""

import os
import re
import sys
from pathlib import Path

# Force UTF-8 encoding for Windows console
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')
    sys.stderr.reconfigure(encoding='utf-8')

# Directories
ASSETS_DIR = Path("assets/legal")
PUBLIC_DIR = Path("public")

# Language metadata
LANGUAGES = {
    "en": {"name": "English", "flag": "🇬🇧"},
    "ru": {"name": "Русский", "flag": "🇷🇺"},
    "de": {"name": "Deutsch", "flag": "🇩🇪"},
    "es": {"name": "Español", "flag": "🇪🇸"},
    "fr": {"name": "Français", "flag": "🇫🇷"},
    "pt": {"name": "Português", "flag": "🇵🇹"},
    "zh": {"name": "中文", "flag": "🇨🇳"},
    "ar": {"name": "العربية", "flag": "🇸🇦"},
    "he": {"name": "עברית", "flag": "🇮🇱"}
}

HTML_TEMPLATE = '''<!DOCTYPE html>
<html lang="{lang}"{rtl}>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} - Lifeline</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {{
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #0D0C11 0%, #1a1a2a 100%);
            color: #E5E7EB;
            min-height: 100vh;
        }}
        .markdown-body {{
            line-height: 1.8;
        }}
        .markdown-body h1 {{
            color: #FF3B3B;
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
        }}
        .markdown-body h2 {{
            color: #FF6B6B;
            font-size: 1.75rem;
            font-weight: 600;
            margin-top: 2.5rem;
            margin-bottom: 1rem;
        }}
        .markdown-body h3 {{
            color: #FFA3A3;
            font-size: 1.25rem;
            font-weight: 600;
            margin-top: 1.5rem;
            margin-bottom: 0.75rem;
        }}
        .markdown-body p {{
            margin-bottom: 1rem;
            color: #D1D5DB;
        }}
        .markdown-body ul, .markdown-body ol {{
            margin-bottom: 1rem;
            padding-left: 1.5rem;
        }}
        .markdown-body li {{
            margin-bottom: 0.5rem;
            color: #D1D5DB;
        }}
        .markdown-body strong {{
            color: #F3F4F6;
            font-weight: 600;
        }}
        .markdown-body code {{
            background: #2a2a3a;
            padding: 0.2rem 0.4rem;
            border-radius: 0.25rem;
            font-size: 0.9em;
        }}
        .markdown-body a {{
            color: #FF3B3B;
            text-decoration: underline;
        }}
        .markdown-body a:hover {{
            color: #FF6B6B;
        }}
        .nav-btn {{
            display: inline-block;
            padding: 0.75rem 1.5rem;
            background: #2a2a3a;
            color: white;
            text-decoration: none;
            border-radius: 0.5rem;
            font-weight: 600;
            transition: all 0.3s;
            margin: 0.5rem;
        }}
        .nav-btn:hover {{
            background: #3a3a4a;
            transform: translateY(-2px);
        }}
        .nav-btn-primary {{
            background: #FF3B3B;
        }}
        .nav-btn-primary:hover {{
            background: #FF6B6B;
        }}
    </style>
</head>
<body class="p-4 md:p-8">

<!-- Navigation -->
<div class="max-w-4xl mx-auto mb-6">
    <a href="index.html" class="nav-btn">← Back to Home</a>
    <a href="{other_doc_link}" class="nav-btn">{other_doc_text}</a>
</div>

<!-- Content -->
<div class="max-w-4xl mx-auto bg-[#1a1a2a] rounded-xl shadow-lg p-6 md:p-12 border border-[#2a2a3a]">
    <div class="markdown-body">
{content}
    </div>
</div>

<!-- Footer Navigation -->
<div class="max-w-4xl mx-auto mt-6 text-center">
    <a href="index.html" class="nav-btn nav-btn-primary">Back to Home</a>
</div>

<!-- Footer -->
<div class="text-center text-gray-400 text-sm mt-8 pb-8">
    <p>© 2025 Lifeline. All rights reserved.</p>
</div>

</body>
</html>
'''

def markdown_to_html(md_text):
    """Convert markdown to HTML"""
    html = md_text

    # Headers
    html = re.sub(r'^# (.+)$', r'<h1>\1</h1>', html, flags=re.MULTILINE)
    html = re.sub(r'^## (.+)$', r'<h2>\1</h2>', html, flags=re.MULTILINE)
    html = re.sub(r'^### (.+)$', r'<h3>\1</h3>', html, flags=re.MULTILINE)

    # Bold
    html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)

    # Links
    html = re.sub(r'\[([^\]]+)\]\(([^\)]+)\)', r'<a href="\2">\1</a>', html)

    # Lists - convert markdown lists to HTML
    lines = html.split('\n')
    in_list = False
    result = []

    for line in lines:
        if re.match(r'^- ', line):
            if not in_list:
                result.append('<ul>')
                in_list = True
            result.append(f'<li>{line[2:]}</li>')
        else:
            if in_list:
                result.append('</ul>')
                in_list = False
            # Wrap non-empty lines in paragraphs (except already tagged)
            if line.strip() and not re.match(r'<[hul]', line):
                result.append(f'<p>{line}</p>')
            else:
                result.append(line)

    if in_list:
        result.append('</ul>')

    return '\n'.join(result)

def generate_html_page(md_file, lang, doc_type):
    """Generate HTML page from markdown file"""
    # Try different encodings for compatibility
    encodings = ['utf-8', 'cp1252', 'latin-1', 'gbk']
    md_content = None

    for encoding in encodings:
        try:
            with open(md_file, 'r', encoding=encoding) as f:
                md_content = f.read()
            break
        except UnicodeDecodeError:
            continue

    if md_content is None:
        raise Exception(f"Could not decode {md_file} with any known encoding")

    html_content = markdown_to_html(md_content)

    # Determine title and links
    if doc_type == "privacy":
        title = "Privacy Policy"
        other_doc_link = f"terms_{lang}.html"
        other_doc_text = "Terms of Service →"
    else:  # terms
        title = "Terms of Service"
        other_doc_link = f"privacy_{lang}.html"
        other_doc_text = "Privacy Policy →"

    # RTL support for Arabic and Hebrew
    rtl = ' dir="rtl"' if lang in ['ar', 'he'] else ''

    html_page = HTML_TEMPLATE.format(
        lang=lang,
        rtl=rtl,
        title=title,
        content=html_content,
        other_doc_link=other_doc_link,
        other_doc_text=other_doc_text
    )

    # Output filename
    output_file = PUBLIC_DIR / f"{doc_type}_{lang}.html"

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(html_page)

    print(f"✅ Generated: {output_file}")

def main():
    print("=" * 60)
    print("Generating HTML pages from markdown documents")
    print("=" * 60)

    # Create public directory if needed
    PUBLIC_DIR.mkdir(exist_ok=True)

    # Generate for each language
    for lang in LANGUAGES.keys():
        print(f"\n{LANGUAGES[lang]['flag']} {LANGUAGES[lang]['name']} ({lang}):")

        # Privacy Policy
        privacy_md = ASSETS_DIR / f"privacy_policy_{lang}.md"
        if privacy_md.exists():
            generate_html_page(privacy_md, lang, "privacy")
        else:
            print(f"   ⚠️ Missing: {privacy_md}")

        # Terms of Service
        terms_md = ASSETS_DIR / f"terms_of_service_{lang}.md"
        if terms_md.exists():
            generate_html_page(terms_md, lang, "terms")
        else:
            print(f"   ⚠️ Missing: {terms_md}")

    print("\n" + "=" * 60)
    print("✅ HTML generation complete!")
    print(f"Output directory: {PUBLIC_DIR}")
    print("\nNext step: Deploy to Firebase Hosting")
    print("Run: firebase deploy --only hosting")
    print("=" * 60)

if __name__ == "__main__":
    main()
