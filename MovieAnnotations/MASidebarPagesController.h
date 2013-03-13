//
//  MASidebarPagesController.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 12.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAAnnotationModel;

//this class manages the three tableViewControllers and the switching between them
@interface MASidebarPagesController : UIViewController <UIScrollViewDelegate>

- (IBAction)pageChanged:(id)sender;
- (void)changePageTo:(int)page;
- (void)scrollToAnnotation:(MAAnnotationModel *)annotation;

@end
