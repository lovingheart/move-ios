//
//  MVAnnotation.h
//  Move
//
//  Created by Edward Chiang on 2014/6/16.
//  Copyright (c) 2014年 LovingHeart, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MVAnnotation : NSObject <MKAnnotation> {
  CLLocationCoordinate2D coordinate;
  NSString *title;
  NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;

@property (nonatomic, assign) BOOL isCheckPoint;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description;


@end
