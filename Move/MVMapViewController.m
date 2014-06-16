//
//  MVMapViewController.m
//  Move
//
//  Created by Edward Chiang on 2014/6/16.
//  Copyright (c) 2014年 LovingHeart, Inc. All rights reserved.
//

#import "MVMapViewController.h"
#import "MVAnnotation.h"

@interface MVMapViewController ()

@end

@implementation MVMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.location.latitude.doubleValue, self.location.longitude.doubleValue);
  [self.mapView setCenterCoordinate:coordinate animated:YES];
  
  MKCoordinateRegion region;
  region.center = coordinate;
  [self.mapView setRegion:region animated:YES];
  
  self.mapView.delegate = self;
  
  __block MKMapView *__mapView = self.mapView;
  CLLocationCoordinate2D coordinates[self.allLocations.count];
  for (int index = 0; index < self.allLocations.count; index ++) {
    Location *location = [self.allLocations objectAtIndex:index];
    coordinates[index] = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);

    MVAnnotation *annotion = [[MVAnnotation alloc] initWithCoordinates:coordinates[index] placeName:[NSString stringWithFormat:@"Step %i", index] description:nil];
    [__mapView addAnnotation:annotion];
  }
  MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:self.allLocations.count];
  [self.mapView addOverlay:polyLine];
  
  [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
  MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
  polylineView.strokeColor = [UIColor redColor];
  polylineView.lineWidth = 10.0;
  
  return polylineView;
}

@end
