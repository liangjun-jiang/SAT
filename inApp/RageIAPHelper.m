//
//  RageIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "RageIAPHelper.h"
#define PRODUCT1 @"com.ljsportapps.hangman.noads"
@implementation RageIAPHelper

+ (RageIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static RageIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      PRODUCT1,
//                                      @"com.razeware.inapprage.drummerrage",
//                                      @"com.razeware.inapprage.itunesconnectrage",
//                                      @"com.razeware.inapprage.nightlyrage",
//                                      @"com.razeware.inapprage.studylikeaboss",
//                                      @"com.razeware.inapprage.updogsadness",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
