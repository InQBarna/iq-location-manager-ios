//
//  IQMapVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 20/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQMapVC.h"

#import "IQTrack.h"
#import "CMMotionActivity+IQ.h"

#import <CoreMotion/CoreMotion.h>
#import <MapKit/MapKit.h>

@interface IQMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView  *mapView;

@end

@implementation IQMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)addTracks:(NSArray *)tracks
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    IQTrack *current;
    CLLocationCoordinate2D coordinates[tracks.count];
    for (int i = 0; i < tracks.count; i++) {
        current = tracks[i];
        coordinates[i] = current.location.coordinate;
    }
    
    MKPolyline *route = [MKPolyline polylineWithCoordinates:coordinates count:tracks.count];
    [self.mapView setVisibleMapRect:route.boundingMapRect animated:NO];
    [self.mapView addOverlay:route];
    
    [self.mapView addAnnotations:tracks];
}

- (void)addLocations:(NSArray *)locations
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self drawLineWithLocations:locations];
    [self.mapView addAnnotations:locations];
}

- (void)drawLineWithLocations:(NSArray *)locations
{
    CLLocation *previous;
    CLLocation *current;
//    for (int i = 0; i < locations.count; i++) {
//        
//        current = locations[i];
//        if (i > 0) {
//            // previous
//            MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:previous.coordinate addressDictionary:nil];
//            MKMapItem *source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
//            
//            // current
//            MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:current.coordinate addressDictionary:nil];
//            MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
//            
//            MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
//            [directionsRequest setSource:source];
//            [directionsRequest setDestination:destination];
//            
//            MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
//            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//                if (error) {
//                    return;
//                }
//                // So there wasn't an error - let's plot those routes
//                [self.mapView setVisibleMapRect:[response.routes firstObject].polyline.boundingMapRect animated:NO];
//                [self.mapView addOverlay:[response.routes firstObject].polyline];
//            }];
//        }
//        previous = current;
//    }

    CLLocationCoordinate2D coordinates[locations.count];
    for (int i = 0; i < locations.count; i++) {
        current = locations[i];
        coordinates[i] = current.coordinate;
    }
    
    MKPolyline *route = [MKPolyline polylineWithCoordinates:coordinates count:locations.count];
    [self.mapView setVisibleMapRect:route.boundingMapRect animated:NO];
    [self.mapView addOverlay:route];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    if ([annotation isKindOfClass:[IQTrack class]]) {        
        MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        if ([(IQTrack *)annotation activity].running || [(IQTrack *)annotation activity].walking) {
            annView.pinColor = MKPinAnnotationColorRed;
        } else if ([(IQTrack *)annotation activity].automotive) {
            annView.pinColor = MKPinAnnotationColorPurple;
        } else if ([(IQTrack *)annotation activity].cycling) {
            annView.pinColor = MKPinAnnotationColorGreen;
        }
        return annView;
        
    } else {
        annotationView = nil;
    }
    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor redColor]];
        [renderer setLineWidth:5.0];
        return renderer;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
//    [self makeAnnotationsVisible:self.mapView.annotations animated:YES];
}

- (void)makeAnnotationsVisible:(NSArray *const)annotations animated:(BOOL const)animated
{
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    
    MKMapPoint center = MKMapPointMake(zoomRect.origin.x + zoomRect.size.width/2.0f,
                                       zoomRect.origin.y + zoomRect.size.height/2.0f);
    
    zoomRect.size.width *= 1.1f;
    zoomRect.size.height *= 1.1f;
    zoomRect.origin.x = center.x - zoomRect.size.width/2.0f;
    zoomRect.origin.y = center.y - zoomRect.size.height/2.0f;
    
    [self.mapView setVisibleMapRect:zoomRect animated:animated];
}

@end
