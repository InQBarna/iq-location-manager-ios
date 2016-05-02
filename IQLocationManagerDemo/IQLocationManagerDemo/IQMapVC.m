//
//  IQMapVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 20/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQMapVC.h"

#import "Track.h"
#import "TrackPoint.h"
#import "IQLocationDataSource.h"

#import <CoreMotion/CoreMotion.h>
#import <MapKit/MapKit.h>

@interface IQMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView  *mapView;
@property (weak, nonatomic) Track             *currentTrack;

@end

@implementation IQMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.currentTrack) {
        [self addTrackPoints:self.currentTrack.points];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.currentTrack = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)configureWithTrack:(Track *)track
{
    self.currentTrack = track;
}

- (void)addTrackPoints:(NSArray *)trackPoints
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    TrackPoint *current;
    CLLocationCoordinate2D coordinates[trackPoints.count];
    for (int i = 0; i < trackPoints.count; i++) {
        current = trackPoints[i];
        coordinates[i] = CLLocationCoordinate2DMake(current.latitude.doubleValue, current.longitude.doubleValue);
    }
    
    MKPolyline *route = [MKPolyline polylineWithCoordinates:coordinates count:trackPoints.count];
    [self.mapView setVisibleMapRect:route.boundingMapRect animated:NO];
    [self.mapView addOverlay:route];
    
    [self.mapView addAnnotations:trackPoints];
}

- (void)addLocations:(NSArray *)locations
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    CLLocation *current;
    CLLocationCoordinate2D coordinates[locations.count];
    for (int i = 0; i < locations.count; i++) {
        current = locations[i];
        coordinates[i] = current.coordinate;
    }
    
    MKPolyline *route = [MKPolyline polylineWithCoordinates:coordinates count:locations.count];
    [self.mapView setVisibleMapRect:route.boundingMapRect animated:NO];
    [self.mapView addOverlay:route];
    
    [self.mapView addAnnotations:locations];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    if ([annotation isKindOfClass:[TrackPoint class]]) {
        
        MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        if ([(TrackPoint *)annotation running].boolValue || [(TrackPoint *)annotation walking].boolValue) {
            annView.pinColor = MKPinAnnotationColorRed;
        } else if ([(TrackPoint *)annotation automotive].boolValue) {
            annView.pinColor = MKPinAnnotationColorPurple;
        } else if ([(TrackPoint *)annotation cycling].boolValue) {
            annView.pinColor = MKPinAnnotationColorGreen;
        }
        
        if ([annotation isEqual:[self.currentTrack points].firstObject] || [annotation isEqual:[self.currentTrack points].lastObject]) {
            annView.canShowCallout = YES;
            annView.hidden = NO;
        } else {
            annView.canShowCallout = NO;
            annView.hidden = YES;
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
        [renderer setStrokeColor:[UIColor purpleColor]];
        [renderer setLineWidth:5.0];
        return renderer;
    }
    return nil;
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
