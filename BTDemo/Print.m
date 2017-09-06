//
//  Print.m
//  BTDemo
//
//  Created by ble on 14-10-31.
//
//

#import "Print.h"


extern CBPeripheral *activeDevice;
extern CBCharacteristic *activeWriteCharacteristic;
extern CBCharacteristic *activeReadCharacteristic;
extern int cmd;
@interface Print ()

@end
@implementation Print


+ (BOOL) printBin:(NSData *)bin
{
    if(activeDevice==nil || !activeDevice.state==CBPeripheralStateConnected) return NO;
    
    if ( isBuffedWrite == YES)
    {
        //NSLog(@"isBufferedWrite==YES");
        if (NO==[self putInBuf:bin])
        {
            NSLog(@"put bin=%@fail",bin);
            return NO;
        }
        else
        {
            if ( taskInRunning==NO )
            {
                taskInRunning = YES;
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(SendTask) userInfo:nil repeats:NO];
                NSLog(@"start sendTask");
                
            }
            return YES;
        }
    }
    else
    {
        NSLog(@"isBufferedWrite==NO");
        //if([activeDevice writeData:bin]) return YES;
        [activeDevice writeValue:bin forCharacteristic:activeWriteCharacteristic type:CBCharacteristicWriteWithResponse];
        //else return NO;
        return YES;
    }
}
+ (BOOL) printTxt:(NSString *)txt
{
    Boolean ret;
    if(activeDevice==nil || !activeDevice) return NO;
    
	NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* data=[txt dataUsingEncoding:enc];
    //Byte *b = (Byte*)[data bytes];
    if ( isBuffedWrite == YES)
    {
        
        if (NO==[self putInBuf:data])
        {
            NSLog(@"put data=%@fail",data);
            return NO;
        }
        else
        {
            if ( taskInRunning==NO )
            {
                taskInRunning = YES;
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(SendTask) userInfo:nil repeats:NO];
            }
            return YES;
        }
    }
    else
    {
    		
        /*ret=[activeDevice writeData:data];
        if(ret==true) return YES;
        return NO;*/
        [activeDevice writeValue:data forCharacteristic:activeWriteCharacteristic type:CBCharacteristicWriteWithResponse];
        return YES;
    }
}
+ (BOOL) printAlignCenter
{
    Byte byte[] = {0x1b,0x61,0x01};//打印居中
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) printAlignLeft
{
    Byte byte[] = {0x1b,0x61,0x00};//打印靠左
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) printAlignRight
{
    Byte byte[] = {0x1b,0x61,0x02};//打印靠右
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) sendCheckPaperOutCmd
{
    cmd = DLE_EOT_4;
    Byte byte[] = {0x10,0x04,0x04};//纸传感器状态指令
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) sendCheckOfflineCmd
{
    cmd = DLE_EOT_1;
    Byte byte[] = {0x10,0x04,0x01};//打印机状态指令
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) sendCheckErrorCmd
{
    cmd = DLE_EOT_3;
    Byte byte[] = {0x10,0x04,0x03};//错误状态指令
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) print2DBarCode:(int)type para1:(int)v para2:(int)r para3:(int)k content:(NSData*)data
{
    Byte byte[10];
    //发GS Z n选择条码类型
    byte[0]=0x1d;
    byte[1]=0x5a;
    byte[2]=type;
    
    //发ESC Z v r nl nh d1...dn
    byte[3]=0x1b;
    byte[4]=0x5a;
    byte[5]=v;
    byte[6]=r;
    byte[7]=k;
    byte[8]=[data length]%256;
    byte[9]=[data length]/256;
    
    NSData *cmd = [[NSData alloc] initWithBytes:byte length:10];
    if(![self printBin:cmd]) return NO;
    if(![self printBin:data]) return NO;
    return YES;

}
+ (BOOL) print1DBarCode:(int)type width:(int)w height:(int)h txtpositon:(int)positon content:(NSData*)data;
{
    Byte byte[13+[data length]];
    NSData * cmd;
    //发GS W n设置宽度
    byte[0]=0x1d;
    byte[1]=0x77;
    byte[2]=w;
    
    //发GS h n设置高度
    byte[3]=0x1d;
    byte[4]=0x68;
    byte[5]=h;
    
    //发GS H n设置文字位置
    byte[6]=0x1d;
    byte[7]=0x48;
    byte[8]=positon;
    
    if (type>=0 && type<=6)
    {
        //发GS k m d1...dk nul打印
        byte[9]=0x1d;
        byte[10]=0x6b;
        byte[11]=type;
        Byte *b=(Byte*)[data bytes];
        memcpy(byte+12,b,[data length]);
        byte[12+[data length]-1]=0x00;
        cmd = [[NSData alloc] initWithBytes:byte length:(12+[data length])];
    }
    else if (type>=65 && type<=73)
    {
        //发GS k m n d1...dn打印
        byte[9]=0x1d;
        byte[10]=0x6b;
        byte[11]=type;
        byte[12]=[data length];
        Byte *b=(Byte*)[data bytes];
        memcpy(byte+13,b,[data length]);
        cmd = [[NSData alloc] initWithBytes:byte length:(13+[data length])];
    }
    else return false;
    //NSLog(@"cmd=%@",cmd);
    if(![self printBin:cmd]) return NO;
    return YES;
    
}
+ (BOOL) printBitMap:(int)mode bitmap:(NSData*)bm
{
    Byte byte[5+[bm length]];
    NSData * cmd;
    //发ESC * m nl nh d1...dn(1b 2a m nl nh dl...dk)
    byte[0]=0x1b;
    byte[1]=0x2a;
    byte[2]=mode;
    byte[3]=[bm length]%256;
    byte[4]=[bm length]/256;
    
    Byte *b=(Byte*)[bm bytes];
    memcpy(byte+5, b, [bm length]);
    cmd = [[NSData alloc] initWithBytes:byte length:5+[bm length]];
    //NSLog(@"cmd=%@",cmd);
    if(![self printBin:cmd]) return NO;
    return YES;
}
+ (BOOL) setLineHeight:(int)n
{
    Byte byte[3];
    NSData * cmd;
    //发ESC 3 n(1b 33 n)
    byte[0]=0x1b;
    byte[1]=0x33;
    byte[2]=n;
    cmd = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:cmd]) return NO;
    return YES;

}
+ (BOOL) restoreDefaultLineHeight
{
    Byte byte[2];
    NSData * cmd;
    //发ESC 2 (1b 32)
    byte[0]=0x1b;
    byte[1]=0x32;
    cmd = [[NSData alloc] initWithBytes:byte length:2];
    if(![self printBin:cmd]) return NO;
    return YES;
   
}
+ (BOOL) setChineseWordFormat:(BOOL)isDoubleHeight doubleWidth:(BOOL)isDoubleWidth underline:(BOOL)isUnderLine
{
    Byte byte[3];
    NSData * cmd;
    //发FS ! n (1c 21 n)
    byte[0]=0x1c;
    byte[1]=0x21;
    byte[2]=0;
    if ( isDoubleHeight==YES ) byte[2] |= 0x08;
    else byte[2] &= 0xf7;
    
    if ( isDoubleWidth==YES ) byte[2] |= 0x04;
    else byte[2] &= 0xfb;
    
    if ( isUnderLine==YES ) byte[2] |= 0x80;
    else byte[2] &= 0xfb;
    
    cmd = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:cmd]) return NO;
    return YES;

    
}

+ (BOOL) setAsciiWordFormat:(int)type bold:(BOOL)isbold doubleHeight:(BOOL)isDoubleHeight doubleWidth:(BOOL)isDoubleWidth underline:(BOOL)isUnderLine
{
    Byte byte[3];
    NSData * cmd;
    //发ESC ! n (1b 21 n)
    byte[0]=0x1b;
    byte[1]=0x21;
    byte[2]=0;
    
    if ( type==1 ) byte[2] |= 0x01;
    
    if ( isbold==YES ) byte[2] |= 0x08;
    else byte[2] &= 0xf7;

    
    if ( isDoubleHeight==YES ) byte[2] |= 0x10;
    else byte[2] &= 0xef;
    
    if ( isDoubleWidth==YES ) byte[2] |= 0x20;
    else byte[2] &= 0xdf;
    
    if ( isUnderLine==YES ) byte[2] |= 0x80;
    else byte[2] &= 0xfb;

    cmd = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:cmd]) return NO;
    return YES;

}

+ (BOOL)setFont:(int)font {
    Byte byte[3];
    NSData *cmd;
    //ESC     M         n 1B         4D         n
    byte[0] = 0x1b;
    byte[1] = 0x4d;
    byte[2] = (Byte)font;
    cmd = [[NSData alloc] initWithBytes:byte length:3];
    if (![self printBin:cmd]) return NO;
    return YES;
}

+ (void) buffedWriteCtrl:(BOOL)isBuffed
{
    isBuffedWrite = isBuffed;
    NSLog(@"isbuffedWrite=%d",isBuffedWrite);
}

//head+1 point to first data postion,fetch start position
//tail point to last data positon positon,
+ (BOOL) putInBuf:(NSData *)data
{
    int dataLen = [data length];
    Byte *b = (Byte*)[data bytes];
    int emptyLen;
    
    if (tail>=head)
    {
        emptyLen=(BUF_SIZE-(tail-head));
        //NSLog(@"before head=%d,tail=%d,emptyLen=%d",head,tail,emptyLen);
        
        if ( emptyLen<dataLen ) return NO;//no place to put
        if ( (BUF_SIZE-tail-1)>=dataLen )
        {
            memcpy(sndBuf+tail+1, b, dataLen);
            tail +=dataLen;
            //if (tail>=BUF_SIZE) tail=0;
        }
        else
        {
            memcpy(sndBuf+tail+1, b, BUF_SIZE-tail-1);
            memcpy(sndBuf,b+BUF_SIZE-tail-1,dataLen-(BUF_SIZE-tail-1));
            tail=dataLen-(BUF_SIZE-tail-1)-1;
        }
    }
    else
    {
        emptyLen=head-tail;
        
        //NSLog(@"before head=%d,tail=%d,emptyLen=%d",head,tail,emptyLen);
        if (emptyLen<dataLen) return NO;//no place to put
        memcpy(sndBuf+tail+1, b, dataLen);
        tail += dataLen;
    }
    //NSLog(@"after head=%d,tail=%d",head,tail);
    return YES;
}
+ (NSData *)getFromBuf
{
    Byte b[GET_NUM];
    int dataLen=0,leftLen=0;
    if ( head == tail ) return nil;
    if ( head>tail)
    {
        if ( (BUF_SIZE-head-1)>=GET_NUM ) //have enough data,no wrap
        {
            dataLen = GET_NUM;
            memcpy(b, sndBuf+head+1, GET_NUM);
            head += GET_NUM;
        }
        else
        {
            dataLen = BUF_SIZE-head-1;
            if (dataLen>0) memcpy(b, sndBuf+head+1, dataLen);
            leftLen = GET_NUM - dataLen;
            
            if (leftLen>=(tail+1)) leftLen=tail+1;
            memcpy(b+dataLen, sndBuf, leftLen);
            dataLen += leftLen;
            head = leftLen-1;
        }
    }
    else
    {
        if ((tail-head)<GET_NUM ) dataLen=tail-head;
        else dataLen = GET_NUM;
        memcpy(b, sndBuf+head+1, dataLen);
        head += dataLen;
    }
    //NSLog(@"getfrom head=%d,tail=%d",head,tail);
    NSData *data = [[NSData alloc] initWithBytes:b length:dataLen];
    //[data retain];
    return data;
}

+ (BOOL) isBuffEmpty
{
    if ( head == tail ) return YES;
    else return NO;
}
+ (void) SendTask
{
    NSLog(@"SendTask started");
    int interval=0.1;
    
    NSData *data;
    if ( lastData!=nil )        //上次有发送失败的，优先发送
    {
        data = [[NSData alloc] initWithData:lastData];
        lastData=nil;
        //NSLog(@"datafromlast=%@",data);
    }
    else
        data = [self getFromBuf];
    // NSLog(@"getFromBuf=%@",data);
    
    if ( data==nil)
    {
        taskInRunning=NO;
        NSLog(@"stop SendTask");
        
    }
    else if ([data length] > 0 )
    {
        NSLog(@"datalen=%d",[data length]);
        //Boolean ret=[activeDevice writeData:data];
        [activeDevice writeValue:data forCharacteristic:activeWriteCharacteristic type:CBCharacteristicWriteWithResponse];
        Boolean ret=YES;
        {
            if (!ret)
            {
                
                NSLog(@"write data failed");
                lastData = [[NSMutableData alloc] initWithData:data];
                NSLog(@"lastData=%@ failed",lastData);
                interval = 1;
            }
            else interval=0.1;
        }
        if ( NO==[self isBuffEmpty] || lastData!=nil )
            [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(SendTask) userInfo:nil repeats:NO];
        else taskInRunning=NO;
    }
    
}
+ (BOOL) printPNG_JPG:(NSString *)filename
{

    Byte BayerPattern[8][8] =
				{
					 {0, 32,  8, 40,  2, 34, 10, 42},
					 {48, 16, 56, 24, 50, 18, 58, 26},
					 {12, 44,  4, 36, 14, 46,  6, 38},
					 {60, 28, 52, 20, 62, 30, 54, 22},
					 {3, 35, 11, 43,  1, 33,  9, 41},
					 {51, 19, 59, 27, 49, 17, 57, 25},
					 {15, 47,  7, 39, 13, 45,  5, 37},
					 {63, 31, 55, 23, 61, 29, 53, 21}
				 };

    UIImage *original = [UIImage imageNamed:filename];
    UIImage *image = [Print scaleWithFixedWidth:576 image: original];
//        UIImage *image = [UIImage imageNamed:filename];
		int imageWidth = image.size.width;
    int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);

	int	bytesPerLine = (imageWidth+7)/8;
    Byte bitmap[imageHeight][bytesPerLine];
    
    for (int i = 0; i < imageHeight; i++) 
			for (int j = 0; j < bytesPerLine; j++)
				bitmap[i][j] = 0;
				
		//遍历像素,生成打印点阵

    uint32_t* pCurPtr = rgbImageBuf;
    
    for (int i = 0; i < imageHeight; i++) 
    {
			for (int j = 0; j < imageWidth; j++)
			{
				int grey = pCurPtr[imageWidth*i+j];

				int red = ((grey & 0x00FF0000) >> 16);
				int green = ((grey & 0x0000FF00) >> 8);
				int blue = (grey & 0x000000FF);

				grey = (int) (red * 0.3 + green * 0.59 + blue * 0.11);
				if( (grey>>2)<BayerPattern[i%8][j%8] )
				{
					bitmap[i][j/8] |= 1<<(7-(j%8));
				}
			}
    }
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(rgbImageBuf);
    Byte lineData[(4+bytesPerLine)*imageHeight+6];
    NSLog(@"datesize=%d",(4+bytesPerLine)*imageHeight+6);
    lineData[(4+bytesPerLine)*imageHeight+3]=0x1d;
    lineData[(4+bytesPerLine)*imageHeight+4]=0x44;
    lineData[(4+bytesPerLine)*imageHeight+5]=0x0;
//    Byte *new[imageHeight * bytesPerLine];
    for (int n = 0; n < imageHeight; n++)
    {
		  lineData[3+(4+bytesPerLine)*n]=0x16;
          lineData[3+(4+bytesPerLine)*n+1]=bytesPerLine;
		  for ( int m=0;m<bytesPerLine;m++) lineData[3+(4+bytesPerLine)*n+2+m]=bitmap[n][m];
		  lineData[3+(4+bytesPerLine)*n+bytesPerLine+2]=0x15;
		  lineData[3+(4+bytesPerLine)*n+bytesPerLine+3]=0x01;
//        for ( int m=0;m<bytesPerLine;m++) new[bytesPerLine*n+m] = bitmap[n][m];

    }
    lineData[0]=0x1d;
    lineData[1]=0x44;
    lineData[2]=0x01;
    NSData *data=[[NSData alloc] initWithBytes:lineData length:(6+(4+bytesPerLine)*imageHeight)];
//    NSLog(@"date=%d",[data length]);
//    NSData *newData = [[NSData alloc] initWithBytes:new length:imageHeight * bytesPerLine];
//    if (![self printBitMap:0 bitmap:newData]) return NO;
    if(![self printBin:data]) return NO;
    else return YES;
  

    //return YES;
}
+ (BOOL) cutPaper:(int) mode feed_distance:(int) dis
{
		Byte byte[4];
    NSData * cmd;
    //发GS V m/GS V m n
    byte[0]=0x1d;
    byte[1]=0x56;
    byte[2]=mode;
    if ( mode==0 || mode==1 || mode==48 || mode==49 )
    	cmd = [[NSData alloc] initWithBytes:byte length:3];
    else 
    {
    	byte[3]=dis;
    	cmd = [[NSData alloc] initWithBytes:byte length:4];
    }
    if(![self printBin:cmd]) return NO;
    return YES;
}

+ (UIImage *)scaleWithFixedWidth:(CGFloat)width image:(UIImage *)image {
    CGImageRef inputImageRef = [image CGImage];
    float newHeight = CGImageGetHeight(inputImageRef) * (width / CGImageGetWidth(inputImageRef));
    CGSize size = CGSizeMake(width, newHeight);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);

    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return imageOut;
}

@end
