#import "LG.h"

@interface TriggerReplaceInfo : NSObject {
  UIViewController *oldCtl;
  UIViewController *newCtl;
  SCREEN_TRANSITION transition;
}
@property (nonatomic, retain) UIViewController *oldCtl, *newCtl;
@property (nonatomic, assign) SCREEN_TRANSITION transition;
@end

@implementation TriggerReplaceInfo
@synthesize oldCtl, newCtl, transition;
- (void)dealloc {
  self.oldCtl = nil;
  self.newCtl = nil;
  [super dealloc];
}
@end


@implementation ScreenNav
@synthesize viewControllers, containerView, floatingView;
@synthesize pushedControllers, popUpViews, transparentView;

- (id)initWithViewController:(UIViewController *)controller {
  if (!(self = [super init]))
    return nil;
  maxDepthOfPushedController = MAX_DEPTH_OF_PUSHED_CONTROLLER;
  self.viewControllers = [NSMutableArray arrayWithCapacity:
                          maxDepthOfPushedController + 1];
  if (controller)
    [viewControllers addObject:controller];
  self.pushedControllers = [NSMutableSet setWithCapacity:
                            maxDepthOfPushedController + 1];
  return self;
}

- (void)dealloc {
  self.viewControllers = nil;
  self.containerView = nil;
  self.floatingView = nil;
  self.pushedControllers = nil;
  self.popUpViews = nil;
  self.transparentView = nil;
  [super dealloc];
}

- (UIView *)createUIView {
  return [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
}

- (void)loadView {
  self.containerView = [self createUIView];
  if ([viewControllers count]) {
    UIViewController *controller = [viewControllers lastObject];
    UIView *nextView = controller.view;
    [controller viewWillAppear:NO];
    [containerView addSubview:nextView];
    [controller viewDidAppear:NO];
  }
  self.view = [self createUIView];
  [self.view addSubview:containerView];
  self.popUpViews = [NSMutableArray array];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
  (UIInterfaceOrientation)toInterfaceOrientation {
  return NO;
}

- (UIViewController *)topViewController {
  int count = [viewControllers count];
  if (count > 0) {
    return [[[viewControllers objectAtIndex:count-1] retain] autorelease];
  }
  return nil;
}

- (UIViewController *)bottomViewController {
  int count = [viewControllers count];
  if (count > 0) {
    return [[[viewControllers objectAtIndex:0] retain] autorelease];
  }
  return nil;
}

- (void)floatView:(UIView *)targetView {
  [floatingView removeFromSuperview];
  self.floatingView = targetView;
  [self.view addSubview:floatingView];
}

- (UIView *)defloatView {
  if (!floatingView)
    return nil;
  [floatingView removeFromSuperview];
  UIView *old = [[floatingView retain] autorelease];
  self.floatingView = nil;
  return old;
}

- (void)popUpViewAnimStep3Finished:(NSString *)animationID
                          finished:(NSNumber *)finished
                           context:(void *)context {
}

- (void)popUpViewAnimStep2Finished:(NSString *)animationID
                          finished:(NSNumber *)finished
                           context:(void *)context {
  [UIView beginAnimations:animationID context:NULL];
  [UIView setAnimationDuration:1/7.5];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationDidStopSelector:@selector(popUpViewAnimStep3Finished:finished:context:)];
  ((UIView *)[popUpViews lastObject]).transform = CGAffineTransformIdentity;
  [UIView commitAnimations];
}

- (void)popUpViewAnimStep1Finished:(NSString *)animationID
                          finished:(NSNumber *)finished
                           context:(void *)context {
  [UIView beginAnimations:animationID context:NULL];
  [UIView setAnimationDuration:1/15.0];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationDidStopSelector:@selector(popUpViewAnimStep2Finished:finished:context:)];
  ((UIView *)[popUpViews lastObject]).transform = CGAffineTransformMakeScale(.9, .9);
  [UIView commitAnimations];
}

- (void)beginPopUpViewAnim {
  UIView *targetView = (UIView *)[popUpViews lastObject];
  if ([targetView respondsToSelector:@selector(viewWillAppear)])
    [targetView performSelector:@selector(viewWillAppear)];
  targetView.transform = CGAffineTransformMakeScale(.1, .1);
  targetView.alpha = .01;
  [self.view addSubview:targetView];
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:.2];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
  [UIView setAnimationDidStopSelector:@selector(popUpViewAnimStep1Finished:finished:context:)];
  targetView.transform = CGAffineTransformMakeScale(1.1, 1.1);
  targetView.alpha = 1;
  [UIView commitAnimations];
}

- (void)addTransparentView {
  self.transparentView = [[UIView alloc] initWithFrame:self.view.frame];
  transparentView.backgroundColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.5];
  [self.view addSubview:transparentView];
  [transparentView release];
}

- (void)popUpView:(UIView *)targetView {
  if ([popUpViews count]) {
    [popUpViews insertObject:targetView atIndex:0];
  } else {
    [self addTransparentView];
    [popUpViews addObject:targetView];
    [self beginPopUpViewAnim];
  }
}

- (void)enableTheSecondTopPopUpView {
  UIView *popUpView = [popUpViews lastObject];
  if (popUpView) {
    [self beginPopUpViewAnim];
  }
}

- (void)removeTransparentView {
  [transparentView removeFromSuperview];
}

- (void)closePopUpViewAnimFinished:(NSString *)animationID
                          finished:(NSNumber *)finished
                           context:(void *)context {
  [[popUpViews lastObject] removeFromSuperview];
  [popUpViews removeLastObject];
  [self enableTheSecondTopPopUpView];
  if (![popUpViews count]) {
    [self removeTransparentView];
  }
}

- (void)closePopUpView {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:.2];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
  [UIView setAnimationDidStopSelector:@selector(closePopUpViewAnimFinished:finished:context:)];
  ((UIView *)[popUpViews lastObject]).alpha = .01;
  [UIView commitAnimations];
}

- (void)onPopUpViewButton:(id)sender {
//  CustomAlertView *alertView = [popUpViews lastObject];
//  if (alertView.delegate &&
//      [alertView.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
//    int idx = 0;
//    for (UIButton *btn in alertView.buttons) {
//      if (sender == btn) {
//        [alertView.delegate alertView:alertView clickedButtonAtIndex:idx];
//        break;
//      }
//      idx++;
//    }
//  }
//  [self closePopUpView];
}

- (void)push:(UIViewController *)ctl transition:(SCREEN_TRANSITION)transition {
  UIViewController *top = [self topViewController];
  [viewControllers insertObject:ctl atIndex:[viewControllers count]];
  // discard controllers that exceeding max depth
  NSUInteger index = 0;
  while (index + 2 < [viewControllers count]) { // don't use '-' for NSUInt
    UIViewController *ctlInStack = [viewControllers objectAtIndex:index];
    if ([pushedControllers containsObject:ctlInStack] &&
        [viewControllers count] > maxDepthOfPushedController + index) {
      [viewControllers removeObjectAtIndex:index];
      [pushedControllers removeObject:ctlInStack];
    } else {
      ++index;
    }
  }
  [self applyTransition:top nextCtl:ctl transition:transition wait:NO];
  [pushedControllers addObject:ctl];
}

- (UIViewController *)popWithTransition:(SCREEN_TRANSITION)transition {
  int count = [viewControllers count];
  if (count > 0) {
    UIViewController *removed = [self topViewController];
    [viewControllers removeLastObject];
    [pushedControllers removeObject:removed];
    [self applyTransition:removed nextCtl:[self topViewController] transition:transition wait:NO];
    return removed;
  }
  return nil;
}

- (NSArray *)popTo:(UIViewController *)ctl
        transition:(SCREEN_TRANSITION)transition {
  UIViewController *top = [self topViewController];
  NSArray *removed = [self _popTo:ctl];
  if ([removed count] > 0) {
    [self applyTransition:top nextCtl:ctl transition:transition wait:NO];
  }
  return removed;
}

- (NSArray *)_popTo:(UIViewController *)ctl {
  assert(ctl == nil || [viewControllers indexOfObject:ctl] != NSNotFound);
  NSMutableArray *removed = [NSMutableArray arrayWithCapacity:5];
  NSEnumerator *enumerator = [viewControllers reverseObjectEnumerator];
  id obj;
  while ((obj = [enumerator nextObject])) {
    if (obj == ctl)
      break;
    [removed addObject:obj];
  }
  for (id obj in removed) {
    [viewControllers removeObject:obj];
    [pushedControllers removeObject:obj];
  }
  return removed;
}

- (UIViewController *)replace:(UIViewController *)oldCtl
                         with:(UIViewController *)newCtl {
  UIViewController *top = [self topViewController];
  // Pop to the view controller node before oldCtl.
  UIViewController *popToCtl = nil;
  if (oldCtl != nil) {
    int index = [viewControllers indexOfObject:oldCtl];
    assert(index != NSNotFound);
    if (index > 0) {
      popToCtl = [viewControllers objectAtIndex:index - 1];
    }
  }
  [self _popTo:popToCtl];
  // Push the newCtl to stack.
  [viewControllers insertObject:newCtl atIndex:[viewControllers count]];
  return top;
}

- (void)replace:(UIViewController *)oldCtl
           with:(UIViewController *)newCtl
     transition:(SCREEN_TRANSITION)transition {
  UIViewController *top;
  top = [self replace:oldCtl with:newCtl];
  // Apply transition
  [self applyTransition:top nextCtl:newCtl transition:transition wait:NO];
}

- (void)immediatelyReplace:(UIViewController *)oldCtl
                      with:(UIViewController *)newCtl
                transition:(SCREEN_TRANSITION)transition {
  UIViewController *top;
  top = [self replace:oldCtl with:newCtl];
  // Apply transition
  [self applyTransition:top nextCtl:newCtl transition:transition wait:YES];
}

- (void)triggerReplace:(NSTimer*)theTimer {
  TriggerReplaceInfo *info = (TriggerReplaceInfo*)[theTimer userInfo];
  [self replace:info.oldCtl with:info.newCtl transition:info.transition];
}

- (void)replace:(UIViewController *)oldCtl
           with:(UIViewController *)newCtl
     transition:(SCREEN_TRANSITION)transition
          after:(NSTimeInterval)seconds {
  TriggerReplaceInfo *info = [TriggerReplaceInfo new];
  info.oldCtl = oldCtl;
  info.newCtl = newCtl;
  info.transition = transition;
  [NSTimer scheduledTimerWithTimeInterval:seconds target:self
                                 selector:@selector(triggerReplace:)
                                 userInfo:info repeats:NO];
  [info release];
}

- (void)animationDidStart {
  [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

- (void)animationDidStop {
  [[UIApplication sharedApplication] endIgnoringInteractionEvents];
  UIViewController *top = [self topViewController];
  if ([top respondsToSelector:@selector(transitionAnimationDidStop)]) {
    [top performSelector:@selector(transitionAnimationDidStop)];
  }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
  [self animationDidStop];
}

- (void)viewAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
  if (context) {
    UIViewController *ctl = (UIViewController *)context;
    [ctl viewWillDisappear:YES];
    [ctl.view removeFromSuperview];
    [ctl viewDidDisappear:YES];
    [ctl release];
  }
  [self animationDidStop];
}

- (void)applyNoneTransition:(UIViewController *)currentCtl
                    nextCtl:(UIViewController *)nextCtl {
  if (currentCtl) {
    UIView *currentView = currentCtl.view;
    [currentCtl viewWillDisappear:YES];
    [currentView removeFromSuperview];
    [currentCtl viewDidDisappear:YES];
  }
  if (nextCtl) {
    UIView *nextView = nextCtl.view;
    [nextCtl viewWillAppear:YES];
    [containerView addSubview:nextView];
    [nextCtl viewDidAppear:YES];
  }
}

- (void)applyViewTransition:(UIViewController *)currentCtl
                    nextCtl:(UIViewController *)nextCtl
                   withType:(UIViewAnimationTransition)type {
  UIView *currentView = nil;
  if (currentCtl)
    currentView = currentCtl.view;
  [currentCtl viewWillDisappear:YES];

  UIView *nextView = nil;
  if (nextCtl)
    nextView = nextCtl.view;
  [nextCtl viewWillAppear:YES];

  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:.8];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationTransition:type
                         forView:containerView cache:YES];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(viewAnimationDidStop:finished:context:)];
  [currentView removeFromSuperview];
  [currentCtl viewDidDisappear:YES];

  [containerView addSubview:nextView];
  [nextCtl viewDidAppear:YES];

  [UIView commitAnimations];
}

- (void)applySlideTransition:(UIViewController *)currentCtl
                     nextCtl:(UIViewController *)nextCtl
                    withType:(NSString *)type subtype:(NSString *)subtype {
  CATransition *transition = [CATransition animation];
  transition.duration = 0.15f;
  transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
  transition.type = type;
  transition.subtype = subtype;
  transition.delegate = self;
  [containerView.layer addAnimation:transition forKey:nil];
  if (currentCtl) {
    UIView *currentView = currentCtl.view;
    [currentCtl viewWillDisappear:YES];
    [currentView removeFromSuperview];
    [currentCtl viewDidDisappear:YES];
  }
  if (nextCtl) {
    UIView *nextView = nextCtl.view;
    [nextCtl viewWillAppear:YES];
    [containerView addSubview:nextView];
    [nextCtl viewDidAppear:YES];
  }
}

typedef enum ROLL_DIRECTION_ {
  ROLL_DOWN,
  ROLL_UP,
} ROLL_DIRECTION;

- (void)applyRollWithNextCtl:(UIViewController *)nextCtl
	     belowCurrentCtl:(UIViewController *)currentCtl
		   direction:(ROLL_DIRECTION)direction {
  UIView *currentView = currentCtl.view;
  UIView *nextView = nextCtl.view;
  UIViewController *ctlToAnimate;

  [nextCtl viewWillAppear:YES];
  switch (direction) {
    case ROLL_UP:
      [containerView insertSubview:nextView belowSubview:currentView];
      ctlToAnimate = currentCtl;
      break;
    case ROLL_DOWN:
      [containerView addSubview:nextView];
      ctlToAnimate = nextCtl;
      break;
    default:
      break;
  }
  [nextCtl viewDidAppear:YES];

  ctlToAnimate.view.clipsToBounds = YES;
  CGRect rect, oldRect;
  UIView *mask = [ctlToAnimate.view viewWithTag:ROLLING_MASK_VIEW_TAG];
  rect = ctlToAnimate.view.frame;
  CGAffineTransform maskTransform;
  if (mask) {
    maskTransform = CGAffineTransformMakeTranslation(0, -mask.frame.origin.y-mask.frame.size.height);
    rect.size.height = CGRectGetMaxY(mask.frame);
  }
  oldRect = rect;
  if (ROLL_DOWN == direction) {
    rect.size.height = 0;
    if (mask) {
      mask.transform = maskTransform;
    }
  }
  ctlToAnimate.view.frame = rect;

  [currentCtl retain]; // will be released in viewAnimationDidStop
  [UIView beginAnimations:nil context:currentCtl];
  [UIView setAnimationDuration:.3];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(viewAnimationDidStop:finished:context:)];
  switch (direction) {
    case ROLL_UP:
      rect = ctlToAnimate.view.frame;
      rect.size.height = 0;
      ctlToAnimate.view.frame = rect;
      if (mask) {
	mask.transform = maskTransform;
      }
      break;
    case ROLL_DOWN:
      ctlToAnimate.view.frame = oldRect;
      if (mask) {
	mask.transform = CGAffineTransformIdentity;
      }
      break;
    default:
      break;
  }
  [UIView commitAnimations];
}

- (void)applyingTransition:(id)theInfo {
  TriggerReplaceInfo *info = theInfo;
  UIViewController *currentCtl = info.oldCtl;
  UIViewController *nextCtl = info.newCtl;
  SCREEN_TRANSITION transition = info.transition;
  switch (transition) {
    case SCREEN_TRANSITION_NONE:
      [self applyNoneTransition:currentCtl nextCtl:nextCtl];
      break;
    case SCREEN_TRANSITION_FLIP:
      [self animationDidStart];
      [self applyViewTransition:currentCtl nextCtl:nextCtl withType:UIViewAnimationTransitionFlipFromLeft];
      break;
    case SCREEN_TRANSITION_CURL_UP:
      [self animationDidStart];
      [self applyViewTransition:currentCtl nextCtl:nextCtl withType:UIViewAnimationTransitionCurlUp];
      break;
    case SCREEN_TRANSITION_CURL_DOWN:
      [self animationDidStart];
      [self applyViewTransition:currentCtl nextCtl:nextCtl withType:UIViewAnimationTransitionCurlDown];
      break;
    case SCREEN_TRANSITION_MOVE_IN_BOTTOM_TO_TOP:
      [self animationDidStart];
      [self applySlideTransition:currentCtl nextCtl:nextCtl withType:kCATransitionMoveIn subtype:kCATransitionFromTop];
      break;
    case SCREEN_TRANSITION_MOVE_OUT_TOP_TO_BOTTOM:
      [self animationDidStart];
      [self applySlideTransition:currentCtl nextCtl:nextCtl withType:kCATransitionReveal subtype:kCATransitionFromBottom];
      break;
    case SCREEN_TRANSITION_MOVE_IN_TOP_TO_BOTTOM:
      [self animationDidStart];
      [self applySlideTransition:currentCtl nextCtl:nextCtl withType:kCATransitionMoveIn subtype:kCATransitionFromBottom];
      break;
    case SCREEN_TRANSITION_MOVE_OUT_BOTTOM_TO_TOP:
      [self animationDidStart];
      [self applySlideTransition:currentCtl nextCtl:nextCtl withType:kCATransitionReveal subtype:kCATransitionFromTop];
      break;
    case SCREEN_TRANSITION_MOVE_IN_RIGHT_TO_LEFT:
      [self animationDidStart];
      [self applySlideTransition:currentCtl nextCtl:nextCtl withType:kCATransitionMoveIn subtype:kCATransitionFromRight];
      break;
    case SCREEN_TRANSITION_MOVE_OUT_LEFT_TO_RIGHT:
      [self animationDidStart];
      [self applySlideTransition:currentCtl nextCtl:nextCtl withType:kCATransitionReveal subtype:kCATransitionFromLeft];
      break;
    case SCREEN_TRANSITION_ROLL_UP_WITH_MASK:
      [self animationDidStart];
      [self applyRollWithNextCtl:nextCtl belowCurrentCtl:currentCtl direction:ROLL_UP];
      break;
    case SCREEN_TRANSITION_ROLL_DOWN_WITH_MASK:
      [self animationDidStart];
      [self applyRollWithNextCtl:nextCtl belowCurrentCtl:currentCtl direction:ROLL_DOWN];
      break;
    default:
      break;
  }
  ASLogDebug(@"ScreenNav view controller stack: %@", viewControllers);
}

- (void)applyTransition:(UIViewController *)currentCtl
                nextCtl:(UIViewController *)nextCtl
             transition:(SCREEN_TRANSITION)transition
                   wait:(BOOL)waitUntilDone {
  TriggerReplaceInfo *info = [TriggerReplaceInfo new];
  info.oldCtl = currentCtl;
  info.newCtl = nextCtl;
  info.transition = transition;
  [self performSelectorOnMainThread:@selector(applyingTransition:) withObject:info waitUntilDone:waitUntilDone];
  [info release];
}

@end
