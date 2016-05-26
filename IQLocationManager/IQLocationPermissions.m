//
//  IQLocationPermissions.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 18/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQLocationPermissions.h"

#define kIQLocationSoftDenied @"kIQLocationSoftDenied"

@interface IQLocationPermissions () <UIAlertViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, copy) void (^completionBlock)(IQLocationResult result);

@end

@implementation IQLocationPermissions

static IQLocationPermissions *__iqLocationPermissions;

#pragma mark Initialization and destroy calls

+ (IQLocationPermissions *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __iqLocationPermissions = [[self alloc] init];
    });
    return __iqLocationPermissions;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.locationManager = nil;
}

- (void)requestLocationPermissionsForManager:(CLLocationManager *)locationManager
                       withSoftAccessRequest:(BOOL)softAccessRequest
                               andCompletion:(void(^)(IQLocationResult result))completion
{
    self.completionBlock = completion;
    self.locationManager = locationManager;
    self.locationManager.delegate = self;
    
    if (softAccessRequest) {        
        NSString *localizedTitle = NSLocalizedString(@"location_request_alert_title", @"");
        if ([localizedTitle isEqualToString:@"location_request_alert_title"]) {
            localizedTitle = NSLocalizedStringFromTable(@"location_request_alert_title",@"IQLocationManager",nil);
        }
        NSString *localizedDescription = NSLocalizedString(@"location_request_alert_description", @"");
        if ([localizedDescription isEqualToString:@"location_request_alert_description"]) {
            localizedDescription = NSLocalizedStringFromTable(@"NSLocationUsageDescription", @"InfoPlist", nil);
            if ([localizedDescription isEqualToString:@"NSLocationUsageDescription"]) {
                localizedDescription = NSLocalizedStringFromTable(@"location_request_alert_description",@"IQLocationManager",nil);
            }
        }
        NSString *localizedCancel = NSLocalizedString(@"location_request_alert_cancel",nil);
        NSString *localizedAccept = NSLocalizedString(@"location_request_alert_accept",nil);
        
        [[[UIAlertView alloc] initWithTitle:localizedTitle
                                    message:localizedDescription
                                   delegate:self
                          cancelButtonTitle:([localizedCancel isEqualToString:@"location_request_alert_cancel"] ?
                                              [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:@"Cancel" value:nil table:nil] : localizedCancel)
                          otherButtonTitles:([localizedAccept isEqualToString:@"location_request_alert_accept"] ?
                                              [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:@"OK" value:nil table:nil] : localizedAccept) , nil] show];
    } else {
        if ([UIDevice currentDevice].systemVersion.floatValue > 7.1) {
            [self requestSystemPermissionForLocation];
        } else {
            // for iOS 7, startUpdating forces the request to the user
            [_locationManager startUpdatingLocation];
        }
    }
}

- (BOOL)getSoftDeniedFromDefaults
{
    BOOL softDenied = [NSUserDefaults.standardUserDefaults boolForKey:kIQLocationSoftDenied];
    return softDenied;
}

- (BOOL)setSoftDenied:(BOOL)softDenied
{
    NSUserDefaults *const standardUserDefaults = NSUserDefaults.standardUserDefaults;
    [NSUserDefaults.standardUserDefaults setBool:softDenied forKey:kIQLocationSoftDenied];
    return [standardUserDefaults synchronize];
}

- (void)requestSystemPermissionForLocation {
    // As of iOS 8, apps must explicitly request location services permissions. IQLocationManager supports both levels, "Always" and "When In Use".
    // IQLocationManager determines which level of permissions to request based on which description key is present in your app's Info.plist
    // If you provide values for both description keys, the more permissive "Always" level is requested.
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        BOOL hasAlwaysKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
        BOOL hasWhenInUseKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
        if (hasAlwaysKey) {
            [self.locationManager requestAlwaysAuthorization];
        } else if (hasWhenInUseKey) {
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            // At least one of the keys NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription MUST be present in the Info.plist file to use location services on iOS 8+.
            NSAssert(hasAlwaysKey || hasWhenInUseKey, @"To use location services in iOS 8+, your Info.plist must provide a value for either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription.");
        }
    }
}

- (IQLocationResult)getLocationStatus
{
    if (!CLLocationManager.locationServicesEnabled) {
        return kIQLocationResultNotEnabled;
    } else {
        CLAuthorizationStatus const status = CLLocationManager.authorizationStatus;
        
        if (status == kCLAuthorizationStatusNotDetermined) {
            if (self.getSoftDeniedFromDefaults){
                return kIQLocationResultSoftDenied;
            } else {
                return kIQLocationResultNotDetermined;
            }
        } else {
            if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
                return kIQLocationResultSystemDenied;
            } else if (status == kCLAuthorizationStatusAuthorized) {
                return kIQlocationResultAuthorized;
            }
            
            if ([UIDevice currentDevice].systemVersion.floatValue > 7.1) {
                if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                    return kIQlocationResultAuthorized;
                }
            }
            
            if (self.getSoftDeniedFromDefaults){
                return kIQLocationResultSoftDenied;
            }
        }
    }
    return kIQLocationResultNotDetermined;
}

#pragma mark - UIAlertViewDelegate methods

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == [alertView cancelButtonIndex] ) {
        [self setSoftDenied:YES];
        if (_completionBlock) {
            _completionBlock(kIQLocationResultSoftDenied);
        }
    } else {
        [self setSoftDenied:NO];
        if ([UIDevice currentDevice].systemVersion.floatValue > 7.1) {
            [self requestSystemPermissionForLocation];
        } else {
            // for iOS 7, startUpdating forces the request to the user
            [_locationManager startUpdatingLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([UIDevice currentDevice].systemVersion.floatValue > 7.1) {
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            if (_completionBlock) {
                _completionBlock(kIQlocationResultAuthorized);
            }
        } else if (status == kCLAuthorizationStatusDenied) {
            if (_completionBlock) {
                _completionBlock(kIQLocationResultSystemDenied);
            }
        }
    } else {
        if (status == kCLAuthorizationStatusAuthorized) {
            if (_completionBlock) {
                _completionBlock(kIQlocationResultAuthorized);
            }
        } else if (status == kCLAuthorizationStatusDenied) {
            if (_completionBlock) {
                _completionBlock(kIQLocationResultSystemDenied);
            }
        }
    }
}

@end
