//
//  MAAnnotationModel.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 10.03.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MACategoryModel, MACommentModel, MAMovieModel, MARatingModel, MAUserModel;

@interface MAAnnotationModel : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * isSceneSpecific;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * percentagePosition;
@property (nonatomic, retain) MAUserModel *author;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) MAMovieModel *movie;
@property (nonatomic, retain) NSSet *ratings;
@end

@interface MAAnnotationModel (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(MACategoryModel *)value;
- (void)removeCategoriesObject:(MACategoryModel *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addCommentsObject:(MACommentModel *)value;
- (void)removeCommentsObject:(MACommentModel *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addRatingsObject:(MARatingModel *)value;
- (void)removeRatingsObject:(MARatingModel *)value;
- (void)addRatings:(NSSet *)values;
- (void)removeRatings:(NSSet *)values;

@end
