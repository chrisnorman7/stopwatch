@echo off
flutter build web --base-href /stopwatch/ --release & scp -Cr build\web\* root@backstreets.site:/var/www/html/stopwatch
