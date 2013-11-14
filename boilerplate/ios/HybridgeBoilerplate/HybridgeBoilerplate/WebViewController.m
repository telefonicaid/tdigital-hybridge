/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

#import "WebViewController.h"
#import "Hybridge.h"

@interface WebViewController ()
{
    @private Hybridge *_hybridge;
}
@end

@implementation WebViewController

NSString *_targetURL = @"http://127.0.0.1/hybridge.html";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // Hybridge binding
    _hybridge = [Hybridge sharedInstance];

    // Handlers
    
    // Example handler, just parses data to JSON from ajax header in order to process it
    // and writes back JSON in a response header
    HybridgeHandlerBlock_t initHandler = ^(NSURLProtocol *url, NSString *data, NSHTTPURLResponse *response) {
        
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        
        BOOL hybridgeInitialized = [[params objectForKey:@"initialized"] boolValue];
        if (hybridgeInitialized) {
            [self fireJavascriptEvent:kHybridgeEventReady data:(NSString*) @"{}"];
        }
    };
    
    [_hybridge subscribeAction:@"init" withHandler:initHandler];
    
    self.webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webview.delegate = self;
    self.webview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.webview];
    
    // Load local HTML
    //NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"index" ofType:@"html"];
    //NSURL *url = [NSURL fileURLWithPath:filePath];
    
    // Load HTTP
    NSURL*url = [NSURL URLWithString:_targetURL];
  
    [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_hybridge initJavascript:self.webview];
}

- (void) fireJavascriptEvent:(NSString *)eventName data:(NSString *)jsonString
{
    [_hybridge fireEventInWebView:eventName data:jsonString web:self.webview];
}

@end
