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
  PAGE_TAG_START = 2000,
  PLAYER_TAG_START = 3000,
  FENCE_TAG_START = 4000,
  WOOD_FLOOR_TAG_START = 4500,
  NAME_TAG = 5000,
  SCARESROW_TAG,
  AVATAR_TAG,
  BOUNTY_TAG,
  STATE_TAG,
  ROLLING_MASK_VIEW_TAG,
  SALOON_CUSTOMIZE_ME_BUTTON_TAG,
  HIGHLIGHT_OVERLAY_TAG,
  HIGHLIGHT_BUBBLE_TAG,
  GOLD_BAG_VIEW_TAG,
};


#pragma mark Global variables
extern LGScreenNav *screenNav;