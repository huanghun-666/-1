//
//  SCenViewController.m
//  太阳系1
//
//  Created by 姚立飞 on 2017/10/12.
//  Copyright © 2017年 姚立飞. All rights reserved.
//

#import "SCenViewController.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface SCenViewController ()<ARSCNViewDelegate>

@property (nonatomic, strong) ARSCNView *arSCNView;
@property (nonatomic, strong) ARSession *arSession;
@property (nonatomic, strong) ARConfiguration *arSessionConfiguation;

@property (nonatomic, strong) SCNNode *sunNode;
@property (nonatomic, strong) SCNNode *moonNode;
@property (nonatomic, strong) SCNNode *earthNode;
// 地月节点：用来设置地球和月亮
@property (nonatomic, strong) SCNNode *earthGroupNode;
@property(nonatomic, strong)SCNNode * sunHaloNode;



@end

@implementation SCenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化 AR 环境
    [self.view addSubview:self.arSCNView];
    self.arSCNView.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 创建追踪
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    // 自适应灯光
    _arSessionConfiguation = configuration;
    _arSessionConfiguation.lightEstimationEnabled = YES;
    [self.arSession runWithConfiguration:configuration];
    
    
}

- (void)initNode {
    
    _sunNode        = [SCNNode new];
    _moonNode       = [SCNNode new];
    _earthNode      = [SCNNode new];
    _earthGroupNode = [SCNNode new];
    
    // 确定节点几何
    _sunNode.geometry   = [SCNSphere sphereWithRadius:3];
    _earthNode.geometry = [SCNSphere sphereWithRadius:1.0];
    _moonNode.geometry  = [SCNSphere sphereWithRadius:0.5];
    
    // 渲染上图
    // multiply: 镶嵌 把整张图片拉伸，之后会变淡
    _sunNode.geometry.firstMaterial.multiply.contents  = @"art.scnassets/earth/sun.jpg";
    // diffuse: 扩散， 平均扩散到整个物件的表面，并且光滑透亮
    _sunNode.geometry.firstMaterial.diffuse.contents   = @"art.scnassets/earth/sun.jpg";
    
    _earthNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/earth-diffuse-mini.jpg";
    _earthNode.geometry.firstMaterial.emission.contents = @"art.scnassets/earth/earth-emissive-mini.jpg";
    _earthNode.geometry.firstMaterial.specular.contents = @"art.scnassets/earth/earth-specular-mini.jpg";
    
    _moonNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/moon.jpg";
    _moonNode.geometry.firstMaterial.specular.contents = [UIColor redColor];

    _sunNode.geometry.firstMaterial.multiply.intensity = 0.5; // 强度
    _sunNode.geometry.firstMaterial.lightingModelName  = SCNLightingModelConstant;
    // wraps 从左到右
    // wrapt 从上到下
    _sunNode.geometry.firstMaterial.multiply.wrapS     =
    _sunNode.geometry.firstMaterial.diffuse.wrapS      =
    _sunNode.geometry.firstMaterial.multiply.wrapT     =
    _sunNode.geometry.firstMaterial.diffuse.wrapT      = SCNWrapModeRepeat;
    
    // 太阳照到地球上的光源，还有反光度，地球的反光度
    _earthNode.geometry.firstMaterial.shininess   = 0.1; // 光源
    _earthNode.geometry.firstMaterial.specular.intensity = 0.5; // 反射多少光出去
    
    //设置太阳的位置
    _sunNode.position   = SCNVector3Make(0, 5, -20);
    //设置地球节点的位置
    _earthNode.position = SCNVector3Make(3, 0, 0);
    //设置月球节点的位置
    _moonNode.position  = SCNVector3Make(3, 0, 0);
    // 设置地月节点的位置
    _earthGroupNode.position  =  SCNVector3Make(10, 0, 0);
    
    // 设置地球节点的位置
    [_earthGroupNode addChildNode:_earthNode];
    
    [self.arSCNView.scene.rootNode addChildNode:_sunNode];
    
    [self addAnimationToSun];
    
    [self rationNode];
    
    [self addLight];
    
}
// 公转动画
- (void)rationNode {
    
    [_earthNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]]; // 地球自转
    
   
    SCNNode *moonRotationNode = [SCNNode node];
    [moonRotationNode addChildNode:_moonNode];
    
    // 月亮自转
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 1.5;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [_moonNode addAnimation:animation forKey:@"moon rotation"];

    // 月亮绕着地球转
    CABasicAnimation *moonRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonRotationAnimation.duration = 5.0;
    moonRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    moonRotationAnimation.repeatCount = FLT_MAX;
    [moonRotationNode addAnimation:moonRotationAnimation forKey:@"moom rotation around earth"];
    

    // 地球绕着太阳转
    SCNNode *earthRotationNode = [SCNNode node];
    [_sunNode addChildNode:earthRotationNode];
    [earthRotationNode addChildNode:_earthGroupNode];
    
    [_earthGroupNode addChildNode:moonRotationNode];
    
    
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 10.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [earthRotationNode addAnimation:animation forKey:@"earth rotation around sun"];
    
    
}


// 太阳自传
- (void)addAnimationToSun {
    
    CABasicAnimation *animtaion = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    animtaion.duration = 10.0;
    animtaion.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animtaion.repeatCount = FLT_MAX;
    [_sunNode.geometry.firstMaterial.diffuse addAnimation:animtaion forKey:@"sun-texture"];

    animtaion.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5 ))];
    animtaion.repeatCount = FLT_MAX;
    
    
}

- (void)addLight {
    
    SCNNode *lightNode = [SCNNode node];
    lightNode.light    = [SCNLight light];
    lightNode.light.color = [UIColor redColor];
    [_sunNode addChildNode:lightNode];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1];
    {
        
        lightNode.light.color = [UIColor whiteColor]; // switch on
        _sunHaloNode.opacity = 0.5; // make the halo stronger
    }
    [SCNTransaction commit];
    
    _sunHaloNode = [SCNNode node];
    _sunHaloNode.geometry = [SCNPlane planeWithWidth:25 height:25];
    _sunHaloNode.rotation = SCNVector4Make(1, 0, 0, 0 * M_PI / 180.0);
    _sunHaloNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun-halo.png";
    _sunHaloNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    _sunHaloNode.geometry.firstMaterial.writesToDepthBuffer = NO; // do not write to depth
    _sunHaloNode.opacity = 0.9;
    [_sunNode addChildNode:_sunHaloNode];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ARSCNView *)arSCNView {
    if (!_arSCNView) {
        _arSCNView = [[ARSCNView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _arSCNView.session = self.arSession;
        _arSCNView.automaticallyUpdatesLighting = YES;
    }
    return _arSCNView;
}

- (ARSession *)arSession {
    if (!_arSession) {
        _arSession = [[ARSession alloc] init];
        
        [self initNode];
    }
    return _arSession;
}




@end
