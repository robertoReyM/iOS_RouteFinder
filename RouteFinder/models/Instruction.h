//
//  Instruction.h
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstructionType.h"

@protocol Instruction
@end

@interface Instruction : NSObject

@property (nonatomic, assign) InstructionType type;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *details;
@end
