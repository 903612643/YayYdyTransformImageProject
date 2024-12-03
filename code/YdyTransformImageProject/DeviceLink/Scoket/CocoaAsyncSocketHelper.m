

#import "CocoaAsyncSocketHelper.h"


@interface CocoaAsyncSocketHelper ()<GCDAsyncSocketDelegate>


@property (nonatomic, strong) dispatch_queue_t socketQueue;

@property(nonatomic, strong) NSTimer *heartbeatTimer;


@end

@implementation CocoaAsyncSocketHelper

static dispatch_once_t onceToken;
static CocoaAsyncSocketHelper *instance = nil;


+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    if(self = [super init]){
        self.socketQueue = dispatch_queue_create("com.myapp.socketQueue", DISPATCH_QUEUE_SERIAL);
        self.dataArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)connectWiFiWithIpAddress:(NSString *)ipAddress port:(int)port{
    NSError *error;
    BOOL isConnect = [self.tcpSocket connectToHost:ipAddress onPort:port error:&error];
}



#pragma mark - 连接成功 请求设备数据
- (void)sendBuffer {
    NSData *sendBufferData = [self dataFromHexadecimalString:@"aabb080003000000000003"];
    [self.tcpSocket writeData:sendBufferData withTimeout:10 tag:100];
}


#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if(self.linkResultlock){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.linkResultlock();
            [self beginSendHeartbeat];
        });
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if(self.dissLinkResultlock){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dissLinkResultlock();
            if (self.heartbeatTimer) {
                [self.heartbeatTimer invalidate];
                self.heartbeatTimer = nil;
            }
        });
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [self.tcpSocket readDataWithTimeout:-1 tag:tag];
}

// 服务器返回数据
- (void)socket:(GCDAsyncSocket*)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.dataArr addObject:@{@"title":[NSString stringWithFormat:@"package%ld：",self.dataArr.count+1],@"data":[self hexadecimalStringFromNSData:data]}];
    if(self.resultDatablock){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultDatablock(self.dataArr);
        });
    }
}


#pragma mark - 开启心跳包线程
- (void)beginSendHeartbeat{
    if (self.heartbeatTimer) {
        [self.heartbeatTimer invalidate];
        self.heartbeatTimer = nil;
    }
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(sendHeartbeat:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.heartbeatTimer = timer;
}

- (void)sendHeartbeat:(NSTimer *)timer {
//    if (timer != nil) {
//        char heartbeat[4] = {0xab,0xcd,0x00,0x00};
//        NSData *heartbeatData = [NSData dataWithBytes:&heartbeat length:sizeof(heartbeat)];
//        [self.tcpSocket writeData:heartbeatData withTimeout:-1 tag:0];
//    }
    [self sendBuffer];
}

-(void)dealloc
{
    if (self.heartbeatTimer) {
        [self.heartbeatTimer invalidate];
        self.heartbeatTimer = nil;
    }
}


#pragma mark - Get

- (GCDAsyncSocket *)tcpSocket {
    if(!_tcpSocket){
        _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return _tcpSocket;
}


- (NSData *)dataFromHexadecimalString:(NSString *)hexString {
    if (hexString.length == 0) {
        return nil;
    }
    NSMutableData *data = [NSMutableData dataWithCapacity:hexString.length / 2];
    unsigned char buffer;
    char byteChars[3] = {'\0', '\0', '\0'};
    for (int i = 0; i < hexString.length; i += 2) {
        byteChars[0] = [hexString characterAtIndex:i];
        byteChars[1] = [hexString characterAtIndex:i+1];
        buffer = strtol(byteChars, NULL, 16);
        [data appendBytes:&buffer length:1];
    }

    return [data copy];
}


- (NSString *)hexadecimalStringFromNSData:(NSData *)data {
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
        return @"";
    }
    const unsigned char *dataBytes = data.bytes;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:dataLength * 2];
    for (NSUInteger i = 0; i < dataLength; i++) {
        [hexString appendFormat:@"%02x", dataBytes[i]];
    }
    return [hexString copy];
}




@end
