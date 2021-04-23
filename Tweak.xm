#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

UIViewController *batteryPopViewController;

// Add the popover delegate to our new view controller
@interface PopLockAndDropItViewController : UIViewController <UIPopoverPresentationControllerDelegate>
@end

// Create a new view controller

@implementation PopLockAndDropItViewController
//This will tell our new view controller to not conform to a modal presentation when our popover is presented
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}
@end

@interface _UIStatusBarForegroundView : UIView
- (void)batteryTapGesture:(UITapGestureRecognizer *)sender;
- (double)deviceBatteryPercent;
@end

@interface SBIconController : UIViewController
+(id)sharedInstance;
@end

%hook _UIStatusBarForegroundView

- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(batteryTapGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    
    return self;
}

%new
- (double)deviceBatteryPercent {
    UIDevice *device = [UIDevice currentDevice];
    [device setBatteryMonitoringEnabled:YES];
    return (float)[device batteryLevel];
}

%new
- (void)batteryTapGesture:(UITapGestureRecognizer *)sender {
    
    // The view controller holding our popover
    batteryPopViewController = [[UIViewController alloc] init];
    batteryPopViewController.modalPresentationStyle = UIModalPresentationPopover;
    batteryPopViewController.preferredContentSize = CGSizeMake(200,130);

    UILabel *batteryLabel = [[UILabel alloc] init];
    batteryLabel.frame = CGRectMake(0, 50, 200, 80);
    batteryLabel.numberOfLines = 1;
    batteryLabel.textAlignment = NSTextAlignmentCenter;
    batteryLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    batteryLabel.adjustsFontSizeToFitWidth = YES;
    batteryLabel.userInteractionEnabled = NO;
    batteryLabel.font = [UIFont boldSystemFontOfSize:40];
    batteryLabel.textColor = [UIColor labelColor];
    CGFloat myFloat = [self deviceBatteryPercent];
    batteryLabel.text = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:myFloat] numberStyle:NSNumberFormatterPercentStyle];
    [batteryPopViewController.view addSubview:batteryLabel];
    
    UILabel *batteryInfoLabel = [[UILabel alloc] init];
    batteryInfoLabel.frame = CGRectMake(0, 10, 200, 40);
    batteryInfoLabel.numberOfLines = 2;
    batteryInfoLabel.textAlignment = NSTextAlignmentCenter;
    batteryInfoLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    batteryInfoLabel.adjustsFontSizeToFitWidth = YES;
    batteryInfoLabel.userInteractionEnabled = NO;
    batteryInfoLabel.font = [UIFont boldSystemFontOfSize:20];
    batteryInfoLabel.textColor = [UIColor labelColor];
    batteryInfoLabel.text = @"Your current battery level is:";
    [batteryPopViewController.view addSubview:batteryInfoLabel];
     
    // The popover
    UIPopoverPresentationController *batteryPopover = batteryPopViewController.popoverPresentationController;
    
    // The viewcontroller presenting our popover (We will assign the delegate of our popover to this)
    PopLockAndDropItViewController *vc = [[PopLockAndDropItViewController alloc] init];
    batteryPopover.delegate = vc;
    
    // UIPopoverArrowDirectionUp
    // UIPopoverArrowDirectionDown
    // UIPopoverArrowDirectionLeft
    // UIPopoverArrowDirectionRight
    // UIPopoverArrowDirectionAny (this is the default)
    // UIPopoverArrowDirectionUnknown
    batteryPopover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    
    //batteryPopover.barButtonItem = batteryButtonItem;
    // you can replace the below two methods with barbuttonitem if you are using a UIBarButtonItem
    // Here I am telling the popover that self is the view it should pop from and give it the frame of self so that it knows to center itself in the middle
    batteryPopover.sourceView = self;
    batteryPopover.sourceRect = self.frame;
    
    [[%c(SBIconController) sharedInstance] presentViewController:batteryPopViewController animated:YES completion:nil];
    AudioServicesPlaySystemSound(1519);
}
%end

%hook UIApplication
-(void)applicationWillSuspend {
    %orig;
    // if our popover is left open when leaving the app, this will dismiss it
    [[%c(SBIconController) sharedInstance] dismissViewControllerAnimated:batteryPopViewController completion:nil];
}
%end
