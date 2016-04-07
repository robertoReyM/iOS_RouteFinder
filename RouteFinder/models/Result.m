//
//  Result.m
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//


#import "Result.h"

#define  nBUS               @"1"
#define  nCOLECTOR          @"2"
#define  nTUZOBUS           @"3"

@implementation Result


- (NSMutableArray<Instruction> *)generateInstructions{
    
    NSMutableArray<Instruction> * instructions = [[NSMutableArray<Instruction> alloc] init];
    
    Instruction *origin = [Instruction alloc];
    [origin setType:SOURCE];
    [origin setAction:@"Origen"];
    [instructions addObject:origin];
    
    Instruction *start = [Instruction alloc];
    [start setType:WALK];
    [start setAction:@"Camina"];
    [start setDetails:((Trajectory *)[self.trajectories objectAtIndex:0]).source.name];
    [instructions addObject:start];
    
    for (Trajectory *trajectory in self.trajectories) {
        
        Instruction * instruction1 = [Instruction alloc];
        if ([trajectory.type isEqualToString:nBUS]) {
            [instruction1 setType:BUS_ON];
        }else if ([trajectory.type isEqualToString:nCOLECTOR]) {
            [instruction1 setType:COLECTOR_ON];
        }else if ([trajectory.type isEqualToString:nTUZOBUS]) {
            [instruction1 setType:TUZOBUS_ON];
        }
        [instruction1 setAction:[NSString stringWithFormat:@"Sube a %@",trajectory.name]];
        [instruction1 setDetails:trajectory.source.name];
        [instructions addObject:instruction1];
        
        
        Instruction * instruction2 = [Instruction alloc];
        if ([trajectory.type isEqualToString:nBUS]) {
            [instruction2 setType:BUS_OFF];
        }else if ([trajectory.type isEqualToString:nCOLECTOR]) {
            [instruction2 setType:COLECTOR_OFF];
        }else if ([trajectory.type isEqualToString:nTUZOBUS]) {
            [instruction2 setType:TUZOBUS_OFF];
        }
        [instruction2 setAction:[NSString stringWithFormat:@"Baja de %@",trajectory.name]];
        [instruction2 setDetails:trajectory.destination.name];
        [instructions addObject:instruction2];
        
        Instruction *finish = [Instruction alloc];
        [finish setAction:@"Camina hacia tu destino"];
        [finish setType:WALK];
        [instructions addObject:finish];
        
        Instruction *destination = [Instruction alloc];
        [destination setType:DESTINATION];
        [destination setAction:@"Destino"];
        [instructions addObject:destination];
    }
    
    return instructions;
}
- (float)getDistance{
    
    float totalDistance = 0;
    
    for(Trajectory *trajectory in self.trajectories){
        totalDistance+= trajectory.distance;
    }
    return totalDistance;
}

- (float)getPrice{
    
    float totalPrice = 0;
    
    NSArray *routesArray = [self.routes componentsSeparatedByString:@","];
    
    int tuzoBusCtr = 0;
    
    for(Trajectory *trajectory in self.trajectories){
        

        //check for tuzobus or colector
        if([trajectory.type isEqualToString: nCOLECTOR] ||
           [trajectory.type isEqualToString: nTUZOBUS]){
            if (tuzoBusCtr==0) {
                //add max rate
                totalPrice+= trajectory.max_rate;
            }else if(tuzoBusCtr==1){
                //add min rate
                totalPrice+= trajectory.min_rate;
            }else{
                //more than 2 no charge
            }
            tuzoBusCtr++;
        }else{
            //sum up min rate
            totalPrice+= trajectory.min_rate;
        }
    }
    return totalPrice;
}

@end
