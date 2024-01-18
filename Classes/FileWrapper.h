//
//  FileWrapper.h
//  SCIIBinX
//
//  Created by mark lim on 10/7/17.
//  Copyright 2017 Incremental Innovation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// this procedure of wrapping the BinScii file object seems necessary.
@interface FileWrapper : NSObject
{
#if __OBJC__
    id bsqFile;
#endif
#if __cplusplus__   
    BinScii *bsqFile;           // C++ object;
#endif
    NSString *destFolderName;   // both are not needed currently
    NSString *fileName;
    NSString *pathName;         // Only this is required.

}

@property (nonatomic, assign) id        bsqFile;
@property (nonatomic, retain) NSString  *destFolderName;
@property (nonatomic, retain) NSString  *pathName;

- (id) initWithPath:(NSString *)path
              error:(NSError **)errorPtr;

- (BOOL) unpack:(NSError **)errorPtr;

- (NSDictionary *) attributesOfDecodedFile;

- (BOOL) verifyHeader:(NSError **)errorPtr;

- (NSString *) pathOfDecodedFile;

- (NSUInteger) decodedFileLength;

@end
