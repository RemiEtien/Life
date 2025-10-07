#!/bin/bash

# iOS Setup Verification Script for Lifeline
# Run this before attempting to build for iOS

echo "=================================================="
echo "  Lifeline iOS Setup Verification"
echo "=================================================="
echo ""

ERRORS=0
WARNINGS=0

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check 1: GoogleService-Info.plist
echo -n "1. Checking for GoogleService-Info.plist... "
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${GREEN}✓ Found${NC}"
else
    echo -e "${RED}✗ MISSING${NC}"
    echo "   ERROR: GoogleService-Info.plist not found!"
    echo "   See: ios/Runner/README_FIREBASE.md"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check 2: Bundle ID
echo -n "2. Checking Bundle ID... "
BUNDLE_ID=$(grep -o 'PRODUCT_BUNDLE_IDENTIFIER = com\.momentic\.lifeline' ios/Runner.xcodeproj/project.pbxproj | wc -l)
if [ "$BUNDLE_ID" -ge "3" ]; then
    echo -e "${GREEN}✓ Correct (com.momentic.lifeline)${NC}"
else
    echo -e "${YELLOW}⚠ May be incorrect${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Check 3: URL Scheme in Info.plist
echo -n "3. Checking Google Sign-In URL Scheme... "
if grep -q "CFBundleURLTypes" ios/Runner/Info.plist && ! grep -q "<!-- <key>CFBundleURLTypes</key>" ios/Runner/Info.plist; then
    # Uncommented and exists
    if grep -q "YOUR_REVERSED_CLIENT_ID" ios/Runner/Info.plist; then
        echo -e "${YELLOW}⚠ Placeholder not replaced${NC}"
        echo "   WARNING: Replace YOUR_REVERSED_CLIENT_ID with actual value from GoogleService-Info.plist"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓ Configured${NC}"
    fi
else
    echo -e "${RED}✗ Not configured${NC}"
    echo "   ERROR: URL Scheme is still commented out in Info.plist"
    echo "   See: docs/ios_setup_requirements.md"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check 4: Xcode version (optional)
echo -n "4. Checking Xcode availability... "
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    echo -e "${GREEN}✓ $XCODE_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ Not found${NC}"
    echo "   WARNING: Xcode not found. Required for iOS builds."
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Check 5: CocoaPods (optional)
echo -n "5. Checking CocoaPods... "
if command -v pod &> /dev/null; then
    POD_VERSION=$(pod --version)
    echo -e "${GREEN}✓ Version $POD_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ Not installed${NC}"
    echo "   WARNING: CocoaPods not found. May be needed for some plugins."
    echo "   Install with: sudo gem install cocoapods"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Check 6: iOS deployment target
echo -n "6. Checking iOS deployment target... "
DEPLOY_TARGET=$(grep "IPHONEOS_DEPLOYMENT_TARGET = " ios/Runner.xcodeproj/project.pbxproj | head -n 1 | grep -o '[0-9]*\.[0-9]*')
if [ ! -z "$DEPLOY_TARGET" ]; then
    echo -e "${GREEN}✓ iOS $DEPLOY_TARGET${NC}"
else
    echo -e "${YELLOW}⚠ Unable to determine${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Check 7: Required permissions
echo "7. Checking required permissions in Info.plist..."
REQUIRED_PERMS=(
    "NSCameraUsageDescription"
    "NSPhotoLibraryUsageDescription"
    "NSMicrophoneUsageDescription"
    "NSFaceIDUsageDescription"
)

for PERM in "${REQUIRED_PERMS[@]}"; do
    echo -n "   - $PERM... "
    if grep -q "<key>$PERM</key>" ios/Runner/Info.plist; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ Missing${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# Summary
echo "=================================================="
echo "  Summary"
echo "=================================================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "You can now try building for iOS:"
    echo "  flutter build ios --release"
    echo ""
    echo "Or open in Xcode:"
    echo "  open ios/Runner.xcworkspace"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    echo ""
    echo "You can try building, but some features may not work."
    echo "See docs/ios_setup_requirements.md for details."
    echo ""
    exit 0
else
    echo -e "${RED}✗ $ERRORS critical error(s) found${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    fi
    echo ""
    echo "❌ iOS build will FAIL or CRASH"
    echo ""
    echo "Fix these issues before building:"
    echo "  1. Read docs/ios_setup_requirements.md"
    echo "  2. Read ios/Runner/README_FIREBASE.md"
    echo "  3. Run this script again to verify"
    echo ""
    exit 1
fi
