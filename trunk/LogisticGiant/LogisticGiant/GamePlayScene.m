//
//  GamePlayScene.m
//  LogisticGiant
//
//  Created by Liu Lingguang on 8/3/11.
//  Copyright 2011 FrontGo. All rights reserved.
//

#import "LG.h"


@implementation GamePlayScene

- (id)init {
  if (!(self = [super init])) {
    return nil;
  }
  CCSprite *bg = [CCSprite spriteWithFile:@"ipad.jpg"];
  [self addChild:bg];
  return self;
}

@end