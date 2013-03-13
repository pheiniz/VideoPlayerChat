//
//  MACommentModel.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 21.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MAAnnotationModel, MARatingModel, MAUserModel;

@interface MACommentModel : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) MAAnnotationModel *annotation;
@property (nonatomic, retain) MAUserModel *author;
@property (nonatomic, retain) NSSet *ratings;
@end

@interface MACommentModel (CoreDataGeneratedAccessors)

- (void)addRatingsObject:(MARatingModel *)value;
- (void)removeRatingsObject:(MARatingModel *)value;
- (void)addRatings:(NSSet *)values;
- (void)removeRatings:(NSSet *)values;

@end
