//
//  MAHeaderCell.h
//  MovieAnnotations
//
//  Created by Jan on 10.03.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIView *backingView;
- (void)setupWithHeader:(NSString *)header;

@end
