//
//  MVCheckPoint.h
//  Move
//
//  Created by Edward Chiang on 2014/6/18.
//  Copyright (c) 2014年 LovingHeart, Inc. All rights reserved.
//

#import <Parse/Parse.h>

@interface MVCheckPoint : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, strong) PFGeoPoint *geoPoint;
@property (nonatomic, strong) NSString *name;

@end
