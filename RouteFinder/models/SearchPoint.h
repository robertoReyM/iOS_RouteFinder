//
//  SearchPoint.h
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchPoint : NSObject


@property (nonatomic, strong) CLLocation *position;
@property (nonatomic, strong) NSMutableDictionary *availableRoutes;
@property (nonatomic, strong) NSMutableDictionary *closestStops;

@end
