//
//  MainViewController.m
//  WaterMonitor
//
//  Created by AKI on 2015/3/31.
//  Copyright (c) 2015年 AKI. All rights reserved.
//

#import "MainViewController.h"
#import "TFHpple.h"
#import "TFHppleElement.h"

#define waterURL @"http://fhy.wra.gov.tw/ReservoirPage_2011/StorageCapacity.aspx"

#define VponID @"8a8081824c6e3a77014c700120de079e"

#define RGBCOLOR(r, g, b)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewTest;
@property (weak, nonatomic) IBOutlet UIAlertController *alert;

@end

@implementation MainViewController
@synthesize dataArray;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelector:@selector(requestData:) withObject:nil afterDelay:0.1f];
}

-(void)requestData:(id)sender{
    
    NSURL *wUrl = [NSURL URLWithString:waterURL];
    
    NSData *HtmlData = [NSData dataWithContentsOfURL:wUrl];
    
    
    
    TFHpple *Parser = [TFHpple hppleWithHTMLData:HtmlData];
    
    NSString *XpathQueryString = @"//table[@id='ctl00_cphMain_gvList']/tr";
    
    NSArray *mArray = [Parser searchWithXPathQuery:XpathQueryString];
    
    if(mArray.count==0){
        ErrorCount++;
        
        if(ErrorCount>5){
        
            self.alert = [UIAlertController
                                         alertControllerWithTitle:@"網路讀取錯誤"
                                         message:@"請檢查網路狀況"
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"是"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                            [self clearAllData];
                                        }];
            
            UIAlertAction* noButton = [UIAlertAction
                                       actionWithTitle:@"取消"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                          [self clearAllData];
                                       }];
            
            //Add your buttons to alert controller
            
            [self.alert addAction:yesButton];
            [self.alert addAction:noButton];
            
            [self presentViewController:self.alert animated:YES completion:nil];
            
            return;
        }
        
        [self performSelector:@selector(requestData:) withObject:nil afterDelay:10.0f];
        
        return;
    }
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<mArray.count; i++) {
        
        NSArray *sArray =[(TFHppleElement *)[mArray objectAtIndex:i] childrenWithTagName:@"td"];
        if(sArray.count!=0){
            
            if([[(TFHppleElement *)[sArray lastObject] text] rangeOfString:@"%"].location !=NSNotFound){
                [dataArray addObject:[NSString stringWithFormat:@"%@,%@", [(TFHppleElement *)[sArray objectAtIndex:0] text] , [(TFHppleElement *)[sArray lastObject] text]]];
                
            }
            
        }
    }
   
    self.dataArray = dataArray;
    [self main];
}

-(void)clearAllData {
    
    [self.alert dismissViewControllerAnimated:true completion:nil];
}

-(void)main {
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[ContainerView bounds]];
    
    view1 = [[ReservoirViewController alloc] initWithNibName:@"ReservoirViewController" bundle:nil];
    
    view1.dataArray = dataArray;
    
    
    view2 = [[FavoriteViewController alloc] initWithNibName:@"FavoriteViewController" bundle:nil];
    
    view2.mArray = dataArray;
    
    viewControllers =[NSArray arrayWithObject:view1];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [ContainerView addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    for (UIView *view in self.pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)view setDelegate:self];
        }
    }
    
    
    CGPoint origin = CGPointMake(([UIScreen mainScreen].bounds.size.width-CGSizeFromVpadnAdSize(VpadnAdSizeBanner).width)/2,0.0);
    [self doButtonState:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    UIViewController *currentView = [self.pageController.viewControllers objectAtIndex:0];
    
    if ([currentView isKindOfClass:[view1 class]]) {
        [UIView animateWithDuration:0.24f animations:^{
            [self->selectedBar setFrame:CGRectMake(btnWater.frame.origin.x-3, selectedBar.frame.origin.y, selectedBar.frame.size.width, selectedBar.frame.size.height)];
        } completion:^(BOOL finished) {
            
            [self doButtonState:1];
        }];
    }
    else if([currentView isKindOfClass:[view2 class]]){
        [UIView animateWithDuration:0.24f animations:^{
            [self->selectedBar setFrame:CGRectMake(btnSetting.frame.origin.x-3, selectedBar.frame.origin.y, selectedBar.frame.size.width, selectedBar.frame.size.height)];
        } completion:^(BOOL finished) {
            
            [self doButtonState:1];
        }];
    }
   
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if ([[viewController class] isSubclassOfClass:[view1 class]]) {
        return nil;
    }
    
    if([[viewController class] isSubclassOfClass:[view2 class]]){
        return view1;
    }
    
    return nil;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if([[viewController class] isSubclassOfClass:[view1 class]]){
        return view2;
    }
    
    return nil;
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 2;
}




-(IBAction)btnWater:(id)sender{
    [self.pageController setViewControllers:[NSArray arrayWithObject:view1] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [UIView animateWithDuration:0.24f animations:^{
        [selectedBar setFrame:CGRectMake(btnWater.frame.origin.x, selectedBar.frame.origin.y, selectedBar.frame.size.width, selectedBar.frame.size.height)];
    } completion:^(BOOL finished) {
        
        [self doButtonState:0];
        
        
    }];
    
}


-(IBAction)btnSetting:(id)sender{
    
    [self.pageController setViewControllers:[NSArray arrayWithObject:view2] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [UIView animateWithDuration:0.24f animations:^{
        [selectedBar setFrame:CGRectMake(btnSetting.frame.origin.x, selectedBar.frame.origin.y, selectedBar.frame.size.width, selectedBar.frame.size.height)];
    } completion:^(BOOL finished) {
        
        [self doButtonState:1];
    }];
    
}

-(void)doButtonState:(int)idx{
    if(idx==0){
        [btnWater setBackgroundColor:RGBCOLOR(0,128,255)];
        [btnSetting setBackgroundColor:[UIColor whiteColor]];
        
        [btnWater setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnSetting setTitleColor:RGBCOLOR(0,128,255) forState:UIControlStateNormal];
    }else{
        
        [btnSetting setBackgroundColor:RGBCOLOR(0,128,255)];
        [btnWater setBackgroundColor:[UIColor whiteColor]];
        
        [btnSetting setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnWater setTitleColor:RGBCOLOR(0,128,255) forState:UIControlStateNormal];

    }
}




@end
