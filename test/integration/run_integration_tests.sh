#!/bin/bash

# Integration Tests Runner for Lifeline
# This script sets up the Firebase Emulator and runs all integration tests

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Lifeline Integration Tests Runner ===${NC}\n"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}Error: Firebase CLI is not installed${NC}"
    echo "Install it with: npm install -g firebase-tools"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed${NC}"
    exit 1
fi

echo -e "${YELLOW}1. Checking Firebase project configuration...${NC}"
if [ ! -f "firebase.json" ]; then
    echo -e "${RED}Error: firebase.json not found${NC}"
    echo "Run: firebase init emulators"
    exit 1
fi

echo -e "${GREEN}✓ Firebase project configured${NC}\n"

echo -e "${YELLOW}2. Installing Flutter dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}\n"

echo -e "${YELLOW}3. Starting Firebase Emulators...${NC}"
# Kill any existing emulator instances
pkill -f "firebase emulators" || true
sleep 2

# Start emulators in background
firebase emulators:start --only auth,firestore,storage &
EMULATOR_PID=$!

# Wait for emulators to start
echo "Waiting for emulators to initialize..."
sleep 10

# Check if emulators are running
if ! curl -s http://localhost:4000 > /dev/null; then
    echo -e "${RED}Error: Emulators failed to start${NC}"
    kill $EMULATOR_PID 2>/dev/null || true
    exit 1
fi

echo -e "${GREEN}✓ Emulators running${NC}"
echo "  - Auth Emulator: http://localhost:9099"
echo "  - Firestore Emulator: http://localhost:8080"
echo "  - Storage Emulator: http://localhost:9199"
echo "  - Emulator UI: http://localhost:4000"
echo ""

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Stopping Firebase Emulators...${NC}"
    kill $EMULATOR_PID 2>/dev/null || true
    sleep 2
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

trap cleanup EXIT INT TERM

echo -e "${YELLOW}4. Running Integration Tests...${NC}\n"

# Run tests based on command line argument
case "${1:-all}" in
    auth)
        echo "Running Authentication Flow Tests..."
        flutter test test/integration/auth_flow_integration_test.dart
        ;;
    memory)
        echo "Running Memory CRUD & Sync Tests..."
        flutter test test/integration/memory_crud_sync_integration_test.dart
        ;;
    premium)
        echo "Running Premium Purchase Tests..."
        flutter test test/integration/premium_purchase_integration_test.dart
        ;;
    functions)
        echo "Running Cloud Functions Tests..."
        echo -e "${YELLOW}Note: Some tests may be skipped if functions are not deployed${NC}"
        flutter test test/integration/cloud_functions_integration_test.dart
        ;;
    all)
        echo "Running All Integration Tests..."
        flutter test test/integration/ --exclude-tags=requires-functions
        ;;
    coverage)
        echo "Running All Integration Tests with Coverage..."
        flutter test test/integration/ --exclude-tags=requires-functions --coverage
        echo -e "\n${YELLOW}Generating HTML coverage report...${NC}"
        if command -v lcov &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html
            echo -e "${GREEN}✓ Coverage report generated: coverage/html/index.html${NC}"
        else
            echo -e "${YELLOW}Warning: lcov not installed. Install with: sudo apt-get install lcov${NC}"
        fi
        ;;
    *)
        echo -e "${RED}Unknown test suite: $1${NC}"
        echo "Usage: $0 [auth|memory|premium|functions|all|coverage]"
        exit 1
        ;;
esac

TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "\n${GREEN}=== All Tests Passed! ===${NC}\n"
else
    echo -e "\n${RED}=== Tests Failed ===${NC}\n"
    exit $TEST_EXIT_CODE
fi

# Keep script running to allow manual inspection
echo -e "${YELLOW}Emulator UI is still running at http://localhost:4000${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop emulators and exit${NC}\n"

# Wait for user to stop
wait $EMULATOR_PID
