//
//  MAAnnotationModel.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 10.03.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MAAnnotationModel.h"
#import "MACategoryModel.h"
#import "MACommentModel.h"
#import "MAMovieModel.h"
#import "MARatingModel.h"
#import "MAUserModel.h"


@implementation MAAnnotationModel

@dynamic content;
@dynamic creationDate;
@dynamic isSceneSpecific;
@dynamic time;
@dynamic percentagePosition;
@dynamic author;
@dynamic categories;
@dynamic comments;
@dynamic movie;
@dynamic ratings;

@end
