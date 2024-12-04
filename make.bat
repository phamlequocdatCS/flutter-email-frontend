@echo off
set OUTPUT=flutter-email-app
set GITHUB_USER=phamlequocdatCS

echo Clean existing repository
call flutter clean

echo Getting packages...
call flutter pub get

echo Generating the web folder...
call flutter create . --platform web

echo Building for web...
call flutter build web --base-href "/%OUTPUT%/" --release

echo Deploying to git repository
cd build\web
git init
git add .
git commit -m "Deploy Version latest"
git branch -M main
git remote add origin https://github.com/%GITHUB_USER%/%OUTPUT%
git push -u -f origin main

echo Finished deploy: https://github.com/%GITHUB_USER%/%OUTPUT%
echo Flutter web URL: https://phamlequocdatCS.github.io/%OUTPUT%/