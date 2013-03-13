//
//  MACommentsHiddenCell.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 09.03.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAAnnotationModel.h"

@protocol MACommentsHiddenCellDelegate

- (void)insertCommentsForAnnotation:(MAAnnotationModel *)theAnnotation;

@end

@interface MACommentsHiddenCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *displayCommentsButton;
@property (weak, nonatomic) MAAnnotationModel *annotationModel;

@property (weak, nonatomic) id<MACommentsHiddenCellDelegate> delegate;

- (IBAction)displayCommentsButtonPressed:(id)sender;
@end
