//
//  MACoreDataController.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 20.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MACoreDataController.h"
#import "MAMovieModel.h"
#import "MACategoryModel.h"
#import "MAAnnotationModel.h"
#import "MAUserModel.h"
#import "MACommentModel.h"
#import "MARatingModel.h"
#import "MAOrganizingController.h"

@implementation MACoreDataController

// Get the shared instance and create it if necessary.
static MACoreDataController *sharedInstance = nil;
+ (MACoreDataController *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [super allocWithZone:NULL] ;
		sharedInstance = [sharedInstance init];
    }
	
    return sharedInstance;
}


+(id)allocWithZone:(NSZone *)zone
{
	return [MACoreDataController sharedInstance];
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    self = [super init];
	
    if (self)
    {
        //custom code
    }
    return self;
}

- (NSArray *)getAnnotationsForMovie:(MAMovieModel *)currentMovie whereSceneSpecificIs:(BOOL)isSceneSpecific
{
    NSError *error;
    
    //retrieving infos
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MAAnnotationModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *sceneSpecificPredicate = [NSPredicate predicateWithFormat:@"isSceneSpecific == %@",[NSNumber numberWithBool:isSceneSpecific]];
    [fetchRequest setPredicate:sceneSpecificPredicate];
    
	NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
	
	
	if(isSceneSpecific)
	{
		sorting = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	}
	 

    [fetchRequest setSortDescriptors:@[sorting]];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
    return fetchedObjects;
}

- (void)addRatingForAnnotation:(MAAnnotationModel *)theAnnotation withPositiveVote:(BOOL)vote
{
    MAUserModel *currentUser = [MAOrganizingController sharedInstance].currentUser;
    
    MARatingModel *newRating;
    
    //check if the user already voted on the annotation
    for (MARatingModel *userRating in currentUser.ratings)
    {
        if(userRating.annotation == theAnnotation)
        {
            newRating = userRating;
        }
    }
    
    //if the user hasn't made a rating --> create a new one
    if(!newRating)
    {
        newRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:self.managedObjectContext];
        newRating.isPositive = [NSNumber numberWithBool:vote];
        newRating.author = [MAOrganizingController sharedInstance].currentUser;
        
        [theAnnotation addRatingsObject:newRating];
    }
    //otherwise just adapt the vote
    else
    {
        newRating.isPositive = [NSNumber numberWithBool:vote];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"couldn't save new AnnotationRating: %@",[error localizedDescription]);
    }
}

- (void)addRatingForComment:(MACommentModel *)theComment withPositiveVote:(BOOL)vote
{
    MAUserModel *currentUser = [MAOrganizingController sharedInstance].currentUser;
    
    MARatingModel *newRating;
    
    //check if the user already voted on the comment
    for (MARatingModel *userRating in currentUser.ratings)
    {
        if (userRating.comment == theComment)
        {
            newRating = userRating;
        }
    }
    
    //if the user hasn't made a rating --> create a new one
    if (!newRating)
    {
        newRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:self.managedObjectContext];
        newRating.isPositive = [NSNumber numberWithBool:vote];
        newRating.author = currentUser;
        
        [theComment addRatingsObject:newRating];
    }
    //otherwise just adapt the vote
    else
    {
        newRating.isPositive = [NSNumber numberWithBool:vote];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"couldn't save new CommentRating: %@",[error localizedDescription]);
    }
}

-(void)addNewAnnotationWithContent:(NSString *)content andCategories:(NSSet *)categories isSceneSpecific:(BOOL)isSceneSpecific forTimestamp:(NSTimeInterval)timestamp andPercentagePosition:(float)position
{
	MAAnnotationModel *newAnnotation = [NSEntityDescription insertNewObjectForEntityForName:@"MAAnnotationModel" inManagedObjectContext:self.managedObjectContext];
	newAnnotation.movie = [MAOrganizingController sharedInstance].currentMovie;
	newAnnotation.time = [NSNumber numberWithFloat:timestamp];
	newAnnotation.percentagePosition = [NSNumber numberWithFloat:position];
	newAnnotation.author = [MAOrganizingController sharedInstance].currentUser;
	newAnnotation.content = content;
	newAnnotation.categories = categories;
	newAnnotation.isSceneSpecific = [NSNumber numberWithBool:isSceneSpecific];
	newAnnotation.creationDate = [NSDate date];
	if (isSceneSpecific)
    {
        newAnnotation.time = [NSNumber numberWithFloat:timestamp];
    }
    
	NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"couldn't save new Annotation: %@",[error localizedDescription]);
    }
    else
    {
        if (newAnnotation.isSceneSpecific.boolValue)
        {
            [self.specificTableViewDelegate addedNewAnnotation:newAnnotation];
        }
        else
        {
            [self.generalTableViewDelegate addedNewAnnotation:newAnnotation];
        }
    }
}

- (void)addNewCommentToAnnotation:(MAAnnotationModel *)theAnnotation withContent:(NSString *)theContent
{
    MACommentModel *newCommentModel = [NSEntityDescription insertNewObjectForEntityForName:@"MACommentModel" inManagedObjectContext:self.managedObjectContext];
    newCommentModel.content = theContent;
    newCommentModel.author = [MAOrganizingController sharedInstance].currentUser;
    newCommentModel.creationDate = [NSDate date];
    
    [theAnnotation addCommentsObject:newCommentModel];
    
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"couldn't save new Comment: %@",[error localizedDescription]);
    }
    else
    {
        if (theAnnotation.isSceneSpecific.boolValue)
        {
            [self.specificTableViewDelegate addedNewComment:newCommentModel forAnnotation:theAnnotation];
        }
        else
        {
            [self.generalTableViewDelegate addedNewComment:newCommentModel forAnnotation:theAnnotation];
        }
    }
}

//TODO: Mockup
- (NSArray *)getMockupUsers
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MAUserModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    //get just the Jan & Phil Users
    NSMutableArray *janPhilArray = [NSMutableArray arrayWithCapacity:2];
    for (MAUserModel *currentUser in fetchedObjects)
    {
        if ([currentUser.name isEqualToString:@"Jan"] || [currentUser.name isEqualToString:@"Phil"])
        {
            [janPhilArray addObject:currentUser];
        }
    }
    
    return janPhilArray;
}

- (MAMovieModel *)getMockupMovie
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MAMovieModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects[0];
}

- (NSArray *)getMockupCategories
{
	NSError *error;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MACategoryModel" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	return fetchedObjects;
}


@end
