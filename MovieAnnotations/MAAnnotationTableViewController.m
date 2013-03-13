//
//  MACommentTableViewController.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 20.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MAAnnotationTableViewController.h"
#import "MAAnnotationCell.h"
#import "MACommentCell.h"
#import "MARatingModel.h"
#import "MAAnnotationModel.h"
#import "MACommentModel.h"
#import <QuartzCore/QuartzCore.h>
#import "MAHeaderCell.h"
#import "MAOrganizingController.h"


@interface MAAnnotationTableViewController ()

/*
 this array holds all the information for the cells.
 this is necessary since the height of a row is queried before the content.
 So we compute the height and information before and store them in this array
 The structure is this:
 annotationThreads: holds all annotationThreads (Annotation + Comments)
                    they represend a section in the table view
 each element of annotation threads is itself an NSMutableArray
    these hold one individual annotation thread
 each of these threads has an element holding the annotation (usually element 0) and then elements that represent the other cells
    this could be: Comment cells, a new comment cell, or a cell that is displayed when the thread is collapsed and toggles to the expanded state
 
 each of these elements is an array again of three objects: 
    1st object: the model (either annotationModel or commentModel
    2nd object: the height of the cell
    3rd object: the identifier of the cell
 
 the tableViewDelegate methods act based on the information in this array
*/
@property (strong, nonatomic) NSMutableArray *annotationThreads;

@property (strong, nonatomic) IBOutlet MAAnnotationCell *annotationCell;
@property (strong, nonatomic) IBOutlet MACommentCell *commentCell;
@property (strong, nonatomic) IBOutlet MANewCommentCell *neueCommentCell;
@property (strong, nonatomic) IBOutlet MACommentsHiddenCell *commentsHiddenCell;
@property (strong, nonatomic) IBOutlet MAHeaderCell *headerCell;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

//method to determine the height of the textview that shows the content and has the specifeid width
- (int)calculateHeightOfContent:(NSString *)content forTextFieldWithWidth:(int)textFieldWidth;

@end

@implementation MAAnnotationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.annotationThreads = [[NSMutableArray alloc] init];
    self.view.frame = CGRectMake(0, 0, 320, 768);
	self.view.backgroundColor = [UIColor underPageBackgroundColor];
	self.tableView.backgroundColor = [UIColor clearColor];
    
    if (self.tableViewType == kGeneralTableView)
    {
        [MACoreDataController sharedInstance].generalTableViewDelegate = self;
		self.titleLabel.text = @"General Annotations";
    }
    else if (self.tableViewType == kSpecificTableView)
    {
        [MACoreDataController sharedInstance].specificTableViewDelegate = self;
		self.titleLabel.text = @"Scene Annotations";
    }
    else
    {
        self.titleLabel.text = @"Own Annotations";
    }
	
	//shadow for title label
	self.titleLabel.layer.masksToBounds = NO;
	CAGradientLayer *gradient = [CAGradientLayer layer];
	CGRect frame = self.titleLabel.bounds;
	frame.origin.y	= frame.size.height;
	frame.size.height = 5;
	gradient.frame = frame;
	gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0. alpha:0.3]CGColor], (id)[[UIColor clearColor]CGColor], nil];
	[self.titleLabel.layer addSublayer:gradient];

	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    
    [self prepareData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.annotationThreads.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ((NSArray *)self.annotationThreads[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    //Decide which kind of cell to use
    NSArray *currentAnnotationThread = self.annotationThreads[indexPath.section];
    NSString *cellIdentifier = (NSString *) ((NSArray *)currentAnnotationThread[indexPath.row]).lastObject;
    if ([cellIdentifier isEqualToString:@"AnnotationCell"])
    {
        //AnnotationCell
        MAAnnotationCell *currentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (currentCell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"MAAnnotationCell" owner:self options:nil];
            currentCell = self.annotationCell;
        }
        [currentCell setUpWithInformation:currentAnnotationThread[0][0] andHeight:currentAnnotationThread[0][1]];
        cell = currentCell;
    }
    else if ([cellIdentifier isEqualToString:@"CommentsHiddenCell"])
    {
        MAAnnotationModel *currentAnnotation = currentAnnotationThread[0][0];
    
        MACommentsHiddenCell *currentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (currentCell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"MACommentsHiddenCell" owner:self options:nil];
            currentCell = self.commentsHiddenCell;
        }
        currentCell.annotationModel = currentAnnotation;
        if (currentAnnotation.comments.count > 1)
        {
            [currentCell.displayCommentsButton setTitle:[NSString stringWithFormat:@"%d comments for this annotation", currentAnnotation.comments.count] forState:UIControlStateNormal];
        }
        else if (currentAnnotation.comments.count == 1)
        {
            [currentCell.displayCommentsButton setTitle:[NSString stringWithFormat:@"%d comment for this annotation", currentAnnotation.comments.count] forState:UIControlStateNormal];
        }
        else
        {
            [currentCell.displayCommentsButton setTitle:[NSString stringWithFormat:@"No comments for this annotation"] forState:UIControlStateNormal];
        }
        
        currentCell.delegate = self;
        cell = currentCell;
    }
    else if ([cellIdentifier isEqualToString:@"NewCommentCell"])
    {
        MAAnnotationModel *currentAnnotation = currentAnnotationThread[0][0];
        
        //NewCommentCell
        MANewCommentCell *currentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (currentCell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"MANewCommentCell" owner:self options:nil];
            currentCell = self.neueCommentCell;
        }
        //set the annotationModel this newCommentCell belongs to (so it can tell the CoreData controller which annotation to add the comment to
        currentCell.annotationModel = currentAnnotation;
        currentCell.delegate = self;
        cell = currentCell;
    }
    else if ([cellIdentifier isEqualToString:@"CommentCell"])
    {
        //CommentCell
        MACommentCell *currentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (currentCell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"MACommentCell" owner:self options:nil];
            currentCell = self.commentCell;
        }
        [currentCell setUpWithInformation:currentAnnotationThread[indexPath.row][0] andHeight:currentAnnotationThread[indexPath.row][1]];
        cell = currentCell;
    }
    else if ([cellIdentifier isEqualToString:@"General Annotations"] || [cellIdentifier isEqualToString:@"Scene Annotations"])
    {
        MAHeaderCell *currentCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        if (currentCell == nil)
        {
			[[NSBundle mainBundle]loadNibNamed:@"MAHeaderCell" owner:self options:nil];
			currentCell = self.headerCell;
			//shadow for title label
			currentCell.backingView.layer.masksToBounds = YES;
			CAGradientLayer *gradient = [CAGradientLayer layer];
			CGRect frame = currentCell.backingView.bounds;
			gradient.frame = frame;
			gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor]CGColor], (id)[[UIColor colorWithWhite:0. alpha:1.]CGColor], (id)[[UIColor clearColor]CGColor], nil];
			[currentCell.backingView.layer addSublayer:gradient];

        }
		[currentCell setupWithHeader:cellIdentifier];
		
		cell = currentCell;
    }
    return cell;
}

#pragma mark - Getting the Annotations and calculating Cell properties

//preparing the initial annotationThreads array
- (void)prepareData
{
    if (self.tableViewType == kOwnTableView)
    {
        NSSet *allAnnotationsOfTheUser = [MAOrganizingController sharedInstance].currentUser.annotations;
        //filter for the currentMovie
        NSPredicate *filterForCurrentMovie = [NSPredicate predicateWithFormat:@"movie == %@",[MAOrganizingController sharedInstance].currentMovie];
        NSSet *movieAnnotationsOfCurrentUser = [allAnnotationsOfTheUser filteredSetUsingPredicate:filterForCurrentMovie];
        
        //filter for general Annotations
        NSPredicate *filterForGeneralAnnotations = [NSPredicate predicateWithFormat:@"isSceneSpecific == NO"];
        NSSet *generalAnnotations = [movieAnnotationsOfCurrentUser filteredSetUsingPredicate:filterForGeneralAnnotations];
        
        //filter for scene Annotations
        NSPredicate *filterForSceneAnnotations = [NSPredicate predicateWithFormat:@"isSceneSpecific == YES"];
        NSSet *sceneAnnotations = [movieAnnotationsOfCurrentUser filteredSetUsingPredicate:filterForSceneAnnotations];
        
        //sort generalAnnotations by their rating
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ratings" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
			NSSet *ratings1 = (NSSet *)obj1;
			NSSet *ratings2 = (NSSet *)obj2;
			int count1 = 0;
			int count2 = 0;
			
			for (MARatingModel *rating in ratings1) {
				if(rating.isPositive.boolValue)
					count1++;
			}
			
			for (MARatingModel *rating in ratings2) {
				if(rating.isPositive.boolValue)
					count2++;
			}
			
			int finalRating1 = count1 - (ratings1.count - count1);
            int finalRating2 = count2 - (ratings2.count - count2);
            
            if(finalRating1 > finalRating2)
            {
                return NSOrderedAscending;
            }
            else if (finalRating1 < finalRating2)
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedSame;
            }
			
		}];
        NSArray *sortedGeneralAnnotations = [generalAnnotations sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        //sort scene Annotations by their time in the movie
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
        NSArray *sortedSceneAnnotations = [sceneAnnotations sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        
        //fill the annotationsThreads Array
        //The general annotations and scene annotations are started by a normal cell with the kind of annotation --> make this clear in the annotation thread
        if (sortedGeneralAnnotations.count > 0)
        {
            //starting point for general Annotations
            NSArray *cellInfos = [NSArray arrayWithObjects:[NSNull null], [NSNumber numberWithInt:50], @"General Annotations", nil];
            NSMutableArray *annotationThread = [[NSMutableArray alloc] initWithObjects:cellInfos, nil];
            [self.annotationThreads addObject:annotationThread];
            
            //add the generalAnnotations
            for (MAAnnotationModel *currentAnnotation in sortedGeneralAnnotations)
            {
                NSNumber *heightOfCell = [NSNumber numberWithInt:[self calculateHeightOfContent:currentAnnotation.content forTextFieldWithWidth:205] + 60];
                NSArray *cellInfos = [[NSArray alloc] initWithObjects:currentAnnotation, heightOfCell, @"AnnotationCell", nil];
                NSMutableArray *annotationThread = [[NSMutableArray alloc] initWithObjects:cellInfos, nil];
                
                //add cellInfo for CommentsHiddenCell
                NSArray *commentsHiddenCellInfos = [NSArray arrayWithObjects:[NSNull null], [NSNumber numberWithInt:100], @"CommentsHiddenCell", nil];
                [annotationThread addObject:commentsHiddenCellInfos];
                
                [self.annotationThreads addObject:annotationThread];
            }

        }
        if (sortedSceneAnnotations.count > 0)
        {
            //starting point for scene Annotations
            NSArray *cellInfos = [NSArray arrayWithObjects:[NSNull null], [NSNumber numberWithInt:50], @"Scene Annotations", nil];
            NSMutableArray *annotationThread = [[NSMutableArray alloc] initWithObjects:cellInfos, nil];
            [self.annotationThreads addObject:annotationThread];
            
            //add the generalAnnotations
            for (MAAnnotationModel *currentAnnotation in sortedSceneAnnotations)
            {
                NSNumber *heightOfCell = [NSNumber numberWithInt:[self calculateHeightOfContent:currentAnnotation.content forTextFieldWithWidth:205] + 60];
                NSArray *cellInfos = [[NSArray alloc] initWithObjects:currentAnnotation, heightOfCell, @"AnnotationCell", nil];
                NSMutableArray *annotationThread = [[NSMutableArray alloc] initWithObjects:cellInfos, nil];
                
                //add cellInfo for CommentsHiddenCell
                NSArray *commentsHiddenCellInfos = [NSArray arrayWithObjects:[NSNull null], [NSNumber numberWithInt:100], @"CommentsHiddenCell", nil];
                [annotationThread addObject:commentsHiddenCellInfos];
                
                [self.annotationThreads addObject:annotationThread];
            }

        }
        
    }
    else
        //either all general or all scene Annotations
    {
        BOOL shouldGetSceneSpecific = NO;
        if (self.tableViewType == kGeneralTableView)
        {
            shouldGetSceneSpecific = NO;
        }
        else if (self.tableViewType == kSpecificTableView)
        {
            shouldGetSceneSpecific = YES;
        }
        NSArray *fetchedAnnotations = [[MACoreDataController sharedInstance] getAnnotationsForMovie:[MAOrganizingController sharedInstance].currentMovie whereSceneSpecificIs:shouldGetSceneSpecific];

		if(self.tableViewType == kGeneralTableView)
		{
			NSArray *tempArray = [fetchedAnnotations sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				MAAnnotationModel *a1 = (MAAnnotationModel *)obj1;
				MAAnnotationModel *a2 = (MAAnnotationModel *)obj2;
				int count1 = 0;
				int count2 = 0;
				
				for (MARatingModel *rating in a1.ratings) {
					if(rating.isPositive.boolValue)
						count1++;
				}
				
				for (MARatingModel *rating in a2.ratings) {
					if(rating.isPositive.boolValue)
						count2++;
				}
				
                int finalRating1 = count1 - (a1.ratings.count - count1);
                int finalRating2 = count2 - (a2.ratings.count - count2);
                
				if(finalRating1 > finalRating2)
				{
					return NSOrderedAscending;
				}
				else if (finalRating1 < finalRating2)
				{
					return NSOrderedDescending;
				}
				else
				{
					return NSOrderedSame;
				}
				
			}];
			fetchedAnnotations = tempArray;
		}



        for (MAAnnotationModel *currentAnnotation in fetchedAnnotations)
        {
            NSNumber *heightOfCell = [NSNumber numberWithInt:[self calculateHeightOfContent:currentAnnotation.content forTextFieldWithWidth:205] + 60];
            NSArray *cellInfos = [[NSArray alloc] initWithObjects:currentAnnotation, heightOfCell, @"AnnotationCell", nil];
            NSMutableArray *annotationThread = [[NSMutableArray alloc] initWithObjects:cellInfos, nil];
            
            //add cellInfo for CommentsHiddenCell
            NSArray *commentsHiddenCellInfos = [NSArray arrayWithObjects:[NSNull null], [NSNumber numberWithInt:100], @"CommentsHiddenCell", nil];
            [annotationThread addObject:commentsHiddenCellInfos];

            [self.annotationThreads addObject:annotationThread];
        }
    }
}

- (int)calculateHeightOfContent:(NSString *)content forTextFieldWithWidth:(int)textFieldWidth
{
    CGSize textViewFrame = [content sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:CGSizeMake(textFieldWidth, 2000) lineBreakMode:NSLineBreakByWordWrapping];
    [content sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] forWidth:textFieldWidth lineBreakMode:NSLineBreakByWordWrapping];
    
    int newHeight = textViewFrame.height;
    if (newHeight > 50)
    {
        int returnValue = newHeight+0.2*content.length;

        //TODO: this calculation is not very good since it adds to much space when the content is long.
        //There is no perfect way to calculate the height.
        return returnValue+20;
    }
    else
    {
        return 80;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {

    NSArray *annotationThread = self.annotationThreads[indexPath.section];
//        NSLog(@"%d, %d",self.annotationThreads.count, annotationThread.count);
    NSArray *cellInfo = annotationThread[indexPath.row];
    NSNumber *height = cellInfo[1];
    return height.intValue;
//        return ((NSNumber *) self.annotationThreads[indexPath.section][indexPath.row][1]).intValue;
}


#pragma mark - MACoreDataController delegate

- (void)addedNewAnnotation:(MAAnnotationModel *)theAnnotation
{
    //calculate the cellInfos of the new Annotation
    NSNumber *heightOfCell = [NSNumber numberWithInt:[self calculateHeightOfContent:theAnnotation.content forTextFieldWithWidth:205] + 60];
    NSArray *cellInfos = [NSArray arrayWithObjects:theAnnotation, heightOfCell, @"AnnotationCell", nil];
    NSMutableArray *newAnnotationThread = [NSMutableArray arrayWithObject: cellInfos];
    
    //add cellInfo for CommentsHiddenCell
    NSArray *commentsHiddenCellInfos = [NSArray arrayWithObjects:[NSNull null], [NSNumber numberWithInt:100], @"CommentsHiddenCell", nil];
    [newAnnotationThread addObject:commentsHiddenCellInfos];
    
    //add it to the annotation threads
    [self.annotationThreads addObject:newAnnotationThread];
    
    //update the tableView
    [self.tableView reloadData];
    //[self scrollToAnnotation:theAnnotation];
}

- (void)addedNewComment:(MACommentModel *)newComment forAnnotation:(MAAnnotationModel *)theAnnotation
{
    //TODO: just do this if the CommentsHiddenCell is already removed
    
    NSMutableArray *theAnnotationThread;
    //find the annotation thread this comment belongs to
    NSMutableArray *currentAnnotationThread;
    int sectionCounter = 0;
    for (sectionCounter = 0; sectionCounter < self.annotationThreads.count; sectionCounter++)
    {
        currentAnnotationThread = self.annotationThreads[sectionCounter];
        if (currentAnnotationThread[0][0] == theAnnotation)
        {
            theAnnotationThread = currentAnnotationThread;
            break;
        }
    }
    
    //just add the cell information into the arrays if the thread is already displayed (expanded)
    //if this change is triggered remotely and the thread isn't visible yet it should not change
    if (theAnnotationThread.count == 2 && [((NSString *) ((NSArray *)theAnnotationThread.lastObject).lastObject) isEqualToString:@"CommentsHiddenCell"])
    {
        //the comment would be inserted if the annotation thread expands. So we don't have to do it here
        return;
    }
    NSNumber *heightOfCell = [NSNumber numberWithInt:[self calculateHeightOfContent:newComment.content forTextFieldWithWidth:190] + 60];
    NSArray *cellInfos = [[NSArray alloc] initWithObjects:newComment, heightOfCell, @"CommentCell", nil];
    
    //add the new cellInfo at the second to last place
    [theAnnotationThread insertObject:cellInfos atIndex:theAnnotationThread.count-1];
    
    NSIndexPath *indexPathForNewRow = [NSIndexPath indexPathForRow:theAnnotationThread.count-2 inSection:sectionCounter];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForNewRow] withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark - MACommentsHiddenCell delegate

- (void)insertCommentsForAnnotation:(MAAnnotationModel *)theAnnotation
{
    NSMutableArray *theAnnotationThread;
    //find the annotation thread this comment belongs to
    NSMutableArray *currentAnnotationThread;
    int sectionCounter = 0;
    for (sectionCounter = 0; sectionCounter < self.annotationThreads.count; sectionCounter++)
    {
        currentAnnotationThread = self.annotationThreads[sectionCounter];
        if (currentAnnotationThread[0][0] == theAnnotation)
        {
            theAnnotationThread = currentAnnotationThread;
            break;
        }
    }
    
    //remove the commentsHiddenCellInfos
    if ([(NSString *)((NSArray *)currentAnnotationThread.lastObject).lastObject isEqualToString:@"CommentsHiddenCell"])
    {
        [currentAnnotationThread removeLastObject];
    }
    
    //sort the comments of the annotation
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    NSArray *sortedComments = [theAnnotation.comments sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:sortedComments.count];

    NSArray *cellInfos;
    NSNumber *heightOfCell;
    for (MACommentModel *currentComment in sortedComments) {
        heightOfCell = [NSNumber numberWithInt:[self calculateHeightOfContent:currentComment.content forTextFieldWithWidth:190] + 60];
        cellInfos = [[NSArray alloc] initWithObjects:currentComment, heightOfCell, @"CommentCell", nil];
        
        //add the new cellInfo at the last place
        [theAnnotationThread addObject:cellInfos];

        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:theAnnotationThread.count-1 inSection:sectionCounter];
        [indexPaths addObject:currentIndexPath];
    }
    
    //add infos for newCommentCell
    cellInfos = [[NSArray alloc] initWithObjects:[NSNull null], [NSNumber numberWithInt:215], @"NewCommentCell", nil];
    [theAnnotationThread addObject:cellInfos];
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:theAnnotationThread.count-1 inSection:sectionCounter];
    [indexPaths addObject:currentIndexPath];

    NSIndexPath *indexPathOfHiddenCommentsCell = [NSIndexPath indexPathForRow:1 inSection:sectionCounter];
    NSArray *indexPathArray = [NSArray arrayWithObject:indexPathOfHiddenCommentsCell];
    
    //Insert the CommentCells and remove the commentsHiddenCell
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self scrollToAnnotation:theAnnotation];

}

#pragma mark - NewCommentCell delegate
- (void)scrollUpCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)hideCommentsOfAnnotationAtSection:(int)section
{
    //get annotation thread array
    NSArray *annotationThread = self.annotationThreads[section];
    
    //get the number of elements that are removed (needed for the indexPaths)
    int numberOfRemovedElements = annotationThread.count - 1;
    
    //make new Array containing just the annotation and the CommentsHiddenCellInfos
    NSMutableArray *newAnnotationThreadArray = [NSMutableArray arrayWithCapacity:2];
    newAnnotationThreadArray[0] = annotationThread[0];
    
    NSArray *commentsHiddenCellInfos = [NSArray arrayWithObjects:[NSNull null], [NSNumber numberWithInt:100], @"CommentsHiddenCell", nil];
    [newAnnotationThreadArray addObject:commentsHiddenCellInfos];
    NSIndexPath *commentsHiddenCellIndexPath = [NSIndexPath indexPathForRow:1 inSection:section];
    
    self.annotationThreads[section] = newAnnotationThreadArray;
    
    //creating indexPath objects for animation
    NSMutableArray *indexPathArray = [NSMutableArray arrayWithCapacity:numberOfRemovedElements];
    for (int i = 0; i < numberOfRemovedElements; i++)
    {
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:i+1 inSection:section];
        [indexPathArray addObject:currentIndexPath];
    }

    //Insert the CommentsHiddenCell and Remove the other Comments
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:commentsHiddenCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self scrollToAnnotation:annotationThread[0][0]];
    
}

- (void)scrollToAnnotation:(MAAnnotationModel *)annotation
{
	// chose for due to index, can also be obtained by function call inside of forin-enumeration => faster?
	for (int i = 0; i < self.annotationThreads.count; ++i) {
		NSArray *annotationInfo = (NSArray *)self.annotationThreads[i];
		// check for equality
		if(annotationInfo[0][0] == annotation)
		{
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
			//selection (=> highlighting) does not work for some reason
//			[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] animated:YES scrollPosition:UITableViewScrollPositionTop];
			break;
		}
	}
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


//adjust the frame of the table view to shrink when the keyboard is shown
//this is taken from: http://stackoverflow.com/questions/2743140/ipad-keyboard-dimensions
- (void) keyboardDidShow:(NSNotification*)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //NSLog(@"keyboard frame raw %@", NSStringFromCGRect(keyboardFrame));
    
    UIWindow *window = [[[UIApplication sharedApplication] windows]objectAtIndex:0];
    UIView *mainSubviewOfWindow = window.rootViewController.view;
    CGRect keyboardFrameConverted = [mainSubviewOfWindow convertRect:keyboardFrame fromView:window];
    //NSLog(@"keyboard frame converted %@", NSStringFromCGRect(keyboardFrameConverted));
    
    CGRect frame = self.tableView.frame;
    frame.size.height = frame.size.height - keyboardFrameConverted.size.height;
    self.tableView.frame = frame;
}
- (void) keyboardDidHide:(NSNotification *)notification
{
    CGRect frame = self.tableView.frame;
    frame.size.height = 719;
    self.tableView.frame = frame;
}

@end
