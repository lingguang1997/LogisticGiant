//
//  Cocos2dPatches.h
//  LogisticGiant
//
//  Created by Liu Lingguang on 8/1/11.
//  Copyright 2011 FrontGo. All rights reserved.
//

#import "CCTextureCache.h"


@interface ParamForAsync : NSObject {
  id param1;
  id param2;
}
@property(readwrite, assign) id param1;
@property(readwrite, assign) id param2;

@end


@interface CusCCAsyncObject : NSObject {
  SEL selector_;
  id target_;
  ParamForAsync *data_;
}
@property(readwrite, assign) SEL selector;
@property(readwrite, retain) id target;
@property(readwrite, retain) ParamForAsync *data;

@end


@interface CCTextureCache (PassParameter)

- (void)addImageAsyncWithComstomizedParam:(ParamForAsync *)objectWithImagePath
                                   target:(id)target
                                 selector:(SEL)selector;
- (void)addImageWithCusAsyncObject:(CusCCAsyncObject*)async;

@end
