//
//  DDProgressView.m
//  DDProgressView
//
//  Created by Damien DeVille on 3/13/11.
//  Copyright 2011 Snappy Code. All rights reserved.
//

#import "DDProgressView.h"

#define kProgressBarHeight  22.0f
#define kProgressBarWidth	160.0f

@implementation DDProgressView

@synthesize innerColor ;
@synthesize outerColor ;
@synthesize emptyColor ;
@synthesize progress ;

- (id)init
{
	return [self initWithFrame: CGRectZero] ;
}

- (void)awakeFromNib
{
	self.backgroundColor = [UIColor clearColor] ;
	self.innerColor = [UIColor colorWithWhite:1.0 alpha:0.6] ;
	self.outerColor = [UIColor colorWithWhite:1.0 alpha:0.6] ;
	self.emptyColor = [UIColor clearColor] ;
	
}

- (void)dealloc
{
	innerColor = nil ;
	outerColor = nil ;
	emptyColor = nil ;
	
	 ;
}

- (void)setProgress:(float)theProgress
{
	// make sure the user does not try to set the progress outside of the bounds
	if (theProgress > 1.0f)
		theProgress = 1.0f ;
	if (theProgress < 0.0f)
		theProgress = 0.0f ;

	progress = theProgress ;
	//NSLog(@"progress: %f", progress);
	[self setNeedsDisplay] ;
}

- (void)setFrame:(CGRect)frame
{
	// we set the height ourselves since it is fixed
	frame.size.height = kProgressBarHeight ;
	[super setFrame: frame] ;
}

- (void)setBounds:(CGRect)bounds
{
	// we set the height ourselves since it is fixed
	bounds.size.height = kProgressBarHeight ;
	[super setBounds: bounds] ;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext() ;
	
	// save the context
	CGContextSaveGState(context) ;
	
	// allow antialiasing
	CGContextSetAllowsAntialiasing(context, TRUE) ;
	
	// we first draw the outter rounded rectangle
	rect = CGRectInset(rect, 1.0f, 1.0f) ;
	CGFloat radius = 0.5f * rect.size.height ;
    
	CGContextSetStrokeColorWithColor(context, self.outerColor.CGColor);
	CGContextSetLineWidth(context, 2.0f) ;
	
	CGContextBeginPath(context) ;
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect)) ;
	CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius) ;
	CGContextClosePath(context) ;
	CGContextDrawPath(context, kCGPathStroke) ;
    
	
    // draw the empty rounded rectangle (shown for the "unfilled" portions of the progress
    rect = CGRectInset(rect, 3.0f, 3.0f) ;
	radius = 0.5f * rect.size.height ;
	
	
	CGContextSetFillColorWithColor(context, emptyColor.CGColor);
	
	CGContextBeginPath(context) ;
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect)) ;
	CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius) ;
	CGContextClosePath(context) ;
	CGContextFillPath(context) ;
    
	 
	// draw the inside moving filled rounded rectangle
	radius = 0.5f * rect.size.height ;
	
	// make sure the filled rounded rectangle is not smaller than 2 times the radius
	rect.size.width *= progress ;
	if (rect.size.width < 2 * radius)
		rect.size.width = 2 * radius ;
	//NSLog(@"rect: %@", NSStringFromCGRect(rect));
	
	CGContextSetStrokeColorWithColor(context, self.innerColor.CGColor);
	CGContextSetFillColorWithColor(context, self.innerColor.CGColor);
	
	CGContextBeginPath(context) ;
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect)) ;
	CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius) ;
	CGContextClosePath(context) ;
	CGContextFillPath(context) ;
		 
	
	// restore the context
	CGContextRestoreGState(context) ;
}

@end
