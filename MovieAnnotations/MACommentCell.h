//
//  MACommentView.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 20.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MACommentModel;

@interface MACommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextField;
@property (weak, nonatomic) IBOutlet UIButton *upVoteButton;
@property (weak, nonatomic) IBOutlet UIButton *downVoteButton;


- (IBAction)upvoteButtonPressed:(id)sender;
- (IBAction)downvoteButtonPressed:(id)sender;

- (void)setUpWithInformation:(MACommentModel *)modelInfo andHeight:(NSNumber *)height;
@end
