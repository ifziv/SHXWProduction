//
//  RootViewController.m
//  SHXWProduction
//
//  Created by zivInfo on 16/7/14.
//  Copyright © 2016年 xiwangtech.com. All rights reserved.
//

#import "RootViewController.h"

#define SERVER_ADDRESS     @"http://112.124.50.236:3000/"
#define USER_REGISTER      @"/api/v1/devices"

@interface RootViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSString *name;
    NSString *type;
    NSString *model;
}

@property (nonatomic, strong)BLECenterServer   *BLECenter;         //蓝牙连接的类
@property (nonatomic, strong)NSMutableArray    *dataArray;         //总数据源(BLE)
@property (nonatomic, strong)NSMutableArray    *tempArray;         //临时数据(BLE)
@property (nonatomic, strong)NSMutableArray    *disbleArray;       //

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *typeTextField;
@property (strong, nonatomic) IBOutlet UITextField *modelTextField;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UIButton *updataButton;
@property (strong, nonatomic) IBOutlet UITableView *listTableView;

@end

@implementation RootViewController

-(BLECenterServer *)BLECenter
{
    if (_BLECenter == nil) {
        _BLECenter = [BLECenterServer sharedBLECenterServer];
    }
    return _BLECenter;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataArray;
}

- (NSMutableArray *)tempArray
{
    if (_tempArray == nil) {
        _tempArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _tempArray;
}

- (NSMutableArray *)disbleArray
{
    if (_disbleArray == nil) {
        _disbleArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _disbleArray;
}

- (IBAction)startAction:(UIButton *)sender
{
    //扫描蓝牙设备
    if ([self respondsToSelector:@selector(scanBLE:)]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanBLE:) object:@"正在扫描.."];
        [self performSelector:@selector(scanBLE:) withObject:@"正在扫描.." afterDelay:0.20f];
    }
}

- (IBAction)stopAction:(UIButton *)sender
{
    [self.BLECenter stop];
}

- (IBAction)updataAction:(UIButton *)sender
{
    NSLog(@"%@ %@ %@", name, type, model);
    
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] init];
    
    NSDictionary *dic = @{@"token":@"0aab52bfa3b958314bc316a7bd94ef21",
                          @"mac_address":@"20:91:48:52:F9:26",
                          @"product_vendor":@"测试",
                          @"device_type":[NSNumber numberWithInteger:1],
                          @"device_model":[NSNumber numberWithInteger:1]};
    
    [sessionManager POST:[NSString stringWithFormat:@"%@%@", SERVER_ADDRESS, USER_REGISTER] parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"%@", responseObject);
        NSLog(@"success..");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error..");
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"烯旺信息生产工具";
    
    [self initButton];
}

-(void)initButton
{
    self.nameTextField.tag = 100001;
    self.nameTextField.placeholder = @"请输入批次的名字..";
    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.typeTextField.tag = 100002;
    self.typeTextField.placeholder= @"请输入设备的类型..";
    self.typeTextField.returnKeyType = UIReturnKeyDone;
    self.typeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

    self.modelTextField.tag = 100003;
    self.modelTextField.placeholder = @"请输入设备的型号..";
    self.modelTextField.returnKeyType = UIReturnKeyDone;
    self.modelTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    self.startButton.layer.masksToBounds = YES;
    self.startButton.layer.cornerRadius = 4.0;
    self.startButton.layer.borderWidth = 1.0;
    self.startButton.layer.borderColor = [UIColor colorWithRed:73.0/255.0 green:189.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor;
    
    self.stopButton.layer.masksToBounds = YES;
    self.stopButton.layer.cornerRadius = 4.0;
    self.stopButton.layer.borderWidth = 1.0;
    self.stopButton.layer.borderColor = [UIColor colorWithRed:73.0/255.0 green:189.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor;
    
    self.updataButton.layer.masksToBounds = YES;
    self.updataButton.layer.cornerRadius = 4.0;
    self.updataButton.layer.borderWidth = 1.0;
    self.updataButton.layer.borderColor = [UIColor colorWithRed:73.0/255.0 green:189.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor;
}

#pragma mark -
#pragma mark -
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 100001)
        name = textField.text;
    else if (textField.tag == 100002)
        type = textField.text;
    else if (textField.tag == 100003)
        model = textField.text;
}

//按下Done按钮的调用方法，我们让键盘消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark -
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"TableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier: SimpleTableIdentifier];
    }

    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -
#pragma mark - BLE info
-(void)scanBLE:(NSString *)title
{
    self.BLECenter = [BLECenterServer sharedBLECenterServer];
    
    if (!self.BLECenter.isOff) {
        [self.BLECenter scanDevices:^(NSMutableArray *pinfos) {
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:pinfos];
            
            [self.disbleArray removeAllObjects];
            
            [self.disbleArray addObjectsFromArray:pinfos];
            
            for (int j = 0; j < pinfos.count; j++) {
                for (NSString *macStr in self.tempArray) {
                    if ([macStr isEqualToString:pinfos[j]] && [self.disbleArray count] != 0) {
                        
                        [self.disbleArray removeObjectAtIndex:j];
                    }
                }
            }

            [self.tempArray addObjectsFromArray:pinfos];
            
            //控制刷新频率
            if ([self respondsToSelector:@selector(reloadDatas)]) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadDatas) object:nil];
                [self performSelector:@selector(reloadDatas) withObject:nil afterDelay:1.0f];
            }
        }];
    }
}

- (void)reloadDatas
{
    NSLog(@"data==> %@", self.disbleArray);

    [self.listTableView reloadData];
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

@end
