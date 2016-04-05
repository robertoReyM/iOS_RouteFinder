//
//  RouteFinder.m
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

#import "RouteFinder.h"

@interface RouteFinder ()

@property (nonatomic,strong) NSMutableDictionary * routes;
@property (nonatomic,strong) CLLocation * source;
@property (nonatomic,strong) CLLocation * destination;

@property (nonatomic,strong) SearchPoint * sourcePoint;
@property (nonatomic,strong) SearchPoint * destinationPoint;

@end

@implementation RouteFinder

/*****************************************************************************************************
                                            PUBLIC METHODS
 *****************************************************************************************************/

/******************************************************************************************************/
- (void)setAvailableRoutes:(NSMutableArray *)routesArray{
    
    self.routes = [self preProcessingRoutes:routesArray];
}

/******************************************************************************************************/
- (NSArray<Result> *)searchRoutes{
    
    //get available routes for source and destination points
    [self searchSourcePoint:self.source forDestinationPoint:self.destination];
    
    //check for common routes
    NSMutableDictionary *results = [self checkFistLevelForSource:self.sourcePoint forDestination:self.destinationPoint];
    
    if(results.count == 0){
        
        //check for intersections between source an destination routes
        results = [self checkSecondLevelForSource:self.sourcePoint forDestination:self.destinationPoint];
    }
    
    if(results.count == 0){
        
        //check for intersections for 3 routes result
        results = [self checkThirdLevelForSource:self.sourcePoint forDestination:self.destinationPoint];
    }
    if(results.count>0){
        
        NSArray *sortedResults = [[results allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            
            Result *r1 = (Result*)obj1;
            Result *r2 = (Result*)obj2;
            if ([r1 getDistance] > [r2 getDistance]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([r2 getDistance] < [r2 getDistance]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        return sortedResults;
    }
    
    return nil;
}

-(void)paintResult:(Result *)result onMap:(GMSMapView *)mapView{
    
    if(result!=nil && result.trajectories!=nil) {
        for (Trajectory *trajectory  in result.trajectories) {
            
            GMSMutablePath *path = [GMSMutablePath path];
            for(CLLocation *location in trajectory.points){
                
                [path addCoordinate:location.coordinate];
            }
            
            GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
            rectangle.map = mapView;
        }
        
        
    }
}
/*****************************************************************************************************
 PRIVATE METHODS
 *****************************************************************************************************/
-(NSMutableDictionary *)preProcessingRoutes:(NSMutableArray *)routesArray{
    
    NSMutableDictionary *routes = [[NSMutableDictionary alloc] init];
    
    //iterate through polylines
    for (int i1 = 0; i1<routesArray.count; i1++) {
        Route * route = [Route alloc];
        route.id = [NSString stringWithFormat:@"%d",i1];
        route.name = ((Route *)[routesArray objectAtIndex:i1]).name;
        route.polyline = ((Route *)[routesArray objectAtIndex:i1]).polyline;
        route.intersectedRoutes = [[NSMutableDictionary alloc] init];
        [routes setObject:route forKey:route.id];
        
        //get list of points
        route.points = [RouteFinder decodePolyline:route.polyline];
        
        //get stops from route
        NSMutableArray<Stop> *stops1 = [[NSMutableArray<Stop> alloc] init];
        int c1 = 0;
        for (CLLocation *point in route.points) {
            Stop *stop = [Stop alloc];
            stop.position = point;
            stop.name = [NSString stringWithFormat:@"Stop %d",c1];
            [stops1 addObject:stop];
            c1++;
        }
        route.stops = stops1;
        
        //iterate through points inside route
        for(int i2 = 0; i2<route.stops.count;i2++){
            
            //get current point
            Stop *stop1 = [route.stops objectAtIndex:i2];
            CLLocation * point1 = stop1.position;
            
            //go through all other polylines and get possible intersections
            for (int i3 = 0; i3<routesArray.count; i3++) {
                
                //Create new route intersection
                RouteIntersection * routeIntersection = [RouteIntersection alloc];
                routeIntersection.routeID = [NSString stringWithFormat:@"%d",i3];
                routeIntersection.pointIntersections = [[NSMutableArray<PointIntersection> alloc] init];
                
                //as long is not the same route
                if(i3!=i1){
                    
                    //get list of points of route to compare with
                    NSMutableArray *points2 = [RouteFinder decodePolyline:((Route *)[routesArray objectAtIndex:i3]).polyline];
                    
                    //get stops from route
                    NSMutableArray<Stop> *stops2 = [[NSMutableArray<Stop> alloc] init];
                    int c2 = 0;
                    for(CLLocation *point in points2){
                        Stop * stop = [Stop alloc];
                        stop.position = point;
                        stop.name = [NSString stringWithFormat:@"Stop %d",c2];
                        [stops2 addObject:stop];
                        c2++;
                    }
                    
                    //iterate through points on route to compare
                    for (int i4 = 0; i4<stops2.count; i4++) {
                        
                        //get current point
                        Stop *stop2 = [stops2 objectAtIndex:i4];
                        CLLocation *point2 = stop2.position;
                        
                        //get distance to source
                        CLLocationDistance distance = [point1 distanceFromLocation:point2];
                        
                        //check if is close enough
                        if(distance<DEFAULT_INTERSECTION_TOLERANCE){
                            
                            PointIntersection *pointIntersection = [PointIntersection alloc];
                            
                            //Assign r1 information
                            pointIntersection.r1Stop = stop1;
                            pointIntersection.r1ID = [NSString stringWithFormat:@"%d",i1];
                            
                            //Assign r2 information
                            pointIntersection.r2Stop = stop2;
                            pointIntersection.r2ID = [NSString stringWithFormat:@"%d",i3];
                            
                            NSLog(@"%@,%@ r2 stop: %f,%f",pointIntersection.r1ID,pointIntersection.r2ID,pointIntersection.r2Stop.position.coordinate.latitude,pointIntersection.r2Stop.position.coordinate.longitude);
                            //add to route intersection
                            [routeIntersection.pointIntersections addObject:pointIntersection];
                        }
                        
                    }
                    
                    //check for a valid route intersection object
                    if(routeIntersection.pointIntersections.count>0){
                        
                        if([route.intersectedRoutes objectForKey:routeIntersection.routeID]!=nil){
                            
                            //add point intersections to current route intersection
                            [((RouteIntersection *)[route.intersectedRoutes objectForKey:routeIntersection.routeID]).pointIntersections addObjectsFromArray:routeIntersection.pointIntersections];
                        }else{
                            
                            //Add route intersection to route
                            [route.intersectedRoutes setObject:routeIntersection forKey:routeIntersection.routeID];
                        }
                    }
                    
                }
            }
        }
    }

    return routes;
}

/******************************************************************************************************/
- (void)searchSourcePoint:(CLLocation *)source forDestinationPoint:(CLLocation*)destination{
    
    self.sourcePoint = [[SearchPoint alloc] init];
    [self.sourcePoint setPosition:source];
    [self.sourcePoint setClosestStops:[[NSMutableDictionary alloc] init]];
    [self.sourcePoint setAvailableRoutes:[[NSMutableDictionary alloc] init]];
    
    self.destinationPoint = [[SearchPoint alloc] init];
    [self.destinationPoint setPosition:source];
    [self.destinationPoint setClosestStops:[[NSMutableDictionary alloc] init]];
    [self.destinationPoint setAvailableRoutes:[[NSMutableDictionary alloc] init]];
    
    for(int i = 0; i<self.routes.count;i++){
        
        BOOL isSourceCloseEnough = false;
        BOOL isDestinationCloseEnough = false;
        float closestSourceDistance = 0;
        float closestDestinationDistance = 0;
        Stop *closestSourceStop = nil;
        Stop *closestDestinationStop = nil;
        
        Route *currentRoute = [self.routes objectForKey:[NSString stringWithFormat:@"%d",i]];
        
        //iterate through points
        for(int i2 = 0; i2< currentRoute.stops.count;i2++){
            
            //get current point
            Stop *stop = [currentRoute.stops objectAtIndex:i2];
            CLLocation *point = stop.position;
            
            //get distance to source
            CLLocationDistance distanceToSource = [source distanceFromLocation:point];
            
            if(distanceToSource<DEFAULT_STOP_TOLERANCE){
                isSourceCloseEnough = true;
                
                //check if existing closest point
                if(closestSourceStop!=nil){
                    
                    //check if is closer than previous
                    if(distanceToSource<closestSourceDistance){
                        
                        //assign new closest stop
                        closestSourceStop = stop;
                        closestSourceDistance = distanceToSource;
                        
                    }
                }else{
                    
                    //assign new closest point
                    closestSourceStop = stop;
                    closestSourceDistance = distanceToSource;
                }
            }
            
            //get distance to destination
            CLLocationDistance distanceToDestination = [destination distanceFromLocation:point];
            
            if(distanceToDestination<DEFAULT_STOP_TOLERANCE){
                isDestinationCloseEnough = true;
                
                //check if existing closest point
                if(closestDestinationStop!=nil){
                    
                    //check if is closer than previous
                    if(distanceToDestination<closestDestinationDistance){
                        
                        //assign new closest stop
                        closestDestinationStop = stop;
                        closestDestinationDistance = distanceToDestination;
                        
                    }
                }else{
                    
                    //assign new closest point
                    closestDestinationStop = stop;
                    closestDestinationDistance = distanceToDestination;
                }
            }
        }
        
        if(isSourceCloseEnough){
            [self.sourcePoint.closestStops setObject:closestSourceStop forKey:currentRoute.id];
            [self.sourcePoint.availableRoutes setObject:currentRoute forKey:currentRoute.id];
        }
        
        if(isDestinationCloseEnough){
            [self.destinationPoint.closestStops setObject:closestDestinationStop forKey:currentRoute.id];
            [self.destinationPoint.availableRoutes setObject:currentRoute forKey:currentRoute.id];
        }
    }
    
}

/******************************************************************************************************/
-(Trajectory *)getTrajectory:(Route *)route forStop1:(Stop *)s1 forStop2:(Stop *)s2{
    
    
    //get list of points
    NSMutableArray *points = [RouteFinder decodePolyline:route.polyline];
    NSMutableArray *trajectoryPoints = [[NSMutableArray alloc] init];
    BOOL isP1Found = false;
    BOOL isP2Found = false;
    
    float totalDistance = 0;
    CLLocation *previousPoint = nil;
    
    for(CLLocation *point in points){
        
        NSLog(@"point : %f,%f",point.coordinate.latitude,point.coordinate.longitude);
        NSLog(@"s1 : %f,%f ",s1.position.coordinate.latitude,s1.position.coordinate.longitude);
        
         if(point.coordinate.latitude == s1.position.coordinate.latitude &&
            point.coordinate.longitude == s1.position.coordinate.longitude){
             
             isP1Found = true;
         }
        
        if (point.coordinate.latitude == s2.position.coordinate.latitude &&
            point.coordinate.longitude == s2.position.coordinate.longitude) {
            
            isP2Found = true;
        }
        
        //check if p1 was found first to check direction
        if(isP1Found){
            
            if(isP2Found){
                
                //check for destination point
                if (point.coordinate.latitude == s2.position.coordinate.latitude &&
                    point.coordinate.longitude == s2.position.coordinate.longitude) {
                    
                    if (previousPoint==nil) {
                        previousPoint = point;
                    }else{
                        
                        CLLocationDistance distance = [previousPoint distanceFromLocation:point];
                        previousPoint = point;
                        totalDistance+=distance;
                        
                    }
                    //get distance to source
                    CLLocationDistance distance = [s1.position distanceFromLocation:point];
                    
                    //check if is close enough
                    if(distance<DEFAULT_INTERSECTION_TOLERANCE){
                        totalDistance = 0;
                        previousPoint = nil;
                        [trajectoryPoints removeAllObjects];
                    }
                    [trajectoryPoints addObject:point];
                }
                
            }else{
             
                if (previousPoint==nil) {
                    previousPoint = point;
                }else{
                    
                    CLLocationDistance distance = [previousPoint distanceFromLocation:point];
                    previousPoint = point;
                    totalDistance +=distance;
                }
                
                //get distance to source
                CLLocationDistance distance = [s1.position distanceFromLocation:point];
                
                if(distance<DEFAULT_INTERSECTION_TOLERANCE){
                    totalDistance = 0;
                    previousPoint = nil;
                    [trajectoryPoints removeAllObjects];
                }
                [trajectoryPoints addObject:point];
            }
        }else if (isP2Found){
            return nil;
        }
    }
    
    Trajectory *trajectory = [Trajectory alloc];
    trajectory.name = route.name;
    trajectory.points = trajectoryPoints;
    trajectory.distance = totalDistance;
    trajectory.source = s1;
    trajectory.destination = s2;
    
    return trajectory;
}

/******************************************************************************************************/
-(NSMutableDictionary *)checkFistLevelForSource:(SearchPoint *)sourcePoint forDestination:(SearchPoint *)destinationPoint{
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    //go through source routes
    for(id key in sourcePoint.availableRoutes){
        
        //check for a common route
        if([destinationPoint.availableRoutes objectForKey:key]!=nil){
            
            //get common route
            Route *route = [sourcePoint.availableRoutes objectForKey:key];
            
            Trajectory *trajectory = [self getTrajectory:route
                                                forStop1:[sourcePoint.closestStops objectForKey:route.id]
                                                forStop2:[destinationPoint.closestStops objectForKey:route.id]];
            
            if(trajectory!=nil){
                
                //create result
                Result * result = [Result alloc];
                result.routes = route.name;
                result.trajectories = [[NSMutableArray<Trajectory> alloc] init];
                [result.trajectories addObject:trajectory];
                
                //check for the same result
                if ([results objectForKey:result.routes]!=nil) {
                    
                    //compare distances
                    if([(Result *)[results objectForKey:result.routes] getDistance]>[result getDistance]){
                        
                        //replace result
                        [results setObject:result forKey:result.routes];
                    }
                }else{
                    
                    //add result
                    [results setObject:result forKey:result.routes];
                }
            }
        }
    }
    
    return results;
}


/******************************************************************************************************/
-(NSMutableDictionary *)checkSecondLevelForSource:(SearchPoint *)sourcePoint forDestination:(SearchPoint *)destinationPoint{
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    //go through source routes
    for(id key1 in sourcePoint.availableRoutes){
        
        Route *sourceRoute = [sourcePoint.availableRoutes objectForKey:key1];
    
        for(id key2 in destinationPoint.availableRoutes){
            
            Route *destinationRoute = [destinationPoint.availableRoutes objectForKey:key2];
            
            //check if source intersects with current destination route
            if([sourceRoute.intersectedRoutes objectForKey:key2]!=nil){
                
                NSMutableArray * pointIntersections = ((RouteIntersection *)[sourceRoute.intersectedRoutes objectForKey:key2]).pointIntersections;
                
                for (PointIntersection *pointIntersection in pointIntersections) {
                    
                    Trajectory *trajectory1 = [self getTrajectory:sourceRoute
                                                         forStop1:[sourcePoint.closestStops objectForKey:sourceRoute.id]
                                                         forStop2:pointIntersection.r1Stop];
                    
                    Trajectory *trajectory2 = [self getTrajectory:destinationRoute
                                                         forStop1:pointIntersection.r2Stop
                                                         forStop2:[destinationPoint.closestStops objectForKey:destinationRoute.id]];
                    
                    if(trajectory1!=nil && trajectory2!=nil){
                        //add trajectories to result
                        Result *result = [Result alloc];
                        result.routes = [NSString stringWithFormat:@"%@,%@",sourceRoute.name,destinationRoute.name];
                        result.trajectories = [[NSMutableArray<Trajectory> alloc] init];
                        [result.trajectories addObject:trajectory1];
                        [result.trajectories addObject:trajectory2];
                        
                        //check for the same result
                        if([results objectForKey:result.routes]!=nil){
                            
                            //compare distances
                            if([((Result *)[results objectForKey:result.routes]) getDistance]> [result getDistance]){
                                
                                //replace result
                                [results setObject:result forKey:result.routes];
                            }
                        }else{
                            
                            //add result
                            [results setObject:result forKey:result.routes];
                        }
                    }
                }
            }
        }
    }
    
    return results;
}

/******************************************************************************************************/
-(NSMutableDictionary *)checkThirdLevelForSource:(SearchPoint *)sourcePoint forDestination:(SearchPoint *)destinationPoint{

    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    //go through source routes
    for(id key1 in sourcePoint.availableRoutes){
        
        Route *sourceRoute = [sourcePoint.availableRoutes objectForKey:key1];
        
        //go through source intersected routes
        for(id key2 in sourceRoute.intersectedRoutes){
            
            Route *currentIntersectedRoute = [self.routes objectForKey:key2];
            RouteIntersection *routeIntersection1 = [sourceRoute.intersectedRoutes objectForKey:key2];
            
            //go through destination routes
            for(id key3 in destinationPoint.availableRoutes){
                
                Route *destinationRoute = [destinationPoint.availableRoutes objectForKey:key3];
                
                // find an intersection with current intersected route
                if([currentIntersectedRoute.intersectedRoutes objectForKey:key3]!=nil){
                    
                    //go though pointer intersections for first stop
                    for(PointIntersection *pointIntersection1 in routeIntersection1.pointIntersections){
                        
                        RouteIntersection *routeIntersection2 = [currentIntersectedRoute.intersectedRoutes objectForKey:key3];
                        
                        for(PointIntersection *pointIntersection2 in routeIntersection2.pointIntersections){
                            
                            //get trajectory from source to first intersection
                            Trajectory *trajectory1 = [self getTrajectory:sourceRoute
                                                                 forStop1:[sourcePoint.closestStops objectForKey:sourceRoute.id]
                                                                 forStop2:pointIntersection1.r1Stop];
                            
                            
                            //get trajectory from intersection one to intersection 2
                            Trajectory *trajectory2 = [self getTrajectory:currentIntersectedRoute
                                                                 forStop1:pointIntersection1.r2Stop
                                                                 forStop2:pointIntersection2.r1Stop];
                            
                            //get trajectory from intersection 2 to destination
                            Trajectory *trajectory3 = [self getTrajectory:destinationRoute
                                                                 forStop1:pointIntersection2.r2Stop
                                                                 forStop2:[destinationPoint.closestStops objectForKey:destinationRoute.id]];
                            
                            if(trajectory1!=nil && trajectory2!=nil && trajectory3!=nil){
                                
                                //add trajectories to result
                                Result * result = [Result alloc];
                                result.routes = [NSString stringWithFormat:@"%@,%@,%@",sourceRoute.name,currentIntersectedRoute.name,destinationRoute.name];
                                result.trajectories = [[NSMutableArray<Trajectory> alloc] init];
                                [result.trajectories addObject:trajectory1];
                                [result.trajectories addObject:trajectory2];
                                [result.trajectories addObject:trajectory3];
                                
                                //check for the same result
                                if([results objectForKey:result.routes]!=nil){
                                    
                                    //compare distances
                                    if([((Result *)[results objectForKey:result.routes]) getDistance]> [result getDistance]){
                                        
                                        //replace result
                                        [results setObject:result forKey:result.routes];
                                    }
                                }else{
                                    
                                    //add result
                                    [results setObject:result forKey:result.routes];
                                }

                            }
                        }
                        
                    }
                }
            }
        }
        
    }
    return results;
    
}

/*****************************************************************************************************
                                            STATIC METHODS
 *****************************************************************************************************/
+ (NSMutableArray *)decodePolyline:(NSString *)encodedString {
    
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    
    NSMutableArray *points = [[NSMutableArray alloc] init];
    
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        [points addObject:[[CLLocation alloc] initWithLatitude:finalLat longitude:finalLon]];
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    
    free(coords);
    
    return points;
}
@end