//
//  Ticket.h
//  Move
//
//  Created by Edward Chiang on 2014/6/18.
//  Copyright (c) 2014年 LovingHeart, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface Ticket : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Location *relationship;

@end
