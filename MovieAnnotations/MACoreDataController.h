//
//  MACoreDataController.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 20.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <Foundation/Foundation.h>

//CoreData Model classes
@class MAAnnotationModel;
@class MAUserModel;
@class MAMovieModel;
@class MACategoryModel;
@class MACommentModel;
@class MARatingModel;

//methods to notify the deletate that a new annotation or new comment was added (used to update the interface)
@protocol MACoreDataDelegate

- (void)addedNewComment:(MACommentModel *)newComment forAnnotation:(MAAnnotationModel *)theAnnotation;
- (void)addedNewAnnotation:(MAAnnotationModel *)theAnnotation;

@end

@interface MACoreDataController : NSObject

@property (strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) id<MACoreDataDelegate> generalTableViewDelegate;
@property (weak, nonatomic) id<MACoreDataDelegate> specificTableViewDelegate;

+ (MACoreDataController *)sharedInstance;

//convenience methods to query and modify the core data model
- (NSArray *)getAnnotationsForMovie:(MAMovieModel *)currentMovie whereSceneSpecificIs:(BOOL)isSceneSpecific;

- (void)addRatingForAnnotation:(MAAnnotationModel *)theAnnotation withPositiveVote:(BOOL)vote;
- (void)addRatingForComment:(MACommentModel *)theComment withPositiveVote:(BOOL)vote;

- (void)addNewCommentToAnnotation:(MAAnnotationModel *)theAnnotation withContent:(NSString *)theContent;

- (void)addNewAnnotationWithContent:(NSString *)content andCategories:(NSSet *)categories isSceneSpecific:(BOOL)isSceneSpecific forTimestamp:(NSTimeInterval)timestamp andPercentagePosition:(float)position;

//Mockup
- (NSArray *)getMockupUsers;
- (MAMovieModel *)getMockupMovie;
- (NSArray *)getMockupCategories;

@end
