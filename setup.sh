#!/bin/bash

# Drift Project Setup Script
# This script sets up the development environment for the Drift project

set -e

echo "Setting up Drift project..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Flutter is not installed. Please install Flutter first."
    echo "Visit: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo -e
echo "Flutter found: $(flutter --version | head -n 1)"

echo -e
echo "Getting dependencies for core package..."
cd apps/core
dart pub get
cd ../..

echo -e
echo "Getting dependencies for Flutter app..."
cd apps/flutter
flutter pub get
cd ../..

echo -e
echo "Running Flutter doctor..."
flutter doctor

echo -e
echo "Setup completed"
echo "For more information, see the README.md file."
