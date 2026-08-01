#!/bin/bash
# Sarthee AI Release Candidate Build Automation Script
# Usage: ./scripts/build_release.sh

set -e

echo "🚀 Starting Sarthee AI Production Release Candidate Build..."

# 1. Run Backend Unit & Integration Tests
echo "🧪 Running Backend Unit & Integration Tests..."
cd backend
npm test
cd ..

# 2. Build Docker Production Image
echo "🐳 Building Production Docker Container..."
docker build -t sarthee-ai-backend:latest ./backend

# 3. Analyze Flutter Mobile Code
echo "📱 Analyzing Flutter Mobile Codebase..."
cd Sarthe_AI
flutter analyze lib/features/nearby
cd ..

echo "✅ Sarthee AI Release Candidate Build Completed Successfully!"
