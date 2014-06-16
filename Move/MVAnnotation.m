//
//  MVAnnotation.m
//  Move
//
//  Created by Edward Chiang on 2014/6/16.
//  Copyright (c) 2014年 LovingHeart, Inc. All rights reserved.
//

#import "MVAnnotation.h"

@implementation MVAnnotation

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description {
  self = [super init];
  if (self != nil) {
    _coordinate = location;
    _title = placeName;
    _subtitle = description;
  }
  return self;
}

@end
