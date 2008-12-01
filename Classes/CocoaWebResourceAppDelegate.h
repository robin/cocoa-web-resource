//
//  CocoaWebResourceAppDelegate.h
//  CocoaWebResource
//
//  Created by Robin Lu on 12/1/08.
//  Copyright robinlu.com 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CocoaWebResourceViewController;

@interface CocoaWebResourceAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CocoaWebResourceViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CocoaWebResourceViewController *viewController;

@end

