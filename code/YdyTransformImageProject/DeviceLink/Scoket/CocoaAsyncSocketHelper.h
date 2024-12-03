//
//  CocoaAsyncSocketHelper.h
//  YdyTransformImageProject
//
//  Created by LaserPecker-iOS on 2024/11/29.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

NS_ASSUME_NONNULL_BEGIN

@interface CocoaAsyncSocketHelper : NSObject

@property (strong,nonatomic) GCDAsyncSocket *tcpSocket;
@property(nonatomic, copy) void (^linkResultlock)(void);
@property(nonatomic, copy) void (^dissLinkResultlock)(void);
@property(nonatomic, copy) void (^resultDatablock)(NSArray *dataArr);
@property(nonatomic, strong) NSMutableArray *dataArr;
- (void)connectWiFiWithIpAddress:(NSString *)ipAddress port:(int)port;

+ (instancetype)sharedInstance;

- (void)sendBuffer;



@end

NS_ASSUME_NONNULL_END
