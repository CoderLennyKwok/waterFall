//
//  LKWaterfallView.h
//  WaterFall
//
//  Created by Lenny on 4/16/15.
//  Copyright (c) 2015 Lenny. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    LKWaterfallViewMarginTypeTop,
    LKWaterfallViewMarginTypeBottom,
    LKWaterfallViewMarginTypeLeft,
    LKWaterfallViewMarginTypeRight,
    LKWaterfallViewMarginTypeColumn, // 每一列
    LKWaterfallViewMarginTypeRow, // 每一行
    
}LKWaterfallViewMarginType;
@class LKWaterfallView,LKWaterfallViewCell;
/**
 *  实现数据源的代理
 */
@protocol LKWaterfallViewDataSource <NSObject>
/**
 *  必须实现的代理 如果 不实现 那么将会报错误
 */
@required
/**
 *  一共有多个数据 数据源的实现方法
 *
 *  @param waterfallView view
 *
 *  @return 数据源的个数
 */
-(NSUInteger)numberOfCellInWaterfallView:(LKWaterfallView *)waterfallView;
/**
 *  返回Index下面的cell
 */
-(LKWaterfallViewCell *)waterfallView:(LKWaterfallView *)waterfallView cellAtIndex:(NSUInteger)index;

@optional
/**
 *  一共有多少列
 */
- (NSUInteger)numberOfColumnsInWaterfallView:(LKWaterfallView *)waterfallView;

@end
@protocol LKWaterfallViewDelegate <UIScrollViewDelegate>

@optional
/**
 *  第index位置cell对应的高度
 */
- (CGFloat)waterfallView:(LKWaterfallView *)waterfallView heightAtIndex:(NSUInteger)index;
/**
 *  选中第index位置的cell
 */
- (void)waterfallView:(LKWaterfallView *)waterfallView didSelectAtIndex:(NSUInteger)index;
/**
 *  返回间距
 */
- (CGFloat)waterfallView:(LKWaterfallView *)waterfallView marginForType:(LKWaterfallViewMarginType)type;


@end
@interface LKWaterfallView : UIScrollView
/**
 *  数据源代理
 */
@property(nonatomic,weak) id<LKWaterfallViewDataSource> dataSource;
/**
 *  代理
 */
@property(nonatomic,weak) id<LKWaterfallViewDelegate> delegate;
//数据的重新加载（只要调用这个方法，会重新向数据源和代理发送请求，请求数据）

-(void)reloadData;

/**
 *  根据标识去缓存池查找可循环利用的cell(这里是采用的复用的技术 将减轻内存的压力)
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
/**
 *  cell的宽度
 */
-(CGFloat)cellWidth;
@end
