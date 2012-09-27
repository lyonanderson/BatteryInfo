//
//  ELViewController.m
//  BatteryInfo
//
//  Created by Christopher Anderson on 27/09/2012.
//  Copyright (c) 2012 Christopher Anderson. All rights reserved.
//

#import "ELViewController.h"

@interface OSDBattery : NSObject
+ (id) sharedInstance;
- (id)_getChargerType;
- (NSString*)_getBatteryID;
- (id)_getBatteryManufacturer;
- (id)_getBatterySerialNumber;
- (BOOL)_deviceIsCharging;
- (BOOL)_exactDeviceChargerConnected;
- (BOOL)_deviceChargerConnected;
- (int)_getRawBatteryVoltage;
- (int)_getBatteryCycleCount;
- (int)_getBatteryDesignCapacity;
- (int)_getBatteryLevel;
- (int)_getChargerID;
- (int)_getChargerCurrent;
- (BOOL)_externalPowerConnected;
- (int)_getBatteryMaxCapacity;
- (int)_getBatteryCurrentCapacity;
- (unsigned int)_getIOPMPowerSourceService;
- (id)_batteryID;
@end


@interface ELViewController ()
@property (nonatomic, strong) NSDictionary *batteryInfo;
@property (nonatomic, strong) NSTimer *refreshTimer;
@end

@implementation ELViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initBatteryInfo];
    }
    return self;
}

- (void)dealloc {
    [self.refreshTimer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.title = @"Battery Info";
}

- (void) viewDidAppear:(BOOL)animated {
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshBatteryInfo:) userInfo:nil repeats:YES];
}

- (void) refreshBatteryInfo:(NSTimer*)timer {
    [self initBatteryInfo];
    [self.tableView reloadData];
}

#pragma mark BatteryInfo

- (void) initBatteryInfo {
    NSBundle *b = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/GAIA.framework"];
    BOOL success = [b load];
    
    if (success) {
        Class OSDBattery = NSClassFromString(@"OSDBattery");
        id powerController = [OSDBattery sharedInstance];
        
        NSMutableDictionary *batteryInfo = [NSMutableDictionary dictionary];

        
        [batteryInfo setObject:[NSString stringWithFormat:@"%d", [powerController _getRawBatteryVoltage]] forKey:@"Raw Voltage"];
        [batteryInfo setObject:[NSString stringWithFormat:@"%d", [powerController _getBatteryLevel]] forKey:@"Battery Level"];
        [batteryInfo setObject:[NSString stringWithFormat:@"%d", [powerController _getBatteryCurrentCapacity]] forKey:@"Current Capacity"];
        [batteryInfo setObject:[NSString stringWithFormat:@"%d", [powerController _getBatteryDesignCapacity]] forKey:@"Design Capacity"];
        [batteryInfo setObject:[NSString stringWithFormat:@"%d", [powerController _getBatteryCycleCount]] forKey:@"Cycle Count"];
        [batteryInfo setObject:[NSString stringWithFormat:@"%d", [powerController _getChargerID]] forKey:@"Charger ID"];
        [batteryInfo setObject:[NSString stringWithFormat:@"%d", [powerController _getChargerCurrent]] forKey:@"Charger Current"];
        [batteryInfo setObject:[powerController _externalPowerConnected] ? @"Yes" : @"No" forKey:@"External Power"];
        [batteryInfo setObject:[powerController _deviceIsCharging] ? @"Yes" : @"No"  forKey:@"Device Charging"];
        [batteryInfo setObject:[powerController _deviceChargerConnected] ? @"Yes" : @"No" forKey:@"Device Charger Connected"];
        [batteryInfo setObject:[powerController _exactDeviceChargerConnected] ? @"Yes" : @"No" forKey:@"Exact Device Charger"];
        [batteryInfo setObject:[powerController _batteryID] forKey:@"Battery ID"];
        [batteryInfo setObject:[powerController _getBatterySerialNumber] forKey:@"Serial Number"];
        [batteryInfo setObject:[powerController _getBatteryManufacturer]  forKey:@"Manufacturer"];
        [batteryInfo setObject:[powerController _getChargerType] forKey:@"Charger Type"];
        [batteryInfo setObject:[NSString stringWithFormat:@"%d", [powerController _getRawBatteryVoltage]] forKey:@"Raw Voltage"];

        self.batteryInfo = batteryInfo;
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.batteryInfo count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"BatteryInfoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *title = [[self.batteryInfo allKeys] objectAtIndex:indexPath.row];
    NSString *detail = [[self.batteryInfo allValues] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    
    return cell;
}


@end
