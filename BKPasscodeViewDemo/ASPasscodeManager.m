
#import "ASPasscodeManager.h"
#import "BKCustomPasscodeViewController.h"

NSString *const PASSCODE_KEY = @"aspasscode.key";

NSString *const BKPasscodeKeychainServiceName = @"BKPasscodeSampleService";

@interface ASPasscodeManager ()<BKPasscodeViewControllerDelegate>
@property (strong, nonatomic) NSString          *passcode;
@end

@implementation ASPasscodeManager

+(instancetype) manager{
    static ASPasscodeManager * _manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[ASPasscodeManager alloc] init];
    });
    
    return _manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _passcode = [[NSUserDefaults standardUserDefaults] stringForKey:PASSCODE_KEY];
    }
    return self;
}

-(BOOL) hasPasscode{
    return self.passcode ? YES : NO;
}

-(void) inputPasscode:(UIViewController *) nav complete:(PasscodeCompleteResponse)completeBlock{
    [self presentPasscodeViewControllerWithType:BKPasscodeViewControllerNewPasscodeType owner:nav complete:completeBlock];
}

-(void) updatePasscode:(UIViewController *) nav complete:(PasscodeCompleteResponse)completeBlock{
    [self presentPasscodeViewControllerWithType:BKPasscodeViewControllerChangePasscodeType owner:nav complete:completeBlock];

}

-(void) deletePasscode:(UIViewController *) nav complete:(PasscodeCompleteResponse)completeBlock{
    _passcode = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSCODE_KEY];
    
    if (completeBlock)
        completeBlock(TRUE);
}

-(void) checkPasscode:(UIViewController *) nav complete:(PasscodeCompleteResponse)completeBlock{
    [self presentPasscodeViewControllerWithType:BKPasscodeViewControllerCheckPasscodeType owner:nav complete:completeBlock];
}

- (void)presentPasscodeViewControllerWithType:(BKPasscodeViewControllerType)type owner:(UIViewController *) root
                                     complete:(PasscodeCompleteResponse) completeBlock{
    BKPasscodeViewController *viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    viewController.type = type;
    viewController.complateRespose = completeBlock;
    
    // Passcode style (numeric or ASCII)
    viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
    
    // Setup Touch ID manager
    BKTouchIDManager *touchIDManager = [[BKTouchIDManager alloc] initWithKeychainServiceName:BKPasscodeKeychainServiceName];
    touchIDManager.promptText = @"BKPasscodeView Touch ID Demo";
    viewController.touchIDManager = touchIDManager;
    
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                    target:viewController action:@selector(passcodeViewCloseButtonPressed:)];

    if (viewController.type == BKPasscodeViewControllerCheckPasscodeType) {
        // Show Touch ID user interface
        [viewController startTouchIDAuthenticationIfPossible:^(BOOL prompted) {
            // If Touch ID is unavailable or disabled, present passcode view controller for manual input.
            [root.navigationController pushViewController:viewController animated:YES];
        }];
        
    } else {
        [root.navigationController pushViewController:viewController animated:YES];
    }
}
#pragma mark - BKPasscodeViewControllerDelegate

- (void)passcodeViewControllerDidFinishByCancel:(BKPasscodeViewController *)aViewController{
    UINavigationController  * nav = aViewController.navigationController;
    [nav popViewControllerAnimated:YES];
    
    if(aViewController.complateRespose)
        aViewController.complateRespose(NO);
}

- (void)passcodeViewController:(BKPasscodeViewController *)aViewController authenticatePasscode:(NSString *)aPasscode resultHandler:(void (^)(BOOL))aResultHandler
{
    if ([aPasscode isEqualToString:self.passcode]) {
        
        self.lockUntilDate = nil;
        self.failedAttempts = 0;
        
        aResultHandler(YES);
    } else {
        aResultHandler(NO);
    }
}

- (void)passcodeViewControllerDidFailAttempt:(BKPasscodeViewController *)aViewController
{
    self.failedAttempts++;
    
    if (self.failedAttempts > 5) {
        
        NSTimeInterval timeInterval = 60;
        
        if (self.failedAttempts > 6) {
            
            NSUInteger multiplier = self.failedAttempts - 6;
            
            timeInterval = (5 * 60) * multiplier;
            
            if (timeInterval > 3600 * 24) {
                timeInterval = 3600 * 24;
            }
        }
        
        self.lockUntilDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    }
}

- (NSUInteger)passcodeViewControllerNumberOfFailedAttempts:(BKPasscodeViewController *)aViewController{
    return self.failedAttempts;
}

- (NSDate *)passcodeViewControllerLockUntilDate:(BKPasscodeViewController *)aViewController{
    return self.lockUntilDate;
}

-(void) saveCurrentPasscode{
    [[NSUserDefaults standardUserDefaults] setObject:self.passcode forKey:PASSCODE_KEY];
}

- (void)passcodeViewController:(BKPasscodeViewController *)aViewController didFinishWithPasscode:(NSString *)aPasscode{
    switch (aViewController.type) {
        case BKPasscodeViewControllerNewPasscodeType:
        case BKPasscodeViewControllerChangePasscodeType:
            self.passcode = aPasscode;
            self.failedAttempts = 0;
            self.lockUntilDate = nil;
            [self saveCurrentPasscode];
            break;
        case BKPasscodeViewControllerCheckPasscodeType:
            break;
        default:
            NSAssert(NO, @"Shouldn't happen");
            break;
    }
    
    UINavigationController  * nav = aViewController.navigationController;
    [nav popViewControllerAnimated:YES];

    
    if(aViewController.complateRespose)
        aViewController.complateRespose(YES);
}


@end
