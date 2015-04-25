//
//  LKWaterfallView.m
//  WaterFall
//
//  Created by Lenny on 4/16/15.
//  Copyright (c) 2015 Lenny. All rights reserved.
//

#import "LKWaterfallView.h"
#import "LKWaterfallViewCell.h"
#define LKWaterfallViewDefaultCellH 70
#define LKWaterfallViewDefaultNumberOfColumns 3
#define LKWaterfallViewDefaultMargin 8
@interface LKWaterfallView ()
/**
 *  所有cell的frame 数据
 */
@property(nonatomic,strong) NSMutableArray * cellFrames;
/**
 *  正在展示的cell
 */
@property(nonatomic,strong) NSMutableDictionary * displayingCells;
/**
 *  缓存池 是让main函数使用的
 */
@property(nonatomic,strong) NSMutableSet * reusableCells;
//@property(nonatomic,assign) CGFloat  CellWith;
@end
@implementation LKWaterfallView
#pragma mark - 数据的懒加载
-(NSMutableSet *)reusableCells
{
    if (_reusableCells == nil) {
        self.reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}
-(NSMutableDictionary *)displayingCells
{
    if (_displayingCells == nil) {
        self.displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}
-(NSMutableArray *)cellFrames
{
    if (_cellFrames == nil) {
        self.cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
#pragma mark - 公共接口
/**
 *  cell的宽度
 *
 *  @return cell的宽度
 */
-(CGFloat)cellWidth
{
    int numberOfColumns = (int)[self.dataSource numberOfColumnsInWaterfallView:self];
    CGFloat  columnM = [self marginForType:LKWaterfallViewMarginTypeColumn];
    CGFloat  leftM = [self marginForType:LKWaterfallViewMarginTypeLeft];
    CGFloat  rightM = [self marginForType:LKWaterfallViewMarginTypeRight];
    return (self.bounds.size.width - leftM - rightM - (numberOfColumns - 1)*columnM)/numberOfColumns;
}
/**
 *  刷新数据
 *  1.计算每一个cell的frame
 */
-(void)reloadData
{
    //清空之前的所有数据
    //移除正在显示的cell的数据
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //清除字典里面所有的值
    [self.displayingCells removeAllObjects];
    //清除所有的frame
    [self.cellFrames removeAllObjects];
    //清除所有的缓存
    [self.reusableCells removeAllObjects];
    //cell 的总数
    int numberOfCells = (int)[self.dataSource numberOfCellInWaterfallView:self];
    //总列数
    int numberOfColumns = (int)[self.dataSource numberOfColumnsInWaterfallView:self];
    //间距
    CGFloat  topM = [self marginForType:LKWaterfallViewMarginTypeTop];
    CGFloat  bottomM = [self marginForType: LKWaterfallViewMarginTypeBottom];
    CGFloat  leftM = [self marginForType:LKWaterfallViewMarginTypeLeft];
//    CGFloat  rightM = [self marginForType:LKWaterfallViewMarginTypeRight];
    CGFloat  columnM = [self marginForType:LKWaterfallViewMarginTypeColumn];
    CGFloat  rowM = [self marginForType:LKWaterfallViewMarginTypeRow];
    //cell 的宽度
    CGFloat  cellW = [self cellWidth];
//    self.CellWith = cellW;
    //cell的高度
    //使用一个c语言数组进行盛放所有列里面的最大的Y值
    CGFloat maxYOfColumns[numberOfColumns];
    for (int i = 0; i < numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    //计算所有cell的frame
    /**
     *  numberOfCells cell的总个数 这里将所有cell的frame都进行算出 并且将其装进数组
     */
    for (int i = 0; i < numberOfCells; i++) {
        //cell处Y最短的一列
        NSUInteger cellColumn = 0;
        // cell所处那列的最大Y值(最短那一列的最大Y值)
        CGFloat  maxYOfCellColumn = maxYOfColumns[cellColumn];
        for (int j = 1; j < numberOfColumns; j++) {
            if (maxYOfCellColumn > maxYOfColumns[j]) {
                cellColumn = j;
                maxYOfCellColumn =  maxYOfColumns[j];
                //                NSLog(@"maxYOfCellColumn ----%f",maxYOfCellColumn);
            }
        }
        //询问代理 i位置的高度是多少
        CGFloat cellH = [self heightAtIndex:i];
        //        NSLog(@"cellH --- %f",cellH);
        //cell的位置
        
        CGFloat cellX =leftM + cellColumn * (cellW + columnM);
        CGFloat cellY = 0;
        //如果是第一行那么就不可以使用通用的方法
        if (maxYOfCellColumn == 0.0) {
            cellY = topM;
        }else
        {
            cellY = maxYOfCellColumn + rowM;
            //            NSLog(@"maxYOfCellColumn ----%f",maxYOfCellColumn);
        }
        //添加到frame数组中
        CGRect  cellframe = CGRectMake(cellX, cellY,cellW, cellH);
        NSLog(@"%@",NSStringFromCGRect(cellframe));
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellframe]];
        //更新最短的那一列的最大Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellframe);
        
    }
        // 设置contentSize
        CGFloat contentH = maxYOfColumns[0];
        for (int j = 1; j < numberOfColumns; j++) {
            if (maxYOfColumns[j] > contentH) {
                contentH = maxYOfColumns[j];
            }
        }
        contentH += bottomM;
        self.contentSize = CGSizeMake(0, contentH);
}
/**
 *  当UIScrollView滚动的时候会调用这个方法
 */
-(void)layoutSubviews
{
    [super layoutSubviews];
    //向数据源索要相对应位置的cell
    NSUInteger numberOfCells = [self.dataSource numberOfCellInWaterfallView:self];
    for (int i = 0; i < numberOfCells; i++) {
        //取出i位置的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        //优先从字典去取出i位置对应的cell
        LKWaterfallViewCell * cell = self.displayingCells[@(i)];
        //判断i位置上的cell 是否在屏幕上显示(能否被看见)
        if ([self isInScreen:cellFrame]) {//在屏幕上
            if (cell == nil) {//字典里面没有
                cell = [self.dataSource waterfallView:self cellAtIndex:i];
                cell.frame = cellFrame;
                //加入其中
                [self addSubview: cell];
                //存放到字典中
                self.displayingCells[@(i)]= cell;
            }
        }else//不在屏幕上
        {
            if (cell) {
                //从ScrollView移除
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                
                //放进缓冲池
                [self.reusableCells addObject:cell];
            }
        }
    }
}

-(id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block LKWaterfallViewCell * reusablecell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(LKWaterfallViewCell * cell, BOOL *stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusablecell = cell;
            *stop = YES;
        }
    }];
    if (reusablecell) {//从缓存池移除
        [self.reusableCells removeObject:reusablecell];
    }
    return reusablecell;
}
#pragma mark - 私有接口
/**
 *  判断一个frame有无显示在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame
{
    return (CGRectGetMaxY(frame)> self.contentOffset.y)&&(CGRectGetMinY(frame)<self.contentOffset.y + self.bounds.size.height);
}

/**
 *  间距
 */
-(CGFloat)marginForType:(LKWaterfallViewMarginType)type
{
    if ([self.delegate respondsToSelector:@selector(waterfallView:marginForType:)]) {
        return [self.delegate waterfallView:self marginForType:type];
    }else
        return LKWaterfallViewDefaultMargin;
}
/**
 *  index位置对应的高度
 */
- (CGFloat)heightAtIndex:(NSUInteger)index
{
    
    if ([self.delegate respondsToSelector:@selector(waterfallView:heightAtIndex:)]) {
        return [self.delegate waterfallView:self heightAtIndex:index];
    }else
        return LKWaterfallViewDefaultCellH;
}
#pragma mark - 事件处理
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.delegate respondsToSelector:@selector(waterfallView:didSelectAtIndex:)])
        return;
    //获得触摸点
    UITouch * touch = [touches anyObject];
    CGPoint  point = [touch locationInView:self];
    
    __block NSNumber * selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id key, LKWaterfallViewCell* cell,  BOOL *stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    if (selectIndex) {
        [self.delegate waterfallView:self didSelectAtIndex:selectIndex.unsignedIntegerValue];
    }
    
}
@end
