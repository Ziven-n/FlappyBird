//
//  GameScene.m
//  ninja
//
//  Created by ziven on 2018/7/18.
//  Copyright © 2018年 ziven. All rights reserved.
//

#import "GameScene.h"

@interface GameScene()<SKPhysicsContactDelegate>

@property (nonatomic,assign) BOOL haveStartGame;
@property (nonatomic,assign) BOOL isGameOver;

@end

static uint32_t _floorCy = 0;
static uint32_t _pipeCy = 1;
static uint32_t _birdCy = 2;

@implementation GameScene  {
    
    SKSpriteNode *_groundNode;  // 地面
    SKSpriteNode *_skyNode;     // 天空
    
    SKSpriteNode *_groundNode1;  // 地面1
    SKSpriteNode *_skyNode1;     // 天空1
    
    SKSpriteNode *_bird;          // 小鸟
    
    SKSpriteNode *_overNode;         // 游戏结束提示
}

- (void)sceneDidLoad {
    
    self.physicsWorld.contactDelegate = self;
    
    // 地面
    _groundNode = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    _groundNode.anchorPoint = CGPointZero;
    _groundNode.name = @"ground";
    _groundNode.position = CGPointZero;
    _groundNode.zPosition = -1;
    _groundNode.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/6);
    [self addChild:_groundNode];
    _groundNode.physicsBody = [SKPhysicsBody bodyWithTexture:_groundNode.texture size:_groundNode.size];
    _groundNode.physicsBody.categoryBitMask = _floorCy;
    _groundNode.physicsBody.dynamic = NO;
    
    _groundNode1 = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    _groundNode1.anchorPoint = CGPointZero;
    _groundNode1.name = @"ground";
    _groundNode1.position = CGPointMake(_groundNode.size.width, 0);
    _groundNode1.zPosition = -1;
    _groundNode1.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/6);
    [self addChild:_groundNode1];
    _groundNode1.physicsBody = [SKPhysicsBody bodyWithTexture:_groundNode1.texture size:_groundNode1.size];
    _groundNode1.physicsBody.categoryBitMask = _floorCy;
    _groundNode1.physicsBody.dynamic = NO;
    
    // 背景天空
    _skyNode = [SKSpriteNode spriteNodeWithImageNamed:@"bg_light"];
    _skyNode.anchorPoint = CGPointZero;
    _skyNode.position = CGPointMake(0, [UIScreen mainScreen].bounds.size.height/6);
    _skyNode.zPosition = -1;
    _skyNode.size = CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height/6*5);
    [self addChild:_skyNode];
    
    _skyNode1 = [SKSpriteNode spriteNodeWithImageNamed:@"bg_light"];
    _skyNode1.anchorPoint = CGPointMake(0, 0);
    _skyNode1.position = CGPointMake(_skyNode.size.width-2, [UIScreen mainScreen].bounds.size.height/6);
    _skyNode1.zPosition = -1;
    _skyNode1.size = CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height/6*5);
    [self addChild:_skyNode1];
    
    // 小鸟
    _bird = [SKSpriteNode spriteNodeWithImageNamed:@"fly_2"];
    _bird.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    _bird.size = CGSizeMake(34, 24);
    _bird.name = @"bird";
    [self addChild:_bird];
    
    
    [self birdFly];
}

// 小鸟动起来
- (void)birdFly {
    
    SKAction *action = [SKAction animateWithTextures:@[
                                                       [SKTexture textureWithImage:[UIImage imageNamed:@"fly_1"]],
                                                       [SKTexture textureWithImage:[UIImage imageNamed:@"fly_2"]],
                                                       [SKTexture textureWithImage:[UIImage imageNamed:@"fly_3"]],
                                                       [SKTexture textureWithImage:[UIImage imageNamed:@"fly_2"]],
                                                       ]
                                        timePerFrame:0.1];
    
    [_bird runAction:[SKAction repeatActionForever:action] withKey:@"flybird"];
    
    
}

// 停止飞行
- (void)stopFly {
    
    [_bird removeActionForKey:@"flybird"];
}


- (void)begin {
    
    _groundNode.position = CGPointMake(_groundNode.position.x - 1, _groundNode.position.y);
    _groundNode1.position = CGPointMake(_groundNode1.position.x - 1, _groundNode1.position.y);
    
    _skyNode.position = CGPointMake(_skyNode.position.x - 1, _skyNode.position.y);
    _skyNode1.position = CGPointMake(_skyNode1.position.x - 1, _skyNode1.position.y);
    
    if (_groundNode.position.x < -_groundNode.size.width) {
        
        _groundNode.position = CGPointZero;
        _groundNode1.position = CGPointMake(_groundNode.size.width, 0);
    }
    
    if (_skyNode.position.x < -_skyNode.size.width+2) {
        
        _skyNode.position = CGPointMake(0, [UIScreen mainScreen].bounds.size.height/6);
        _skyNode1.position = CGPointMake(_skyNode.size.width-2, [UIScreen mainScreen].bounds.size.height/6);
    }
    
    for (SKNode *node in self.children) {
        
        if ([node isKindOfClass:[SKSpriteNode class]]&& [node.name isEqualToString:@"pipe"]) {
            
            node.position = CGPointMake(node.position.x - 1, node.position.y);
            
            if (node.position.x < -30) {
                
                [node removeFromParent];
            }
        }
    }

}

- (void)over {

    _groundNode.position = CGPointMake(_groundNode.position.x, _groundNode.position.y);
    _groundNode1.position = CGPointMake(_groundNode1.position.x, _groundNode1.position.y);

    _skyNode.position = CGPointMake(_skyNode.position.x, _skyNode.position.y);
    _skyNode1.position = CGPointMake(_skyNode1.position.x, _skyNode1.position.y);

    
    [self removeAllActions];
}

- (void)update:(NSTimeInterval)currentTime {
    
    if (_isGameOver) {
        [self over];
    }else {
        [self begin];
    }
}

// 创建随机水管
- (void)creatPipeAction {
    
    SKAction *action = [SKAction waitForDuration:3 withRange:1];
    
    SKAction *creat = [SKAction runBlock:^{
       
        [self creatRandomPipe];
    }];
    
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[action,creat]]] withKey:@"randompipe"];
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, _groundNode.size.height, self.size.width, self.size.height - _groundNode.size.height)];
    
    _bird.physicsBody = [SKPhysicsBody bodyWithTexture:_bird.texture size:_bird.size];
    _bird.physicsBody.categoryBitMask = _birdCy;
    
    // 设置小鸟可检测到的碰撞体
    _bird.physicsBody.contactTestBitMask = _floorCy|_pipeCy;
    _bird.physicsBody.dynamic = YES;
    // 不允许翻滚
    _bird.physicsBody.allowsRotation = NO;
    _bird.physicsBody.collisionBitMask = 1;
//    _bird.physicsBody.mass = 0.09;
}

- (void)creatRandomPipe {
    
    // 地面距离顶部的高度
    float baseHeight = (self.size.height - _groundNode.size.height);
    
    // 设置小鸟可以通过的间隙高度，最小为小鸟大小的2.5倍，最高3.5倍
    float spaceHeight = _bird.size.height*3 +  (CGFloat)(arc4random() % (UInt32)(_bird.size.height*4));
        
    // 设置顶部随机高度，最低是地面高度，最高是底部为地面高度时
    float topPipeHeight = _groundNode.size.height + (CGFloat)(arc4random() % (UInt32)(baseHeight - _groundNode.size.height*2 - spaceHeight));
    
//    NSLog(@"最大高度应该不超过%f",(baseHeight - _groundNode.size.height - spaceHeight));
    
    float bottomPipeHeight = baseHeight - spaceHeight - topPipeHeight;
    
//    NSLog(@"顶部高度%f底部高度%f",topPipeHeight,bottomPipeHeight);
    
    // 上水管
    SKSpriteNode *topPipeNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"pipeline"]] size:CGSizeMake(30, topPipeHeight)];
    topPipeNode.anchorPoint = CGPointZero;
    topPipeNode.name = @"pipe";
    topPipeNode.position = CGPointMake(self.size.width, self.size.height - topPipeNode.size.height);
    [self addChild:topPipeNode];
//    topPipeNode.physicsBody = [SKPhysicsBody bodyWithTexture:topPipeNode.texture size:topPipeNode.size];
    topPipeNode.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, topPipeNode.size.width, topPipeNode.size.height)];
    topPipeNode.physicsBody.categoryBitMask = _pipeCy;
    topPipeNode.physicsBody.contactTestBitMask = _birdCy;
    topPipeNode.physicsBody.dynamic = YES;
    
    // 下水管      图片大小54*640
    SKSpriteNode *bottomPipeNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"pipeline"]] size:CGSizeMake(30, bottomPipeHeight)];
    bottomPipeNode.anchorPoint = CGPointMake(0, 0);
    bottomPipeNode.name = @"pipe";
    bottomPipeNode.position = CGPointMake(self.size.width, _groundNode.size.height);
    [self addChild:bottomPipeNode];
//    bottomPipeNode.physicsBody = [SKPhysicsBody bodyWithTexture:bottomPipeNode.texture size:bottomPipeNode.size];
    bottomPipeNode.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, bottomPipeNode.size.width, bottomPipeNode.size.height)];
    bottomPipeNode.physicsBody.categoryBitMask = _pipeCy;
    bottomPipeNode.physicsBody.contactTestBitMask = _birdCy;
    bottomPipeNode.physicsBody.dynamic = YES;
    
}

- (void)touchDownAtPoint:(CGPoint)pos {
}

- (void)touchMovedToPoint:(CGPoint)pos {
}

- (void)touchUpAtPoint:(CGPoint)pos {
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_isGameOver) {
        
        [self removeAllChildren];
        
        [self sceneDidLoad];
        
        _isGameOver = NO;
        
        _haveStartGame = NO;
        
        _bird.physicsBody.dynamic = YES;
    }
    
    if (_haveStartGame) {
        
        [_bird.physicsBody applyImpulse:CGVectorMake(0, 20)];
        
    }else {
        [self creatPipeAction];
        _haveStartGame = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    [self over];
    
    // 避免掉落时重复调用碰撞方法
    _bird.physicsBody.dynamic = NO;
    
    // 不允许点击
    self.userInteractionEnabled = NO;
    
    _overNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"game_over"]]];
    // 设置初始位置在屏幕下方正中间的位置
    _overNode.position = CGPointMake(self.size.width/2, 0);
    _overNode.zPosition = 1;
    _overNode.name = @"over";
    [self addChild:_overNode];
    
    SKAction *showAction = [SKAction moveBy:CGVectorMake(0, self.size.height/2) duration:1];
    [_overNode runAction:showAction completion:^{
        
        self.userInteractionEnabled = YES;
        self.isGameOver = YES;
    }];
    
    SKAction *rotateAction = [SKAction rotateByAngle:1 duration:1];
    SKAction *dropAction = [SKAction moveToY:0 duration:1];
    
    // 组合动作
//    SKAction *allAction = [SKAction sequence:@[rotateAction,dropAction]];
    SKAction *allAction = [SKAction group:@[rotateAction,dropAction]];
    
    [_bird runAction:allAction completion:^{
        
        [self->_bird removeFromParent];
    }];
}
- (void)didEndContact:(SKPhysicsContact *)contact {
    
    NSLog(@"%@---%@",contact.bodyA,contact.bodyB);
}

@end
