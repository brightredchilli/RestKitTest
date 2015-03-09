//
//  AppDelegate.m
//  RestKitTest
//
//  Created by Ying Quan Tan on 3/8/15.
//  Copyright (c) 2015 Intrepid. All rights reserved.
//

#import "AppDelegate.h"
#import "RKTest.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RKTest *tester = [[RKTest alloc] init];
    [tester runTests];

    return YES;
}

@end
