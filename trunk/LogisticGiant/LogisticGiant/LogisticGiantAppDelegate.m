//
//  LogisticGiantAppDelegate.m
//  LogisticGiant
//
//  Created by Liu Lingguang on 7/22/11.
//  Copyright 2011 FrontGo. All rights reserved.
//

#import "LG.h"


@implementation LogisticGiantAppDelegate
@synthesize window;

- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Set up Logger
  ASLogger *logger = [ASLogger defaultLogger];
  [logger setName:@"LogisticGiant"
         facility:@"com.frontgo.lg"
          options:ASL_OPT_NO_REMOTE|ASL_OPT_STDERR];
  [logger setFilter:ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG)];
  
#ifdef LOG_MEMORY_USAGE
  ASLogWarning(@"Before init app.");
  print_free_memory();
#endif

  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]
                 autorelease];
  [window setUserInteractionEnabled:YES];
  [window setMultipleTouchEnabled:YES];

  screenNav = [[LGScreenNav alloc] initWithViewController:
               [[GamePlayController new] autorelease]];
  [window addSubview:screenNav.view];

  [window makeKeyAndVisible];
  
  // must be called before any other call to the director
  // default NSTimer Director sometimes not working under OS4
  if(![CCDirector setDirectorType:CCDirectorTypeDisplayLink])
    [CCDirector setDirectorType:CCDirectorTypeDefault];
  [[CCDirector sharedDirector] setAnimationInterval:1.0 / FRAME_RATE];
  
  // Create a depth buffer of 24 bits
  // These means that openGL z-order will be taken into account
  // [[CCDirector sharedDirector] setDepthBufferFormat:kDepthBuffer16];
  
  // before creating any layer, set the landscape mode
  [[CCDirector sharedDirector] setDisplayFPS:DISPLAY_FPS];
  
  
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc {
  self.window = nil;
  [super dealloc];
}

@end
