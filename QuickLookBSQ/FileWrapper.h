//
//  FileWrapper.h
//  QuickLookBSQ
//
//  Created by mark lim on 12/28/13.
//  Copyright 2013 IncrementalInnovation.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// this procedure of wrapping the BinScii file object seems necessary.
@interface FileWrapper : NSObject
{
#if __OBJC__
	id bsqFile;
#endif
#if __cplusplus__	
	BinScii *bsqFile;			// C++ object;
#endif
	
}

@property (nonatomic, assign) id		bsqFile;

- (id) initWithPath:(NSString *)path;

- (NSDictionary *) attributesOfDecodedFile;

- (BOOL) verifyHeader;

- (NSString *) pathOfDecodedFile;

@end
