//
//  AtlasManager.m
//  LogisticGiant
//
//  Created by Liu Lingguang on 7/30/11.
//  Copyright 2011 FrontGo. All rights reserved.
//

#import "AtlasManager.h"


#define TILE_WIDTH 20
#define TILE_HEIGHT 10

@implementation AtlasManager
@synthesize mapMatrix, layer;

- (void)initWithLayer:(CCLayer *)aLayer {
  self.layer = aLayer;
  [super init];
}

- (void)dealloc {
  self.mapMatrix = nil;
  [super dealloc];
}

- (void)drawMapBy:(NSString *)mapFileName {
  [self loadMatrixFromFile:mapFileName];
  [self schedule:@selector(loadImages:) interval:.1f]; 
}

- (void)loadMatrixFromFile:(NSString *)filePath {
  filePath = [[NSBundle mainBundle] pathForResource:filePath ofType:@""];
  NSString *matrixStr = [NSString stringWithContentsOfFile:filePath
                                                  encoding:NSASCIIStringEncoding
                                                     error:nil];
  NSArray *lines = [matrixStr componentsSeparatedByString:@"\n"];
  self.mapMatrix = [NSMutableArray arrayWithCapacity:[lines count]];
  for (NSString *line in lines) {
    NSArray *chars = [line componentsSeparatedByString:@" "];
    [mapMatrix addObject:chars];
  }
}

- (CGPoint)toIsometricPoint:(CGPoint)point {
  int uCount = [(NSArray *)[mapMatrix objectAtIndex:0] count];
  CGPoint origin = ccp(0, uCount * TILE_HEIGHT / 2);
  CGPoint p = ccp((point.x + point.y) * TILE_WIDTH / 2,
                  (point.y - point.x) * TILE_HEIGHT / 2);
  return ccpAdd(origin, p);
}

- (void)loadImages {
  [self unschedule:_cmd];

  int uCount = [(NSArray *)[mapMatrix objectAtIndex:0] count];
  int vCount = [mapMatrix count];
  for (int i = 0; i < uCount; i++) {
    for (int j = 0; j < vCount; j++) {
      ParamForAsync *pfa = [[[ParamForAsync alloc] init] autorelease];
      pfa.param1 = @"track_tile.png";
      pfa.param2 = [NSArray arrayWithObjects:[NSNumber numberWithInt:i],
                                             [NSNumber numberWithInt:j], nil];
      CCTextureCache *cusTexCache =
        (CCTextureCache *)[CCTextureCache sharedTextureCache];
      [cusTexCache addImageAsyncWithComstomizedParam:pfa
                                              target:self
                                            selector:@selector(imageLoaded:)];
    }
  }
}

- (void)imageLoaded:(ParamForAsync *)pfa {
  CCSprite *sprite = [CCSprite spriteWithTexture:pfa.param1];
  sprite.anchorPoint = ccp(0, TILE_HEIGHT / 2);
  NSArray *array = (NSArray *)pfa.param2;
  NSInteger u = [(NSNumber *)[array objectAtIndex:0] intValue];
  NSInteger v = [(NSNumber *)[array objectAtIndex:1] intValue];
  
  sprite.position = [self toIsometricPoint:ccp(u, v)];
  [layer addChild:sprite];
}

@end
