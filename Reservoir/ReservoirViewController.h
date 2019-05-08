//
//  ReservoirViewController.h
//  Reservoir
//
//  Created by AKI on 2015/3/31.
//  Copyright (c) 2015年 AKI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReservoirViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
{
    IBOutlet UICollectionView *mCollection;
    
    
    
    
    
    
}

@property (nonatomic,retain) NSArray *dataArray;

@end
