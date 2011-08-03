//
//  GamePlay.m
//  LogisticGiant
//
//  Created by Liu Lingguang on 8/3/11.
//  Copyright 2011 FrontGo. All rights reserved.
//

#import "LG.h"


@implementation GamePlayController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  GamePlayScene *gps = [GamePlayScene node];
  
  AtlasManager *atlasManager = [[AtlasManager alloc] initWithNode:gps];
  [atlasManager drawMapBy:@"map_1"];
  
  [[CCDirector sharedDirector] runWithScene:gps];
}

@end
