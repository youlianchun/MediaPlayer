//
//  FlowNavigationViewController.m
//  UPBOX
//
//  Created by YLCHUN on 2017/4/24.
//  Copyright © 2017年 PPSPORTS Cultural Development Co., Ltd. All rights reserved.
//

#import "FlowNavigationViewController.h"

@interface UIBorderViewController : UIViewController
@end
@implementation UIBorderViewController
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
@end

@interface FlowNavigationViewController ()<UINavigationControllerDelegate>
@property (nonatomic, assign) BOOL initFlag;
@property (nonatomic, assign) BOOL closeFlag;
@property (nonatomic, retain) UIView *shadeView;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, copy) void(^dismisCompletion)();

@property (nonatomic, assign) BOOL animated;
-(instancetype)initWithRootViewController_self:(UIViewController *)rootViewController;
@end

@implementation FlowNavigationViewController

+(instancetype)flowNavigationWithViewController:(UIViewController*)viewController {
    UIBorderViewController *rootVC = [[UIBorderViewController alloc] init];
    FlowNavigationViewController * fnvc = [[FlowNavigationViewController alloc] initWithRootViewController_self:rootVC];
    fnvc.viewController = viewController;
    return fnvc;
}

-(instancetype)initWithRootViewController_self:(UIViewController *)rootViewController  {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

-(UIView *)shadeView {
    if (!_shadeView) {
        _shadeView = [[UIView alloc] initWithFrame:self.view.bounds];
        _shadeView.backgroundColor = [UIColor blackColor];
    }
    return _shadeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.initFlag = YES;
    [self performSelector:@selector(showViewController) withObject:nil afterDelay:0];
    // Do any additional setup after loading the view.
}

-(void)showViewController{
    [self pushViewController:self.viewController animated:self.animated];
    _viewController = nil;
}


-(void)popToStartViewControllerWithAnimated:(BOOL)flag {
    if(self.viewControllers.count>1) {
        UIViewController *viewController = self.viewControllers[1];
        [super popToViewController:viewController animated:flag];
    }
}

-(void)pushViewController:(UIViewController *)viewController beforePop:(NSUInteger)popCount animated:(BOOL)animated {
    NSUInteger count = MIN(popCount, self.viewControllers.count-1);
    [super pushViewController:viewController animated:YES];
    NSMutableArray *arr = [self.viewControllers mutableCopy];
    for (int i = 0; i<count; i++) {
        [arr removeObjectAtIndex:arr.count-2];
    }
    self.viewControllers = arr;
}

-(void)closeFlowWithAnimated:(BOOL)flag {
    if (!self.closeFlag) {
        self.closeFlag = YES;
        self.shadeView.alpha = 0.2;
        [self.view.superview insertSubview:self.shadeView belowSubview:self.view];
        [UIView animateWithDuration:0.3 animations:^{
            self.shadeView.alpha = 0;
            self.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(self.view.bounds), 0.0);
        }completion:^(BOOL finished) {
            [self.shadeView removeFromSuperview];
            [self dismissViewControllerAnimated:NO completion:^{
                self.shadeView.alpha = 0.2;
                self.closeFlag = NO;
                self.view.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:NO completion:^{
        if ([self respondsToSelector:@selector(flowEndEvent)]) {
            [(FlowNavigationViewController<FlowNavigationProtocol>*)self flowEndEvent];
        }
        if (self.viewControllers.count>1) {
            self.viewControllers = @[self.viewControllers[0]];
        }
        if (self.dismisCompletion) {
            self.dismisCompletion();
        }
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Navigation

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ((navigationController.viewControllers.count == 1  || [self.topViewController isKindOfClass:[UIBorderViewController class]]) && !self.initFlag) {
        [super dismissViewControllerAnimated:NO completion:nil];
    }
    self.initFlag = NO;
}

@end

#import <objc/runtime.h>
@implementation UIViewController(Flow)

-(id)flowObject {
    return objc_getAssociatedObject(self, @selector(flowObject));
}

-(void)setFlowObject:(id)flowObject {
    objc_setAssociatedObject(self, @selector(flowObject), flowObject, OBJC_ASSOCIATION_RETAIN);
}

-(FlowNavigationViewController*)presentFlowViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag {
    FlowNavigationViewController *fnvc;
    if ([viewControllerToPresent isKindOfClass:[FlowNavigationViewController class]]) {
        fnvc = (FlowNavigationViewController*)viewControllerToPresent;
        if ([fnvc.viewControllers[0] class] != [UIBorderViewController class] || !fnvc.viewController) {
            NSAssert(NO, @"FlowNavigationViewController 格式错误");
            return nil;
        }
    }else {
        fnvc = [FlowNavigationViewController flowNavigationWithViewController:viewControllerToPresent];
    }
    fnvc.animated = flag;
    [self presentViewController:fnvc animated:NO completion:nil];
    return fnvc;
}

-(void)dismisFlowViewControllerWithAnimated:(BOOL)flag completion: (void (^)(void))completion {
    FlowNavigationViewController * fnvc;
    if ([self isKindOfClass:[FlowNavigationViewController class]]) {
        fnvc = (FlowNavigationViewController*)self;
    }
    if ([self.navigationController isKindOfClass:[FlowNavigationViewController class]]) {
        fnvc = (FlowNavigationViewController*)self.navigationController;
    }
    if (fnvc) {
        fnvc.dismisCompletion = completion;
        [fnvc closeFlowWithAnimated:flag];
    }
}

@end
