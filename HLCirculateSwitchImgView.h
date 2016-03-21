//
//  HLCirculateSwitchImgView.h
//  DriveUserProject
//
//  Created by sd on 16/3/15.
//  Copyright © 2016年 CJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JGCirculateSwitchImgViewBlock)(NSInteger index);

@interface HLCirculateSwitchImgView : UIView

@property(nonatomic,strong)NSArray *imgUrlArr;
@property(nonatomic,strong)NSArray *titles;

@property(nonatomic,copy)JGCirculateSwitchImgViewBlock block;

-(void)closeTimer;
-(void)resetTimer;

@end
