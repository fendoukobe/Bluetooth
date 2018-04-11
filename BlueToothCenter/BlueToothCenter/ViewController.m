//
//  ViewController.m
//  BlueToothCenter
//
//  Created by apple on 2018/3/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>


#define SERVICE_UUID        @"CDD1"
#define CHARACTERISTIC_UUID @"CDD2"

@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) CBCentralManager *centralManager;
@property (nonatomic,strong) CBPeripheral *peripheral;
@property (nonatomic,strong) CBCharacteristic *characteristic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    // options   @seealso        CBCentralManagerOptionShowPowerAlertKey 用于当中心管理类被初始化时若此时蓝牙系统为关闭状态，是否向用户显示警告对话框。该字段对应的是NSNumber类型的对象，默认值为NO
    //    @seealso        CBCentralManagerOptionRestoreIdentifierKey  中心管理器的唯一标识符，系统根据这个标识识别特定的中心管理器，为了继续执行应用程序，标识符必须保持不变，才能还原中心管理类
  // [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:nil];
    
    // 获取一个已知CBPeripheral的列表(过去曾经发现过或者连接过的peripheral)
    //self.centralManager retrievePeripheralsWithIdentifiers:<#(nonnull NSArray<NSUUID *> *)#>
    // 根据services 数据来检索所有连接在当前系统的外设，返回的是一个外设集合，这个集合也有可能包括了其他应用连接的外设，所以我们在用这些外设之前需要调用连接方法才能使用
    //self.centralManager retrieveConnectedPeripheralsWithServices:<#(nonnull NSArray<CBUUID *> *)#>
}

// 初始化蓝牙设备中心的时候会调用这个方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if(central.state == CBManagerStatePoweredOn){
        // 根据服务ID来扫描外设，如果不设置服务ID，则默认会扫描有所得蓝牙设备
        // options CBCentralManagerScanOptionAllowDuplicatesKey 是否允许重复扫描设备，默认为NO，官方建议此值为NO，当为YES时，可能对电池寿命产生影响，建议在必要时才使用
        
      /*  CBCentralManagerScanOptionSolicitedServiceUUIDsKey 想要扫描的服务的UUID，对应一个NSArray数值
        
        UUID 表示外设的服务标识，当serviceUUIDs参数为nil时，将返回所有发现的外设(苹果不推荐此种做法)；当填写改服务标识时，系统将返回对应该服务标识的外设
        
        可以指定允许应用程序在后台扫描设备，前提必须满足两个条件：
        
        必须允许在蓝牙的后台模式
        
        必须指定一个或多个UUID服务标识*/
        
        [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
    }else if(central.state == CBManagerStateUnsupported){
        NSLog(@"该设备不支持蓝牙");
    }else if(central.state == CBManagerStatePoweredOff){
        NSLog(@"蓝牙已关闭");
    }
}
/* 当系统恢复时先调用此方法
 
 *app状态的保存或者恢复，这是第一个被调用的方法当APP进入后台去完成一些蓝牙有关的工作设置，使用这个方法同步app状态通过蓝牙系统
 
 *
 
 * dic中的信息
 
 * CBCentralManagerRestoredStatePeripheralsKey 在系统终止程序时，包含的已经连接或者正在连接的外设的集合
 
 * CBCentralManagerRestoredStateScanServicesKey 系统终止应用程序时中心管理器连接的服务UUID数组
 
 * CBCentralManagerRestoredStateScanOptionsKey  系统终止应用程序时中心管理器正在使用的外设选项
 
 */
//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict{
    
//}

// 当扫描到外设之后，就会回调这个方法，我们可以在这个方法中继续设置筛选条件，例如根据外设名字的前缀来选择，如果符合条件则进行连接
/**
 advertisementData 广播中的信息
 
 * CBAdvertisementDataLocalNameKey 对应设置NSString类型的广播名
 
 * CBAdvertisementDataManufacturerDataKey 外设制造商的NSData数据
 
 * CBAdvertisementDataServiceDataKey  外设制造商的CBUUID数据
 
 * CBAdvertisementDataServiceUUIDsKey 服务的UUID与其对应的服务数据字典数组
 
 * CBAdvertisementDataOverflowServiceUUIDsKey 附加服务的UUID数组
 
 * CBAdvertisementDataTxPowerLevelKey 外设的发送功率 NSNumber类型
 
 * CBAdvertisementDataIsConnectable 外设是否可以连接
 
 * CBAdvertisementDataSolicitedServiceUUIDsKey 服务的UUID数组
 */
/**
 RSSI 收到当前信号的强度，单位分贝
 */

/** CBPeripheral
 name 外设的名称
 services 外设中所有的服务(必须先使用查找服务的方法先找到服务，该属性才有对应的值)
 state 当前连接的状态
 
 CBPeripheralStateDisconnected 当前没有连接
 
 CBPeripheralStateConnecting 正在连接
 
 CBPeripheralStateConnected 已连接
 
 CBPeripheralStateDisconnecting 正在断开连接
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    self.peripheral = peripheral;
    
    /*if([peripheral.name hasPrefix:@""]){
        
    }*/
    /* options CBConnectPeripheralOptionNotifyOnConnectionKey 应用程序被挂起时，成功连接到外设，是否向用户显示警告对话框，对应NSNumber对象，默认值为NO
     
     CBConnectPeripheralOptionNotifyOnDisconnectionKey 应用程序被挂起时，与外设断开连接，是否向用户显示警告对话框，对应NSNumber对象，默认值为NO
     
     CBConnectPeripheralOptionNotifyOnNotificationKey 应用程序被挂起时，只要接收到给定peripheral的通知，是否就弹框显示
     */
    /* 官方建议如果连接设备不成功且没有进行重连，要明确取消与外设的连接(即调用断开与外设连接的方法) 当调用断开方法，断开与设备连接时，官方明确表明取消本地连接不能保证物理链接立即断开。当设备连接时间超过8秒后，调用断开的API能立即断开；但是连接未超过8秒，就调用断开API需要几秒后系统才与设备断开连接
     */
    [self.centralManager connectPeripheral:peripheral options:nil];
}
// 当连接成功之后，为了省电，就让中心设备停止扫描，并且别忘记设置连接上的外设的代理，在这个方法里根据UUID进行服务的查找
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    // 停止扫描
    [self.centralManager stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
    NSLog(@"连接成功");
}

// 连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%@",error);
}
// 断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
}

#pragma mark - 处理CBPeripheralDelegate代理方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    // 遍历外设中所有的设备
    for (CBService *service in peripheral.services) {
        NSLog(@"所有服务: %@",service);
    }
    
    // 这里仅有一个服务，直接获取
    CBService *service = peripheral.services.lastObject;
    // 根据UUID姓赵服务中的特征,数组中是特征UUID的集合
    [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] forService:service];
    
}
// 发现特征的回调，当发现特征以后，与服务一样可以遍历特征，根据外设开发人员给出的文档找出不同特征，做出相应的操作
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    //peripheral.name
   // peripheral.services
   //peripheral.state
    /*
     
     * 当设置serviceUUIDs参数时，只返回指定的服务(官方推荐做法)
     
     * 当为指定serviceUUIDs参数为nil时，将返回外设中所有可用的服务
     
     */
    // [peripheral discoverServices:nil];
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"所有特征： %@",characteristic);
    }
    
    // 因为这里只有一个特征
    //写入数据的时候也需要用到这个特征
    self.characteristic = service.characteristics.lastObject;
    // 读取这个特征的数据， 会调用didUpdateValueForCharacteristic
    [peripheral readValueForCharacteristic:self.characteristic];
    // 对这个特征进行订阅，订阅成功之后，就可以监控外设中这个特征值的变化了
    [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
}

// 当订阅状态发生变化时
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
        NSLog(@"订阅失败");
        NSLog(@"%@",error);
    }else if(characteristic.isNotifying){
         NSLog(@"订阅成功");
    }else{
        NSLog(@"取消订阅");
    }
}


- (void)setupUI{
    self.textField = [[UITextField alloc] init];
    self.textField.frame = CGRectMake(100, 100, 200, 30);
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.textColor = [UIColor blackColor];
    [self.view addSubview:self.textField];
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton setTitle:@"发送" forState:UIControlStateNormal];
    [postButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    postButton.frame = CGRectMake(150, 150, 60, 30);
    [postButton addTarget: self action:@selector(postData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:postButton];
    UIButton *receiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [receiveButton setTitle:@"接收" forState:UIControlStateNormal];
    [receiveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    receiveButton.frame = CGRectMake(240, 150, 60, 30);
    [receiveButton addTarget: self action:@selector(receiveData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:receiveButton];
}

// 向外设发送数据或者请求，指令
// 首先把要写入的数据转化为NSData格式，然后根据上面拿到的写入数据的特征，运用方法writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type来进行数据的写入。
- (void)postData{
    NSData *data = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"写入成功");
}
// 接收数据
- (void)receiveData{
    [self.peripheral readValueForCharacteristic:self.characteristic];
}
//外设可以发数据给中心设备，中心设备也可以从外设读取数据(从外设接收到数据时)
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"接收外设的数据");
    NSData *data = characteristic.value;
    self.textField.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
