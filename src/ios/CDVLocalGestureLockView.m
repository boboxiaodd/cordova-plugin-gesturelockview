#import <Cordova/CDV.h>
#import "CDVLocalWWW.h"
#import "SSZipArchive.h"
#import <JGProgressHUD/JGProgressHUD.h>

@interface CDVLocalWWW()
@property (nonatomic,strong) JGProgressHUD* hud;
@end

@implementation CDVLocalWWW
- (void)pluginInitialize
{
    NSLog(@"--------------- init CDVLocalWWWW --------");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *srcPath = [[[NSBundle mainBundle] URLForResource:@"www" withExtension:@"zip"] absoluteString];
    NSString *zipPath = [[NSURL URLWithString:srcPath] path];
    NSArray *directoryPaths = [fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    NSURL *distPath = [[directoryPaths firstObject] URLByAppendingPathComponent:@"NoCloud/www"];
    NSString *destinationPath = [distPath path];
    NSError *error;
    if([SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath overwrite:YES password:nil error:&error delegate:nil]) {
        NSLog(@"unzip success!");
    } else {
        NSLog(@"%@ - %@", @"Error occurred during unzipping", [error localizedDescription]);
    }
}
//进度条
- (void)showProgress:(CDVInvokedUrlCommand *)command
{
    if(_hud) return;
    NSDictionary *options = [command.arguments objectAtIndex: 0];
    BOOL is_progress = [[options valueForKey:@"is_progress"] boolValue];
    NSString * title = [options objectForKey:@"title"] ?: @"加载中...";
    _hud = [[JGProgressHUD alloc] init];
    _hud.textLabel.text = title;
    if(is_progress){
        _hud.detailTextLabel.text = @"0% 完成";
        _hud.indicatorView = [[JGProgressHUDPieIndicatorView alloc] init];
        _hud.progress = 0.0f;
    }else{
        _hud.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] init];
    }
    _hud.style = JGProgressHUDStyleLight;
    [_hud showInView:self.viewController.view];
}
- (void)setProgress:(CDVInvokedUrlCommand *)command
{
    if(!_hud) return;
    NSDictionary *options = [command.arguments objectAtIndex: 0];
    _hud.progress = [[options objectForKey:@"progress"] floatValue] ?: 0.0;
    _hud.detailTextLabel.text = [NSString stringWithFormat:@"%.0f%@ 完成",_hud.progress * 100,@"%"];
}
- (void)hideProgress:(CDVInvokedUrlCommand *)command
{
    if(!_hud) return;
    [_hud dismiss];
    _hud = nil;
}

-(void) goSetting:(CDVInvokedUrlCommand *)command
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
}
-(void) goURL:(CDVInvokedUrlCommand *)command
{
    NSDictionary *options = [command.arguments objectAtIndex: 0];
    NSString *urlstr = [options valueForKey:@"url"];
    NSURL *url = [NSURL URLWithString:urlstr];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL res){
        [self send_event:command withMessage:@{@"success":@"success"} Alive:NO State:YES];
    }];
}

-(void) playBeep:(CDVInvokedUrlCommand *)command
{
    UIImpactFeedbackGenerator *feedBackGenertor = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [feedBackGenertor impactOccurred];
}

- (void)getSystemInfo:(CDVInvokedUrlCommand*)command
{
    BOOL is_debug = false;
    BOOL is_iphonex = false;

    #ifdef DEBUG
        is_debug = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsBool:(true)];
    #endif
    CGFloat safeBottom =  UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    if(safeBottom > 0.0){
        is_iphonex = true;
    }
    [self send_event:command withMessage:@{
        @"is_debug":@(is_debug),
        @"is_iphonex":@(is_iphonex),
        @"auth": [self settingForKey:@"authkey"],
    } Alive:NO State:YES];
}



- (id)settingForKey:(NSString*)key
{
    return [self.commandDelegate.settings objectForKey:[key lowercaseString]];
}

- (void)send_event:(CDVInvokedUrlCommand *)command withMessage:(NSDictionary *)message Alive:(BOOL)alive State:(BOOL)state{
    CDVPluginResult* res = [CDVPluginResult resultWithStatus: (state ? CDVCommandStatus_OK : CDVCommandStatus_ERROR) messageAsDictionary:message];
    if(alive) [res setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult: res callbackId: command.callbackId];
}

@end
