#   2log.io
#   Copyright (C) 2021 - 2log.io | mail@2log.io,  mail@friedemann-metzger.de
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

QT += network
CONFIG += c++11

INCLUDEPATH += $$PWD#/ProvisioningModule

SOURCES += \
        $$PWD/AbstractWifiChanger.cpp \
        $$PWD/ManualWifiChanger.cpp \
        $$PWD/ProvisioningManager.cpp \
        $$PWD/SocketConfigLegacy.cpp \
        $$PWD/ios/src/DeepLinkURIReader.cpp


HEADERS += \
        $$PWD/AbstractWifiChanger.h \
        $$PWD/ISleepAvoider.h \
        $$PWD/ISocketConfig.h \
        $$PWD/InitPlatformAbstraction.h \
        $$PWD/ManualWifiChanger.h \
        $$PWD/ProvisioningManager.h \
        $$PWD/SocketConfigLegacy.h \
        $$PWD/ios/src/DeepLinkURIReader.h

ios {
    MY_ENTITLEMENTS.name = CODE_SIGN_ENTITLEMENTS
    MY_ENTITLEMENTS.value = $$PWD/ios/assets/portal.entitlements

    QMAKE_MAC_XCODE_SETTINGS += MY_ENTITLEMENTS
    QMAKE_ASSET_CATALOGS += $$PWD/ios/assets/Images.xcassets

    ios_icon.files = $$files($$PWD/ios/assets/icon/AppIcon.appiconset/Icon-App-*.png)

    QMAKE_BUNDLE_DATA += ios_icon
    QMAKE_INFO_PLIST = $$PWD/ios/assets/Info.plist

    OBJECTIVE_SOURCES += \
        $$PWD/ios/src/WifiChanger.mm \
        $$PWD/ios/src/PermissionRequester.mm \
        $$PWD/ios/src/Notch.mm \
        $$PWD/ios/src/SleepAvoider.mm \
        $$PWD/ios/src/QtAppDelegate.mm

    SOURCES += \
        $$PWD/ios/src/WifiChanger.cpp

    HEADERS += \
        $$PWD/ios/src/WifiChanger.h \
        $$PWD/ios/src/PermissionRequester.h \
        $$PWD/ios/src/Notch.h \
        $$PWD/ios/src/SleepAvoider.h
#        $$PWD/ios/src/QtAppDelegate-C-Interface.h \
#        $$PWD/ios/src/QtAppDelegate.h

    LIBS += -framework NetworkExtension
    LIBS += -framework CoreLocation
    QMAKE_CXXFLAGS += -fobjc-arc
    QMAKE_TARGET_BUNDLE_PREFIX = io.2log.in
}

# SocketConfigIDFix uses QSSlSockets which is not supported in Qt for WebAssembly
!wasm {
SOURCES += \
        $$PWD/SocketConfigIDFix.cpp

HEADERS += \
        $$PWD/SocketConfigIDFix.h
}

android {
    ANDROID_PACKAGE_SOURCE_DIR += \
        $$PWD/android

    QT += androidextras

    DISTFILES +=   \
        $$PWD/android/AndroidManifest.xml \
        $$PWD/android/build.gradle \
        $$PWD/android/gradle/wrapper/gradle-wrapper.jar \
        $$PWD/android/gradle/wrapper/gradle-wrapper.properties \
        $$PWD/android/gradlew \
        $$PWD/android/gradlew.bat \
        $$PWD/android/res/values/libs.xml \
        $$PWD/android/src/org/twolog/android/provisioning/WifiChanger.java \
        $$PWD/android/Logo_120x120px.png

     HEADERS += \
        $$PWD/android/src/WifiChanger.h \
        $$PWD/android/src/SleepAvoider.h

     SOURCES += \
        $$PWD/android/src/WifiChanger.cpp \
        $$PWD/android/src/SleepAvoider.cpp
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

RESOURCES += \
    $$PWD/PlatformAbstractionResources.qrc
