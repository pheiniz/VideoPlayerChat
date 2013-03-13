//
//  MAUserModel.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 21.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MAAnnotationModel, MACommentModel, MARatingModel;

@interface MAUserModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *annotations;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *ratings;
@end

@interface MAUserModel (CoreDataGeneratedAccessors)

- (void)addAnnotationsObject:(MAAnnotationModel *)value;
- (void)removeAnnotationsObject:(MAAnnotationModel *)value;
- (void)addAnnotations:(NSSet *)values;
- (void)removeAnnotations:(NSSet *)values;

- (void)addCommentsObject:(MACommentModel *)value;
- (void)removeCommentsObject:(MACommentModel *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addRatingsObject:(MARatingModel *)value;
- (void)removeRatingsObject:(MARatingModel *)value;
- (void)addRatings:(NSSet *)values;
- (void)removeRatings:(NSSet *)values;

@end
