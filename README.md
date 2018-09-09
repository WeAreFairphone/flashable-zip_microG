microG/UnifiedNlp Installer
===

**Flashable ZIP** to install [microG](https://microg.org) or [UnifiedNlp](https://github.com/microg/android_packages_apps_UnifiedNlp/blob/master/README.md) into an Android system. This also includes an OTA survival `addon.d` script.  
You'll usually install them normally, but Google blocked userspace location providers in Android 7+, and some ROMs have not applied [required patches](https://github.com/microg/android_packages_apps_UnifiedNlp/tree/master/patches) yet, like LineageOS.

**microG** is a free-as-in-freedom re-implementation of [Google’s proprietary Android user space apps and libraries](https://arstechnica.com/gadgets/2013/10/googles-iron-grip-on-android-controlling-open-source-by-any-means-necessary/).  
**Unified Network Location Provider** (UnifiedNlp) is a library that provides Wi-Fi- and Cell-tower-based geolocation [with configurable plugins](https://github.com/microg/android_packages_apps_UnifiedNlp#usage) to applications that use Google’s network location provider. It is included in GmsCore but can also run independently on most Android systems.


Install
===

You'll need a custom recovery installed on your device, such as [TWRP](https://twrp.me/).

Restart your device into recovery and start `ADB sideload`. Then run:
```
adb sideload <flashable-zip-name>
```

Alternatively, copy the resulting ZIP to your device storage, restart your device into recovery and use the GUI `Install` or `Install ZIP` option.


### Note for UnifiedNLP on Android Oreo

In Oreo, the UnifiedNlp app is launched in a different way than before. After reboot, you need to go to "Location settings" in **Settings** &rarr; **Security and Privacy** &rarr; **Location Settings**, or by tapping and holding the notification bar quick-setting for toggling location. Then, at the bottom ("Location services"), you can launch **UnifiedNlp settings**. There you need to enable at least one location backend for network location to work, as usual. If you chose the `minimal` ZIP flavour, you need to install your preferred location backends first, e.g. from [F-Droid](https://staging.f-droid.org/search?q=UnifiedNlp+backend).


Build
===

### Requirements

[XMLStarlet](http://xmlstar.sourceforge.net/download.php) is needed to parse F-Droid-like repo indexes.

On Debian/Ubuntu systems, run `sudo apt install xmlstarlet`

### Build ZIP

Run the `build-zip.sh` shell script:
```
./build-zip.sh
```

This will generate a `microg_YYYY-MM-DD.zip` file.

### ZIP Flavours

You can **add you own flavour** just by writing a `<newflavour>_config.txt` file.

`build-zip.sh` accepts a single `<flavour>` string argument. Each flavour has a `<flavour>_config.txt` file.
```
./build-zip.sh <flavour>
```

This will generate a `<flavour>_YYYY-MM-DD.zip` file.

For example, to build the `unifiednlp` flavour, run:
```
./build-zip.sh unifiednlp
```

This will generate a `unifiednlp_YYYY-MM-DD.zip` file.
