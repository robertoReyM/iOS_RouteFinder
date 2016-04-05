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


@property (nonatomic, assign) NSString * id;
@property (nonatomic, assign) NSString * name;
@property (nonatomic, assign) NSString * polyline;
@property (nonatomic, strong) NSMutableArray<Stop> *stops;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableDictionary *intersectedRoutes;

@end
