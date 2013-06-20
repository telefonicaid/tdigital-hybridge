//
//  WebViewController.m
//  enj-iPhone
//
//  Created by ALTEN on 18/09/12.
//  Copyright (c) 2012 EnjoyMobile. All rights reserved.
//

#import "WebViewController.h"
#import "NSURLProtocolBridge.h"


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
