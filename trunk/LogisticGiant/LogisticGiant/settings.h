//
//  settings.h
//  LogisticGiant
//
//  Created by Liu Lingguang on 8/2/11.
//  Copyright 2011 FrontGo. All rights reserved.
//

#pragma mark Cocos2D
#define FRAME_RATE    30.0
#define PIXEL_FORMAT  kRGBA8
#define DISPLAY_FPS   YES
#define SCREEN_WIDTH  768
#define SCREEN_HEIGHT 1024
#define SCREEN_CENTER ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)

extern const BOOL SHOW_FPS;


enum UIVIEW_TAGS {
  ROLLING_MASK_VIEW_TAG
};


#pragma mark Global variables
extern LGScreenNav *screenNav;