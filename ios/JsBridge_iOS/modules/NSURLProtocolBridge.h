/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

@class SBJsonParser;
@class SBJsonWriter;

@interface NSURLProtocolBridge : NSURLProtocol
{
    
@private
    SBJsonParser *parser;
    SBJsonWriter *writer;
}

@end
