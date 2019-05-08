//
//  FavoriteViewController.h
//  WaterMonitor
//
//  Created by AKI on 2015/3/31.
//  Copyright (c) 2015年 AKI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    IBOutlet UITableView *mTable;
    
     UIView *viewHint;
    
     UIScrollView *myScrollView;
    
     UIPageControl *mPage;
    
}
@property (nonatomic,retain) NSArray *mArray;

@end
