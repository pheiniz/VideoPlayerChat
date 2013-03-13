//
//  Category.h
//  MovieAnnotations
//
//  Created by Philipp Wacker on 19.01.13.
//  Copyright (c) 2013 Philipp Wacker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MAAnnotationModel;

@interface MACategoryModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *annotations;
@end

@interface MACategoryModel (CoreDataGeneratedAccessors)

- (void)addAnnotationsObject:(MAAnnotationModel *)value;
- (void)removeAnnotationsObject:(MAAnnotationModel *)value;
- (void)addAnnotations:(NSSet *)values;
- (void)removeAnnotations:(NSSet *)values;

@end
