//
//  ViewController.m
//  RouteFinder
//
//  Created by Roberto Rey Magaña on 01/04/16.
//  Copyright © 2016 Smartplace. All rights reserved.
//

#import "ViewController.h"
@import CoreLocation;
@import GoogleMaps;
#import "RouteFinder.h"
#import "Result.h"

@interface ViewController ()

@property (nonatomic, strong) CLLocation *source;
@property (nonatomic, strong) CLLocation *destination;
@property (nonatomic, strong) RouteFinder *routeFinder;
@property (nonatomic, strong) NSArray<Result> *results;
@property (nonatomic, strong) NSMutableArray<Route> *routes;
@property (nonatomic, assign) int counter;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *lblDistance;
- (IBAction)btnFindRoutePressed:(id)sender;

@end

@implementation ViewController{
    NSArray  *POLYLINES;
}

- (void)viewDidLoad {
    
    
    CLLocationCoordinate2D p1 = CLLocationCoordinate2DMake(20.661764, -103.452766);
    CLLocationCoordinate2D p2 = CLLocationCoordinate2DMake(20.699594,-103.390514);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:p1 coordinate:p2];
    GMSCameraPosition *camera = [self.mapView cameraForBounds:bounds insets:UIEdgeInsetsZero];
    self.mapView.camera = camera;
    
    self.source = [[CLLocation alloc] initWithLatitude:20.681568 longitude:-103.433966];
    //self.destination = [[CLLocation alloc] initWithLatitude:20.680323 longitude:-103.427153]; //one route
    //self.destination = [[CLLocation alloc] initWithLatitude:20.690124 longitude:-103.416188];   //two routes
    self.destination = [[CLLocation alloc] initWithLatitude:20.700919 longitude:-103.375442];   //third routes
    
    // Creates a markers for source and destination.
    GMSMarker *markerSource = [[GMSMarker alloc] init];
    markerSource.position = self.source.coordinate;
    markerSource.title = @"Punto de origen";
    markerSource.map = self.mapView;
    
    GMSMarker *markerDestination = [[GMSMarker alloc] init];
    markerDestination.position = self.destination.coordinate;
    markerDestination.title = @"Punto de destino";
    markerDestination.map = self.mapView;
    
    
    POLYLINES = @[
                  @"qkf}BdgivRrA{IzDo\\bAuJnBmPlBkNjBoOjDiLbD{H|E`BnGnB`Cp@tN|D|TfHpMhEhL`DhN~EvJxCpGvB`KvBfI`ChJ`DvFtA",
                  @"mca}BbyfvRcWtAiS~@eQ~@aKv@uK`@sF_AiGuCgH{B}MmAyScC_UmCyPaBsJiAiDYoDw@gDcC_BoD}AwM{AsB{DGqK?}IFgJvB}GXcKmAyHsBuJ_EwHmCaG}CoCwDwBwE_DiG",
                  @"u~f}B`ifvRxIv@`IfAbCTbHp@xIpAlHdAfGV|Fb@jGl@`GbD~GpC`JCrFY",
                  @"ube}BbufvRiNgBiK}AiNuA_MgBiLkAqGs@_B}HoAoJ_DiNw@kLy@_JXkOn@}LqDaKwEgMo@kLgCsOqEsG_GuIaCcOoHqGiKaGaLcLwDeIwEiJaDaH_A{C_DcH_B_JyEr@wIjD",
                  @"oog}BlzfvReBkWkHmb@eCs^^_YaI{SqCm^gJgJ_D}H_BsKiGiGaLcH_L{KyEiKgC{GyE{H_EyJwBaKqGFgIpCqHnF_F~EgEhDqDpBo@fGgC~IwD|LqCpFgI|AfKmIhDkIjByEbAkDj@eEvA{DpDaCrA_AbEkDrDoDhCwBvGgCtG_BhCMdI{A`GcBzFoAdFeArFmBhDoB",
                  @"cfm}Bl``vR~H_BhByGvAiGfCaG~@gFv@oFhDaDnFsCvCaDxHgF~FiChFcA~IcA`I{C~FcAxEmAfIyC`F_C~DmAxJa@~JPhLFxMP",
                  @"kud}BnwfvRqSeBqKwBaPuAqQwBiP}AaM{CyEcPgCiGqLQaPQ_L|DyNmAyOmEyNcHyIuEoHyNqDwMoFyCoDuDOcEnBqCf@sGn@mMoCqJ_BeM^aG~GeInDuHVeF_@{K_DmWgA_JoAwI_@aHo@gFW_Fo@_J"
                  ];
    
    
    self.routes = [[NSMutableArray<Route> alloc] init];
    
    for (int i = 0; i<POLYLINES.count; i++) {
        Route *route = [Route alloc];
        route.polyline = [POLYLINES objectAtIndex:i];
        route.name = [NSString stringWithFormat:@"Route %d",i];
        route.route_type = [NSString stringWithFormat:@"%d",i%3+1];
        
        NSMutableArray *points = [RouteFinder decodePolyline:route.polyline];
        NSMutableArray<Stop> *stops = [[NSMutableArray<Stop> alloc] init];
        
        int c1 = 0;
        for (CLLocation *point in points) {
            Stop *stop = [Stop alloc];
            stop.position = point;
            stop.name = [NSString stringWithFormat:@"Stop %d",c1];
            [stops addObject:stop];
            c1++;
        }
        route.stops = stops;
        [self.routes addObject:route];
    }
    
    
    
    self.routeFinder = [RouteFinder alloc];
    [self.routeFinder setSource:self.source];
    [self.routeFinder setDestination:self.destination];
    [self.routeFinder setAvailableRoutes:self.routes];
    
    NSMutableArray<Stop> *stops = [self.routeFinder getAvailableStops:[[CLLocation alloc] initWithLatitude:20.6955039 longitude:-103.4219898]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnFindRoutePressed:(id)sender {
    
    self.results = [self.routeFinder searchRoutes];
    
    if(self.results!=nil && self.results.count>0 && self.counter<self.results.count){
        
        [self.mapView clear];
        
        // Creates a markers for source and destination.
        GMSMarker *markerSource = [[GMSMarker alloc] init];
        markerSource.position = self.source.coordinate;
        markerSource.title = @"Punto de origen";
        markerSource.map = self.mapView;
        
        GMSMarker *markerDestination = [[GMSMarker alloc] init];
        markerDestination.position = self.destination.coordinate;
        markerDestination.title = @"Punto de destino";
        markerDestination.map = self.mapView;
        
        [self.routeFinder paintResult:[self.results objectAtIndex:self.counter] onMap:self.mapView];
        [self.lblDistance setText:[NSString stringWithFormat:@"%f",[((Result *)[self.results objectAtIndex:self.counter]) getDistance]]];
        self.counter++;
    }
}
@end
