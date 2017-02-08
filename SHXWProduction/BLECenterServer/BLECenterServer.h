//
//  BLECenterServer.h
//  SHXWProduction
//
//  Created by zivInfo on 16/7/14.
//  Copyright © 2016年 xiwangtech.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//扫描后数据的返回
typedef void (^blacksScanPeriperalInfos)(NSMutableArray *pinfos);

@interface BLECenterServer : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

//手机系统蓝牙状态
@property (nonatomic, assign, readonly, getter=isOff)BOOL systemBLEOpenStatus;

+(BLECenterServer *)sharedBLECenterServer;

//停止扫描
-(void)stop;

//中心设备扫描外设的方法
-(void)scanDevices:(blacksScanPeriperalInfos)blacksScanPeriperalInfos;

@end
