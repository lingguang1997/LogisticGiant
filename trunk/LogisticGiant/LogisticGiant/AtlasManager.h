//
//  AtlasManager.h
//  LogisticGiant
//
//  Created by Liu Lingguang on 7/30/11.
//  Copyright 2011 FrontGo. All rights reserved.
//

#import "LG.h"


@interface AtlasManager : CCNode {
 @public
  NSMutableArray *mapMatrix;
  CCLayer *layer;
}
@property(retain) NSMutableArray *mapMatrix;
@property(assign) CCLayer *layer;

- (void)drawMapBy:(NSString *)mapFileName;
- (void)loadMatrixFromFile:(NSString *)filePath;
- (CGPoint)toIsometricPoint:(CGPoint)point;
- (void)loadImages;
- (void)imageLoaded:(ParamForAsync *)pfa;

@end
