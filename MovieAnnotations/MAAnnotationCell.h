//
//  MAAnnotationView.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 20.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAAnnotationModel;

@interface MAAnnotationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextField;
@property (weak, nonatomic) IBOutlet UIButton *upVoteButton;
@property (weak, nonatomic) IBOutlet UIButton *downVoteButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (IBAction)upButtonPressed:(id)sender;
- (IBAction)downButtonPressed:(id)sender;
- (void)resizeContentTextField;

- (void)setUpWithInformation:(MAAnnotationModel *)modelInfo andHeight:(NSNumber *)height;
@end
