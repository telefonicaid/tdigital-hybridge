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
#import "SBJson.h"

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _parser = [[SBJsonParser alloc] init];
    _writer = [[SBJsonWriter alloc] init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSURLProtocol registerClass:[NSURLProtocolBridge class]];
    // ***************
    // Example of subscription to an action named "currentTime"
    
    BridgeSubscriptor *subscriptor = [BridgeSubscriptor sharedInstance];

    // Handlers
    
    // Example handler, just parses data to JSON from ajax header in order to process it
    // and writes back JSON in a response header
    BridgeHandlerBlock_t timeHandler = ^(NSString *action, NSURLProtocol *url, NSString *data) {
        NSLog(@"Ha llegado la petición: %@", action);
        NSLog(@"Componentes: %@", [url.request.URL.pathComponents componentsJoinedByString:@","]);
        NSLog(@"Data: %@", data);
        
        NSDictionary *params = [_parser objectWithString:data];
        NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
        //NSString *ts = [json objectForKey:@"timestamp"];
        //[json setValue:ts  forKey:@"data"];
        [json setValue:@"application/json; charset=utf-8" forKey:@"Content-Type"];
        [json setValue:@"*" forKey:@"Access-Control-Allow-Origin"];
        [json setValue:@"Content-Type" forKey:@"Access-Control-Allow-Headers"];
        
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url.request.URL statusCode:200 HTTPVersion:@"1.1" headerFields:json];
        
        NSString *jsonString = [_writer stringWithObject:params];
        NSData *jsonBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        id client = [url client];
        [client URLProtocol:url didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocol:url didLoadData:jsonBody];
        [client URLProtocolDidFinishLoading:url];
        
        // Dispatch Event to WebView
        NSMutableString* ms = [[NSMutableString alloc] initWithString:@"JsBridge.dispatchEvent(\"JsBridgeMessage\","];
        [ms appendString:jsonString];
        [ms appendString:@")"];
        NSString *js = ms;
        [self performSelectorOnMainThread:@selector(runJsInWebview:) withObject:js waitUntilDone:NO];
    };
    
    // Subscribe to action named "currentTime"
    //[subscriptor subscribeAction:@"currentTime" withHandler:handler];
    [subscriptor subscribeAction:@"state" withHandler:timeHandler];
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
    NSString *js = @"document.dispatchEvent(JsBridge.event.JsBridgeReady);";
    [self performSelectorOnMainThread:@selector(runJsInWebview:) withObject:js waitUntilDone:NO];
    return YES;
}

- (NSString *)runJsInWebview:(NSString *)js
{
    NSLog(@"runJsInWebview: %@",js);
    NSString *jsResponse = [self.theWeb stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"runJsInWebview response: %@",jsResponse);
    return jsResponse;
}


@end
