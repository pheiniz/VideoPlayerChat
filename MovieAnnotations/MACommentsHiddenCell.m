//
//  MACommentsHiddenCell.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 09.03.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MACommentsHiddenCell.h"

@implementation MACommentsHiddenCell


- (IBAction)displayCommentsButtonPressed:(id)sender
{
    [self.delegate insertCommentsForAnnotation:self.annotationModel];
}
@end
