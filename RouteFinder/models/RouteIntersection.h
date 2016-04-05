//
//  RouteIntersection.h
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PointIntersection.h"

@interface RouteIntersection : NSObject

@property (nonatomic, strong) NSString *routeID;
@property (nonatomic, strong) NSMutableArray<PointIntersection> *pointIntersections;
@end
