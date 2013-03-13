//
//  MAHeaderCell.m
//  MovieAnnotations
//
//  Created by Jan on 10.03.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MAHeaderCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MAHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithHeader:(NSString *)header
{

	NSString *newString = header;
	[self.headerLabel setText:newString];
}

@end
