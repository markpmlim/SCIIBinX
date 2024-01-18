//
//  Error.h
//  SCIIBinX
//
//  Created by mark lim on 10/7/17.
//  Copyright 2017 Incremental Innovation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "ErrorCodes.h"

/*
 This class is used to report errors specific to SCIIBinX.
*/

@interface BSCError : NSError

+ (id) errorWithCode:(BSErrorCodes)code;

@end
