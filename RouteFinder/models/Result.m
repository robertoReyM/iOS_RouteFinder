//
//  Result.m
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

#import "Result.h"

@implementation Result


- (NSMutableArray<Instruction> *)generateInstructions{
    
    NSMutableArray<Instruction> * instructions = [[NSMutableArray<Instruction> alloc] init];
    
    
    return instructions;
}
- (float)getDistance{
    
    float totalDistance = 0;
    
    for(Trajectory *trajectory in self.trajectories){
        totalDistance+= trajectory.distance;
    }
    return totalDistance;
}

@end
