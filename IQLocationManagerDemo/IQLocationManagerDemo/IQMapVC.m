//
//  IQMapVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 20/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQMapVC.h"

#import <MapKit/MapKit.h>

@interface IQMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

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

- (void)addLocations:(NSArray *)locations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:locations];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    [self makeAnnotationsVisible:self.mapView.annotations animated:YES];
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
