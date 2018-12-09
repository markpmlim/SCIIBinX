#ifndef __ERRORMESSAGES_H__
#define __ERRORMESSAGES_H__
/*
 *  ErrorMessages.h
 *  SCIIBinX
 *
 *  Created by mark lim on 10/7/17.
 *  Copyright 2017 IncrementalInnovation.com. All rights reserved.
 *
 */

typedef enum BSErrorCodes {
    kBSNoError                  =  0,
    kBSOpenFileError            = -1,
    kBSNoFileStartHeaderError   = -2,
    kBSAlphabetHeaderError      = -3,
    kBSHeaderCRCError           = -4,
    kBSUnexpectedEOFError       = -5,
    kBSBadLengthError           = -6,
    kBSWriteError               = -7,
    kBSOutputError              = -8,
    kBSBadSegmentCRCError       = -9,
    kBSSegmentHeaderError       = -11   // unused?
} BSErrorCodes;

#endif