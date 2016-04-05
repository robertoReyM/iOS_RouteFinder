//
//  InstructionType.h
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

#ifndef InstructionType_h
#define InstructionType_h

typedef enum {
    SOURCE = 1,
    WALK = 2,
    BUS_ON = 3,
    BUS_OFF = 4,
    COLECTOR_ON = 5,
    COLECTOR_OFF = 6,
    TUZOBUS_ON = 7,
    TUZOBUS_OFF = 8,
    DESTINATION = 9
} InstructionType;

#endif /* InstructionType_h */
