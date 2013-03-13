//
//  MASidebarController.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 13.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MASidebarController.h"
#import "MASidebarPagesController.h"
#import "MAOrganizingController.h"
#import "MAAnnotationModel.h"

@interface MASidebarController (){
    //testing
    BOOL sidebarPagesIsLoaded;
}


@property (strong, nonatomic) MASidebarPagesController *sidebarPagesController;
@property (strong, nonatomic) MAAddNewInformationViewController *addNewInformationController;

@end

@implementation MASidebarController

- (id)initWithViewFrame:(CGRect)frame
{
    self = [super init];
    if (self)
    {
        self.view.frame = frame;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
    
    //TODO: don't know why I have to set the frame again. Why are the values set in "initWithFrame" not kept?
    self.view.frame = CGRectMake(0, 0, 320, 768);
    self.sidebarPagesController = [[MASidebarPagesController alloc] initWithNibName:@"MASidebarPagesController" bundle:[NSBundle mainBundle]];
    self.addNewInformationController = [[MAAddNewInformationViewController alloc] initWithNibName:@"MAAddNewInformationViewController" bundle:[NSBundle mainBundle]];
	self.addNewInformationController.sidebarController = self;
    [self.view addSubview:self.sidebarPagesController.view];
    sidebarPagesIsLoaded = YES;
    self.isOnScreen = NO;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCommentButtonPressed
{
    if (!sidebarPagesIsLoaded)
    {
        [self.addNewInformationController.view removeFromSuperview];
        [self.view addSubview:self.sidebarPagesController.view];
        sidebarPagesIsLoaded = YES;
    }
    
    [self.sidebarPagesController changePageTo:0];
}

- (void)showAnnotationButtonPressedForAnnotation:(MAAnnotationModel *)annotation
{

	if (!sidebarPagesIsLoaded)
    {
        [self.addNewInformationController.view removeFromSuperview];
        [self.view addSubview:self.sidebarPagesController.view];
        sidebarPagesIsLoaded = YES;
    }
    
    [self.sidebarPagesController changePageTo:1];
	[self.sidebarPagesController scrollToAnnotation:annotation];
}

- (void)displaySectionWithID:(int)id
{
    if (!sidebarPagesIsLoaded)
    {
        [self.addNewInformationController.view removeFromSuperview];
        [self.view addSubview:self.sidebarPagesController.view];
        sidebarPagesIsLoaded = YES;
    }
    
    [self.sidebarPagesController changePageTo:id];
}

- (void)addNewInformationButtonPressedAtPlaytime:(NSTimeInterval)timestamp andPosition:(float)position inDelegate:(id<MAAddNewInformationDelegate>)delegate
{
    if (sidebarPagesIsLoaded)
    {
        [self.sidebarPagesController.view removeFromSuperview];
		self.addNewInformationController.delegate = delegate;
        [self.view addSubview:self.addNewInformationController.view];
		self.addNewInformationController.timestamp = timestamp;
		self.addNewInformationController.position = position;
        sidebarPagesIsLoaded = NO;
    }
}


@end
