//
//  DJIRootViewController.m
//  GSDemo
//
//  Created by OliverOu on 7/7/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "DJIRootViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJISDK.h>
#import "DJIMapController.h"
#import "DJIGSButtonViewController.h"
#import "DJIWaypointConfigViewController.h"
#import "LoadPathViewController.h"
#import "DemoUtility.h"
#import "mars2earth.h"
#import <VideoPreviewer/VideoPreviewer.h>
#import "VCCReader.h"
#import "VCCDroneWaypoint.h"
#import "DemoUtility/DataStructures.h"
#import "DDTTYLogger.h"

#define ENTER_DEBUG_MODE 0


@interface DJIRootViewController ()<DJIGSButtonViewControllerDelegate, DJIWaypointConfigViewControllerDelegate, LoadPathViewControllerDelegte,MKMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate, DJIFlightControllerDelegate, DJIGimbalDelegate,DJIBaseProductDelegate>

@property (nonatomic, assign) BOOL isEditingPoints;
@property (nonatomic, assign) BOOL isWatching;
@property (nonatomic, assign) BOOL photoNotvideo;
@property (nonatomic, assign) BOOL isRecording;


@property (nonatomic, strong) DJIGSButtonViewController *gsButtonVC;
@property (nonatomic, strong) DJIWaypointConfigViewController *waypointConfigVC;
@property (nonatomic, strong) DJIMapController *mapController;
@property (nonatomic, strong) LoadPathViewController *loadpathVC;

@property(nonatomic, strong) CLLocationManager* locationManager;
@property(nonatomic, assign) CLLocationCoordinate2D userLocation;//mars
@property(nonatomic, assign) CLLocationCoordinate2D droneLocation;//mars
@property(nonatomic, assign) CLLocationCoordinate2D earthdroneLocation;//earth fof log

@property (nonatomic) DJIAttitude logAircraftAttitude;
@property (nonatomic) DJIGimbalAttitude logGimbalAttitude;
@property float logHomeAltitude;
@property float logAircraftAltitude;
@property float logVelocityX;
@property float logVelocityY;
@property float logVelocityZ;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (weak, nonatomic) IBOutlet UIView *fpvPreviewView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property(nonatomic, strong) IBOutlet UILabel* modeLabel;
@property(nonatomic, strong) IBOutlet UILabel* gpsLabel;
@property(nonatomic, strong) IBOutlet UILabel* speedLabel;     //3dv
@property(nonatomic, strong) IBOutlet UILabel* hsLabel;
@property(nonatomic, strong) IBOutlet UILabel* vsLabel;
@property(nonatomic, strong) IBOutlet UILabel* vxLabel;
@property(nonatomic, strong) IBOutlet UILabel* vyLabel;
@property(nonatomic, strong) IBOutlet UILabel* altitudeLabel;
@property(nonatomic, strong) IBOutlet UILabel* headingLabel;
@property(nonatomic, strong) IBOutlet UILabel* gimbalpitchLabel;
@property(nonatomic, strong) IBOutlet UILabel* gpscoordLabel;
@property(nonatomic, strong) IBOutlet UILabel* hhLabel;



@property(nonatomic, strong) DJIWaypointMission* waypointMission;
@property(nonatomic, strong) DJIMissionManager* missionManager;
@property (strong, nonatomic) NSMutableArray *loadedWaymissionPoints;

//information need to be stored
// /var/mobile/Containers/Data/Application/BC43AC77-00FC-4EB7-9D5E-E86C5A52A476/Documents/CaptureLog-2016-11-24 17/20/18.962000.txt
//every launch a new time-based file is created and used to store key shots.
@property (strong, nonatomic) NSString *keyShotsFileName;
@property (strong, nonatomic) NSMutableArray< NSString*>* narratives;
//For logging drone status while shooting a video
//VideoLog-2016-11-24 17/23/24.193000.txt
@property (strong, nonatomic) NSString *recordFileName;
@property (strong, nonatomic) NSMutableArray< NSString*>* statusRecords;
@property (strong, nonatomic) NSFileHandle *recordFileHandler;

@property int numOfRecords;
@property int numOfPicsTaken;
@property BOOL statusRecordsWritten;
//end of record

@end

@implementation DJIRootViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startUpdateLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self registerApp];
    self.missionManager = [DJIMissionManager sharedInstance];
    
    [self initUI];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark Init Methods
-(void)initData
{
    self.userLocation = kCLLocationCoordinate2DInvalid;
    self.droneLocation = kCLLocationCoordinate2DInvalid;
    
    self.mapController = [[DJIMapController alloc] init];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addWaypoints:)];
    self.mapView.delegate =self;
    [self.mapView addGestureRecognizer:self.tapGesture];
    self.loadedWaymissionPoints =[[NSMutableArray alloc]init];
    self.numOfRecords = 0;
    self.numOfPicsTaken = 0;
    self.statusRecordsWritten = NO;
    [self initKeyFrameLogFileName];
    [self initRecordLogFileName];

}

-(void) initUI
{
    self.modeLabel.text = @"N/A";
    self.gpsLabel.text = @"0";
    self.vsLabel.text = @"0.0 M/S";
    self.hsLabel.text = @"0.0 M/S";
    self.speedLabel.text = @"0.0 M/S";
    self.vxLabel.text = @"0.0 M/S";
    self.vyLabel.text = @"0.0 M/S";
    self.altitudeLabel.text = @"0 M";
    self.headingLabel.text = @"0.0";
    self.gimbalpitchLabel.text = @"0.0";
    self.gpscoordLabel.text = @"unknown";
    
    self.isEditingPoints = NO;
    self.isWatching = NO;
    self.photoNotvideo = YES;
    
    WeakRef(weakSelf);
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.fpvPreviewView.alpha = 0.0;
    }];

    //self.mapView.delegate = self;
    self.gsButtonVC = [[DJIGSButtonViewController alloc] initWithNibName:@"DJIGSButtonViewController" bundle:[NSBundle mainBundle]];
    [self.gsButtonVC.view setFrame:CGRectMake(0, self.topBarView.frame.origin.y + self.topBarView.frame.size.height, self.gsButtonVC.view.frame.size.width, self.gsButtonVC.view.frame.size.height)];
    self.gsButtonVC.delegate = self;
    [self.view addSubview:self.gsButtonVC.view];
    
    self.waypointConfigVC = [[DJIWaypointConfigViewController alloc] initWithNibName:@"DJIWaypointConfigViewController" bundle:[NSBundle mainBundle]];
    self.waypointConfigVC.view.alpha = 0;
    self.waypointConfigVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    [self.waypointConfigVC.view setCenter:self.view.center];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) //Check if it's using iPad and center the config view
    {
        self.waypointConfigVC.view.center = self.view.center;
    }

    self.waypointConfigVC.delegate = self;
    [self.view addSubview:self.waypointConfigVC.view];
    //loadPathViewController
    self.loadpathVC = [[LoadPathViewController alloc] initWithNibName:@"LoadPathViewController" bundle:[NSBundle mainBundle]];
    self.loadpathVC.view.alpha = 0;
    self.loadpathVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    [self.loadpathVC.view setCenter:self.view.center];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) //Check if it's using iPad and center the config view
    {
        self.loadpathVC.view.center = self.view.center;
    }
    
    self.loadpathVC.delegate = self;
    [self.view addSubview:self.loadpathVC.view];
}

-(void) registerApp
{
    NSString* appKey = @"7a4cb207be0d3f639d99410e";
    [DJISDKManager registerApp:appKey withDelegate:self];
}

#pragma mark DJISDKManagerDelegate Methods

- (void)sdkManagerDidRegisterAppWithError:(NSError *_Nullable)error
{
    if (error){
        NSString *registerResult = [NSString stringWithFormat:@"Registration Error:%@", error.description];
        ShowMessage(@"Registration Result", registerResult, nil, @"OK");
    }
    else{
#if ENTER_DEBUG_MODE
        [DJISDKManager enterDebugModeWithDebugId:@"Please Enter Your Debug ID"];
#else
        [DJISDKManager startConnectionToProduct];
#endif
    }
}

- (void)sdkManagerProductDidChangeFrom:(DJIBaseProduct *_Nullable)oldProduct to:(DJIBaseProduct *_Nullable)newProduct
{
    if (newProduct){
        DJIFlightController* flightController = [DemoUtility fetchFlightController];
        if (flightController) {
            flightController.delegate = self;
        }
        DJIGimbal* gimbalController = [DemoUtility fetchGimbal];
        if (gimbalController) {
            gimbalController.delegate = self;
        }
        DJICamera* camera = [DemoUtility fetchCamera];
        if (camera != nil) {
            camera.delegate = self;
        }
    }

}

#pragma mark action Methods
- (void)focusMap
{
    if (CLLocationCoordinate2DIsValid(self.droneLocation)) {
        MKCoordinateRegion region = {0};
        region.center = self.droneLocation;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        [self.mapView setRegion:region animated:YES];
    }
}

#pragma mark CLLocation Methods
-(void) startUpdateLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        if (self.locationManager == nil) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = 0.1;
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            [self.locationManager startUpdatingLocation];
        }
    }else
    {
        ShowMessage(@"Location Service is not available", @"", nil, @"OK");
    }
}

#pragma mark UITapGestureRecognizer Methods
- (void)addWaypoints:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.mapView];
    
    if(tapGesture.state == UIGestureRecognizerStateEnded){
         if (self.isEditingPoints)
            [self.mapController addPoint:point withMapView:self.mapView];
    }
}

#pragma mark - DJIWaypointConfigViewControllerDelegate Methods

- (void)cancelBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC
{
    WeakRef(weakSelf);
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
    
}

- (void)finishBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC
{
    WeakRef(weakSelf);
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
    NSLog(@"finishBtnAtionInDJIWayPointConfigViewCOntroller");
    
    for (int i = 0; i < self.waypointMission.waypointCount; i++) {
        DJIWaypoint* waypoint = [self.waypointMission getWaypointAtIndex:i];
        //if you want to fly in a isohypse line change here
        waypoint.altitude = 100;
    }
    
    self.waypointMission.maxFlightSpeed = [self.waypointConfigVC.maxFlightSpeedTextField.text floatValue];
    self.waypointMission.autoFlightSpeed = [self.waypointConfigVC.autoFlightSpeedTextField.text floatValue];
    self.waypointMission.headingMode = (DJIWaypointMissionHeadingMode)self.waypointConfigVC.headingSegmentedControl.selectedSegmentIndex;
    self.waypointMission.finishedAction = (DJIWaypointMissionFinishedAction)self.waypointConfigVC.actionSegmentedControl.selectedSegmentIndex;

    [self.missionManager prepareMission:self.waypointMission withProgress:^(float progress) {
        //Do something with progress
    } withCompletion:^(NSError * _Nullable error) {
        if (error){
            NSString* prepareError = [NSString stringWithFormat:@"Prepare Mission failed:%@", error.description];
            ShowMessage(@"ERROR!", prepareError, nil, @"OK");
        }else {
            ShowMessage(@"Have Fun!", @"Prepare Mission Finished", nil, @"OK");
        }
    }];
}

#pragma mark - DJIGSButtonViewController Delegate Methods

- (void)stopBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self.missionManager stopMissionExecutionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            NSString* failedMessage = [NSString stringWithFormat:@"Stop Mission Failed: %@", error.description];
            ShowMessage(@"Stop Mission Failed", failedMessage, nil, @"OK");
        }else
        {
            ShowMessage(@"Stop Mission Finished", @"Stop Mission Finished", nil, @"OK");
        }
    }];
}

- (void)clearBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self.mapController cleanAllPointsWithMapView:self.mapView];
    
}

- (void)focusMapBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self focusMap];
}

//
- (void)cameraBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
         WeakRef(weakSelf);
    
    if (self.isWatching) {
        self.isWatching = NO;
        [button setTitle:@"Camera" forState:UIControlStateNormal];
        [[VideoPreviewer instance] setView:nil];

        [UIView animateWithDuration:0.25 animations:^{
            WeakReturn(weakSelf);
            weakSelf.mapView.alpha = 1.0;
            weakSelf.fpvPreviewView.alpha = 0.0;
        }];

    }else
    {
        self.isWatching = YES;
        [button setTitle:@"Map" forState:UIControlStateNormal];
        [[VideoPreviewer instance] setView:self.fpvPreviewView];
        [[VideoPreviewer instance] start];          //decode starting
        [UIView animateWithDuration:0.25 animations:^{
            WeakReturn(weakSelf);
            weakSelf.mapView.alpha = 0.0;
            weakSelf.fpvPreviewView.alpha = 1.0;
        }];

    }
    
}


- (void)configBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    WeakRef(weakSelf);
    
    NSArray* wayPoints = self.mapController.wayPoints;
    if (wayPoints == nil || wayPoints.count < DJIWaypointMissionMinimumWaypointCount) {
        ShowMessage(@"No or not enough waypoints for mission", @"", nil, @"OK");
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 1.0;
    }];
    
    if (self.waypointMission){
        [self.waypointMission removeAllWaypoints];
    }
    else{
        self.waypointMission = [[DJIWaypointMission alloc] init];
    }
    
    for (int i = 0; i < wayPoints.count; i++) {
        CLLocation* location = [wayPoints objectAtIndex:i];
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            CLLocationCoordinate2D reallocation = [mars2earth MarsPoint2gpsPoint:location.coordinate];
            DJIWaypoint* waypoint = [[DJIWaypoint alloc] initWithCoordinate:reallocation];
            [self.waypointMission addWaypoint:waypoint];
        }
    }
}

- (void)startBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self.missionManager startMissionExecutionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            ShowMessage(@"Start Mission Failed", error.description, nil, @"OK");
        }else
        {
            ShowMessage(@"", @"Mission Started", nil, @"OK");
        }
    }];
}

- (void)switchToMode:(DJIGSViewMode)mode inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    if (mode == DJIGSViewMode_EditMode) {
        [self focusMap];
    }
    
}

- (void)addBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    if (self.isEditingPoints) {
        self.isEditingPoints = NO;
        [button setTitle:@"Add" forState:UIControlStateNormal];
    }else
    {
        self.isEditingPoints = YES;
        [button setTitle:@"Finished" forState:UIControlStateNormal];
    }
}

- (void)captureBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC{
    __weak DJICamera* camera = [DemoUtility fetchCamera];
    if (camera) {
        [camera startShootPhoto:DJICameraShootPhotoModeSingle withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowMessage(@"Take Photo Error", error.description, nil, @"OK");
            }else{
                [self logAdditionalCaptureInformation];
            }
        }];
    }
}
- (void)recordBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC{
    __weak DJICamera* camera = [DemoUtility fetchCamera];
    if (camera) {
        
        if (self.isRecording) {
            [camera stopRecordVideoWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowMessage(@"Stop Recording Error", error.description, nil, @"OK");
                }
            }];

        }else
        {
            [camera startRecordVideoWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowMessage(@"Start Recording Error", error.description, nil, @"OK");
                }
            }];
            //[button setTitle:@"Finished" forState:UIControlStateNormal];
        }
    }
}

- (void)modeflagBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC{
    
    __weak DJICamera* camera = [DemoUtility fetchCamera];
    
    if (camera) {
        if (_photoNotvideo == YES) { //Take photo
            [camera setCameraMode:DJICameraModeShootPhoto withCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowMessage(@"Set DJICameraModeShootPhoto Failed", error.description, nil, @"OK");
                }
            }];
            [button setTitle:@"Photo" forState:UIControlStateNormal];
            _photoNotvideo = NO;
        }else if (_photoNotvideo == NO){ //Record video
            [camera setCameraMode:DJICameraModeRecordVideo withCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowMessage(@"Set DJICameraModeRecordVideo Failed", error.description, nil, @"OK");
                }
                
            }];
            [button setTitle:@"Video" forState:UIControlStateNormal];
            _photoNotvideo = YES;
        }
    }

}

- (void)loadpathBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC{
    WeakRef(weakSelf);
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        //weakSelf.mapView.alpha = 0.0;
        weakSelf.loadpathVC.view.alpha = 1.0;
    }];
    
    
}

//commit mission and start
- (void)pathgoBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC{
    
    //push the button in the loadpathVC, then we do pathgo
    //so far, we load our file into loadedWaymissionPoints
    //next... preperation
     //*  All the data already loaded in loadedWaymissionPoints

    //start
    [self.missionManager startMissionExecutionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            ShowMessage(@"Start Mission Failed", error.description, nil, @"OK");
        }else
        {
            ShowMessage(@"Mission Started", @"Mission Started", nil, @"OK");
        }
    }];
    
    
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    self.userLocation = location.coordinate;
    self.hhLabel.text = [NSString stringWithFormat:@"%0.1f M",location.altitude];
    self.logHomeAltitude = location.altitude;
    //self.gpscoordLabel.text = [NSString stringWithFormat:@"%f, %f",location.coordinate.latitude,location.coordinate.longitude];// home coordinate
}

#pragma mark - MKMapViewDelegate Method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //debugger
    NSLog(@"run view for Annotation with %lu count!",self.mapController.editPoints.count);
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin_Annotation"];
                    pinView.animatesDrop = YES;
            pinView.pinTintColor = [UIColor blueColor];
        return pinView;
        
    }else if ([annotation isKindOfClass:[DJIAircraftAnnotation class]])
    {
        DJIAircraftAnnotationView* annoView = [[DJIAircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Aircraft_Annotation"];
        ((DJIAircraftAnnotation*)annotation).annotationView = annoView;
        return annoView;
    }
    
    return nil;
}

#pragma mark - DJIFlightControllerDelegate

- (void)flightController:(DJIFlightController *)fc didUpdateSystemState:(DJIFlightControllerCurrentState *)state
{
    self.droneLocation = [mars2earth gpsPoint2MarsPoint:(state.aircraftLocation)];
    //self.droneLocation = state.aircraftLocation;
    NSLog(@"UpdateSystemState");
    //for logging
    self.earthdroneLocation = state.aircraftLocation;
    self.logAircraftAttitude = state.attitude;
    self.logAircraftAltitude = state.altitude;
    self.logVelocityX = state.velocityX;
    self.logVelocityY = state.velocityY;
    self.logVelocityZ = state.velocityZ;
    //end of logging
    self.modeLabel.text = state.flightModeString;
    self.gpsLabel.text = [NSString stringWithFormat:@"%d", state.satelliteCount];
    self.vsLabel.text = [NSString stringWithFormat:@"%0.1f M/S",state.velocityZ];
    float hs = sqrtf(state.velocityX*state.velocityX + state.velocityY*state.velocityY);
    float speed = sqrtf(hs*hs +state.velocityZ*state.velocityZ);
    self.hsLabel.text = [NSString stringWithFormat:@"%0.1f M/S",hs];
    self.vxLabel.text = [NSString stringWithFormat:@"%0.1f M/S",state.velocityX];
    self.vyLabel.text = [NSString stringWithFormat:@"%0.1f M/S",state.velocityY];
    self.speedLabel.text = [NSString stringWithFormat:@"%0.1f M/S",speed];
    self.altitudeLabel.text = [NSString stringWithFormat:@"%0.1f M",state.altitude];
    self.headingLabel.text = [NSString stringWithFormat:@"%0.1f ",state.attitude.yaw];
    self.gpscoordLabel.text = [NSString stringWithFormat:@"%f, %f",self.earthdroneLocation.latitude,self.earthdroneLocation.longitude];
    
    [self.mapController updateAircraftLocation:self.droneLocation withMapView:self.mapView];
    double radianYaw = RADIAN(state.attitude.yaw);
    [self.mapController updateAircraftHeading:radianYaw];
}

#pragma mark - DJIGimbalDelegate
// Override method in DJIGimbalDelegate to receive the pushed data
-(void)gimbal:(DJIGimbal *)gimbal didUpdateGimbalState:(DJIGimbalState *)gimbalState {
    self.logGimbalAttitude = gimbalState.attitudeInDegrees;
    self.gimbalpitchLabel.text = [NSString stringWithFormat:@"%0.1f", gimbalState.attitudeInDegrees.pitch];

}


#pragma mark - DJIBaseProductDelegate Method
//Since the camera component of the aircraft may change to another type,
//we should invoke this delegate method to check the component changes too.
-(void) componentWithKey:(NSString *)key changedFrom:(DJIBaseComponent *)oldComponent to:(DJIBaseComponent *)newComponent {
    
    if ([key isEqualToString:DJICameraComponent] && newComponent != nil) {
        __weak DJICamera* camera = [DemoUtility fetchCamera];
        if (camera) {
            [camera setDelegate:self];
        }
    }
}

#pragma mark - DJICameraDelegate Method
//to get the live H264 video feed data and send them to the VideoPreviewer to decode
-(void)camera:(DJICamera *)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)size
{
    [[VideoPreviewer instance] push:videoBuffer length:(int)size];
}

//to get the camera state from the camera on your aircraft
//for shooting
-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    self.isRecording = systemState.isRecording;
    if (self.isRecording) {
        [self.gsButtonVC.recordBtn setTitle:[self formattingSeconds:systemState.currentVideoRecordingTimeInSeconds] forState:UIControlStateNormal];
        
    }else
    {
        [self.gsButtonVC.recordBtn setTitle:@"Record" forState:UIControlStateNormal];
    }
}
#pragma mark - LoadPathViewControllerDelegate

- (void)goBtnActionInLoadPathViewController:(LoadPathViewController *)loadpathVC{
    WeakRef(weakSelf);
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.loadpathVC.view.alpha = 0;
    }];
    //clean the editpoint in mapcontroller
    [self.mapController.editPoints removeAllObjects];;
    //self.isStartFLag = YES;
    //start load file from the inbox
    //textField
    NSString *fileName= [self.loadpathVC.fileNameTextField.text stringByAppendingString:@".drone_path"];
    NSLog(@"fileName:%@",fileName);
    //homeDirectory
    NSString *homeDirectory = NSHomeDirectory();
    NSLog(@"homepath:%@", homeDirectory);
    //documentDirectory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSLog(@"docpath:%@", docDir);
    //inbox
    NSString *fileDirectory = [docDir stringByAppendingPathComponent:@"Inbox"];
    NSLog(@"Inboxpath:%@", fileDirectory);
    //realpath
    NSString *filePath = [fileDirectory stringByAppendingPathComponent:fileName];
    
    NSLog(@"path:%@", filePath);
    //now we get the full docment path, time to load some real data
    VCCReader *reader = [[VCCReader alloc]initReaderwith:filePath];
    //for test
    NSLog(@"can we be here");
    NSLog(@"%lu", [reader.vccReader count]);
    
    if ([reader.vccReader count] == 0) {
        ShowMessage(@"NO FILE!", @"Wrong fIle", nil, @"OK");
        //return;
    }
    
    
    NSLog(@"can we be ????");
    [reader showWhatWeRead];
    NSLog(@"can we be there");
    
    int n_line = [reader getNumberofRecords];
    //debugger
//    NSString *msg = [NSString stringWithFormat:@"There is %ld record(s) in the file",(long)n_line];
//    ShowMessage(@"DEBUG!", msg, nil, @"OK");
    //get sample frequency
    NSInteger samplef = [self.loadpathVC.samplefTextField.text intValue];
    self.mapView.delegate = self;
        [self.loadedWaymissionPoints removeAllObjects];
        [self.mapController cleanAllPointsWithMapView:self.mapView];
    
        for (int i = 0; i<n_line; i += samplef) {
            VCCDroneWaypoint* wayppoint = [reader DataAtIndex:i];
//            

            [self.loadedWaymissionPoints addObject:wayppoint];
        }
        
        //NSArray* annos = [NSArray arrayWithArray:((MKMapView*)self.mapViewController.view).annotations];
        NSString *msg = [NSString stringWithFormat:@"Way point number: %lu",(unsigned long)self.loadedWaymissionPoints.count];
         ShowMessage(@"Way point number!", msg, nil, @"OK");
    
    //commit
    NSArray* ALLwayPoints = self.loadedWaymissionPoints;
    if (ALLwayPoints == nil || ALLwayPoints.count < DJIWaypointMissionMinimumWaypointCount) {
        ShowMessage(@"No or not enough waypoints for mission", @"", nil, @"OK");
        //return;
    }
    else
    {
    //make the take off heading free
    float heading_tmp = ((VCCDroneWaypoint*)[ALLwayPoints objectAtIndex:0]).heading;
    // *  1. Create an instance of DJIWaypointMission.
    if (self.waypointMission){
        [self.waypointMission removeAllWaypoints];
    }
    else{
        self.waypointMission = [[DJIWaypointMission alloc] init];
        
    }
    //* loop
    for (int i = 0; (self.waypointMission.waypointCount < DJIWaypointMissionMaximumWaypointCount) && (i < ALLwayPoints.count); i++) {
        //*  2. Create coordinates.
        //our stupid file is made of the marslocation
        VCCDroneWaypoint* vccwaypoint = [ALLwayPoints objectAtIndex:i];
        CLLocationCoordinate2D marslocation = CLLocationCoordinate2DMake(vccwaypoint.lati, vccwaypoint.longti);
        if (CLLocationCoordinate2DIsValid(marslocation)) {
            //mapview
            //[NSThread sleepForTimeInterval:5];
            
            [self.mapController addGPSPoint:marslocation withMapView:self.mapView];
            
            //*  3. Use the coordinate to create an instance of DJIWaypoint.
            //first come back to earth
            CLLocationCoordinate2D gpslocation = [mars2earth MarsPoint2gpsPoint:marslocation];
            DJIWaypoint* waypoint = [[DJIWaypoint alloc] initWithCoordinate:gpslocation];
            waypoint.heading = vccwaypoint.heading;
            waypoint.gimbalPitch = vccwaypoint.pitch;
            waypoint.altitude = vccwaypoint.height;
            //4.add action
            //no action in the curve mode
//            if(i == 0)
//            {
//                [waypoint addAction:[[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeStartRecord param:6 ]];
//            }
            //set the turnMode
            VCCDroneWaypoint* waypoint_next;
            if (i == ALLwayPoints.count - 1) {
                waypoint_next = [ALLwayPoints objectAtIndex:(i)];
//                [waypoint addAction:[[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeStopRecord param:6 ]];
                
            }
            else waypoint_next = [ALLwayPoints objectAtIndex:(i+1)];
            
            float dis = waypoint_next.heading - heading_tmp;
            
            
            if (dis < -180)
            {
                waypoint.turnMode = DJIWaypointTurnClockwise;
            }
            else if(dis < 0 )
            {
                waypoint.turnMode = DJIWaypointTurnCounterClockwise;
            }
            else if (dis < 180)
            {
                waypoint.turnMode = DJIWaypointTurnClockwise;
            }
            else
            {
                waypoint.turnMode = DJIWaypointTurnCounterClockwise;
            }
            heading_tmp = waypoint_next.heading;
            //*  5. Add the waypoints into the mission.
            waypoint.cornerRadiusInMeters = [self.loadpathVC.rTextField.text floatValue];
            [self.waypointMission addWaypoint:waypoint];
        }

    }
    //step 4 seems useless
    //*  4. Add actions for each waypoint. Not too much actions need to be add, so we do this out side the loop
    [[self.waypointMission getWaypointAtIndex:0] addAction:[[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeStartRecord param:6 ]];
    [[self.waypointMission getWaypointAtIndex:self.waypointMission.waypointCount-1] addAction:[[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeStopRecord param:6 ]];
    //mode change
    self.waypointMission.flightPathMode = DJIWaypointMissionFlightPathCurved;
    
    self.waypointMission.maxFlightSpeed = [self.waypointConfigVC.maxFlightSpeedTextField.text floatValue];
    self.waypointMission.autoFlightSpeed = [self.waypointConfigVC.autoFlightSpeedTextField.text floatValue];
    self.waypointMission.headingMode = (DJIWaypointMissionHeadingMode)self.waypointConfigVC.headingSegmentedControl.selectedSegmentIndex;
    self.waypointMission.finishedAction = (DJIWaypointMissionFinishedAction)self.waypointConfigVC.actionSegmentedControl.selectedSegmentIndex;
    self.waypointMission.rotateGimbalPitch = YES;


    //PrepareMission
    //have fun? here wei gou!
    [self.missionManager prepareMission:self.waypointMission withProgress:^(float progress) {
        //Do something with progress
    } withCompletion:^(NSError * _Nullable error) {
        if (error){
            NSString* prepareError = [NSString stringWithFormat:@"Prepare Mission failed:%@", error.description];
            ShowMessage(@"ERROR!", prepareError, nil, @"OK");
        }else {
            ShowMessage(@"Have Fun!", @"Prepare Mission Finished", nil, @"OK");
        }
    }];
    
    }//valid waypoint number else
    

}


#pragma mark - Staff
- (NSString *)formattingSeconds:(int)seconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSString *formattedTimeString = [formatter stringFromDate:date];
    return formattedTimeString;
}

//logging status while in shooting mode

- (void)logDroneStatuswhileShooting {
    
    self.numOfRecords += 1;
    AircraftStatusPacket pack;
    
    pack.longitude = self.earthdroneLocation.longitude;
    pack.latitude = self.earthdroneLocation.latitude;
    //altitude + haiba(mobile device)
    //记录的是海拔
    pack.altitude = self.logAircraftAltitude + self.logHomeAltitude;
    
    pack.gimbalPitch = self.logGimbalAttitude.pitch;
    pack.gimbalYaw = self.logGimbalAttitude.yaw;
    pack.gimbalRoll = self.logGimbalAttitude.roll;
    
    pack.AircraftPitch = self.logAircraftAttitude.pitch;
    pack.AircraftYaw = self.logAircraftAttitude.yaw;
    pack.AircraftRoll = self.logAircraftAttitude.roll;
    
    pack.Vx = self.logVelocityX;
    pack.Vy = self.logVelocityY;
    pack.Vz = self.logVelocityZ;
    
    NSString *dataString = [NSString stringWithFormat: @"%05d\t%@\t%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n", self.numOfRecords, [DDTTYLogger nowString], pack.longitude, pack.latitude, pack.altitude,
                            pack.gimbalPitch, pack.gimbalYaw, pack.gimbalRoll,
                            pack.AircraftPitch, pack.AircraftYaw, pack.AircraftRoll,
                            pack.Vx, pack.Vy, pack.Vz];
    [self.statusRecords addObject:dataString];
    
}

-(void) logAdditionalCaptureInformation {
    //    self.currentCameraAttitudeInAngles.text = self.topBarVC.cameraHeadingLabel.text;
    
    self.numOfPicsTaken += 1;
    //TODO
    //write into files
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExit = [manager fileExistsAtPath:self.keyShotsFileName];
    
    if (!isExit) {
        NSLog(@"文件不存在，创建中\n");
        NSString *comment = [NSString stringWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\n", @"#ID", @"time", @"lon", @"lat", @"altitude", @"GPitch", @"GYaw", @"GRoll", @"DPitch", @"DYaw", @"DRoll", @"Vx", @"Vy", @"Vz"];
        if(![comment writeToFile:self.keyShotsFileName atomically:YES encoding:NSUTF8StringEncoding error:nil])
            NSLog(@"FAILED to create file!\n");
        else{
            NSLog(@"file name: %@\n", self.keyShotsFileName);
            NSLog(@"GUIDE: %@\n", comment);
            [self.narratives addObject:comment];
        }
    }
    
    NSFileHandle *keyShotsHandle = [NSFileHandle fileHandleForWritingAtPath:self.keyShotsFileName];
    if (!keyShotsHandle) {
        NSLog(@"文件打开失败！\n");
    }
    [keyShotsHandle seekToEndOfFile];
    //记录的是海拔，不是相对起飞点高度
    NSString *one_shot = [NSString stringWithFormat:@"%03d\t%@\t%10.7f%10.7f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n", self.numOfPicsTaken, [DDTTYLogger nowString], self.earthdroneLocation.longitude, self.earthdroneLocation.latitude, self.logAircraftAltitude + self.logHomeAltitude,  self.logGimbalAttitude.pitch, self.logGimbalAttitude.yaw, self.logGimbalAttitude.roll,
                          self.logAircraftAttitude.pitch, self.logAircraftAttitude.yaw, self.logAircraftAttitude.roll, self.logVelocityX, self.logVelocityY,
                          self.logVelocityZ];
    NSLog(@"shot #%d:\n%@", self.numOfPicsTaken, one_shot);
    [self.narratives addObject:one_shot];
    NSString *text = self.narratives.firstObject;
    text = [text stringByAppendingString:[self.narratives lastObject]];
    
    
    NSData *buffer;
    buffer = [one_shot dataUsingEncoding:NSUTF8StringEncoding];
    
    [keyShotsHandle writeData:buffer];
    [keyShotsHandle closeFile];
    
}

- (void) initKeyFrameLogFileName{
    //set keyShots file name to current second
    //CaptureLog-YYYY-MM-ddThh:mm:ss.txt
    NSString *nowString = [DDTTYLogger nowString];
    NSString *prefix = @"CaptureLog";
    NSString *postfix = @"txt";
    NSString *filename = [NSString stringWithFormat:@"%@-%@.%@", prefix, nowString, postfix];
    //set key shots log file path
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0];
    
    self.keyShotsFileName = [documentDirectory stringByAppendingPathComponent:filename];
    
    NSLog(@"$FILENAME: %@\n", self.keyShotsFileName);
    
}

- (void) initRecordLogFileName{
    NSString *nowString = [DDTTYLogger nowString];
    NSString *prefix = @"VideoLog";
    NSString *postfix = @"txt";
    NSString *filename = [NSString stringWithFormat:@"%@-%@.%@", prefix, nowString, postfix];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0];
    
    self.recordFileName = [documentDirectory stringByAppendingPathComponent:filename];
}
@end
