//
//  MACommentTableViewController.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 20.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MACoreDataController.h"
#import "MACommentsHiddenCell.h"
#import "MANewCommentCell.h"

//type to differentiate between the different tableview kinds
typedef enum {
    kGeneralTableView,
    kSpecificTableView,
    kOwnTableView
} TableViewType;


@interface MAAnnotationTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MACoreDataDelegate, MACommentsHiddenCellDelegate, MANewCommentCellDelegate>

@property (nonatomic) TableViewType tableViewType;

- (void)scrollToAnnotation:(MAAnnotationModel *)annotation;

@end
