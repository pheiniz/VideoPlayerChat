//
//  MAMovieController.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 13.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAAddNewInformationViewController.h"

@class MAOrganizingController;

@interface MAMovieController : UIViewController <MAAddNewInformationDelegate>

@property (weak,nonatomic) MAOrganizingController *organizingController;

- (void)setPlayerIsPlaying:(BOOL)state;
- (void)toggleControls;
- (void)leftArrowInSlider;
- (void)rightArrowInSlider;


// used to update player size, when sliding in/out
-(void) updatePlayerFrame;

-(void) jumpToAnnotation:(MAAnnotationModel *)annotation;

@end
