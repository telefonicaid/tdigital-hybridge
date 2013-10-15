//
//  WebViewController.h
//  enj-iPhone
//
//  Created by ALTEN on 18/09/12.
//  Copyright (c) 2012 EnjoyMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCALog.h"
#import "Hybridge.h"

@class SBJsonParser;
@class SBJsonWriter;

@interface WebViewController : UIViewController <UIWebViewDelegate>
{

@private
    SBJsonParser *_parser;
    SBJsonWriter *_writer;
    Hybridge *_hybridge;
}

@property (strong) UIWebView *webview;

- (void) fireJavascriptEvent:(NSString *)eventName data:(NSString *)jsonString;

@end

