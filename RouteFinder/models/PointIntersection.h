//
//  PointIntersection.h
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stop.h"
@protocol PointIntersection
@end

@interface PointIntersection : NSObject


@property (nonatomic, assign) NSString * r1ID;
@property (nonatomic, strong) Stop *r1Stop;
@property (nonatomic, assign) NSString * r2ID;
@property (nonatomic, strong) Stop *r2Stop;

@end
