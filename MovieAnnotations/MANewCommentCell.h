//
//  MANewCommentView.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 20.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAAnnotationModel.h"

//notify the delegate about touches. It should then update the interface
@protocol MANewCommentCellDelegate

- (void)hideCommentsOfAnnotationAtSection:(int)section;
- (void)scrollUpCellAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface MANewCommentCell : UITableViewCell<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *contentTextField;
@property (weak, nonatomic) MAAnnotationModel *annotationModel;

@property (weak, nonatomic) id<MANewCommentCellDelegate> delegate;

- (IBAction)postButtonPressed:(id)sender;
- (IBAction)hideCommentsButtonPressed:(id)sender;

@end
