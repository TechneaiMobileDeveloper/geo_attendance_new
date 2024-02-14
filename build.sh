flutter clean && flutter build apk --split-per-abi "lib/main.dart"
if [[ $? == 0 ]]; then
echo "Copying APK...."
cp -f "$PWD/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk" "$HOME/Desktop/"
echo "APK copied."
echo "Renaming APK...."
mv "$HOME/Desktop/app-armeabi-v7a-release.apk" "$HOME/Desktop/BUILD_A_geo_attendance-$(date "+%F").apk"
else
echo "Flutter APK Build Failed"
fi

# chmod +x send_apk_to_desktop.sh
