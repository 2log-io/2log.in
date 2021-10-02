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


#ifndef WIFICHANGERIOS_H
#define WIFICHANGERIOS_H

#include <QObject>
#include "../../AbstractWifiChanger.h"
#include <CoreFoundation/CoreFoundation.h>


namespace iOS
{
  
    class WifiChanger : public AbstractWifiChanger
    {
        Q_OBJECT

    public:
        WifiChanger(QObject* parent = nullptr);
        bool switchWifi(QString ssid, QString pass = "") override;
        int requestPermissions() override;
        bool removeWifi(QString ssid) override;
        
    private:
        void init();
        static WifiChanger* _this;
        static QString getCurrentSsid();
        static void onNotifyCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
    };
}

#endif // WIFICHANGER_H
