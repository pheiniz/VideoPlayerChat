//
//  MAAddNewInformationViewController.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 13.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MACoreDataController.h"

@class MASidebarController;

@protocol MAAddNewInformationDelegate <NSObject>

-(void)resumePlaying;
-(void)reloadAnnotations;

@end

@interface MAAddNewInformationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) MASidebarController *sidebarController;
@property (assign) NSTimeInterval timestamp;
@property (assign) float position;
@property (weak, nonatomic) id<MAAddNewInformationDelegate> delegate;

@end
