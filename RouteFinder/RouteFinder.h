//
//  RouteFinder.h
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

@import GoogleMaps;
@import CoreLocation;
#import <Foundation/Foundation.h>
#import "Route.h"
#import "RouteIntersection.h"
#import "SearchPoint.h"
#import "Trajectory.h"
#import "Result.h"


#define DEFAULT_STOP_TOLERANCE              500
#define DEFAULT_INTERSECTION_TOLERANCE      100

@interface RouteFinder : NSObject

-(void)setSource:(CLLocation *)source;

-(void)setDestination:(CLLocation *)destination;

- (void)setAvailableRoutes:(NSMutableArray *)routesArray;

- (NSMutableArray<Stop> *)getAvailableStops:(CLLocation *)location;

- (NSArray<Result> *)searchRoutes;

-(void)paintResult:(Result *)result onMap:(GMSMapView *)mapView;

+ (NSMutableArray *)decodePolyline:(NSString *)encodedString;
@end
