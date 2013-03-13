//
//  MAAnnotationView.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 20.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MAAnnotationCell.h"
#import "MAAnnotationModel.h"
#import "MACategoryModel.h"
#import "MAUserModel.h"
#import "MACoreDataController.h"
#import "MAOrganizingController.h"

@interface MAAnnotationCell ()

@property (weak, nonatomic) IBOutlet UIImageView *speechBubbleImageView;
@property (strong, nonatomic) MAAnnotationModel *backingModel;
- (IBAction)handleTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *cameoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *triviaImageView;
@property (weak, nonatomic) IBOutlet UIImageView *actorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blooperImageView;
@property (weak, nonatomic) IBOutlet UIImageView *funFactImageView;

@end

@implementation MAAnnotationCell


- (void)setUpWithInformation:(MAAnnotationModel *)modelInfo andHeight:(NSNumber *)height;
{
    CGRect frame = self.contentTextField.frame;
    frame.size.height = height.intValue-60;
    self.contentTextField.frame = frame;
    frame = self.frame;
    frame.size.height = height.intValue;
    self.frame = frame;
	
	if(modelInfo.isSceneSpecific.boolValue){
		NSDate *first = [NSDate date];
		NSDate *second = [NSDate dateWithTimeInterval:modelInfo.time.floatValue sinceDate:first];
		
		NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:first toDate:second options:0];
		
		self.timeLabel.text = [NSString stringWithFormat:@"%d:%02d:%02d", [comp	hour], [comp minute], [comp second]];
	}
	else
	{
		self.timeLabel.text = @"";
	}
		
	for (MACategoryModel *cat in modelInfo.categories) {
		if([cat.name isEqualToString:@"Bloopers"])
			self.blooperImageView.hidden = NO;
		else if([cat.name isEqualToString:@"Cameo"])
			self.cameoImageView.hidden = NO;
		else if ([cat.name isEqualToString:@"Trivia"])
			self.triviaImageView.hidden = NO;
		else if ([cat.name isEqualToString:@"Actor"])
			self.actorImageView.hidden = NO;
		else if ([cat.name isEqualToString:@"Fun Fact"])
			self.funFactImageView.hidden = NO;
	}
	
    self.userLabel.text = modelInfo.author.name;
    self.contentTextField.text = modelInfo.content;
    
    self.backingModel = modelInfo;
    [self updateRatingLabels];
}

- (IBAction)upButtonPressed:(id)sender
{
    [[MACoreDataController sharedInstance] addRatingForAnnotation:self.backingModel withPositiveVote:YES];
    [self updateRatingLabels];
}

- (IBAction)downButtonPressed:(id)sender
{
    [[MACoreDataController sharedInstance] addRatingForAnnotation:self.backingModel withPositiveVote:NO];
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

- (void)resizeContentTextField
{
    CGRect frame = self.contentTextField.frame;
    frame.size.height = self.contentTextField.contentSize.height;
    self.contentTextField.frame = frame;
    frame = self.frame;
    frame.size.height = self.contentTextField.contentSize.height + 60;
    self.frame = frame;
}



- (IBAction)handleTouch:(id)sender
{
	if (self.backingModel.isSceneSpecific.boolValue) {
		[[MAOrganizingController sharedInstance].movieController jumpToAnnotation:self.backingModel];
	}

}
@end
