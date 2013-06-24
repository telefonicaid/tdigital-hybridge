//
//  WebViewController.m
//  enj-iPhone
//
//  Created by ALTEN on 18/09/12.
//  Copyright (c) 2012 EnjoyMobile. All rights reserved.
//

#import "WebViewController.h"
#import "NSURLProtocolBridge.h"
#import "BridgeSubscriptor.h"

@implementation WebViewController

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
    
    [NSURLProtocol registerClass:[NSURLProtocolBridge class]];
    
    // ***************
    // Example of subscription to an action named "action1"
    
    BridgeSubscriptor *subscriptor = [BridgeSubscriptor sharedInstance];
    // Block to handle request to action1
    BridgeHandlerBlock_t handler = ^(NSString *action, NSArray *pathComponents, NSString *data) {
        NSLog(@"Ha llegado la petición: %@", action);
        NSLog(@"Componentes: %@", [pathComponents componentsJoinedByString:@","]);
        NSLog(@"Data: %@", data);
    };
    // Subscribe to action named "action1"
    [subscriptor subscribeAction:@"action1" withHandler:handler];
    // ***************
    
    self.theWeb = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.theWeb.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.theWeb];
    
    // Carga HTML local
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"index" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    [self.theWeb loadRequest:[NSURLRequest requestWithURL:url]];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

@end
