//
//  JOBTSecondViewController.m
//  BTDemo
//
//  Created by ble on 14-10-31.
#import <Foundation/Foundation.h>//

#import "JOBTSecondViewController.h"
#import "Print.h"
int cmd=0;
extern CBPeripheral *activeDevice;
id<CBPeripheralDelegate> deviceDelegate=nil;

@interface JOBTSecondViewController ()

@end

@implementation JOBTSecondViewController

@synthesize textView_SendData;
@synthesize statusText;
- (void)viewDidLoad
{
    [super viewDidLoad];
	 
    deviceDelegate = self;
    if(activeDevice)
    {
        activeDevice.delegate = deviceDelegate;
    }

}
- (void)viewDidAppear:(BOOL)animated
{
    deviceDelegate = self;
    if(activeDevice)
    {
        activeDevice.delegate = deviceDelegate;
    }
}

- (void)viewDidUnload
{
    
    [self setTextView_SendData:nil];
    [super viewDidUnload];
		
    /*if(activeDevice)
    {
        activeDevice.delegate = nil;
    }*/
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (IBAction)buttonCompleteInputContent:(id)sender {

    [textView_SendData resignFirstResponder];
}

- (IBAction)buttonSend:(id)sender {
    NSData* data;
    if(activeDevice!=nil && activeDevice.state==CBPeripheralStateConnected)
    {
       
        if (isSwitchOn)//16进制数据,hex->NSData
        {
            NSLog(@"text=%d",[textView_SendData.text length]);
            if (([textView_SendData.text length]%2)!=0 )
            {
                [self alertMessage:@"请输入偶数个字符a-f/A-F，0-9"];
                return;
            }
            
            Byte bt[[textView_SendData.text length]/2];
            for (int i=0;i<[textView_SendData.text length];i=i+2)
            {
                int result=0;
                unichar ch = [textView_SendData.text characterAtIndex:i];
                if (ch>='0' && ch<='9') result = (ch-'0')*16;
                else if (ch>='a' && ch<='f') result = (ch-'a'+10)*16;
                else if (ch>='A' && ch<='F') result = (ch-'A'+10)*16;
                else
                {
                    [self alertMessage:@"请输入16进制字符a-f/A-F，0-9"];
                    return;
                }
                ch = [textView_SendData.text characterAtIndex:(i+1)];
                if (ch>='0' && ch<='9') result += (ch-'0');
                else if (ch>='a' && ch<='f') result += (ch-'a'+10);
                else if (ch>='A' && ch<='F') result += (ch-'A'+10);
                else
                {
                    [self alertMessage:@"请输入16进制字符a-f/A-F，0-9"];
                    return;
                }

                bt[i/2]=result;
            }
            data = [[NSData alloc]initWithBytes:bt length:[textView_SendData.text length]/2];
            NSLog(@"data=%@",data);
        }
        else//文本数据
        {
            //转换成GB2312编码之后，再发送给打印机,否则打印机无法打印
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            data=[textView_SendData.text dataUsingEncoding:enc];
            if(data == nil)
            {//转换失败的话，我们转换为UTF8编码，但这个时候只能够打印英文字母
                data = [textView_SendData.text dataUsingEncoding:NSUTF8StringEncoding];
            }
        }
       
        

        if(![Print printBin:data])
        {
            [self alertMessage:@"发送数据失败"];
        }
        
       
    }
    else {
        [self alertMessage:@"请连接设备后再发送数据"];
    }
}

- (IBAction)buttonClear:(id)sender {
    self.textView_SendData.text = nil;

    self.statusText.text = nil;
    
}

//页模式下页的大小跟具体型号有关，demo的这个版本x最大为576，y为350
- (IBAction)buttonPageModePrint:(id)sender
{
	
    //定义页：水平偏移从0开始，水平和垂直分辨率为203，页高为350
    [Print printTxt:@"! 0 200 200 350 1\n"];
    //居中:从text命令的x起始到行末结束计算居中位置
    [Print printTxt:@"CENTER\n"];
    //倍高倍宽
    [Print printTxt:@"TEXT 24 11 0 0 打印机打印测试\n"];
    //靠左，正常一文本行占32点行
    [Print printTxt:@"LEFT\n"];
    [Print printTxt:@"TEXT 24 0 150 96 中华\n"];
    [Print printTxt:@"TEXT 24 0 150 128 人民共和国\n"];
    [Print printTxt:@"TEXT 24 0 150 160 万岁！\n"];
    //打印二维码:范围M 2，倍数U 6，位置 (x,y)=(276,64)
    [Print printTxt:@"B QR 276 64 M 2 U 6\n"];
    //纠错等级M，自动选择版本号
    [Print printTxt:@"QA,http://www.china.cn-中国\n"];
    [Print printTxt:@"ENDQR\n"];
    //页定义结束，开始真正打印
    [Print printTxt:@"PRINT\n"];
    //走纸几行-非页模式指令
    [Print printTxt:@"打印结束\n\n\n\n\n\n"];
    
}

- (IBAction)buttonPrintPNGorJPG:(id)sender
{
//    [Print printTxt:@"\n打印图片！\n\n"];

    [Print printPNG_JPG:@"1.jpg"];
//    [Print printPNG_JPG:@"1.jpg"];

    //走纸几行-非页模式指令
    [Print printTxt:@"\n\n打印图片结束\n\n\n\n\n\n"];
}
- (IBAction)buttonPrintPage:(id)sender
{
    Byte bitmapLine1[]= {0x3f,0x3f,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x3f,0x3f};

    Byte bitmapLine2[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine3[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine4[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine5[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine6[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine7[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine8[]= {0xfc,0xfc,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0xfc,0xfc};
    

    NSData *data;
    
    //居中打印，对齐指令需要在行首发
    [Print printAlignCenter];
    BOOL ret=[Print printTxt:@"打印机打印测试\n\n\n"];
    if (ret!=YES) NSLog(@"ret fail");

    [Print printAlignCenter];
    [Print printTxt:@"调用1b 61 1居中打印\n居中打印\n居中打印\n\n\n\n"];

    
    //靠右打印
    [Print printAlignRight];

    [Print printTxt:@"调用1b 61 2靠右打印\n靠右打印\n靠右打印\n\n\n\n"];

    //靠左打印
    [Print printAlignLeft];
    [Print printTxt:@"调用1b 61 0恢复靠左打印\n靠左打印\n靠左打印\n\n\n"];
    
    //加大行距ESC 3 n(1b 33 n)
    [Print setLineHeight:255];
    [Print printTxt:@"调用ESC 3 n加大行距\n加大行距\n加大行距\n"];
    [Print restoreDefaultLineHeight];
    [Print printTxt:@"调用ESC 2恢复默认行距\n恢复默认行距\n恢复默认行距\n\n\n\n"];
    
    
    //设置标准ascii字符加粗、倍高、倍宽、下划线打印
    [Print printTxt:@"调用ESC ! n 设置标准ascii字符加粗、倍高、倍宽、下划线打印\n"];
    [Print setAsciiWordFormat:0 bold:YES doubleHeight:YES doubleWidth:YES underline:YES];
    [Print printTxt:@"12345abcdefghijklmnopq\n"];
    [Print printTxt:@"12345abcdefghijklmnopq\n"];
    [Print printTxt:@"12345abcdefghijklmnopq\n"];
    
    //清除标准ascii字符加粗、倍高、倍宽、下划线打印
    [Print setAsciiWordFormat:0 bold:NO doubleHeight:NO doubleWidth:NO underline:NO];
    [Print printTxt:@"调用ESC ! n 清除标准ascii字符加粗、倍高、倍宽、下划线打印\n"];
    [Print printTxt:@"12345abcdefghijklmnopq\n"];
    [Print printTxt:@"1234567890abcdefghijklmnopq\n"];
    [Print printTxt:@"1234567890abcdefghijklmnopq\n\n\n"];
    
    
    //设置汉子字符加粗、倍高、倍宽、下划线打印
    [Print printTxt:@"调用FS ! n设置倍高、倍宽、下划线打印\n"];
    [Print setChineseWordFormat:YES doubleWidth:YES underline:YES];
    [Print printTxt:@"汉字打印测试\n"];
    [Print printTxt:@"汉字打印测试\n"];
    [Print printTxt:@"汉字打印测试\n"];
    
    //清除汉子字符加粗、倍高、倍宽、下划线打印
    [Print setChineseWordFormat:NO doubleWidth:NO underline:NO];
    [Print printTxt:@"调用FS ! n清除倍高、倍宽、下划线打印\n"];
    [Print printTxt:@"打印机汉字打印测试\n"];
    [Print printTxt:@"打印机汉字打印测试\n"];
    [Print printTxt:@"打印机汉字打印测试\n\n\n"];


    
    [Print printAlignCenter];
    //打印一个位图
    [Print printTxt:@"打印位图\n"];
    [Print setLineHeight:0];       //设置行间距为0
    //NSLog(@"bitmaplength=%d",sizeof(bitmap));
    data=[[NSData alloc] initWithBytes:bitmapLine1 length:sizeof(bitmapLine1)];
    [Print printBitMap:0 bitmap:data];
    [Print printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine2 length:sizeof(bitmapLine2)];
    [Print printBitMap:0 bitmap:data];
    [Print printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine3 length:sizeof(bitmapLine3)];
    [Print printBitMap:0 bitmap:data];
    [Print printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine4 length:sizeof(bitmapLine4)];
    [Print printBitMap:0 bitmap:data];
    [Print printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine5 length:sizeof(bitmapLine5)];
    [Print printBitMap:0 bitmap:data];
    [Print printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine6 length:sizeof(bitmapLine6)];
    [Print printBitMap:0 bitmap:data];
    [Print printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine7 length:sizeof(bitmapLine7)];
    [Print printBitMap:0 bitmap:data];
    [Print printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine8 length:sizeof(bitmapLine8)];
    [Print printBitMap:0 bitmap:data];
    [Print printTxt:@"\n"];
    [Print restoreDefaultLineHeight];   //恢复行间距
    [Print printTxt:@"\n\n\n"];
    
    //打印一维条码
    [Print printTxt:@"打印一维条码\n"];
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    data=[@"1234567890" dataUsingEncoding:enc];
    
    [Print print1DBarCode:POS_BT_CODE39 width:2 height:150 txtpositon:POS_BT_HT_DOWN content:data];
    
    data=[@"12345" dataUsingEncoding:enc];
    
    [Print print1DBarCode:POS_BT_CODE39 width:2 height:150 txtpositon:POS_BT_HT_DOWN content:data];
    
    //打印二位条码
    [Print printTxt:@"打印二维条码\n"];
    data=[@"www.sina.com-中国" dataUsingEncoding:enc];
    [Print print2DBarCode:POS_BT_PDF417 para1:2 para2:6 para3:1 content:data];
    
    data=[@"www.sina.com-北京市" dataUsingEncoding:enc];
    [Print print2DBarCode:POS_BT_DATAMATRIX para1:40 para2:40 para3:4 content:data];
    
    data=[@"www.sina.com-石家庄" dataUsingEncoding:enc];
    [Print print2DBarCode:POS_BT_QRCODE para1:2 para2:77 para3:4 content:data];
    
    //
    [Print printTxt:@"\n\n\n\n切纸\n"];
    [Print cutPaper:0 feed_distance:0];
    
    [Print printTxt:@"打印测试完毕！\n\n\n\n\n\n"];
    [Print printAlignLeft];
    [Print printTxt:@"\n"];
    
}
- (IBAction)buttonQuery:(id)sender
{
    NSLog(@"call QueryStatus");
    BOOL state = [Print sendCheckPaperOutCmd];
    if (!state) statusText.text = @"网络或通讯异常！";
}
- (IBAction)switchAction:(id)sender
{
    UISwitch *switchButton=(UISwitch *)sender;
    isSwitchOn = [switchButton isOn];
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"enter didUpdateValueForCharacteristic!");
    NSData *data = characteristic.value; 
    NSLog(@"secondview:read data=%@!",data);
    

    const Byte *res =[data bytes];
    char hex_resp[[data length]*2+1];
    char temp[3];
    memset(hex_resp, 0, [data length]*2+1);
    memset(temp,0,3);
    
    switch (cmd)
    {
        
        case DLE_EOT_1:
            
            if (res[0] & 0x08) statusText.text=@"脱机";
            else  statusText.text=@"正常";
            break;
        
        case DLE_EOT_3:
            if (res[0] & 0x68) statusText.text=@"打印机错误";
            else  statusText.text=@"正常";
            break;
        case DLE_EOT_4:
            if (res[0] & 0x60) statusText.text=@"缺纸";
            else  statusText.text=@"正常";
            break;
        default:
        
            for (int i=0;i<[data length];i++)
            {
               
                sprintf(temp,"%02x",res[i]);
                strcat(hex_resp,temp);
            }
            statusText.text=[NSString stringWithUTF8String:hex_resp];
            break;
    }
    cmd = 0;
    
}



-(void) alertMessage:(NSString *)msg{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示" 
                                                   message:msg
                                                  delegate:self
                                         cancelButtonTitle:@"关闭" 
                                         otherButtonTitles:nil];
    [alert show];
    //[alert release];
    
}
@end


