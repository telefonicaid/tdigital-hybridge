//
//  WebViewController.h
//  enj-iPhone
//
//  Created by ALTEN on 18/09/12.
//  Copyright (c) 2012 EnjoyMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBJsonParser;
@class SBJsonWriter;

@interface WebViewController : UIViewController <UIWebViewDelegate>
{

@private
    SBJsonParser *_parser;
    SBJsonWriter *_writer;
}

@property (strong) UIWebView *theWeb;

- (NSString *)runJsInWebview:(NSString *)js;

@end

