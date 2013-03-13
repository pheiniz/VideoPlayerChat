//
//  MAAppDelegate.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 09.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MAAppDelegate.h"

#import "MASidebarController.h"
#import "MAMovieController.h"
#import "MAAnnotationTableViewController.h"

#import "MACoreDataController.h"
//CoreData Models
#import "MAUserModel.h"
#import "MAAnnotationModel.h"
#import "MARatingModel.h"
#import "MAMovieModel.h"
#import "MACommentModel.h"
#import "MACategoryModel.h"


@implementation MAAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    //hand the managedObjectContext to the CoreDataController
    [MACoreDataController sharedInstance].managedObjectContext = self.managedObjectContext;
    
    //fill the database with the mockup information
    NSManagedObjectContext *context = self.managedObjectContext;
    [self fillCoreDataWithObjectContext:context];
    
	UIImage *image = [[UIImage imageNamed:@"gradient.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
	
	[[UIButton appearanceWhenContainedIn:[MAAnnotationTableViewController class], nil]setBackgroundImage:image forState:UIControlStateNormal];
	


    return YES;
}


- (void)fillCoreDataWithObjectContext:(NSManagedObjectContext *)context
{
    //test if there is already something in the database. If so --> don't add anything
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MAMovieModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count != 0)
        return;

    //example Users
    MAUserModel *philUser = [NSEntityDescription insertNewObjectForEntityForName:@"MAUserModel" inManagedObjectContext:context];
    philUser.name = @"Phil";
    
    MAUserModel *janUser = [NSEntityDescription insertNewObjectForEntityForName:@"MAUserModel" inManagedObjectContext:context];
    janUser.name = @"Jan";
    
    MAUserModel *thorinUser = [NSEntityDescription insertNewObjectForEntityForName:@"MAUserModel" inManagedObjectContext:context];
    thorinUser.name = @"Thorin123";
    MAUserModel *gandalfUser = [NSEntityDescription insertNewObjectForEntityForName:@"MAUserModel" inManagedObjectContext:context];
    gandalfUser.name = @"Gandalf";
    MAUserModel *bilboUser = [NSEntityDescription insertNewObjectForEntityForName:@"MAUserModel" inManagedObjectContext:context];
    bilboUser.name = @"Shir3Folk";
    
    //example Movie
    MAMovieModel *hobbitMovie = [NSEntityDescription insertNewObjectForEntityForName:@"MAMovieModel" inManagedObjectContext:context];
    hobbitMovie.title = @"The Hobbit - Trailer";
    
    //mockup categories
	MACategoryModel *category = [NSEntityDescription insertNewObjectForEntityForName:@"MACategoryModel" inManagedObjectContext:context];
	category.name = @"Trivia";
	
	MACategoryModel *secondCategory = [NSEntityDescription insertNewObjectForEntityForName:@"MACategoryModel" inManagedObjectContext:context];
	secondCategory.name = @"Fun Fact";
	
	MACategoryModel *thirdCategory = [NSEntityDescription insertNewObjectForEntityForName:@"MACategoryModel" inManagedObjectContext:context];
	thirdCategory.name = @"Actor";
	
	MACategoryModel *fourthCategory = [NSEntityDescription insertNewObjectForEntityForName:@"MACategoryModel" inManagedObjectContext:context];
	fourthCategory.name = @"Bloopers";
	
	MACategoryModel *fifthCategory = [NSEntityDescription insertNewObjectForEntityForName:@"MACategoryModel" inManagedObjectContext:context];
	fifthCategory.name = @"Cameo";

    
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setYear:2013];
    [comp setMonth:01];
    [comp setDay:22];
    [comp setHour:14];
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [comp setCalendar:cal];
    
    NSDate *currentDate = [cal dateFromComponents:comp];

    //general Annotations
    
    //firstAnnotation + Comments + Ratings
    MAAnnotationModel *costAnnotation = [NSEntityDescription insertNewObjectForEntityForName:@"MAAnnotationModel" inManagedObjectContext:context];
    costAnnotation.author = thorinUser;
    costAnnotation.movie = hobbitMovie;
    costAnnotation.creationDate = currentDate;
    costAnnotation.isSceneSpecific = [NSNumber numberWithBool:NO];
    costAnnotation.content = @"This movie is the first that was shot and shown with 48 frames per second. This is supposed to make the film smoother...especially when viewing in 3D.";
    [costAnnotation addCategoriesObject:category];
    
    //ratings
    MARatingModel *janRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    janRating.author = janUser;
    janRating.isPositive = [NSNumber numberWithBool:YES];
    
    MARatingModel *philRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    philRating.author = philUser;
    philRating.isPositive = [NSNumber numberWithBool:YES];
    
    MARatingModel *thorinRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    thorinRating.author = thorinUser;
    thorinRating.isPositive = [NSNumber numberWithBool:NO];
    
    MARatingModel *gandalfRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    gandalfRating.author = gandalfUser;
    gandalfRating.isPositive = [NSNumber numberWithBool:YES];
    
    MARatingModel *bilboRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    bilboRating.author = bilboUser;
    bilboRating.isPositive = [NSNumber numberWithBool:YES];
    
    [costAnnotation addRatings:[NSSet setWithObjects:thorinRating, gandalfRating, bilboRating, nil]];
    
    
    [comp setHour:15];
    currentDate = [cal dateFromComponents:comp];
    MACommentModel *positiveComment = [NSEntityDescription insertNewObjectForEntityForName:@"MACommentModel" inManagedObjectContext:context];
    positiveComment.author = gandalfUser;
    positiveComment.content = @"It is definitely smoother. I saw no 'jumps' during the long tracking shots";
    positiveComment.creationDate = currentDate;
    //ratings
    bilboRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    bilboRating.author = bilboUser;
    bilboRating.isPositive = [NSNumber numberWithBool:YES];

    gandalfRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    gandalfRating.author = gandalfUser;
    gandalfRating.isPositive = [NSNumber numberWithBool:YES];
    [positiveComment addRatings:[NSSet setWithObjects:bilboRating, gandalfRating, nil]];
    
    [costAnnotation addCommentsObject:positiveComment];
    

    [comp setDay: 25];
    currentDate = [cal dateFromComponents:comp];
    //secondAnnotation + Comments + Ratings
    MAAnnotationModel *humanAnnotation = [NSEntityDescription insertNewObjectForEntityForName:@"MAAnnotationModel" inManagedObjectContext:context];
    humanAnnotation.author = bilboUser;
    humanAnnotation.movie = hobbitMovie;
    humanAnnotation.creationDate = currentDate;
    humanAnnotation.isSceneSpecific = [NSNumber numberWithBool:NO];
    humanAnnotation.content = @"This is the first Middle-Earth film directed by Peter Jackson that does not have any speaking characters that are ordinary humans, known in the work of J.R.R. Tolkien as the 'race of Men.' Some men appear in the opening flashback but do not speak. Hobbits are technically descended from the race of Men, and Wizards are strictly not man even though they appear so. ";
    [humanAnnotation addCategoriesObject:category];

    //ratings
    gandalfRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    gandalfRating.author = gandalfUser;
    gandalfRating.isPositive = [NSNumber numberWithBool:NO];
    
    bilboRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    bilboRating.author = bilboUser;
    bilboRating.isPositive = [NSNumber numberWithBool:YES];

    thorinRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    thorinRating.author = thorinUser;
    thorinRating.isPositive = [NSNumber numberWithBool:NO];
    
    [humanAnnotation addRatings:[NSSet setWithObjects:bilboRating, thorinRating, gandalfRating, nil]];
    
    
    MAAnnotationModel *oscarAnnotation = [NSEntityDescription insertNewObjectForEntityForName:@"MAAnnotationModel" inManagedObjectContext:context];
    oscarAnnotation.author = janUser;
    oscarAnnotation.movie = hobbitMovie;
    oscarAnnotation.creationDate = currentDate;
    oscarAnnotation.isSceneSpecific = [NSNumber numberWithBool:NO];
    oscarAnnotation.content = @"The hobbit is the only 'Middle-Earth' movie that was not nominated for the 'best-picture' oscar.";
    [oscarAnnotation addCategories:[NSSet setWithObjects:category, secondCategory, nil]];
    


    //sceneSpecific Annotations

    MAAnnotationModel *bomburAnnotation = [NSEntityDescription insertNewObjectForEntityForName:@"MAAnnotationModel" inManagedObjectContext:context];
    bomburAnnotation.author = thorinUser;
    bomburAnnotation.movie = hobbitMovie;
    bomburAnnotation.creationDate = currentDate;
    bomburAnnotation.isSceneSpecific = [NSNumber numberWithBool:YES];
    bomburAnnotation.time = [NSNumber numberWithFloat:34.612489];
    bomburAnnotation.percentagePosition = [NSNumber numberWithFloat:0.228929];
    bomburAnnotation.content = @"Bombur (the fat dwarf) doesn't say a word during the whole movie!";
    [bomburAnnotation addCategoriesObject:thirdCategory];
    [bomburAnnotation addCategoriesObject:secondCategory];
    //ratings
    gandalfRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    gandalfRating.author = gandalfUser;
    gandalfRating.isPositive = [NSNumber numberWithBool:YES];
    
    bilboRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    bilboRating.author = bilboUser;
    bilboRating.isPositive = [NSNumber numberWithBool:YES];

    thorinRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    thorinRating.author = thorinUser;
    thorinRating.isPositive = [NSNumber numberWithBool:YES];
    
    [bomburAnnotation addRatings:[NSSet setWithObjects:gandalfRating, bilboRating, thorinRating, nil]];
    
    [comp setHour:15];
    currentDate = [cal dateFromComponents:comp];
    MACommentModel *eatingComment = [NSEntityDescription insertNewObjectForEntityForName:@"MACommentModel" inManagedObjectContext:context];
    eatingComment.author = bilboUser;
    eatingComment.content = @"Well he was eating very often.";
    eatingComment.creationDate = currentDate;
    //ratings
    gandalfRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    gandalfRating.author = gandalfUser;
    gandalfRating.isPositive = [NSNumber numberWithBool:NO];

    [eatingComment addRatings:[NSSet setWithObjects: gandalfRating, nil]];
    
    [comp setHour:16];
    currentDate = [cal dateFromComponents:comp];
    MACommentModel *gandalfComment = [NSEntityDescription insertNewObjectForEntityForName:@"MACommentModel" inManagedObjectContext:context];
    gandalfComment.author = gandalfUser;
    gandalfComment.content = @"Actually not as often as I would have imagined.";
    gandalfComment.creationDate = currentDate;
    
    [bomburAnnotation addComments:[NSSet setWithObjects:eatingComment, gandalfComment, nil]];

    
    MAAnnotationModel *hobbitonAnnotation = [NSEntityDescription insertNewObjectForEntityForName:@"MAAnnotationModel" inManagedObjectContext:context];
    hobbitonAnnotation.author = philUser;
    hobbitonAnnotation.movie = hobbitMovie;
    hobbitonAnnotation.creationDate = currentDate;
    hobbitonAnnotation.isSceneSpecific = [NSNumber numberWithBool:YES];
    hobbitonAnnotation.time = [NSNumber numberWithFloat:55.383489];
    hobbitonAnnotation.percentagePosition = [NSNumber numberWithFloat:0.366310];
    hobbitonAnnotation.content = @"They actually didn't deconstruct this set. So tourists can take tours to this location.";
    [hobbitonAnnotation addCategoriesObject:category];
    //ratings
    gandalfRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    gandalfRating.author = gandalfUser;
    gandalfRating.isPositive = [NSNumber numberWithBool:YES];
    
    bilboRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    bilboRating.author = bilboUser;
    bilboRating.isPositive = [NSNumber numberWithBool:YES];
    
    thorinRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    thorinRating.author = thorinUser;
    thorinRating.isPositive = [NSNumber numberWithBool:YES];
    [hobbitonAnnotation addRatings:[NSSet setWithObjects:gandalfRating, bilboRating, thorinRating, nil]];
    
    [comp setHour:15];
    currentDate = [cal dateFromComponents:comp];
    MACommentModel *lordComment = [NSEntityDescription insertNewObjectForEntityForName:@"MACommentModel" inManagedObjectContext:context];
    lordComment.author = gandalfUser;
    lordComment.content = @"After 'The Lord of the Rings' they just left white plywood in front of the holes. This time they left it completely intact. Quite cool.";
    lordComment.creationDate = currentDate;
    //ratings
    gandalfRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    gandalfRating.author = gandalfUser;
    gandalfRating.isPositive = [NSNumber numberWithBool:YES];
    [lordComment addRatings:[NSSet setWithObjects: gandalfRating, nil]];
    [hobbitonAnnotation addCommentsObject:lordComment];


    MAAnnotationModel *radagastAnnotation = [NSEntityDescription insertNewObjectForEntityForName:@"MAAnnotationModel" inManagedObjectContext:context];
    radagastAnnotation.author = gandalfUser;
    radagastAnnotation.movie = hobbitMovie;
    radagastAnnotation.creationDate = currentDate;
    radagastAnnotation.isSceneSpecific = [NSNumber numberWithBool:YES];
    radagastAnnotation.time = [NSNumber numberWithFloat:83.709029];
    radagastAnnotation.percentagePosition = [NSNumber numberWithFloat:0.553657];
    radagastAnnotation.content = @"The character Radagast isn't mentioned in the book. But he appears in the Lord of the Rings.";
    [radagastAnnotation addCategories:[NSSet setWithObjects:category, thirdCategory, nil]];
    //ratings
    gandalfRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    gandalfRating.author = gandalfUser;
    gandalfRating.isPositive = [NSNumber numberWithBool:YES];
    
    bilboRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    bilboRating.author = bilboUser;
    bilboRating.isPositive = [NSNumber numberWithBool:NO];
    
    [radagastAnnotation addRatings:[NSSet setWithObjects:gandalfRating, bilboRating, nil]];
    
    
    MAAnnotationModel *worldAnnotation = [NSEntityDescription insertNewObjectForEntityForName:@"MAAnnotationModel" inManagedObjectContext:context];
    worldAnnotation.author = janUser;
    worldAnnotation.movie = hobbitMovie;
    worldAnnotation.creationDate = currentDate;
    worldAnnotation.isSceneSpecific = [NSNumber numberWithBool:YES];
    worldAnnotation.time = [NSNumber numberWithFloat:128.954619];
    worldAnnotation.percentagePosition = [NSNumber numberWithFloat:0.852915];
    worldAnnotation.content = @"The phrase Gandalf uses here: 'Home is behind you....the world is ahead' is originally used in the Lord of the Rings";
    [worldAnnotation addCategories:[NSSet setWithObjects:category, secondCategory, thirdCategory, nil]];
    //ratings
    gandalfRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    gandalfRating.author = gandalfUser;
    gandalfRating.isPositive = [NSNumber numberWithBool:YES];
    
    bilboRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    bilboRating.author = bilboUser;
    bilboRating.isPositive = [NSNumber numberWithBool:YES];
    
    thorinRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    thorinRating.author = thorinUser;
    thorinRating.isPositive = [NSNumber numberWithBool:YES];
    [worldAnnotation addRatings:[NSSet setWithObjects:gandalfRating, bilboRating, thorinRating, nil]];
    
    [comp setHour:15];
    currentDate = [cal dateFromComponents:comp];
    MACommentModel *funComment = [NSEntityDescription insertNewObjectForEntityForName:@"MACommentModel" inManagedObjectContext:context];
    funComment.author = gandalfUser;
    funComment.content = @"Really? I didn't know that :D";
    funComment.creationDate = currentDate;
    //ratings
    gandalfRating = [NSEntityDescription insertNewObjectForEntityForName:@"MARatingModel" inManagedObjectContext:context];
    gandalfRating.author = gandalfUser;
    gandalfRating.isPositive = [NSNumber numberWithBool:YES];
    [funComment addRatings:[NSSet setWithObjects: gandalfRating, nil]];
    [worldAnnotation addCommentsObject:funComment];
    

    if (![context save:&error])
    {
        NSLog(@"couldn't save: %@",[error localizedDescription]);
    }
    
	
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MovieAnnotations" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MovieAnnotations.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
