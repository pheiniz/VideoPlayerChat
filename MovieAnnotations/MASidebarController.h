//
//  MASidebarController.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 13.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAAddNewInformationViewController.h"

@class MAOrganizingController;
@class MAAnnotationModel;

@interface MASidebarController : UIViewController

@property(weak, nonatomic) MAOrganizingController *organizingController;
@property (nonatomic, assign) BOOL isOnScreen;

- (id)initWithViewFrame:(CGRect)frame;

- (void)showCommentButtonPressed;
- (void)showAnnotationButtonPressedForAnnotation:(MAAnnotationModel *)annotation;
- (void)displaySectionWithID:(int)id;
- (void)addNewInformationButtonPressedAtPlaytime:(NSTimeInterval)timestamp andPosition:(float)position inDelegate:(id<MAAddNewInformationDelegate>)delegate;




@end
