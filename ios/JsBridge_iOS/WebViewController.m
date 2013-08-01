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
    BridgeHandlerBlock_t timeHandler = ^(NSURLProtocol *url, NSString *data) {
        DDLogInfo(@"Ha llegado la petición time");
        DDLogInfo(@"Componentes: %@", [url.request.URL.pathComponents componentsJoinedByString:@","]);
        DDLogInfo(@"Data: %@", data);
        
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
        [self fireEventInWebView: (NSString*) @"HybridgeMessage" data:(NSString*) jsonString];
    };
  
    /**
     *	Bloque para manejar las peticiones OPTION (CORS preflight)
     *
     *	@param	action	Acción identificativa
     *	@param	url	Objeto URL
     *	@param	data	String conteniendo el JSON enviado en la pertición
     *
     *	@return	void
     */
    BridgeHandlerBlock_t preflightHandler = ^(NSURLProtocol *url, NSString *data) {
        
        NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
        
        [json setValue:@"application/json; charset=utf-8" forKey:@"Content-Type"];
        [json setValue:@"*" forKey:@"Access-Control-Allow-Origin"];
        [json setValue:@"Content-Type, data" forKey:@"Access-Control-Allow-Headers"];
        
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url.request.URL statusCode:200 HTTPVersion:@"1.1" headerFields:json];
        
        id client = [url client];
        [client URLProtocol:url didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocolDidFinishLoading:url];
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
    BridgeHandlerBlock_t productHandler = ^(NSURLProtocol *url, NSString *data) {
        DDLogInfo(@"Ha llegado la petición product info");
        DDLogInfo(@"Componentes: %@", [url.request.URL.pathComponents componentsJoinedByString:@","]);
        DDLogInfo(@"Data: %@", data);
      
        //NSDictionary *params = [_parser objectWithString:data];
        NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
        //NSString *ts = [json objectForKey:@"timestamp"];
        //[json setValue:ts  forKey:@"data"];
        [json setValue:@"application/json; charset=utf-8" forKey:@"Content-Type"];
        [json setValue:@"*" forKey:@"Access-Control-Allow-Origin"];
        [json setValue:@"Content-Type, data" forKey:@"Access-Control-Allow-Headers"];
      
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url.request.URL statusCode:200 HTTPVersion:@"1.1" headerFields:json];
      
        NSMutableDictionary *product = [[NSMutableDictionary alloc] init];
        // Get product info
        [product setValue:[NSNumber numberWithInt:100] forKey:@"downloaded"];
        NSString *jsonString = [_writer stringWithObject:product];
        NSData *jsonBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
      
        id client = [url client];
        [client URLProtocol:url didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocol:url didLoadData:jsonBody];
        [client URLProtocolDidFinishLoading:url];
      
        // Dispatch Event to WebView
        [self fireEventInWebView: (NSString*) @"HybridgeMessage" data:(NSString*) jsonString];
    };
  
    /**
     *	Bloque para manejar la navegación de WebView a DownloadManager
     *
     *	@param	url	Objeto URL
     *	@param	data	String conteniendo el JSON enviado en la pertición
     *
     *	@return	void
     */
    BridgeHandlerBlock_t downloadHandler = ^(NSURLProtocol *url, NSString *data) {
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
    BridgeHandlerBlock_t playHandler = ^(NSURLProtocol *url, NSString *data) {
        DDLogInfo(@"Ha llegado la petición: play");
        
    };
    
    [subscriptor subscribeAction:@"preflight" withHandler:preflightHandler];
    [subscriptor subscribeAction:@"product" withHandler:productHandler];
    [subscriptor subscribeAction:@"download" withHandler:downloadHandler];
    [subscriptor subscribeAction:@"play" withHandler:playHandler];
    [subscriptor subscribeAction:@"state" withHandler:timeHandler];

    self.theWeb = [[UIWebView alloc] initWithFrame:self.view.bounds];
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
  [self fireEventInWebView: (NSString*) @"HybridgeReady" data:(NSString*) @"{}"];

    return YES;
}

- (NSString *)runJsInWebview:(NSString *)js
{
    DDLogInfo(@"runJsInWebview: %@",js);
    NSString *jsResponse = [self.theWeb stringByEvaluatingJavaScriptFromString:js];
    DDLogInfo(@"runJsInWebview response: %@",jsResponse);
    return jsResponse;
}

- (void)fireEventInWebView:(NSString *)eventName data:(NSString *)jsonString
{
    DDLogInfo(@"Enviando evento a Webview: %@", eventName);
    NSMutableString* ms = [[NSMutableString alloc] initWithString:@"Hybridge.fireEvent(\""];
    [ms appendString:eventName];
    [ms appendString:@"\","];
    [ms appendString:(jsonString?jsonString:@"{}")];
    [ms appendString:@")"];
    NSString *js = ms;
    [self performSelectorOnMainThread:@selector(runJsInWebview:) withObject:js waitUntilDone:NO];
}

@end
