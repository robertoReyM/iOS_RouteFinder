//
//  Trajectory.h
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Stop.h"

@protocol Trajectory
@end

@interface Trajectory : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) float distance;
@property (nonatomic, strong) Stop *source;
@property (nonatomic, strong) Stop *destination;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) float min_rate;
@property (nonatomic, assign) float max_rate;
@end
