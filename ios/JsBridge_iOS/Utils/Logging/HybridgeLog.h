//
//  HybridgeLog.h
//  JsBridge_iOS
//
//  Created by David Garcia on 11/07/13.
//  Copyright (c) 2013 tid.es. All rights reserved.
//

#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "DDASLLogger.h"
#import "DefLog.h"

#ifndef HybridgeLog_h
#define HibridgeLog_h

#ifdef DEBUG
// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_DEBUG;

#else

static const int ddLogLevel = LOG_LEVEL_DEBUG;

#endif

#endif