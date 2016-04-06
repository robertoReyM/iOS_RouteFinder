//
//  Result.h
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trajectory.h"
#import "Instruction.h"
#import "InstructionType.h"
@protocol Result
@end

@interface Result : NSObject


@property (nonatomic, assign) NSString * routes;
@property (nonatomic, strong) NSMutableArray<Trajectory> *trajectories;

- (NSMutableArray<Instruction> *)generateInstructions;
- (float)getDistance;
- (float)getPrice;

@end
