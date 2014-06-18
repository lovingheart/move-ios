//
//  MVLocationsViewController.m
//  Move
//
//  Created by Edward Chiang on 2014/6/13.
//  Copyright (c) 2014年 LovingHeart, Inc. All rights reserved.
//

#import "MVLocationsViewController.h"
#import "Location.h"
#import "MVAppDelegate.h"
#import <NSDate+TimeAgo/NSDate+TimeAgo.h>
#import "MVAnnotation.h"
#import <UIAlertView+BlocksKit.h>
#import <Parse/Parse.h>
#import "MVCheckPoint.h"

@interface MVLocationsViewController ()

@end

@implementation MVLocationsViewController

- (void)awakeFromNib {
  _refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self action:@selector(reloadLocations) forControlEvents:UIControlEventValueChanged];
  
  _checkPoints = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
  
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  _locationsStoredList = [[NSMutableArray alloc] init];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.tableView addSubview:self.refreshControl];
  
  self.mapView.hidden = YES;
  self.mapView.delegate = self;
  
  self.editButton.target = self;
  self.editButton.action = @selector(editTableView:);
  
  self.clearButton.target = self;
  self.clearButton.action = @selector(clearLocations:);
  
  _locations = [[NSMutableArray alloc] init];
  
  if (!_locationManager) {
    _locationManager = [[CLLocationManager alloc] init];
  }
  
  [self.dataSwithSegmentedControl addTarget:self action:@selector(dataSwitch:) forControlEvents:UIControlEventValueChanged];
  
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
  self.locationManager.distanceFilter = 50;
  self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
  self.locationManager.pausesLocationUpdatesAutomatically = YES;
  [self.locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:1000];
  
  if ([CLLocationManager locationServicesEnabled]) {
    [self.locationManager startUpdatingLocation];
  }
  
  [self reloadLocations];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  return self.locationsStoredList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationTimeCell" forIndexPath:indexPath];
  
  // Configure the cell...
  Location *currentLocation = [self.locationsStoredList objectAtIndex:indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"%+.5f, %+.5f", currentLocation.latitude.floatValue, currentLocation.longitude.floatValue];
  cell.detailTextLabel.text = [currentLocation.timestamp dateTimeUntilNow];
  
  return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Return NO if you do not want the specified item to be editable.
  return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // Delete the row from the data source
    
    __block MVLocationsViewController *__self = self;
    
    UIAlertView *confirmDeleteView = [[UIAlertView alloc] bk_initWithTitle:@"Delete" message:@"Want to delet the location?"];
    [confirmDeleteView bk_addButtonWithTitle:@"Yes" handler:^{
      
      Location *removeLocation =  [__self.locationsStoredList objectAtIndex:indexPath.row];
      MVAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
      NSManagedObjectContext *context = [appDelegate managedObjectContext];
      [context deleteObject:removeLocation];
      NSError *error;
      if (![context save:&error]) {
        NSLog(@"Whoops, couldn't delete: %@", [error localizedDescription]);
      }
      
      [__self.locationsStoredList removeObject:removeLocation];
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      
    }];
    [confirmDeleteView bk_setCancelBlock:^{
    }];
    [confirmDeleteView show];
    

  } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
  if (oldLocation) {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
    if (distance > 100) {
      CLLocation* location = oldLocation;
      NSDate* eventDate = location.timestamp;
      NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
      if (abs(howRecent) < 100.0) {
        // If the event is recent, do something with it.
        NSLog(@"Time %@, latitude %+.2f, longitude %+.2f. Saved.",
              [location.timestamp description],
              location.coordinate.latitude,
              location.coordinate.longitude);
        
        [self.locations addObject:location];
      }
    }
    
  }
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
  
  MVAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [appDelegate managedObjectContext];
  
  for (CLLocation *location in locations) {
    NSLog(@"Location: %@", location);
    

        Location *locationInfo = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"Location"
                                  inManagedObjectContext:context];
        locationInfo.longitude = [NSNumber numberWithFloat:location.coordinate.longitude];
        locationInfo.latitude = [NSNumber numberWithFloat:location.coordinate.latitude];
        locationInfo.timestamp = location.timestamp;
        
        NSError *error;
        if (![context save:&error]) {
          NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        } else {
          
          // Check the distance
          for (MVAnnotation *checkPoint in self.checkPoints) {
            CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:
                                           location.coordinate.longitude];
            CLLocation *checkPointLocation = [[CLLocation alloc] initWithLatitude:checkPoint.coordinate.latitude longitude:checkPoint.coordinate.longitude];
            
            CLLocationDistance distanceResult = [currentLocation distanceFromLocation:checkPointLocation];
            
            if (distanceResult < 100) {
              NSLog(@"You made it!");
              
              UIAlertView *confirmDeleteView = [[UIAlertView alloc] bk_initWithTitle:@"Pass" message:
                                                [NSString stringWithFormat:@"You've pass the check point. <%f, %f>", checkPointLocation.coordinate.latitude,
                                                 checkPointLocation.coordinate.longitude]];
              [confirmDeleteView bk_addButtonWithTitle:@"OK" handler:^{
                
              }];
              [confirmDeleteView show];
            }
          }
          
          [self fetchDistance];
          
          if (self.dataSwithSegmentedControl.selectedSegmentIndex == 0) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
          } else if (self.dataSwithSegmentedControl.selectedSegmentIndex == 1) {
            [self loadMapItems];
          }
        }
  }
}

#pragma mark - private

- (void)loadCheckPoints
{
  PFQuery *checkPointsQuery = [MVCheckPoint query];
  [checkPointsQuery whereKey:@"available" equalTo:[NSNumber numberWithBool:YES]];
  __block MVLocationsViewController *__self = self;
  [checkPointsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (objects) {
      
      for (MVCheckPoint *checkPoint in objects) {
        MVAnnotation *checkPointAnnotation = [[MVAnnotation alloc] initWithCoordinates:CLLocationCoordinate2DMake(checkPoint.geoPoint.latitude, checkPoint.geoPoint.longitude) placeName:checkPoint.name description:@""];
        checkPointAnnotation.isCheckPoint = YES;
        [__self.checkPoints addObject:checkPointAnnotation];
      }
      
      [__self loadMapItems];
    }
  }];
}


- (void)editTableView:(id)sender {
  UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
  if (!self.tableView.isEditing) {
    barButtonItem.title = @"Done";
    [self.tableView setEditing:YES animated:YES];
  } else {
    barButtonItem.title = @"Edit";
    [self.tableView setEditing:NO animated:YES];
  }
}

- (void)loadMapItems {
  
  // Clear annotations
  [self.mapView removeAnnotations:self.mapView.annotations];
   [self.mapView addAnnotations:self.checkPoints];
  
  if (self.locationsStoredList.count > 0) {
    
    NSMutableArray *annotationArray = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D coordinates[self.locationsStoredList.count];
    for (int index = 0; index < self.locationsStoredList.count; index ++) {
      Location *location = [self.locationsStoredList objectAtIndex:index];
      coordinates[index] = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
      
      MVAnnotation *annotion = [[MVAnnotation alloc] initWithCoordinates:coordinates[index] placeName:[NSString stringWithFormat:@"Flag %i", index] description:[location.timestamp dateTimeAgo]];
      [annotationArray addObject:annotion];
    }
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:self.locationsStoredList.count];
    [self.mapView addOverlay:polyLine];
    
    // Load User
    [self.mapView addAnnotations:annotationArray];
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
    
    MVAnnotation *selectedAnnotation = [annotationArray objectAtIndex:0];
    [self.mapView selectAnnotation:selectedAnnotation animated:YES];
  }
}

- (void)dataSwitch:(id)sender {
  UISegmentedControl *dataSwitch = (UISegmentedControl *)sender;
  if (dataSwitch.selectedSegmentIndex == 0) {
    self.tableView.hidden = NO;
    self.mapView.hidden = YES;
    [self fetchDistance];
  } else if (dataSwitch.selectedSegmentIndex == 1) {
    self.tableView.hidden = YES;
    self.mapView.hidden = NO;
    [self loadMapItems];
  }
}

- (void)reloadLocations {
  [self fetchDistance];
  [self loadCheckPoints];
}

- (void)clearLocations:(id)sender {
  __block MVLocationsViewController *__self = self;
  UIAlertView *confirmDeleteView = [[UIAlertView alloc] bk_initWithTitle:@"Delete" message:@"Want to delet all locations?"];
  [confirmDeleteView bk_addButtonWithTitle:@"Yes" handler:^{
    
    MVAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptorByTimeStamp = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Location" inManagedObjectContext:context];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorByTimeStamp, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *allLocations = [context executeFetchRequest:fetchRequest error:&error];
    
    for (Location *eachLocation in allLocations) {
      [context deleteObject:eachLocation];
    }
    if (![context save:&error]) {
      NSLog(@"Whoops, couldn't delete: %@", [error localizedDescription]);
    }
    [__self fetchDistance];
    
  }];
  [confirmDeleteView bk_setCancelBlock:^{
  }];
  [confirmDeleteView show];
}

- (void)fetchDistance
{
  
  if (!self.refreshControl.refreshing) {
    [self.refreshControl beginRefreshing];
  }
  
  MVAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSSortDescriptor *sortDescriptorByTimeStamp = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
  NSEntityDescription *entity = [NSEntityDescription
                                 entityForName:@"Location" inManagedObjectContext:managedObjectContext];
  NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorByTimeStamp, nil];
  [fetchRequest setFetchLimit:20];
  [fetchRequest setSortDescriptors:sortDescriptors];
  [fetchRequest setEntity:entity];
  NSError *error;
  [self.locationsStoredList removeAllObjects];
  [self.locationsStoredList addObjectsFromArray:[managedObjectContext executeFetchRequest:fetchRequest error:&error]];
  
  NSLog(@"Locations count: %li", self.locationsStoredList.count);
  
  if (self.refreshControl.refreshing) {
    [self.refreshControl endRefreshing];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
  }
}

#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
  MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
  polylineView.strokeColor = [UIColor redColor];
  polylineView.lineWidth = 10.0;
  
  return polylineView;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  
  static NSString *identifier = @"MyAnnotation";
  MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
  
  MVAnnotation *myAnnotation = (MVAnnotation*) annotation;
  
  // If a new annotation is created
  if (annotationView == nil) {
    annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation reuseIdentifier:identifier];
  } else {
    annotationView.annotation = annotation;
  }
  annotationView.canShowCallout = YES;
  
  // Annotation's color
  if (myAnnotation.isCheckPoint) {
    annotationView.pinColor = MKPinAnnotationColorGreen;
  }
  else {
    annotationView.pinColor = MKPinAnnotationColorRed;
  }
  
  return annotationView;
}

@end
