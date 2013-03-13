//
//  MAOrganizingController.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 18.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAUserModel.h"
#import "MAMovieModel.h"
#import "MAAddNewInformationViewController.h"
#import "MAMovieController.h"

@interface MAOrganizingController : UIViewController

//action to get the organizing Controller
//used by the various view controllers to notify the organizing controller of events (button presses etc)
+ (MAOrganizingController *)sharedInstance;

@property (strong, nonatomic) MAUserModel *currentUser;
@property (strong, nonatomic) MAMovieModel *currentMovie;
@property (strong, nonatomic, readonly) MAMovieController *movieController;
@property (assign, nonatomic) BOOL isMonitoring;

//to show/hide the taskbar
- (void) toggleSidebarButtonPressed;

- (void)addNewInformationButtonPressedAtPlaytime:(NSTimeInterval)timestamp andPosition:(float)position inDelegate:(id<MAAddNewInformationDelegate>)delegate;

- (void)showCommentButtonPressed;
- (void)showAnnotationButtonPressedForAnnotation:(MAAnnotationModel *)annotation;
- (void)slideSidebar:(CGFloat)offset withRecognizerState:(UIGestureRecognizerState)state;

//Mockup method to switch between users
- (void)toggleUser;

@end
