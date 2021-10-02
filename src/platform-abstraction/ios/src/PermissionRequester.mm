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


#include "PermissionRequester.h"
#import <CoreLocation/CLLocationManager.h>
CLLocationManager* locationManager;

void PermissionRequester::requestPermissions()
{
    [locationManager requestWhenInUseAuthorization];
}

int PermissionRequester::getPermissionStatus()
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
            //The user hasn't yet chosen whether your app can use location services or not.
            return 0;

        case kCLAuthorizationStatusAuthorizedAlways:
            //The user has let your app use location services all the time, even if the app is in the background.
            return 1;

        case kCLAuthorizationStatusAuthorizedWhenInUse:
            //The user has let your app use location services only when the app is in the foreground.
            return 2;

        case kCLAuthorizationStatusRestricted:
            //The user can't choose whether or not your app can use location services or not, this could be due to parental controls for example.
            return -1;

        case kCLAuthorizationStatusDenied:
            //The user has chosen to not let your app use location services.
            return -2;
    }
}


void PermissionRequester::init()
{
    locationManager = [[CLLocationManager alloc] init];
}
