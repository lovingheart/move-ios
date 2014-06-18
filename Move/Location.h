//
//  Location.h
//  Move
//
//  Created by Edward Chiang on 2014/6/18.
//  Copyright (c) 2014年 LovingHeart, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Ticket;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Ticket *relationship;

@end
