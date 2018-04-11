//
//  ViewController.m
//  BlueTooth
//
//  Created by apple on 2018/3/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID @"CDD1"
#define CHARACTERISTIC_UUID @"CDD2"

// 外设
@interface ViewController ()<CBPeripheralManagerDelegate>
@property (nonatomic,strong) CBPeripheralManager *peripheralManager;//蓝牙外设管理
@property (nonatomic,strong) CBMutableCharacteristic *characteristic;
@property (nonatomic,strong) UITextField *textField;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self  setupUI];
    // 当进行初始化的时候 会回调判断当前蓝牙状态
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}
- (void)setupUI{
    self.textField = [[UITextField alloc] init];
    self.textField.frame = CGRectMake(100, 100, 200, 30);
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.textColor = [UIColor blackColor];
    [self.view addSubview:self.textField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"发送" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(150, 150, 100, 30);
    [button addTarget: self action:@selector(postData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
// 通过固定的特征发送数据到中心设备
- (void)postData{
    BOOL sendSuccess = [self.peripheralManager updateValue:[self.textField.text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.characteristic onSubscribedCentrals:nil];
    if(sendSuccess){
        NSLog(@"数据发送成功");
    }else{
        NSLog(@"数据发送失败");
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    /*
     设备的蓝牙状态
     CBManagerStateUnknown = 0,  未知
     CBManagerStateResetting,    重置中
     CBManagerStateUnsupported,  不支持
     CBManagerStateUnauthorized, 未验证
     CBManagerStatePoweredOff,   未启动
     CBManagerStatePoweredOn,    可用
     */
    
    if(peripheral.state == CBManagerStatePoweredOn){
        //创建Service(服务)和特征（Characteristics）
        [self setupServiceAndCharacteristics];
        // 根据服务的UUID开始广播
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SERVICE_UUID]]}];
    }
}

#pragma mark -创建服务和特征
- (void)setupServiceAndCharacteristics{
    // 创建服务
    CBUUID *serviceID = [CBUUID UUIDWithString:SERVICE_UUID];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceID primary:YES];
    
    CBUUID *characteristicID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    
    // 只有设置了CBCharacteristicPropertyNotify这个参数，在（center）中心设备才能订阅这个特征
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicID properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    //将特征添加到服务
    service.characteristics = @[characteristic];
    // 服务添加到管理中心取
    [self.peripheralManager addService:service];
    
    // 为了手动给中心设备发送数据
    self.characteristic = characteristic;
}

// 当中心设备读取到这个外设的数据的时候会回调这个方法（也就是说中心设备主动接收外设的数据时，会走这个方法，外设就把要发送的数据给中心设备）
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    // 请求中的数据，这里把文本框的数据发给中心设备
    request.value = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
    // 成功响应请求
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

// 当中心设备往外设写入数据的时候，回调这个方法
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests{
    // 写入数据的请求
    CBATTRequest *request = requests.lastObject;
    // 把写入的数据显示在文本框中
    self.textField.text = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
}
// 中心设备订阅成功的回调（Subscribe == 订阅）
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
