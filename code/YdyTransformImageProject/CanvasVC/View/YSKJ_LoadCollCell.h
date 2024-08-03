//
//  YSKJ_LoadCollCell.h
//  YSKJ_MATCH
//
//  Created by YSKJ on 17/12/18.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol YSKJ_LoadCollCellDelegate <NSObject>

@optional

-(void)getRow:(NSInteger)row;

@end


@interface YSKJ_LoadCollCell : UICollectionViewCell

@property (strong, nonatomic)UIButton *button;
@property (strong, nonatomic)UIButton *panBut;
@property (copy, nonatomic)NSString *url;
@property (strong, nonatomic)UIButton *addBtn;
@property (nonatomic, copy)NSDictionary *objDict;

@property (nonatomic, retain) id <YSKJ_LoadCollCellDelegate>delegate;

@end
