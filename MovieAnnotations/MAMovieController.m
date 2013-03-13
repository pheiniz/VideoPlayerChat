//
//  MAMovieController.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 13.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

//
// Needed from CoreData:
// 	- MovieTitle
// 	- MovieDuration (can be obtained from file)
//	- Movie-URL
// 	- Comments:
//		- timestamp
// 		- Category?
//		- Teaser-Text

#import "MAMovieController.h"
#import "MAOrganizingController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DDProgressView.h"
#import "MACoreDataController.h"
#import "MAAnnotationModel.h"


#define TIMEBAR_OFFSET 38

@interface MAMovieController ()
@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (strong, nonatomic) MPMoviePlayerController *player;
@property (weak, nonatomic) IBOutlet UIView *playerControlsView;
@property (weak, nonatomic) IBOutlet UIView *movieInformationView;
@property (weak, nonatomic) IBOutlet UILabel *movieStatusLabel;
@property (weak, nonatomic) IBOutlet DDProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *sidebarSlider;
@property (weak, nonatomic) IBOutlet UIView *touchInterceptor;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *sliderButton;
@property (nonatomic, assign) BOOL controlsVisible;
@property (nonatomic, strong) UIImageView *timeSlider;
@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;

//mockup
@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, strong) NSMutableArray *annotationMarks;


- (IBAction)addInformationButtonPressed:(id)sender;
- (IBAction)showAnnotationButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(UIButton *)sender;
- (IBAction)toggleSidebarPressed:(id)sender;
- (void)updateProgress;
- (IBAction)handleTap:(UITapGestureRecognizer *)sender;
- (IBAction)handlePan:(UIPanGestureRecognizer *)sender;
- (IBAction)handleTapOnMovie:(id)sender;
- (IBAction)moveSidebar:(UIPanGestureRecognizer *)sender;
- (IBAction)fastForwardButtonPressed:(UIButton *)sender;
- (IBAction)fastRewindButtonPressed:(UIButton *)sender;

//mockup
@property (weak, nonatomic) IBOutlet UISegmentedControl *userSwitch;
- (IBAction)userSwitchValueChanged:(id)sender;

-(void) updateAnnotationMarks;

@end

@implementation MAMovieController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		NSURL *movieURL = [[NSBundle mainBundle]URLForResource:@"The Hobbit" withExtension:@"mov"];
		self.player = [[MPMoviePlayerController alloc]initWithContentURL:movieURL];
		[self.playerContainer addSubview:self.player.view];
		//		[self.player play];
		self.controlsVisible = YES;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	NSURL *movieURL = [[NSBundle mainBundle]URLForResource:@"The Hobbit" withExtension:@"mov"];
	self.player = [[MPMoviePlayerController alloc]initWithContentURL:movieURL];
	self.player.view.frame = CGRectMake(0,0,self.playerContainer.frame.size.width, self.playerContainer.frame.size.height);
	[self.playerContainer insertSubview:self.player.view belowSubview:self.touchInterceptor];
	self.player.controlStyle = MPMovieControlStyleNone;
	self.player.shouldAutoplay = NO;
	[self.player prepareToPlay];
	
	[self updateProgress];
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
	self.timeSlider = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"button-record_smaller.png"]];
	self.timeSlider.frame = CGRectMake(0, 0, 22, 22);
	[self.progressView addSubview:self.timeSlider];
	self.movieInformationView.backgroundColor = [UIColor blackColor];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.movieTitleLabel setText:[[MACoreDataController sharedInstance] getMockupMovie].title];
	self.annotations = [[MACoreDataController sharedInstance] getAnnotationsForMovie:[MAOrganizingController sharedInstance].currentMovie
																whereSceneSpecificIs:YES];
	self.annotationMarks = [[NSMutableArray alloc]init];
	// add commentMarks to timeline
	[self updateAnnotationMarks];
}

-(void) dealloc
{
	self.timeSlider = nil;
	self.player = nil;
	self.annotationMarks = nil;
	self.annotations = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addInformationButtonPressed:(id)sender {
    
	[self.player pause];
	self.playButton.selected = NO;
	NSTimeInterval timestamp = self.player.currentPlaybackTime;
	float position = self.player.currentPlaybackTime/self.player.duration;
    [self.organizingController addNewInformationButtonPressedAtPlaytime:timestamp andPosition:position inDelegate:self];
}

- (IBAction)showAnnotationButtonPressed:(id)sender
{
	if([sender isKindOfClass:[UIButton class]])
	{
		UIButton *button = (UIButton *) sender;
		[self.organizingController showAnnotationButtonPressedForAnnotation:[self.annotations objectAtIndex:button.tag - 42]];
	}

}

- (IBAction)playButtonPressed:(UIButton *)sender
{
	if(self.player.playbackState == MPMoviePlaybackStatePlaying)
	{
		[self.player pause];
		self.playButton.selected = NO;
	}
	else
	{
		[self.player play];
		self.playButton.selected = YES;
	}
}

- (void)setPlayerIsPlaying:(BOOL)state
{
    if (state)
    {
        [self.player play];
		self.playButton.selected = YES;
    }
    else
    {
        [self.player pause];
		self.playButton.selected = NO;
    }
}

- (IBAction)toggleSidebarPressed:(id)sender
{
    [self.organizingController toggleSidebarButtonPressed];
}


-(void)updateProgress
{
	float progress = self.player.currentPlaybackTime / self.player.duration;
	
	// 5 sec threshold for showing comment button
	float threshold = 5 / self.player.duration;
	
	[self.progressView setProgress:(progress)];
	
	// check for pop up
	for (MAAnnotationModel *annotation in self.annotations) {
		int index = [self.annotations indexOfObject:annotation]+42;
		float position = annotation.percentagePosition.floatValue;
		// check if close to a comment
		if(progress > (position - threshold) && progress < (position + threshold))
		{
			// check if button already exists
			if([self.playerContainer viewWithTag:index] == nil){
				// create button
				UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				commentButton.frame = CGRectMake(position * self.progressView.bounds.size.width - 40, 0, 80, 75);
				[commentButton setBackgroundImage:[UIImage imageNamed:@"darkCallout.png"] forState:UIControlStateNormal];
				UILabel *buttonLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,15,commentButton.bounds.size.width - 20, commentButton.bounds.size.height - 20)];
				buttonLabel.textColor = [UIColor whiteColor];
				buttonLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
				buttonLabel.backgroundColor = [UIColor clearColor];
				buttonLabel.numberOfLines = 3;
				buttonLabel.lineBreakMode = NSLineBreakByTruncatingTail;
				buttonLabel.textAlignment = NSTextAlignmentCenter;
				buttonLabel.text = annotation.content;
				[commentButton addSubview:buttonLabel];
				// set Tag for recognizing button again, add offset
				commentButton.tag = index;
				[commentButton addTarget:self action:@selector(showAnnotationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
				[self.playerContainer addSubview:commentButton];
			}
		}
		else if([self.playerContainer viewWithTag:index] != nil)
		{
			// remove button, if it still exists
			[[self.playerContainer viewWithTag:index] removeFromSuperview];
		}
	}
	
	// TODO: fix weird behavior when moving timeslider (not attached to timebar anymore)
	CGRect frame = self.timeSlider.frame;
	frame.origin.x = progress * self.progressView.frame.size.width - 15;
	if(frame.origin.x > 0){
		self.timeSlider.frame = frame;
	}
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
	self.player.currentPlaybackTime = ([sender locationOfTouch:0 inView:sender.view].x / sender.view.bounds.size.width)*self.player.duration;
	[self.progressView setProgress:([sender locationOfTouch:0 inView:sender.view].x / sender.view.bounds.size.width)];
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)sender
{
	self.player.currentPlaybackTime = ([sender locationInView:sender.view].x / sender.view.bounds.size.width)*self.player.duration;
}

- (IBAction)handleTapOnMovie:(id)sender
{
	[self toggleControls];
}

-(void) toggleControls
{
	if(self.controlsVisible)
	{
		[MAOrganizingController sharedInstance].view.frame = [UIScreen mainScreen].bounds;
		[UIView animateWithDuration:0.5 animations:^(void){
			self.playerControlsView.alpha = 0;
			// adapt movie info (move up)
			CGRect infoRect = self.movieInformationView.frame;
			infoRect.origin.y = infoRect.origin.y-TIMEBAR_OFFSET;
			self.movieInformationView.frame = infoRect;
			
			//adapt progress bar, to keep touch recognizer working
			CGRect progressRect = self.progressView.frame;
			progressRect.origin.y = progressRect.origin.y-TIMEBAR_OFFSET;
			self.progressView.frame = progressRect;
			
			
			//adapt player (move up, increase height)
			CGRect playerRect = self.playerContainer.frame;
			playerRect.size.height += TIMEBAR_OFFSET;
			playerRect.origin.y -= TIMEBAR_OFFSET;
			self.playerContainer.frame = playerRect;
		}];
		self.controlsVisible = NO;
	}
	else
	{
		[UIView animateWithDuration:0.5 animations:^(void){
			self.playerControlsView.alpha = 0.6;
			// adapt movie info (move down)
			CGRect infoRect = self.movieInformationView.frame;
			infoRect.origin.y = infoRect.origin.y+TIMEBAR_OFFSET;
			self.movieInformationView.frame = infoRect;
			
			//adapt progress bar, to keep touch recognizer working
			CGRect progressRect = self.progressView.frame;
			progressRect.origin.y = progressRect.origin.y+TIMEBAR_OFFSET;
			self.progressView.frame = progressRect;
			
			// adapt player (move down, decrease height)
			CGRect playerRect = self.playerContainer.frame;
			playerRect.size.height -= TIMEBAR_OFFSET;
			playerRect.origin.y += TIMEBAR_OFFSET;
			self.playerContainer.frame = playerRect;
		} completion:^(BOOL finished){
		}];
		self.controlsVisible = YES;
	}
}

// handle the panning input when the user slides the sidebar out
- (IBAction)moveSidebar:(UIPanGestureRecognizer *)sender
{
	CGFloat newX = [sender translationInView:self.sidebarSlider].x;
	[sender setTranslation:CGPointMake(0, 0) inView:self.sidebarSlider];
	
	[self.organizingController slideSidebar:newX withRecognizerState:sender.state];
}

- (IBAction)fastForwardButtonPressed:(UIButton *)sender
{
	// TODO: check for different fast forward method or other times
	self.player.currentPlaybackTime += 30;
	
}

- (IBAction)fastRewindButtonPressed:(UIButton *)sender
{
	// TODO: check for different fast backward method or other times
	self.player.currentPlaybackTime -= 30;
}

-(void) updatePlayerFrame
{
	self.player.view.frame = self.playerContainer.bounds;
	[self updateAnnotationMarks];
}

-(void) updateAnnotationMarks
{
	// remove marks from timeline
	for (UIImageView *view in self.annotationMarks) {
		[view removeFromSuperview];
	}
	//remove marks from array
	[self.annotationMarks removeAllObjects];
	
	//TODO: when first updating, the frame size of the progressView is wrong (422 instead of 704)
	//add new marks to timeline and array
	for (MAAnnotationModel *annotation in self.annotations) {
		UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue-pin-md.png"]];
		float position = annotation.percentagePosition.floatValue * self.progressView.frame.size.width;
		iv.frame = CGRectMake(position-5.5, 2, 11.0, 18.0);
		iv.tag = [self.annotations indexOfObject:annotation]+42;
		[self.progressView addSubview:iv];
		[self.annotationMarks addObject:iv];
		
	}
	
	// reposition comment buttons
	for (int i = 0; i < self.annotations.count; ++i) {
		if([self.playerContainer viewWithTag:i+42] != nil){
			MAAnnotationModel *annotation = [self.annotations objectAtIndex:i];
			float position = annotation.percentagePosition.floatValue;
			[self.playerContainer viewWithTag:i+42].frame = CGRectMake(position * self.progressView.bounds.size.width - 40, 5, 80, 75);
		}
		
	}
	
}

- (IBAction)userSwitchValueChanged:(id)sender {
    [[MAOrganizingController sharedInstance] toggleUser];
}

- (void)leftArrowInSlider
{
	self.sliderButton.selected = NO;
}

- (void)rightArrowInSlider
{
	self.sliderButton.selected = YES;
}

#pragma mark AddNewInformationDelegate

-(void) resumePlaying
{
	if(self.player.playbackState != MPMoviePlaybackStatePlaying){
		[self.player play];
		self.playButton.selected = YES;
	}
}

-(void) reloadAnnotations
{
	self.annotations = [[MACoreDataController sharedInstance]getAnnotationsForMovie:[MAOrganizingController sharedInstance].currentMovie whereSceneSpecificIs:YES];
	[self updateAnnotationMarks];
}

-(void) jumpToAnnotation:(MAAnnotationModel *)annotation
{
	self.player.currentPlaybackTime = annotation.time.floatValue;
}

@end
