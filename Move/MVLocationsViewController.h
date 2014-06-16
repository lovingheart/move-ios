//
//  MVLocationsViewController.h
//  Move
//
//  Created by Edward Chiang on 2014/6/13.
//  Copyright (c) 2014年 LovingHeart, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVLocationsViewController : UITableViewController <
  CLLocationManagerDelegate
>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSMutableArray *locations;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong) NSArray *locationsStoredList;

@end
