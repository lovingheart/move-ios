//
//  Location.h
//  Move
//
//  Created by Edward Chiang on 2014/6/13.
//  Copyright (c) 2014年 LovingHeart, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * timestamp;

@end
