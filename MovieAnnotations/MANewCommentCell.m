//
//  MANewCommentView.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 20.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MANewCommentCell.h"
#import "MACoreDataController.h"
#import "MAOrganizingController.h"
#import "MAAnnotationTableViewController.h"

@implementation MANewCommentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentTextField.delegate = self;
}

- (IBAction)postButtonPressed:(id)sender
{
    if (self.contentTextField.textColor == [UIColor blackColor] && ![self.contentTextField.text isEqualToString:@""])
    {
        [[MACoreDataController sharedInstance] addNewCommentToAnnotation:self.annotationModel withContent:self.contentTextField.text];
    }
	[self.contentTextField resignFirstResponder];
	self.contentTextField.textColor = [UIColor lightGrayColor];
	self.contentTextField.text = @"Enter your comment here!";
}

- (IBAction)hideCommentsButtonPressed:(id)sender
{
    UITableView *superview = (UITableView *) [self superview];
    [self.delegate hideCommentsOfAnnotationAtSection:[superview indexPathForCell:self].section];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
	
	UITableView *superview = (UITableView *) [self superview];
    [self.delegate scrollUpCellAtIndexPath:[superview indexPathForCell:self]];
	
	
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if([textView.text isEqualToString: @""]){
		textView.textColor = [UIColor lightGrayColor];
		textView.text = @"Enter your comment here!";
	}
}



@end
