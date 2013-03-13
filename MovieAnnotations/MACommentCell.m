//
//  MACommentView.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 20.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MACommentCell.h"
#import "MACommentModel.h"
#import "MAUserModel.h"
#import "MACoreDataController.h"

@interface MACommentCell ()

@property (strong, nonatomic) MACommentModel *backingModel;

@end

@implementation MACommentCell

- (void)setUpWithInformation:(MACommentModel *)modelInfo andHeight:(NSNumber *)height
{
    CGRect frame = self.contentTextField.frame;
    frame.size.height = height.intValue-60;
    self.contentTextField.frame = frame;
    frame = self.frame;
    frame.size.height = height.intValue;
    self.frame = frame;
    
    self.usernameLabel.text = modelInfo.author.name;
    self.contentTextField.text = modelInfo.content;
    
    self.backingModel = modelInfo;
    [self updateRatingLabels];
}

- (IBAction)upvoteButtonPressed:(id)sender
{
    [[MACoreDataController sharedInstance] addRatingForComment:self.backingModel withPositiveVote:YES];
    [self updateRatingLabels];
}

- (IBAction)downvoteButtonPressed:(id)sender
{
    [[MACoreDataController sharedInstance] addRatingForComment:self.backingModel withPositiveVote:NO];
    [self updateRatingLabels];
}

- (void)updateRatingLabels
{
    //set the voting labels
    NSPredicate *getPositiveRatings = [NSPredicate predicateWithFormat:@"isPositive == YES"];
    NSSet *positiveRatings = [self.backingModel.ratings filteredSetUsingPredicate:getPositiveRatings];
    [self.upVoteButton setTitle:[NSString stringWithFormat:@"%dx", [positiveRatings count]] forState:UIControlStateNormal];
	[self.downVoteButton setTitle:[NSString stringWithFormat:@"%dx", ([self.backingModel.ratings count]-[positiveRatings count])] forState:UIControlStateNormal];
    
}
@end
