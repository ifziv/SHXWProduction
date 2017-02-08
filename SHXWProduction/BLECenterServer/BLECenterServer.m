//
//  BLECenterServer.m
//  SHXWProduction
//
//  Created by zivInfo on 16/7/14.
//  Copyright © 2016年 xiwangtech.com. All rights reserved.
//

#import "BLECenterServer.h"

@interface BLECenterServer ()
{
    blacksScanPeriperalInfos  _blackPeriperalInfos;   //扫描后数据的返回
}

@property (nonatomic, strong)CBCentralManager  *centralManager;   //当前的中心设备
@property (nonatomic, strong)NSMutableArray    *periperalAry;     //存外设Mac

@end

@implementation BLECenterServer

+(BLECenterServer *)sharedBLECenterServer
{
    static BLECenterServer *bleCenterServer = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        bleCenterServer = [[self alloc] init];
        [bleCenterServer initBLE];
    });
    return bleCenterServer;
}

-(void)initBLE
{
    self.periperalAry = [NSMutableArray arrayWithCapacity:1];
}

//扫描设备供外部调用
-(void)scanDevices:(blacksScanPeriperalInfos)blacksScanPeriperalInfos
{
    if (self.centralManager == nil) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    else {
        if ([self respondsToSelector:@selector(scan)]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scan) object:nil];
            [self performSelector:@selector(scan) withObject:nil afterDelay:2.0f];
        }
    }
    self.centralManager.delegate = self;
    _blackPeriperalInfos = blacksScanPeriperalInfos;
    [self.periperalAry removeAllObjects];

}

//扫描设备
-(void)scan
{
    //扫描之前先停止上一次扫描行为
    [self stop];
    
    //开始调用系统方法扫描服务
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
//    [self performSelector:@selector(scanTimeout) withObject:nil afterDelay:10.0f];
}

//停止扫描设备
-(void)stop
{
    [self.centralManager stopScan];
}

//扫描超时调用
-(void)scanTimeout
{
    [self stop];
    _blackPeriperalInfos(self.periperalAry);
}

#pragma mark -
#pragma mark - CBCentralManagerDelegate && CBPeripheralDelegate
//检查Phone的蓝牙状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        _systemBLEOpenStatus = YES;
        return;
    }
    _systemBLEOpenStatus = NO;
    
    //开始扫描
    [self scan];
}

//扫描到的蓝牙广播信息
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSMutableString *advertisementStr = [[NSMutableString alloc] initWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]];
    NSString *macAddressStr = [[self getMacAddress:advertisementStr] uppercaseString];
    if (![macAddressStr isEqual:nil] && ![macAddressStr isEqualToString:@""]) {
        [self.periperalAry addObject:macAddressStr];
    }
    _blackPeriperalInfos(self.periperalAry);
}

//解析出MAC地址
- (NSMutableString *)getMacAddress:(NSMutableString *)macStr
{
    NSMutableString *MacAddressStr = [[NSMutableString alloc] init];
    if (macStr.length >= 14) {
        
        NSRange range = NSMakeRange(0, 14);
        
        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"%@",[macStr substringWithRange:range]];
        
        NSRange rang2 = NSMakeRange(0, str.length);
        [str replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:rang2];
        
        for (NSInteger i = str.length - 2; i > 0; i--,i--) {
            
            NSRange rang3 = NSMakeRange(i, 2);
            NSString *str3 = [str substringWithRange:rang3];
            NSString *str4 = MacAddressStr.length ? @":" : @"";
            [MacAddressStr appendString:[NSString stringWithFormat:@"%@%@",str4,str3]];
        }
    }
    return MacAddressStr;
}


@end
