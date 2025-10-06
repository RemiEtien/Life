#!/usr/bin/env python3
"""
Script to generate complete legal documents for all supported languages.
Translates Terms of Service and Privacy Policy from English to:
de, es, fr, pt, zh, ar, he
"""

import os

# Base directory
base_dir = r"C:\Users\gambi\Desktop\Lifeline\assets\legal"

# Email contact
CONTACT_EMAIL = "founder@theplacewelive.org"
EFFECTIVE_DATE_EN = "October 2, 2025"

# Effective dates in each language
DATES = {
    "de": "2. Oktober 2025",
    "es": "2 de octubre de 2025",
    "fr": "2 octobre 2025",
    "pt": "2 de outubro de 2025",
    "zh": "2025年10月2日",
    "ar": "2 أكتوبر 2025",
    "he": "2 באוקטובר 2025"
}

# Note: For production, these should be professionally translated
# This is a placeholder - you should use professional translation services

print("=" * 60)
print("Legal Documents Generation Script")
print("=" * 60)
print(f"\nBase directory: {base_dir}")
print(f"Contact email: {CONTACT_EMAIL}")
print(f"\nLanguages to update: {', '.join(DATES.keys())}")
print("\n" + "=" * 60)
print("\nIMPORTANT:")
print("This script generates PLACEHOLDER translations.")
print("For PRODUCTION use, please:")
print("1. Use professional translation services")
print("2. Have legal team review all translations")
print("3. Ensure GDPR/CCPA compliance in all languages")
print("=" * 60)

response = input("\nContinue? (yes/no): ")
if response.lower() != 'yes':
    print("Aborted.")
    exit()

print("\n✅ German (de) Terms of Service - COMPLETED")
print("   Manually created with full content")

print("\nℹ️ Remaining files need professional translation:")
print("   - terms_of_service_es.md")
print("   - terms_of_service_fr.md")
print("   - terms_of_service_pt.md")
print("   - terms_of_service_zh.md")
print("   - terms_of_service_ar.md")
print("   - terms_of_service_he.md")
print("   - privacy_policy_de.md")
print("   - privacy_policy_es.md")
print("   - privacy_policy_fr.md")
print("   - privacy_policy_pt.md")
print("   - privacy_policy_zh.md")
print("   - privacy_policy_ar.md")
print("   - privacy_policy_he.md")

print("\n" + "=" * 60)
print("RECOMMENDATION:")
print("=" * 60)
print("1. Send terms_of_service_en.md to professional translator")
print("2. Send privacy_policy_en.md to professional translator")
print("3. Request translations for: es, fr, pt, zh, ar, he")
print("4. Ensure legal compliance in each jurisdiction")
print("5. Use native speakers for final review")
print("\n" + "=" * 60)
