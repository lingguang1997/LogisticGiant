//
//  Cocos2dPatches.m
//  LogisticGiant
//
//  Created by Liu Lingguang on 8/1/11.
//  Copyright 2011 FrontGo. All rights reserved.
//

#import "Cocos2dPatches.h"
#import "CCFileUtils.h"
#import "ccMacros.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
static EAGLContext *auxGLcontext = nil;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
static NSOpenGLContext *auxGLcontext = nil;
#endif

@implementation CusCCAsyncObject
@synthesize selector = selector_;
@synthesize target = target_;
@synthesize data = data_;

- (void)dealloc {
  CCLOGINFO(@"cocos2d: deallocing %@", self);
  [target_ release];
  [data_ release];
  [super dealloc];
}

@end


@implementation ParamForAsync
@synthesize param1, param2;

@end


@implementation CCTextureCache (PassParameter)

- (void)addImageAsyncWithComstomizedParam:(ParamForAsync *)objectWithImagePath
                                   target:(id)target
                                 selector:(SEL)selector {
  NSAssert(objectWithImagePath.param1 != nil,
           @"TextureCache: fileimage MUST not be nill");
  
  // optimization
  
  CCTexture2D * tex;
  
  objectWithImagePath.param1 = ccRemoveHDSuffixFromFile(objectWithImagePath.param1);
  
  if ((tex = [textures_ objectForKey:objectWithImagePath.param1])) {
    [target performSelector:selector withObject:tex];
    return;
  }
  
  // schedule the load
  
  CusCCAsyncObject *asyncObject = [[CusCCAsyncObject alloc] init];
  asyncObject.selector = selector;
  asyncObject.target = target;
  asyncObject.data = objectWithImagePath;
  
  [NSThread detachNewThreadSelector:@selector(addImageWithCusAsyncObject:)
                           toTarget:self
                         withObject:asyncObject];
  [asyncObject release];
}

- (void)addImageWithCusAsyncObject:(CusCCAsyncObject*)async {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
  // textures will be created on the main OpenGL context
  // it seems that in SDK 2.2.x there can't be 2 threads creating textures at the same time
  // the lock is used for this purpose: issue #472
  [contextLock_ lock];
  if (auxGLcontext == nil) {
    auxGLcontext = [[EAGLContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES1
                    sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]];
    
    if(!auxGLcontext)
      CCLOG(@"cocos2d: TextureCache: Could not create EAGL context");
  }
  
  if([EAGLContext setCurrentContext:auxGLcontext]) {
    
    // load / create the texture
    CCTexture2D *tex = [self addImage:async.data.param1];
    
    ParamForAsync *pfa = [[[ParamForAsync alloc] init] autorelease];
    pfa.param1 = tex;
    pfa.param2 = async.data.param2;
    
    // The callback will be executed on the main thread
    [async.target performSelectorOnMainThread:async.selector withObject:pfa waitUntilDone:NO];		
    
    [EAGLContext setCurrentContext:nil];
  } else {
    CCLOG(@"cocos2d: TetureCache: EAGLContext error");
  }
  [contextLock_ unlock];
  
  [autoreleasepool release];
#endif
}

@end