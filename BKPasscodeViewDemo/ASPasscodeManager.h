//
//  ASPasscodeManager.h
//  BKPasscodeViewDemo
//
//  Created by liufei on 15/10/30.
//  Copyright © 2015年 Byungkook Jang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKPasscodeDef.h"
#import "BKPasscodeViewController.h"

extern NSString *const BKPasscodeKeychainServiceName;


@interface ASPasscodeManager : NSObject

+(instancetype) manager;

-(BOOL) hasPasscode;
-(void) inputPasscode:(UIViewController *)nav complete:(PasscodeCompleteResponse) completeBlock;
-(void) updatePasscode:(UIViewController *)nav complete:(PasscodeCompleteResponse) completeBlock;
-(void) deletePasscode:(UIViewController *)nav complete:(PasscodeCompleteResponse) completeBlock;
-(void) checkPasscode:(UIViewController *)nav complete:(PasscodeCompleteResponse) completeBlock;


@property (nonatomic) NSUInteger                failedAttempts;
@property (strong, nonatomic) NSDate            *lockUntilDate;

@end
