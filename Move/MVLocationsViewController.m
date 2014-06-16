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

@interface MVLocationsViewController ()

@end

@implementation MVLocationsViewController

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
  
  self.mapView.hidden = YES;
  self.mapView.delegate = self;
  
  _locations = [[NSMutableArray alloc] init];
  
  if (!_locationManager) {
    _locationManager = [[CLLocationManager alloc] init];
  }
  
  [self.dataSwithSegmentedControl addTarget:self action:@selector(dataSwitch:) forControlEvents:UIControlEventValueChanged];
  
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
  self.locationManager.distanceFilter = 100;
  self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
  self.locationManager.pausesLocationUpdatesAutomatically = YES;
  [self.locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:1000];
  
  if ([CLLocationManager locationServicesEnabled]) {
    [self.locationManager startMonitoringSignificantLocationChanges];
  }
  
  [self fetchDistance];
  
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
    
    Location *removeLocation =  [self.locationsStoredList objectAtIndex:indexPath.row];
    MVAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    [context deleteObject:removeLocation];
    NSError *error;
    if (![context save:&error]) {
      NSLog(@"Whoops, couldn't delete: %@", [error localizedDescription]);
    }
    
    [self.locationsStoredList removeObject:removeLocation];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    
    if (self.locationsStoredList.count > 0) {
      Location *lastLocation = [self.locationsStoredList lastObject];
      CLLocationCoordinate2D lastCoordinate = CLLocationCoordinate2DMake(lastLocation.latitude.doubleValue, lastLocation.longitude.doubleValue);
      
      CLLocationDistance distance = [location distanceFromLocation:[[CLLocation alloc] initWithLatitude:lastCoordinate.latitude longitude:lastCoordinate.longitude]];
      
      if (distance > 100) {
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
          NSLog(@"Save one object. Distance: %f", distance);
          [self fetchDistance];
          
          if (self.dataSwithSegmentedControl.selectedSegmentIndex == 0) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
          } else if (self.dataSwithSegmentedControl.selectedSegmentIndex == 1) {
            [self loadMapItems];
          }
          
        }
        
      } else {
        NSLog(@"It's too close. Distance: %f", distance);
      }
    }
    
    
    
  }
}

#pragma mark - private

- (void)loadMapItems {
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
  } else if (dataSwitch.selectedSegmentIndex == 1) {
    self.tableView.hidden = YES;
    self.mapView.hidden = NO;
    [self loadMapItems];
  }
}

- (void)fetchDistance
{
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
}

#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
  MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
  polylineView.strokeColor = [UIColor redColor];
  polylineView.lineWidth = 10.0;
  
  return polylineView;
}


@end
