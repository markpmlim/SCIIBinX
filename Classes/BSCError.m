//
//  Error.m
//  SCIIBinX
//
//  Created by mark lim on 10/7/17.
//  Copyright 2017 Incremental Innovation. All rights reserved.
//

#import "BSCError.h"

NSString* const BinSciiErrorDomain = @"com.innovation.BinScii.ErrorDomain";

@implementation BSCError

- (id)initWithCode:(BSErrorCodes)code
{
    // concise description of the error
    NSString *errorDescription = nil;
    // cause for the error
    switch (code)
    {
    case kBSOpenFileError:
        errorDescription = @"File could not be opened";
        break;
    case kBSNoFileStartHeaderError:
        errorDescription = @"Could not find start of segment";
        break;
    case kBSAlphabetHeaderError:
        errorDescription = @"Wrong Alphabet set";
        break;
    case kBSHeaderCRCError:
        errorDescription = @"Third Line of Segment Header is corrupt";
        break;
    case kBSUnexpectedEOFError:
        errorDescription = @"Unexpected end-of-file error";
        break;
    case kBSBadLengthError:
        errorDescription = @"Bad decoded string length";
        break;
    case kBSWriteError:
        errorDescription = @"Can't write to decoded file";
        break;
    case kBSOutputError:
        errorDescription = @"Decoded File could not be opened for writing";
        break;
    case kBSBadSegmentCRCError:
        errorDescription = @"Corrupt Segment CRC";
        break;
    case kBSSegmentHeaderError:
        // not used.
        errorDescription = @"Corrupt segment header";
        break;
    default:
        break;
    }
    NSDictionary *errorUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       errorDescription, NSLocalizedDescriptionKey,
                                       nil];
    return [super initWithDomain:BinSciiErrorDomain
                            code:code
                        userInfo:errorUserInfo];
}

// Convenience method - designated method
+ (id)errorWithCode:(BSErrorCodes)code
{
    return [[[BSCError alloc] initWithCode:code] autorelease];
}

@end
