//
//  BSQArchive.m
//  QuickLookBSQ
//
//  Created by mark lim on 10/6/17.
//  Copyright 2017 IncrementalInnovation. All rights reserved.
//

#import "BSQArchive.h"
#import "FileWrapper.h"


@implementation BSQArchive
@synthesize fileWrapper;

- (id)initWithURL:(NSURL *)url
{
	self = [super init];
	if (self)
	{
		NSString *path = url.path;
		fileWrapper = [[FileWrapper alloc] initWithPath:path];
		if (fileWrapper == nil)
		{
			self = nil;
		}
		if ([fileWrapper verifyHeader] == NO)
		{
			self = nil;
		}
	}
	return self;
}

- (void)dealloc
{
	//printf("deallocating bsq archive\n");
	if (fileWrapper != nil)
	{
		[fileWrapper release];
		fileWrapper = nil;
	}
	[super dealloc];
}

- (NSString *)fileName
{
	NSString *path = [fileWrapper pathOfDecodedFile];
	return [path lastPathComponent];
}

- (NSDictionary *)attributes
{
	return [fileWrapper attributesOfDecodedFile];
}

@end
