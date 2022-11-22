#import <Cordova/CDV.h>
#import "CDVGestureLockView.h"
#import "TQGestureLockView.h"

@interface CDVGestureLockView() <TQGestureLockViewDelegate>
@property (nonatomic, strong) TQGestureLockView *lockView;
@property (nonatomic, strong) UIView *backdropView;
@property (nonatomic, strong) CDVInvokedUrlCommand *cdvcommand;
@end

@implementation CDVGestureLockView

- (void)show:(CDVInvokedUrlCommand *)command
{
    _cdvcommand = command;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _backdropView = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    _backdropView.backgroundColor = [UIColor whiteColor];
    [self.viewController.view addSubview:_backdropView];

    CGFloat spacing = 40;
    CGFloat diameter = (screenSize.width - spacing * 4) / 3;
    CGFloat bottom1 = 55 + UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    CGFloat width1 = screenSize.width;
    CGFloat top1 = screenSize.height - width1 - bottom1;
    CGRect rect1 = CGRectMake(0, top1, width1, width1);

    CGFloat width2 = screenSize.width, height2 = 30;
    CGFloat top2 = top1 - height2 -17;
    CGRect rect2 = CGRectMake(0, top2, width2, height2);

    TQGestureLockDrawManager *drawManager = [TQGestureLockDrawManager defaultManager];
    drawManager.circleDiameter = diameter;
    drawManager.edgeSpacingInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    drawManager.bridgingLineWidth = 0.5;
    drawManager.hollowCircleBorderWidth = 0.5;

    _lockView = [[TQGestureLockView alloc] initWithFrame:rect1 drawManager:drawManager];
    _lockView.delegate = self;
    [_backdropView addSubview:_lockView];
}
- (void)hide:(CDVInvokedUrlCommand *)command
{
    [_lockView removeFromSuperview];
    [_backdropView removeFromSuperview];
    _cdvcommand = nil;
}


#pragma mark - TQGestureLockViewDelegate

- (void)gestureLockView:(TQGestureLockView *)gestureLockView lessErrorSecurityCodeSting:(NSString *)securityCodeSting
{
    [gestureLockView setNeedsDisplayGestureLockErrorState:YES];
}

- (void)gestureLockView:(TQGestureLockView *)gestureLockView finalRightSecurityCodeSting:(NSString *)securityCodeSting
{
    [gestureLockView setNeedsDisplayGestureLockErrorState:NO];
    NSLog(@"securityCodeSting: %@",securityCodeSting);
    [self send_event:_cdvcommand withMessage:@{@"code":securityCodeSting} Alive:NO State:YES];
}


- (void)send_event:(CDVInvokedUrlCommand *)command withMessage:(NSDictionary *)message Alive:(BOOL)alive State:(BOOL)state{
    CDVPluginResult* res = [CDVPluginResult resultWithStatus: (state ? CDVCommandStatus_OK : CDVCommandStatus_ERROR) messageAsDictionary:message];
    if(alive) [res setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult: res callbackId: command.callbackId];
}

@end
