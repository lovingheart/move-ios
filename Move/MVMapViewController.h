//
//  MVMapViewController.h
//  Move
//
//  Created by Edward Chiang on 2014/6/16.
//  Copyright (c) 2014年 LovingHeart, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Location.h"

@interface MVMapViewController : UIViewController <
  MKMapViewDelegate
>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) Location *location;

@property (nonatomic, strong) NSArray *allLocations;

@end
