//
//  YSKJ_MyLoadProduct.m
//  YSKJ_MATCH
//
//  Created by YSKJ on 17/12/18.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import "YSKJ_MyLoadProduct.h"

#import "YSKJ_LoadCollCell.h"
#import "YSKJ_ProModel.h"
#import "H_TZImagePickerHelper.h"


#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

#define FONT_Medium_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Medium" size:_size_]
#define FONT_Semibold_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Semibold" size:_size_]
#define FONT_Regular_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Regular" size:_size_]

// 16进制颜色值，如：#000000 , 注意：在使用的时候hexValue写成：0x000000
#define HexColor(hexValue) [UIColor colorWithRed:((float)(((hexValue) & 0xFF0000) >> 16))/255.0 green:((float)(((hexValue) & 0xFF00) >> 8))/255.0 blue:((float)((hexValue) & 0xFF))/255.0 alpha:1.0]

@interface YSKJ_MyLoadProduct () <UICollectionViewDataSource,UICollectionViewDelegate,YSKJ_LoadCollCellDelegate>
{
    YSKJ_LoadCollCell *cell;
}

@property (strong, nonatomic)NSMutableArray *data;
@property (strong, nonatomic)UICollectionView *colletionView;
@property (strong, nonatomic)UILabel *canvasTip;

@end

@implementation YSKJ_MyLoadProduct

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor grayColor];
        
        _data = [[NSMutableArray alloc] init];

        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake((self.frame.size.width - 30)/2, (self.frame.size.width - 30)/2 + 20);
        UICollectionView *loadCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10 , self.frame.size.width, self.frame.size.height - 54) collectionViewLayout:layout];
        _colletionView= loadCollectionView;
        loadCollectionView.dataSource = self;
        loadCollectionView.delegate = self;
        loadCollectionView.backgroundColor = [UIColor grayColor];
        [loadCollectionView registerClass:[YSKJ_LoadCollCell class] forCellWithReuseIdentifier:@"cellId"];
        [self addSubview:loadCollectionView];
        
//        UIButton *itemButton1 = [[UIButton alloc] init];
//        [itemButton1 setTitle:@"从相册添加" forState:UIControlStateNormal];
//        itemButton1.titleLabel.font = FONT_Medium_SIZE(14);
//        [itemButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        itemButton1.frame = CGRectMake(10, CGRectGetMaxY(loadCollectionView.frame)  , self.frame.size.width - 20, 34);
//        itemButton1.backgroundColor = [UIColor redColor];
//        itemButton1.layer.cornerRadius = 4;
//        itemButton1.layer.masksToBounds = YES;
//        [itemButton1 addTarget:self action:@selector(itemRightButtonAction1) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:itemButton1];
        
//        UILabel *canvasTip = [[UILabel alloc] initWithFrame:CGRectMake(30, self.frame.size.width/2+20, (self.frame.size.width-60), 60)];
//        canvasTip.font = FONT_Regular_SIZE(18);
//        canvasTip.textColor = HexColor(0xB8BCC2);
//        canvasTip.textAlignment = NSTextAlignmentCenter;
//        canvasTip.numberOfLines = 2;
//        canvasTip.text = @"选择照片与视频到仓库";
//        self.canvasTip = canvasTip;
//        [self addSubview:canvasTip];
        
        UIImage *image = [UIImage imageNamed:@"fruit13.jpg"];
        [self.data addObject:@{@"thumb_file":image}];
        [self.colletionView reloadData];
    }
    
    return self;
}

-(void)itemRightButtonAction1
{

    
    H_TZImagePickerHelper *pickerHelper = [[H_TZImagePickerHelper alloc] init];
     
    [pickerHelper initTZImagePickerVCWithMaxCount:9 option:2];
    
    __weak typeof(self) selfWeak = self;
    
    TZImagePickerInstance.photosAndCountBlock = ^(NSData * _Nullable photoData, NSInteger count) {
        UIImage *image = [UIImage imageWithData:photoData];
        [selfWeak.data addObject:@{@"thumb_file":image}];
        selfWeak.canvasTip.hidden = YES;
        [selfWeak.colletionView reloadData];
    };

    TZImagePickerInstance.videosAndCoverimageAndCountBlock = ^(NSURL * _Nullable url, UIImage * _Nullable coverImage, NSInteger count) {
        [selfWeak.data addObject:@{@"localUrl":url,@"thumb_file":coverImage}];
        selfWeak.canvasTip.hidden = YES;
        [selfWeak.colletionView reloadData];
    };

}


#pragma mark UICollectionViewDataSource,UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _data.count;
   
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    cell.objDict = _data[indexPath.row];
    
    return cell;

}

//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {0,10,10,10};
    return top;
}


#pragma mark YSKJ_LoadCollCellDelegate

-(void)getRow:(NSInteger)row;
{
    UIImage *image = _data[row][@"thumb_file"];
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:_data[row]];
    if (image.size.width>0 && image.size.height>0) {
        [tempDict setValue:[NSString stringWithFormat:@"%f",image.size.width*0.2] forKey:@"netW"];
        [tempDict setValue:[NSString stringWithFormat:@"%f",image.size.height*0.2] forKey:@"netH"];
    }else{
        [tempDict setValue:@200 forKey:@"netW"];
        [tempDict setValue:@200 forKey:@"netH"];
    }
    NSDictionary *dict = @{
                           @"dict":tempDict
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"endPanNotification" object:nil userInfo:dict];
}




@end
