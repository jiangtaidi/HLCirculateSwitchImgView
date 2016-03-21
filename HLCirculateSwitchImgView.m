//
//  HLCirculateSwitchImgView.m
//  DriveUserProject
//
//  Created by sd on 16/3/15.
//  Copyright © 2016年 CJ. All rights reserved.
//


#import "HLCirculateSwitchImgView.h"
#import "UIImageView+WebCache.h"
#import "HLTouchActionImageView.h"

typedef NS_ENUM(NSInteger, SwitchDirection)
{
    //未成功旋转
    SwitchDirectionNone = -1,
    //向右旋转图片
    SwitchDirectionRight = 0,
    //向左训转图片
    SwitchDirectionLeft = 1,
};

//默认2秒训转图片一次,可以根据需要改变

#define WiatForSwitchImgMaxTime 3

@interface HLCirculateSwitchImgView ()<UIScrollViewDelegate>

@property(nonatomic,weak)UIScrollView *contentScrollView;
@property(nonatomic,weak)UIPageControl *pageControlView;

//用保存当前UIPageControl控件显示的当前位置
@property(nonatomic,assign)NSInteger currentPage;

//用于保存当前显示图片在图片urlArr数组中的索引
@property(nonatomic,assign)NSInteger currentImgIndex;

@property(nonatomic,weak)HLTouchActionImageView *imgView1;
@property(nonatomic,weak)HLTouchActionImageView *imgView2;
@property(nonatomic,weak)HLTouchActionImageView *imgView3;

@property(nonatomic,assign)BOOL isDragImgView;
@property(nonatomic,assign)SwitchDirection swDirection;

@property(nonatomic,weak)UILabel *titleLabel;

//定时轮播
@property(nonnull,strong)NSTimer *timer;

@end

@implementation HLCirculateSwitchImgView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self createContentScrollView];
        [self createPageControlView];
        
        //默认第一页
        _currentPage = 0;
        
        //默认显示第一张图片
        _currentImgIndex = 0;
        _isDragImgView = NO;
        _swDirection = SwitchDirectionNone;
    }
    
    return self;
}

-(void)dealloc
{
    [_timer  invalidate];
    _timer = nil;
}

-(void)awakeFromNib
{
    [self createContentScrollView];
    [self createPageControlView];
    
    //默认第一页
    _currentPage = 0;
    
    //默认显示第一张图片
    _currentImgIndex = 0;
    _isDragImgView = NO;
    _swDirection = SwitchDirectionNone;
    
}

-(void)layoutSubviews
{
    _contentScrollView.frame = self.bounds;
   
    _pageControlView.frame = CGRectMake(0, 0, 80, 20);
    _pageControlView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height - 20);
    
    

    
    _contentScrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
    
    _currentImgIndex = 0;
    [_contentScrollView setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:NO];
}

-(void)createContentScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    
    [self addSubview:scrollView];
    
    _contentScrollView = scrollView;
}

-(void)createPageControlView
{
    
    UIPageControl *pageControlVw = [[UIPageControl alloc] init];
    _pageControlView = pageControlVw;
    pageControlVw.frame = CGRectMake(0, 0, 80, 20);
    pageControlVw.center = CGPointMake(self.bounds.size.width - 60, self.bounds.size.height - 20);
    _pageControlView.pageIndicatorTintColor = [UIColor whiteColor];
    _pageControlView.currentPageIndicatorTintColor = HLColor(246, 201, 219);
    
    [self addSubview:pageControlVw];
    
    [self addSubview:_titleLabel];
}

//value对Count取模,并保证为正值
-(NSInteger)switchToValue:(NSInteger)value Count:(NSInteger)count
{
    
    NSInteger result = value % count;
    return result >=0 ? result : result + count;
    
}

-(void)setImgUrlArr:(NSArray *)imgUrlArr
{
    _imgUrlArr = [imgUrlArr copy];
    NSInteger count = imgUrlArr.count;
    
    if (count <= 0 )
    {
        return;
    }
    if (self.titles.count>0) {
        _titleLabel.text = self.titles[0];
    }
    
    
    //如果只显示一张图片,不需要考虑旋转
    if (count == 1)
    {
        HLTouchActionImageView *imgView = [[HLTouchActionImageView alloc]init];
        imgView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [_contentScrollView addSubview:imgView];
        
        _pageControlView.numberOfPages = 1;
        _pageControlView.currentPage = 0;
        
        _contentScrollView.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        
        NSURL *imgUrl = [NSURL URLWithString:imgUrlArr[0]];
        
        [imgView sd_setImageWithURL:imgUrl placeholderImage:nil];
        
        
        return;
    }
    
    if (count > 1)
    {
        //这里只使用3个ImgView轮转多张图片，数量2,3,4,5,6...
        
        for(int i = 0; i < 3 ;i++)
        {
            
            HLTouchActionImageView *imgView = [[HLTouchActionImageView alloc] init];
            
            imgView.frame = CGRectMake(i * ScreenWidth, 0, ScreenWidth, 134);
            
            imgView.layer.masksToBounds = YES;
            imgView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTap:)];
            [imgView addGestureRecognizer:tap];
            
            NSString *urlStr = urlStr = _imgUrlArr[[self switchToValue:i-1 Count:count]];
            
            NSURL *imgUrl = [NSURL URLWithString:urlStr];
            [imgView sd_setImageWithURL:imgUrl  placeholderImage:nil];
            
            if (i == 0)
            {
                _imgView1 = imgView;
            }
            else if (i == 1)
            {
                _imgView2 = imgView;
            }
            else if (i == 2)
            {
                _imgView3 = imgView;
            }
            
            [_contentScrollView addSubview:imgView];
        }
        
        _pageControlView.numberOfPages = count;
        _pageControlView.currentPage = 0;
        [_contentScrollView setContentOffset:CGPointMake(ScreenWidth, 0) animated:NO];

        
        [self performSelector:@selector(startTimer) withObject:nil afterDelay:2];
    }
    
}

-(void)closeTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)resetTimer
{
    [self closeTimer];
     _timer = [NSTimer scheduledTimerWithTimeInterval:WiatForSwitchImgMaxTime target:self selector:@selector(timerAction:)  userInfo:nil repeats:YES];
}

-(void)startTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:WiatForSwitchImgMaxTime target:self selector:@selector(timerAction:)  userInfo:nil repeats:YES];
}

-(void)timerAction:(NSTimer*)timer
{
    _currentPage = [self switchToValue:_currentPage + 1 Count:_imgUrlArr.count];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _pageControlView.currentPage = _currentPage;
        if (self.titles.count >= _pageControlView.currentPage) {
            NSString *title = self.titles[_pageControlView.currentPage];
            self.titleLabel.text = title;
        }
        
        [UIView animateWithDuration:1.0 animations:^{
            _contentScrollView.contentOffset = CGPointMake(2 * self.bounds.size.width, 0);
        } completion:^(BOOL finished) {
            [self reSetImgUrlWithDirection:SwitchDirectionLeft];
            [_contentScrollView setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:NO];

        }];
        
    
    });

}

-(void)switchImg
{
    while (1)
    {
        [NSThread sleepForTimeInterval:WiatForSwitchImgMaxTime];
        
        //如果正在拖拽图片，此次作废
        if (_isDragImgView) {
            
            continue;
            
        }
        
        _currentPage = [self switchToValue:_currentPage + 1 Count:_imgUrlArr.count];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _pageControlView.currentPage = _currentPage;
            if (self.titles.count >= _pageControlView.currentPage) {
                NSString *title = self.titles[_pageControlView.currentPage];
                self.titleLabel.text = title;
            }
            _contentScrollView.contentOffset = CGPointMake(2 * self.bounds.size.width, 0);
            
            [self reSetImgUrlWithDirection:SwitchDirectionLeft];
            
        });
        
    }
}

-(void)switchImgByDirection:(SwitchDirection)direction
{
    if (direction == SwitchDirectionNone) {
        return;
    }
    
    [self reSetImgUrlWithDirection:direction];
    
    [_contentScrollView setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:NO];
}

-(void)reSetImgUrlWithDirection:(SwitchDirection)direction
{
    if (direction == SwitchDirectionRight) {
        
        HLLOG(@"you you");
        [_imgView1 sd_setImageWithURL:[NSURL URLWithString:_imgUrlArr[[self switchToValue:_currentImgIndex - 2 Count:_imgUrlArr.count]]] placeholderImage:nil];
        
        [_imgView2 sd_setImageWithURL:[NSURL URLWithString:_imgUrlArr[[self switchToValue:_currentImgIndex - 1 Count:_imgUrlArr.count]]] placeholderImage:nil];
        
        [_imgView3 sd_setImageWithURL:[NSURL URLWithString:_imgUrlArr[[self switchToValue:_currentImgIndex Count:_imgUrlArr.count]]] placeholderImage:nil];
        
        _currentImgIndex = [self switchToValue:_currentImgIndex - 1 Count:_imgUrlArr.count];
        
    }
    else if(direction == SwitchDirectionLeft)
    {
        [_imgView1 sd_setImageWithURL:[NSURL URLWithString:_imgUrlArr[[self switchToValue:_currentImgIndex Count:_imgUrlArr.count]]] placeholderImage:nil];
        
        [_imgView2 sd_setImageWithURL:[NSURL URLWithString:_imgUrlArr[[self switchToValue:_currentImgIndex + 1 Count:_imgUrlArr.count]]] placeholderImage:nil];
        
        [_imgView3 sd_setImageWithURL:[NSURL URLWithString:_imgUrlArr[[self switchToValue:_currentImgIndex + 2 Count:_imgUrlArr.count]]] placeholderImage:nil];
        
        _currentImgIndex = [self switchToValue:_currentImgIndex + 1 Count:_imgUrlArr.count];
    }
}

#pragma mark -----------------Delegate---------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static float newx = 0;
    static float oldx = 0;
    
    newx= scrollView.contentOffset.x ;
    
    if (newx != oldx )
    {
        if (newx > oldx)
        {
            _swDirection = SwitchDirectionLeft;
            
        }else if(newx < oldx)
        {
            
            _swDirection = SwitchDirectionRight;
        }
        
        oldx = newx;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isDragImgView = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    [self startTimer];

    //向左旋转
    if (_swDirection == SwitchDirectionLeft)
    {
        _currentPage = [self switchToValue:_currentPage + 1 Count:_imgUrlArr.count];
        
        
    }//向右旋转
    else if (_swDirection == SwitchDirectionRight)
    {
        HLLOG(@"you");
        _currentPage = [self switchToValue:_currentPage - 1 Count:_imgUrlArr.count];
    }
    
    _pageControlView.currentPage = _currentPage;
    if (self.titles.count >= _pageControlView.currentPage) {
        NSString *title = self.titles[_pageControlView.currentPage];
        self.titleLabel.text = title;
    }
    
    
    if (_swDirection != SwitchDirectionNone) {
        
        [self switchImgByDirection:_swDirection];
        
    }
    
}

-(void)imgTap:(UITapGestureRecognizer*)tap
{
    if (self.block) {
        self.block(_currentImgIndex);
    }
}

@end

//__weak typeof(self) sf = self;
////轮播图
//_switchImgView = [[HLCirculateSwitchImgView alloc] initWithFrame:CGRectMake(0,0 , ScreenWidth , 134)];
//
//NSArray *imgUrlArr = @[@"http://www.blisscake.cn/Upload/Product/Show/Source/ps_1507201119031647109.jpg",
//                       
//                       @"http://www.blisscake.cn/Upload/Product/Show/Source/ps_1507201116215754685.jpg",
//                       
//                       @"http://www.blisscake.cn/Upload/Product/Show/Source/ps_1507201115524758041.jpg",
//                       
//                       @"http://www.blisscake.cn/Upload/Product/Show/Source/ps_1507201114495822068.jpg",
//                       
//                       @"http://www.blisscake.cn/Upload/Product/Show/Source/ps_1507201107522493367.jpg"];
//
//_switchImgView.imgUrlArr = imgUrlArr;
//_switchImgView.block = ^(NSInteger index)
//{
//    [sf switchImgViewImageClicked:index];
//};
//
//[self addSubview:_switchImgView];
//
//




