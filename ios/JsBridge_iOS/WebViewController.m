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
#import "Hybridge.h"

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
        _parser = [[SBJsonParser alloc] init];
        _writer = [[SBJsonWriter alloc] init];

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
    BridgeHandlerBlock_t timeHandler = ^(NSURLProtocol *url, NSString *data, NSHTTPURLResponse *response) {
        DDLogInfo(@"Ha llegado la petición time");
        DDLogInfo(@"Componentes: %@", [url.request.URL.pathComponents componentsJoinedByString:@","]);
        DDLogInfo(@"Data: %@", data);
        
        NSDictionary *params = [_parser objectWithString:data];
        
        NSString *jsonString = [_writer stringWithObject:params];
        NSData *jsonBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        id client = [url client];
        [client URLProtocol:url didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocol:url didLoadData:jsonBody];
        [client URLProtocolDidFinishLoading:url];
        
        // Dispatch Event to WebView
        [_hybridge fireEventInWebView:@"HybridgeMessage" data:jsonString web:self.theWeb];
    };
    
    /**
     *	Bloque para manejar las peticiones de infrmación de producto
     *
     *	@param	action	Acción identificativa
     *	@param	url	Objeto URL
     *	@param	data	String conteniendo el JSON enviado en la pertición
     *
     *	@return	void
     */
    BridgeHandlerBlock_t productHandler = ^(NSURLProtocol *url, NSString *data, NSHTTPURLResponse *response) {
        DDLogInfo(@"Ha llegado la petición product info");
        DDLogInfo(@"Componentes: %@", [url.request.URL.pathComponents componentsJoinedByString:@","]);
        DDLogInfo(@"Data: %@", data);
      
        NSMutableDictionary *product = [[NSMutableDictionary alloc] init];
        // Get product info
        [product setValue:[NSNumber numberWithInt:0] forKey:@"downloaded"];
        NSString *jsonString = [_writer stringWithObject:product];
        NSData *jsonBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
      
        id client = [url client];
        [client URLProtocol:url didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocol:url didLoadData:jsonBody];
        [client URLProtocolDidFinishLoading:url];
      
        // Dispatch Event to WebView
        [_hybridge fireEventInWebView:@"HybridgeMessage" data:jsonString web:self.theWeb];
    };
  
    /**
     *	Bloque para manejar la navegación de WebView a DownloadManager
     *
     *	@param	url	Objeto URL
     *	@param	data	String conteniendo el JSON enviado en la pertición
     *
     *	@return	void
     */
    BridgeHandlerBlock_t downloadHandler = ^(NSURLProtocol *url, NSString *data, NSHTTPURLResponse *response) {
        DDLogInfo(@"Ha llegado la petición download");
        
    };
    
    /**
     *	Bloque para manejar la navegación de WebView al Player
     *
     *	@param	url	Objeto URL
     *	@param	data	String conteniendo el JSON enviado en la pertición
     *
     *	@return	void
     */
    BridgeHandlerBlock_t playHandler = ^(NSURLProtocol *url, NSString *data, NSHTTPURLResponse *response) {
        DDLogInfo(@"Ha llegado la petición: play");
        
    };
    
    [_hybridge subscribeAction:@"product" withHandler:productHandler];
    [_hybridge subscribeAction:@"download" withHandler:downloadHandler];
    [_hybridge subscribeAction:@"play" withHandler:playHandler];
    [_hybridge subscribeAction:@"state" withHandler:timeHandler];
    
    self.theWeb = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.theWeb.delegate = self;
    self.theWeb.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.theWeb];
    
    // Carga HTML local
    //NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"index" ofType:@"html"];
    //NSURL *url = [NSURL fileURLWithPath:filePath];
  
    // Carga de aplicacion web
    NSURL*url = [NSURL URLWithString:@"http://127.0.0.1/#movies/507/Obama9"];
  
    [self.theWeb loadRequest:[NSURLRequest requestWithURL:url]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [_hybridge fireEventInWebView:@"HybridgeReady" data:@"{}" web:self.theWeb];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DDLogInfo(@"WebView: webViewDidFinishLoad");
    [_hybridge initJavascript:self.theWeb];
}

- (void) fireJavascriptEvent:(NSString *)eventName data:(NSString *)jsonString
{
    [_hybridge fireEventInWebView:eventName data:jsonString web:self.theWeb];
}

@end
