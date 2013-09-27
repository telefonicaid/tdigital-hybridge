//
//  NSURLProtocolBridge.h
//  Hybridge_iOS
//
//  Created by David Garcia on 12/06/13.
//  Copyright (c) 2013 tid.es. All rights reserved.
//

#import "MCALog.h"

@class SBJsonParser;
@class SBJsonWriter;

@interface NSURLProtocolBridge : NSURLProtocol
{
    
@private
    SBJsonParser *parser;
    SBJsonWriter *writer;
}

@end
