#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
  SCREEN_TRANSITION_NONE,
  SCREEN_TRANSITION_FLIP,
  SCREEN_TRANSITION_CURL_UP,
  SCREEN_TRANSITION_CURL_DOWN,
  SCREEN_TRANSITION_MOVE_IN_BOTTOM_TO_TOP,
  SCREEN_TRANSITION_MOVE_OUT_TOP_TO_BOTTOM,
  SCREEN_TRANSITION_MOVE_IN_TOP_TO_BOTTOM,
  SCREEN_TRANSITION_MOVE_OUT_BOTTOM_TO_TOP,
  SCREEN_TRANSITION_MOVE_IN_RIGHT_TO_LEFT,
  SCREEN_TRANSITION_MOVE_OUT_LEFT_TO_RIGHT,
  SCREEN_TRANSITION_ROLL_DOWN_WITH_MASK,
  SCREEN_TRANSITION_ROLL_UP_WITH_MASK,
} SCREEN_TRANSITION;

#define MAX_DEPTH_OF_PUSHED_CONTROLLER 4

/**
 ScreenNav manages a stack of view controllers, implements similar screen
 navigation feature from UINavigationController. The major differences are:
  - ScreenNav don't require a root view controller.
  - ScreenNav can support customized transition animation easily, since you can
    hack the source directly.
 */
@interface ScreenNav : UIViewController {
  UIView *containerView, *floatingView, *transparentView;

  /// The current view controller stack.
  NSMutableArray *viewControllers, *popUpViews;

  NSUInteger maxDepthOfPushedController;
  NSMutableSet *pushedControllers;
}
@property(nonatomic, retain) UIView *containerView, *floatingView, *transparentView;
@property(nonatomic, retain) NSMutableArray *viewControllers, *popUpViews;
@property(nonatomic, retain) NSMutableSet *pushedControllers;

- (id)initWithViewController:(UIViewController *)controller;

/// The top view controller on the stack.
- (UIViewController *)topViewController;

/// The bottom view controller on the stack.
- (UIViewController *)bottomViewController;

- (void)floatView:(UIView *)targetView;
- (UIView *)defloatView;

- (void)popUpView:(UIView *)targetView;
- (void)closePopUpView;
- (void)onPopUpViewButton:(id)sender;

/// Push view controller to stack.
//// All pushed controllers have a depth limit accroding to
//// maxDepthOfPushedController. When pushing new controller,
//// controllers that are too deep in stack will be removed.
//// If you want a controller to be persistant, use
//// replace:with: instead.
- (void)push:(UIViewController *)ctl transition:(SCREEN_TRANSITION)transition;

/// Pop top view controller from stack.
- (UIViewController *)popWithTransition:(SCREEN_TRANSITION)transition;

/// Pop to specific view controller, which must appear in stack or nil.
- (NSArray *)popTo:(UIViewController *)ctl
        transition:(SCREEN_TRANSITION)transition;

/**
 Replace old view controller with new one. The oldViewCtl must appear in
 stack or nil. If is nil, means pop all controllers in hierarchy and push new
 one.
 */
- (void)replace:(UIViewController *)oldCtl
           with:(UIViewController *)newCtl
     transition:(SCREEN_TRANSITION)transition;

/// immediatelyReplace will wait until subview replaced
- (void)immediatelyReplace:(UIViewController *)oldCtl
                      with:(UIViewController *)newCtl
                transition:(SCREEN_TRANSITION)transition;

- (void)replace:(UIViewController *)oldCtl
           with:(UIViewController *)newCtl
     transition:(SCREEN_TRANSITION)transition
          after:(NSTimeInterval)seconds;

#pragma mark Private methods.

- (void)applyTransition:(UIViewController *)currentCtl
                nextCtl:(UIViewController *)nextCtl
             transition:(SCREEN_TRANSITION)transition
                   wait:(BOOL)waitUntilDone;

- (BOOL)shouldAutorotateToInterfaceOrientation:
  (UIInterfaceOrientation)toInterfaceOrientation;

// Pop to specific view controller without transition, return removed ctls.
- (NSArray *)_popTo:(UIViewController *)ctl;

@end
