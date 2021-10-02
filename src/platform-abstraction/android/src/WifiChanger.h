/*   2log.io
 *   Copyright (C) 2021 - 2log.io | mail@2log.io,  mail@friedemann-metzger.de
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#ifndef WIFICHANGERANDROID_H
#define WIFICHANGERANDROID_H

#include <QObject>
#include "../../AbstractWifiChanger.h"
#include <QAndroidJniObject>

namespace Android
{

    class WifiChanger : public AbstractWifiChanger
    {
        Q_OBJECT



    public:
        explicit WifiChanger(QObject *parent = nullptr);

        // JNI API
        static void wifiSsidChanged(JNIEnv *env, jobject thiz, jstring x);
        static void wifiScanResults(JNIEnv *env, jobject thiz, jobjectArray stringArrays);
        static void wifiConnected(JNIEnv *env, jobject thiz, jboolean success);

        // QML API
        QString currentSSID() const;
        QStringList scanResults() const;
        QStringList foundDots() const;
        QStringList foundSwitches() const;
        Q_INVOKABLE bool startScan() override;
        Q_INVOKABLE bool switchWifi(QString ssid, QString pass = "") override;
        Q_INVOKABLE bool removeWifi(QString ssid) override;

    private:
        static WifiChanger* _this;

    };
}

#endif // WIFICHANGER_H
