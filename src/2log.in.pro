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


QT += quick websockets svg widgets
concurrent
TARGET = portal
CONFIG += c++11
INCLUDEPATH += $$PWD/gui/cpp


#CONFIG+=sdk_no_version_check

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the0
# deprecated API to know how to port your code away from it.
# DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0


include(quickhub-qmlclientmodule/QHClientModule.pri)
include(gui/2log-qmlcomponents/src/2log-qmlcomponents.pri)
include(gui/2log-qmlcontrols/src/2log-qmlcontrols.pri)
include(platform-abstraction/2log-platformabstraction.pri)


SOURCES += \
    main.cpp \
    gui/cpp/LanguageSwitcher.cpp \
    gui/cpp/LogModel.cpp


RESOURCES += \
    gui/gui.qrc \
    translations/translations.qrc



# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


# TODO - copy files
#contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
#    ANDROID_EXTRA_LIBS = \
#        $$PWD/../../../../../../Downloads/Android/armeabi-v7a/libcrypto.so \
#        $$PWD/../../../../../../Downloads/Android/armeabi-v7a/libssl.so
#}


DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml \
    src/AppComponents/qmldir \
    translations/main_en.qm

ANDROID_EXTRA_LIBS = /Users/friedemannmetzger/Qt/Android/libcrypto.so /Users/friedemannmetzger/Qt/Android/libssl.so

#ANDROID_PACKAGE_SOURCE_DIR += $$PWD/android

HEADERS += \
    gui/cpp/LanguageSwitcher.h \
    gui/cpp/LogModel.h



