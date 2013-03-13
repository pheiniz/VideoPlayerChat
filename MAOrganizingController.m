//
//  MAOrganizingController.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 18.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#define MIN_SIDEBAR_OFFSET -320
#define MAX_SIDEBAR_OFFSET 0
#define SIDEBAR_THRESHOLD -160
#define MIN_PLAYER_OFFSET 0
#define MAX_PLAYER_OFFSET 320
#define MIN_PLAYER_WIDTH 703
#define MAX_PLAYER_WIDTH 1024

#import "MAOrganizingController.h"
#import "MASidebarController.h"

//TODO Mockup
#import "MACoreDataController.h"

@interface MAOrganizingController ()
@property (strong, nonatomic) MASidebarController *sidebarController;
@property (strong, nonatomic, readwrite) MAMovieController *movieController;


//TODO Mockup
@property (strong, nonatomic) MAUserModel *philUser;
@property (strong, nonatomic) MAUserModel *janUser;

//testing
@property (strong, nonatomic) UIView *touchMonitor;


- (void)toggleSidebar;
- (void)touchReceived;

@end

@implementation MAOrganizingController

static MAOrganizingController *sharedInstance = nil;
+ (MAOrganizingController *)sharedInstance {
    if (sharedInstance == nil) {
        NSLog(@"MAOrganizingController sharedInstance is nil!");
        return nil;
    }
	
    return sharedInstance;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.view.frame = CGRectMake(0, 0, 1024, 768);
    
    //load the view elements
    self.sidebarController = [[MASidebarController alloc] initWithViewFrame:CGRectMake(-320, 0, 320, 768)];
    self.movieController = [[MAMovieController alloc] initWithNibName:@"MAMovieController" bundle:[NSBundle mainBundle]];
    //hardcoded settings since some values weren't set correctly at this time
    self.movieController.view.frame = CGRectMake(0, 0, 1024, 768);
    
    [self.view addSubview:self.sidebarController.view];
    [self.view addSubview:self.movieController.view];
    
    self.movieController.organizingController = self;
    self.sidebarController.organizingController = self;
	
	// testing touch monitoring
	self.touchMonitor = [[UIView alloc]initWithFrame:self.view.bounds];
	UITapGestureRecognizer *receiver = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchReceived)];
	[self.touchMonitor addGestureRecognizer:receiver];
	[self.view addSubview:self.touchMonitor];
	self.isMonitoring = NO;
    
    //set the shared instance
    sharedInstance = self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //set the example users correctly
    NSArray *mockupUsers = [[MACoreDataController sharedInstance] getMockupUsers];
    if ([((MAUserModel *)mockupUsers[0]).name isEqualToString:@"Phil"]) {
        self.philUser = mockupUsers[0];
        self.janUser = mockupUsers[1];
    }
    else
    {
        self.janUser = mockupUsers[0];
        self.philUser = mockupUsers[1];
    }
    self.currentUser = self.janUser;
    
    self.currentMovie = [[MACoreDataController sharedInstance] getMockupMovie];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleSidebarButtonPressed
{
    [self toggleSidebar];
}

//relay actions to sidebar controller
- (void)addNewInformationButtonPressedAtPlaytime:(NSTimeInterval)timestamp andPosition:(float)position inDelegate:(id<MAAddNewInformationDelegate>)delegate
{
    if (!self.sidebarController.isOnScreen)
    {
        [self toggleSidebar];
        [self.movieController setPlayerIsPlaying:NO];
    }
    [self.sidebarController addNewInformationButtonPressedAtPlaytime:timestamp andPosition:position inDelegate:delegate];
}
- (void)showCommentButtonPressed
{
    if (!self.sidebarController.isOnScreen)
    {
        [self toggleSidebar];
        [self.movieController setPlayerIsPlaying:NO];
    }
    [self.sidebarController showCommentButtonPressed];
}

- (void)showAnnotationButtonPressedForAnnotation:(MAAnnotationModel *)annotation
{
	if (!self.sidebarController.isOnScreen)
    {
        [self toggleSidebar];
        [self.movieController setPlayerIsPlaying:NO];
    }
    [self.sidebarController showAnnotationButtonPressedForAnnotation:annotation];
}

- (void)slideSidebar:(CGFloat)offset withRecognizerState:(UIGestureRecognizerState)state
{
	CGRect sidebarFrame = self.sidebarController.view.frame;
	CGRect playerFrame = self.movieController.view.frame;
	
	if(state != UIGestureRecognizerStateEnded)
	{
		sidebarFrame.origin.x += offset;
		if(sidebarFrame.origin.x > MAX_SIDEBAR_OFFSET) sidebarFrame.origin.x = MAX_SIDEBAR_OFFSET;
		else if (sidebarFrame.origin.x < MIN_SIDEBAR_OFFSET) sidebarFrame.origin.x = MIN_SIDEBAR_OFFSET;
		
		playerFrame.origin.x	+= offset;
		playerFrame.size.width -= offset;
		if(playerFrame.origin.x > MAX_PLAYER_OFFSET)
		{
			playerFrame.origin.x = MAX_PLAYER_OFFSET;
			playerFrame.size.width	 = MIN_PLAYER_WIDTH;
			self.sidebarController.isOnScreen = YES;
			[self.movieController leftArrowInSlider];
		}
		else if (playerFrame.origin.x < MIN_PLAYER_OFFSET)
		{
			playerFrame.origin.x = MIN_PLAYER_OFFSET;
			playerFrame.size.width	 = MAX_PLAYER_WIDTH;
			self.sidebarController.isOnScreen = NO;
			[self.movieController rightArrowInSlider];
		}
		self.sidebarController.view.frame = sidebarFrame;
		self.movieController.view.frame = playerFrame;
		[self.movieController updatePlayerFrame];
	}
	else if(state == UIGestureRecognizerStateEnded)
	{
		if (sidebarFrame.origin.x > SIDEBAR_THRESHOLD)
		{
			playerFrame.origin.x = MAX_PLAYER_OFFSET;
			playerFrame.size.width = MIN_PLAYER_WIDTH;
			sidebarFrame.origin.x = MAX_SIDEBAR_OFFSET;
			self.sidebarController.isOnScreen = YES;
			[self.movieController leftArrowInSlider];
		}
		else
		{
			playerFrame.origin.x = MIN_PLAYER_OFFSET;
			playerFrame.size.width = MAX_PLAYER_WIDTH;
			sidebarFrame.origin.x = MIN_SIDEBAR_OFFSET;
			self.sidebarController.isOnScreen = NO;
			[self.movieController rightArrowInSlider];
		}
		
		[UIView animateWithDuration:0.3 animations:^(void){
			self.sidebarController.view.frame = sidebarFrame;
			self.movieController.view.frame = playerFrame;
		} completion:^(BOOL finished){
			[self.movieController updatePlayerFrame];
		}];
	}
	
    
}


-(void)toggleSidebar
{
	// get current frames
	CGRect sidebarFrame = self.sidebarController.view.frame;
	CGRect playerFrame = self.movieController.view.frame;
    
	//set correct frames
	if (!self.sidebarController.isOnScreen)
	{
		playerFrame.origin.x = MAX_PLAYER_OFFSET;
		playerFrame.size.width	 = MIN_PLAYER_WIDTH;
		sidebarFrame.origin.x = MAX_SIDEBAR_OFFSET;
		self.sidebarController.isOnScreen = YES;
		[self.movieController leftArrowInSlider];
	}
	else
	{
		playerFrame.origin.x = MIN_PLAYER_OFFSET;
		playerFrame.size.width	 = MAX_PLAYER_WIDTH;
		sidebarFrame.origin.x = MIN_SIDEBAR_OFFSET;
		self.sidebarController.isOnScreen = NO;
		[self.movieController rightArrowInSlider];
	}
	
	[UIView beginAnimations:@"sliding" context:nil];
	[UIView setAnimationDuration:0.5];
	// change framesize animated
	self.sidebarController.view.frame = sidebarFrame;
	self.movieController.view.frame = playerFrame;
	[UIView commitAnimations];
	
	// update frame (and comment marks)
	[self.movieController updatePlayerFrame];
}

- (void)toggleUser
{
    if (self.currentUser == self.janUser)
    {
        self.currentUser = self.philUser;
    }
    else
    {
        self.currentUser = self.janUser;
    }
}

-(void)setIsMonitoring:(BOOL)isMonitoring
{
	if(isMonitoring)
	{
		self.touchMonitor.hidden = NO;
	}
	else
	{
		self.touchMonitor.hidden = YES;
	}
	
	_isMonitoring = isMonitoring;
}

-(void)touchReceived
{
	if(self.isMonitoring)
	{
		[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
		self.isMonitoring = NO;
	}
}

@end
