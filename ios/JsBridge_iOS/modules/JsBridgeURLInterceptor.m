#import "JsBridgeURLInterceptor.h"
#import "NativeAction.h"

const NSString *commPrefix = @"bridge";

@implementation JsBridgeURLInterceptor

@synthesize delegate = mDelegate;

/*!
 * Este método es llamado antes de dar salida a NSURLRequest. Facilita la intercepción de la petición ajax
 */
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    
    NSURL *url = [request URL];
    
    // Comprueba si es una petición que deba ser interceptada
    if ([[url host] caseInsensitiveCompare:(NSString *) commPrefix] == NSOrderedSame) {
        
        NSString *action = nil;
        if ([[url pathComponents] count] > 1) {
            action = [[url pathComponents] objectAtIndex:1];
        }
        NSString *method = [request HTTPMethod];
        NSDictionary *params = nil;
        
        if ([method isEqualToString:@"HEAD"]) {
            NSLog(@"Petición ajax HEAD interceptada");
            // TODO: process headers data
        }
        
        // Crear un objeto NativeAction para transportar la petición al manejador nativo
//        NativeAction *nativeAction = [[NativeAction alloc] initWithAction:action method:method params:params];
        NSError *error = nil;
        NSMutableDictionary *result = nil;
//        NSMutableDictionary *result = [[self.delegate handleAction:nativeAction error:&error] mutableCopy];
        
        // Error
        if (error) {
            [result setObject:@{
             @"code" : [NSNumber numberWithInt:error.code],
             @"message" : [error localizedDescription]
             
             }          forKey:@"error"];
        }
        
        // Se crea el objeto NSCachedURLResponse que devolverá el método al callback javascript.
        NSCachedURLResponse *cachedResponse = nil;
        if (result) {
            // TODO: procesar JSON
            /*
            NSString *jsonString = [[[SBJsonWriter alloc] init] stringWithObject:result];
            NSData *jsonBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSURLResponse *res = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:@"application/json" expectedContentLength:[jsonBody length] textEncodingName:nil];
            cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:res data:jsonBody];
            */
        }
        return cachedResponse;
    }
    
    // if not matching our custom host, allow system to handle it
    return [super cachedResponseForRequest:request];
}

@end


@implementation NSURLCache (JsBridge)

+ (id <JsBridgeDelegate>)jsBridgeDelegate {
    NSURLCache *sharedURLCache = [NSURLCache sharedURLCache];
    if ([sharedURLCache isKindOfClass:[JsBridgeURLInterceptor class]]) {
        return [(JsBridgeURLInterceptor *) sharedURLCache delegate];
    }
    return nil;
}

+ (void)setJsBridgeDelegate:(id <JsBridgeDelegate>)delegate {
    NSURLCache *sharedURLCache = [NSURLCache sharedURLCache];
    if ([sharedURLCache isKindOfClass:[JsBridgeURLInterceptor class]]) {
        [(JsBridgeURLInterceptor *) sharedURLCache setDelegate:delegate];
    }
}

@end