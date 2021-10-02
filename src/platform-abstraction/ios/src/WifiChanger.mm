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


#include "WifiChanger.h"
#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NetworkExtension.h>

#import <QDebug>

using namespace iOS;

void WifiChanger::init()
{
    if(_this)
        return;

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    NULL, // observer
                                    onNotifyCallback, // callback
                                    CFSTR("com.apple.system.config.network_change"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

    setCurrentSSID(getCurrentSsid());
    _this = this;
}

QString WifiChanger::getCurrentSsid()
{
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    NSDictionary *info;
    for (NSString *ifnam in ifs)
    {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count])
        {
            NSLog(@"Current Wifi: %@", [info objectForKey:@"SSID"]);
            return QString::fromNSString([info objectForKey:@"SSID"]);
            break;
        }
    }

    return "";
}

void WifiChanger::onNotifyCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    Q_UNUSED(center)
    Q_UNUSED(observer)
    Q_UNUSED(object)
    Q_UNUSED(userInfo)

    NSString* notifyName = (__bridge NSString*)name;
    // this check should really only be necessary if you reuse this one callback method
    //  for multiple Darwin notification events
    if ([notifyName isEqualToString:@"com.apple.system.config.network_change"]) {
        qDebug()<<"NETWORK CHANGE" + getCurrentSsid();
        QString ssid = getCurrentSsid();
        _this->setCurrentSSID(ssid);
        _this->setWifiConnected(!ssid.isEmpty());

    } else {
        NSLog(@"intercepted %@", notifyName);
    }
}

bool WifiChanger::switchWifi(QString ssid, QString pass)
{

    if (@available(iOS 11, *))
    {
        // Use iOS 11 APIs.
        NEHotspotConfiguration* configuration;
        if(!pass.isEmpty())
            configuration = [[NEHotspotConfiguration alloc] initWithSSID:ssid.toNSString() passphrase:pass.toNSString() isWEP:false];
        else
            configuration = [[NEHotspotConfiguration alloc] initWithSSID:ssid.toNSString()];

        configuration.joinOnce = YES;

        [[NEHotspotConfigurationManager sharedManager] applyConfiguration:configuration completionHandler:nil];
        return true;
    }

    return false;
}

int WifiChanger::requestPermissions()
{

    


}

bool WifiChanger::removeWifi(QString ssid)
{
    if (@available(iOS 11, *))
    {
        [[NEHotspotConfigurationManager sharedManager] removeConfigurationForSSID:ssid.toNSString()];
        return true;
    }
    return false;
}


