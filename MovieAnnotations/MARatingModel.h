//
//  MARatingModel.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 21.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MAAnnotationModel, MACommentModel, MAUserModel;

@interface MARatingModel : NSManagedObject

@property (nonatomic, retain) NSNumber * isPositive;
@property (nonatomic, retain) MAAnnotationModel *annotation;
@property (nonatomic, retain) MACommentModel *comment;
@property (nonatomic, retain) MAUserModel *author;

@end
