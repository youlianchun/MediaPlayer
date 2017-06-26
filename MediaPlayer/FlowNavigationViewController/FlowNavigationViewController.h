//
//  FlowNavigationViewController.h
//  UPBOX
//
//  Created by YLCHUN on 2017/4/24.
//  Copyright © 2017年 PPSPORTS Cultural Development Co., Ltd. All rights reserved.
//
//  导航控制器 rootViewController 是一个空白 UIViewController ，流程第0个页面是viewControllers[1]
//  流程页面下标从0开始，流程下标0 等于导航控制器viewControllers[1]

#import <UIKit/UIKit.h>


@protocol FlowNavigationProtocol <NSObject>

@optional
//用于FlowNavigation
-(void)flowEndEvent;

@end

@interface FlowNavigationViewController : UINavigationController

-(instancetype)init NS_UNAVAILABLE ;
-(instancetype)initWithRootViewController:(UIViewController *)rootViewController NS_UNAVAILABLE;
-(instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
-(instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass NS_UNAVAILABLE;

/**
 创建流程导航控制器
 仅此方法有效
 
 @param viewController 流程第0个页面
 @return 导航控制器
 */
+(instancetype)flowNavigationWithViewController:(UIViewController*)viewController;


/**
 跳转到流程第0个页面
 
 @param flag 动画
 */
-(void)popToStartViewControllerWithAnimated:(BOOL)flag;


/**
 push之后 pop前边的控制器
 
 @param viewController 目标控制器
 @param popCount pop数量
 @param animated push动画
 */
-(void)pushViewController:(UIViewController *)viewController beforePop:(NSUInteger)popCount animated:(BOOL)animated;

/**
 关闭流程导航控制器
 
 @param flag 动画
 */
-(void)closeFlowWithAnimated:(BOOL)flag;

@end

@interface UIViewController(Flow)

@property (nonatomic, retain) id flowObject;
/**
 模态跳转ViewController 到流程导航控制器
 
 @param viewControllerToPresent 流程第0个页面
 @param flag 动画
 */
-(FlowNavigationViewController*)presentFlowViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag;


/**
 关闭流程导航控制器
 
 @param flag 动画
 */
-(void)dismisFlowViewControllerWithAnimated:(BOOL)flag completion: (void (^)(void))completion;
@end
