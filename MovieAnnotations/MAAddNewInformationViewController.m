//
//  MAAddNewInformationViewController.m
//  MovieAnnotations
//
//  Created by Philipp Wacker on 13.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import "MAAddNewInformationViewController.h"
#import "MACategoryModel.h"
#import "MASidebarController.h"
#import "MAOrganizingController.h"
#import <QuartzCore/QuartzCore.h>

@interface MAAddNewInformationViewController ()
@property (weak, nonatomic) IBOutlet UITextView *annotationContentTextView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeOfAnnotation;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

//mockup
@property (weak, nonatomic) IBOutlet UITableView *categoryTable;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSMutableSet *selectedCategories;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


- (IBAction)cancelButtonPressed;
- (IBAction)saveButtonPressed;

@end

@implementation MAAddNewInformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.selectedCategories = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.categories = [[MACoreDataController sharedInstance] getMockupCategories];
	self.annotationContentTextView.delegate = self;
	self.view.backgroundColor = [UIColor underPageBackgroundColor];
	
	self.titleLabel.layer.masksToBounds = NO;
	CAGradientLayer *gradient = [CAGradientLayer layer];
	CGRect frame = self.titleLabel.bounds;
	frame.origin.y	= frame.size.height;
	frame.size.height = 5;
	gradient.frame = frame;
	gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0. alpha:0.3]CGColor], (id)[[UIColor clearColor]CGColor], nil];
	[self.titleLabel.layer addSublayer:gradient];
	
	UIImage *img = [[UIImage imageNamed:@"gradient"]resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
	[self.cancelButton setBackgroundImage:img forState:UIControlStateNormal];
	[self.saveButton setBackgroundImage:img forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed
{
    //TODO: hide sidebar?
	[self clear];
	[self.sidebarController showCommentButtonPressed];
	[[MAOrganizingController sharedInstance] toggleSidebarButtonPressed];
	[self.delegate resumePlaying];
}

-(void) clear
{
	self.annotationContentTextView.text = @"";
	self.typeOfAnnotation.selectedSegmentIndex = 0;
	[self.selectedCategories removeAllObjects];
}

- (IBAction)saveButtonPressed
{
	//store annotation
	[[MACoreDataController sharedInstance] addNewAnnotationWithContent:self.annotationContentTextView.text
														 andCategories:self.selectedCategories
													   isSceneSpecific:[NSNumber numberWithInt:self.typeOfAnnotation.selectedSegmentIndex].boolValue
														  forTimestamp:self.timestamp
												 andPercentagePosition:self.position];
	
	//return
	[self.sidebarController displaySectionWithID:self.typeOfAnnotation.selectedSegmentIndex];
	
	//start player again
	[self.delegate resumePlaying];
	
	//reload annotation data
	[self.delegate reloadAnnotations];
	
    //clear state
	[self clear];
    
}

#pragma mark TableView
-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
	if(cell == nil)
	{
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CategoryCell"];
	}
	
	MACategoryModel *cat = (MACategoryModel *)[self.categories objectAtIndex:indexPath.row];
	cell.textLabel.text = cat.name;
	if([self.selectedCategories containsObject: [NSNumber numberWithInt:indexPath.row]])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	//default imagename
	NSString *imageName = @"movie.png";
	
	if([cat.name isEqualToString:@"Bloopers"])
	{
		imageName = @"recycle-bin.png";
	}
	else if ([cat.name isEqualToString:@"Cameo"])
	{
		imageName =@"man.png";
	}
	else if ([cat.name isEqualToString:@"Actor"])
	{
		imageName =@"drama.png";
	}
	else if ([cat.name isEqualToString:@"Trivia"])
	{
		imageName =@"question.png";
	}
	else if ([cat.name isEqualToString:@"Fun Fact"])
	{
		imageName =@"smiley.png";
	}
	
	cell.imageView.image = [UIImage imageNamed:imageName];
	
	return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	if([self.selectedCategories containsObject:[self.categories objectAtIndex:indexPath.row]])
	{
		[self.selectedCategories removeObject:[self.categories objectAtIndex:indexPath.row]];
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else
	{
		[self.selectedCategories addObject:[self.categories objectAtIndex:indexPath.row]];
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
	[MAOrganizingController sharedInstance].isMonitoring = YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
	[MAOrganizingController sharedInstance].isMonitoring = NO;
}

@end
