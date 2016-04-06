//
//  Route.h
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stop.h"
@protocol Route
@end
@interface Route : NSObject


@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * polyline;
@property (nonatomic, strong) NSMutableArray<Stop> *stops;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableDictionary *intersectedRoutes;
@property (nonatomic, strong) NSString * route_type;
@property (nonatomic, assign) float min_rate;
@property (nonatomic, assign) float max_rate;

@end
