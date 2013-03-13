//
//  MASidebarPagesController.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 12.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MASidebarPagesController.h"
#import "MAMovieController.h"

//test
#import "MAAnnotationTableViewController.h"

@interface MASidebarPagesController (){
 
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) MAAnnotationTableViewController *generalCommentController;
@property (strong, nonatomic) MAAnnotationTableViewController *sceneCommentController;
@property (strong, nonatomic) MAAnnotationTableViewController *ownCommentController;

-(void) loadScreens;

@end

@implementation MASidebarPagesController


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];

    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 3, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 0;
    
    [self loadScreens];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor underPageBackgroundColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadScreens
{
    self.generalCommentController = [[MAAnnotationTableViewController alloc] initWithNibName:@"MAAnnotationTableViewController" bundle:[NSBundle mainBundle]];
    self.generalCommentController.tableViewType = kGeneralTableView;
    self.sceneCommentController = [[MAAnnotationTableViewController alloc] initWithNibName:@"MAAnnotationTableViewController" bundle:[NSBundle mainBundle]];
    self.sceneCommentController.tableViewType = kSpecificTableView;
    self.ownCommentController = [[MAAnnotationTableViewController alloc] initWithNibName:@"MAAnnotationTableViewController" bundle:[NSBundle mainBundle]];
    self.ownCommentController.tableViewType = kOwnTableView;
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.generalCommentController.view.frame = frame;
    [self.scrollView addSubview:self.generalCommentController.view];
    
    frame.origin.x = frame.size.width;
    self.sceneCommentController.view.frame = frame;
    [self.scrollView addSubview:self.sceneCommentController.view];
    
    frame.origin.x = frame.size.width*2;
    self.ownCommentController.view.frame = frame;
    [self.scrollView addSubview:self.ownCommentController.view];
}

//taken from the PageControl sample
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (IBAction)pageChanged:(id)sender
{
    int page = self.pageControl.currentPage;
	
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

- (void)changePageTo:(int)page
{
    //move to the specific command section
    self.pageControl.currentPage = page;
    [self pageChanged:self];
    
}

- (void)scrollToAnnotation:(MAAnnotationModel *)annotation
{
	[self.sceneCommentController scrollToAnnotation:annotation];
}

@end
