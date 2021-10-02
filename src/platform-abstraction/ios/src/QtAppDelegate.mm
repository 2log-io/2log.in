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


#import "UIKit/UIKit.h"
#include "DeepLinkURIReader.h"

@interface QIOSApplicationDelegate
@end

@interface QIOSApplicationDelegate (WoboqApplicationDelegate)
@end




@implementation QIOSApplicationDelegate (WoboqApplicationDelegate)



- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"launch!");
    return YES;
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    NSLog(@"FOOBAR");
    return YES;
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
  restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *restorableObjects))restorationHandler
{
    DeepLinkURIReader::getInstance()->parseUrl(QString::fromNSString(userActivity.activityType));

    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb])
    {
        DeepLinkURIReader::getInstance()->parseUrl(QString::fromNSString(userActivity.webpageURL.absoluteString));
    }

    return YES;
}


@end
