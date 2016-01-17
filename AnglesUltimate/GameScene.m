//
//  GameScene.m
//  AnglesUltimate
//
//  Created by xinglunxu on 9/20/15.
//  Copyright (c) 2015 xinglunxu. All rights reserved.
//
#import "GameScene.h"
#import "Ball.h"
#import "Bar.h"
#import "BlackHole.h"
#import "TotalScore.h"
#import "ComboNumber.h"
#import "Instruction.h"

NSTimer *timer;
int ballSpeed_X;
int ballSpeed_Y;
Ball *ball;
Bar *bar;
Bar *coloredBar;

const uint32_t ballBitMask = 0x1;
const uint32_t barBitMask = 0x1<<2;
const uint32_t lineBitMask = 0x1<<1;
const uint32_t blackHoleBitMask = 0x1<<3;
const uint32_t coloredBarBitMask = 0x1<<4;
const uint32_t boundaryBitMask = 0x1<<5;
const int COLOREDBAR_SIZE_FACTOR = 1;
const float ADJUSTMENT_ = 12;

int ScreenWidth;
int ScreenHeight;

float touchBeginX;
float touchBeginY;
float touchMoveX;
float touchMoveY;

bool lineReady;
bool lineAbled;
bool blackHoleReady;
bool barDamage;
bool combo;
bool beforeGame;
bool playOnScreen;

SKEmitterNode* ballEmitterGreen;
SKEmitterNode* ballEmitterRed;
SKEmitterNode* ballEmitterBlue;
SKEmitterNode* ballEmitterPurple;

SKSpriteNode* top;
SKSpriteNode* left;
SKSpriteNode* bottom;
SKSpriteNode* right;

SKShapeNode *shapeNode;
UIBezierPath *path;
TotalScore* ts;
ComboNumber* comboNumber;
int comboPoints;
SKSpriteNode *playButton;
SKSpriteNode *helpButton;
SKSpriteNode *backButton;
SKLabelNode* highestScoreLabel;
NSInteger highestScore;
Instruction* instruction;

@implementation GameScene


-(id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0,0);
    ScreenHeight= [UIScreen mainScreen].bounds.size.height;
    ScreenWidth = [UIScreen mainScreen].bounds.size.width;
    self.backgroundColor = [UIColor grayColor];
    return self;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    [self setUpBeginning];
    [self setupBounder];
    beforeGame = true;
    [self displayEndGameLabels];
    //[self startGame];
}

-(void)setUpBeginning
{
    ts = [[TotalScore alloc] initWithSize:self.frame.size];
    [self addChild:ts];
    comboNumber = [[ComboNumber alloc] initWithSize:self.size];
    comboPoints = 0;
    ball = [[Ball alloc] initWithBallImage:@"White.png"];
    
    ball.physicsBody.categoryBitMask = ballBitMask;
    ball.physicsBody.contactTestBitMask = barBitMask | lineBitMask | blackHoleBitMask| boundaryBitMask;
    ball.physicsBody.collisionBitMask = 0;
    playButton = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"play"]];
    playButton.position = CGPointMake(ScreenWidth/2, ScreenHeight/4);
    playButton.name = @"play_";
    highestScoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Regular"];
    highestScoreLabel.fontSize = 35;
    highestScoreLabel.position = CGPointMake(ScreenWidth/2, ScreenHeight/2);
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    highestScore = [nd integerForKey:@"highestScore"];
    [self addChild:highestScoreLabel];
    [self displayHighestScore];
    instruction = [[Instruction alloc] initWithSize:self.frame.size];
    [self addChild:instruction];
    [instruction hideInstructions];
    helpButton = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"Help.png"]];
    helpButton.position =  CGPointMake(ScreenWidth/2+125, ScreenHeight/4);
    backButton = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"back.png"]];
    backButton.position = CGPointMake(ScreenWidth/2, ScreenHeight/7);
    playOnScreen = true;
    
}

-(void)setupBool
{
    beforeGame = true;
    blackHoleReady = false;
    lineAbled = true;
    lineReady = false;
    barDamage = true;
    combo = false;
    
}

-(void)addChildToScene
{
    [self addChild:ball];
    [self addChild:comboNumber];
    [ball removeAllChildren];
    [self generateRandomBar];
    [NSObject cancelPreviousPerformRequestsWithTarget:ballEmitterBlue];
    [NSObject cancelPreviousPerformRequestsWithTarget:ballEmitterRed];
    [NSObject cancelPreviousPerformRequestsWithTarget:ballEmitterGreen];
    [NSObject cancelPreviousPerformRequestsWithTarget:ballEmitterPurple];
    [ballEmitterPurple removeFromParent];
    [ballEmitterGreen removeFromParent];
    [ballEmitterRed removeFromParent];
    [ballEmitterBlue removeFromParent];
    ballEmitterGreen = [self createBallEmitterGreen];
    ballEmitterRed = [self createBallEmitterRed];
    ballEmitterBlue = [self createBallEmitterBlue];
    ballEmitterPurple = [self createBallEmitterPurple];
    [ball addChild:ballEmitterGreen];
    [ball addChild:ballEmitterRed];
    [ball addChild:ballEmitterBlue];
    [ball addChild:ballEmitterPurple];
}

-(void)removeChildFromScene
{
    [ball removeFromParent];
    SKAction *comboRemoved = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode* node, CGFloat elapsedTime){
        [comboNumber removeFromParent];
        beforeGame = true;
    }];
    SKAction* sequence = [SKAction sequence:[NSArray arrayWithObjects:[SKAction waitForDuration:2], comboRemoved, nil]];
    [self runAction:sequence];
}


-(void)startGame
{
    //NSLog(@"StartGameCalled");
    [self setupBool];
    [self addChildToScene];
    ball.position= CGPointMake(100,100);
    [ball moveTowardsPoint:ScreenWidth/2 secondvalue:ScreenHeight/2];
    [ts resetscore];
    highestScoreLabel.alpha = 0;
}

-(void)update:(CFTimeInterval)currentTime {
   //NSLog(@"ball x position: %f  y position: %f", ball.position.x,ball.position.y);
}


-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    //NSLog(@"contact bitmask: %u",secondBody.categoryBitMask);
    
    if(secondBody.categoryBitMask==lineBitMask)
    {
        if(!lineReady){return;}
        [ball Collide:touchBeginX secondvalue:-touchBeginY + ScreenHeight thirdvalue:touchMoveX finalvalue:-touchMoveY + ScreenHeight];
        [shapeNode removeFromParent];
        [self createLineTouchedEmitter:contact.contactPoint];
        lineReady = false;
    }
    else if(secondBody.categoryBitMask == blackHoleBitMask){
        //NSLog(@"Check");
        [ball removeAllActions];
        [ball runAction:[ball getBallMovingAction:[Ball getBallNormalTurnSpeed]]];
    }
    else if(secondBody.categoryBitMask == boundaryBitMask)
    {
        //NSLog(@"Contact");
        if(combo){return;}
        [ball reset];
        [ball moveTowardsPoint:ScreenWidth/2 secondvalue:ScreenHeight/2];
        lineAbled = true;
        barDamage = false;
        [self restoreEmitterSpeed];
        [ts increaseScore:comboPoints];
        [comboNumber comboLost:ts.position];
        comboPoints = 0;
        if([ball damaged])
        {
            [self createBallDestroyedEmitter:ball.position];
            [self gameOver];
            return;
        }
        [self createBallDamagedEmitter:ball.position];
        
        //NSLog(@"TouchBoundary");
    }
    else{
        //NSLog(@"First Bar z: %f", bar.zPosition);
        [shapeNode removeFromParent];
        if(!barDamage){return;}
        barDamage = false;
        [ball moveTowardsPoint:ScreenWidth/2 secondvalue:ScreenHeight/2];
        [self barChanged];
        blackHoleReady = false;
    }
}

-(void)generateRandomBar
{
    if(bar.parent==self){return;}
    int direction = arc4random() % 4;
    direction =  [Bar adjustDirection:direction];
    //NSLog(@"First Direction %i", direction);
    bar = [[Bar alloc] initWithDirection:direction SecondValue:(self.frame.size)];
    bar.physicsBody.categoryBitMask = barBitMask;
    //bar.physicsBody.categoryBitMask = 0;
    bar.physicsBody.contactTestBitMask = ballBitMask;
    bar.physicsBody.collisionBitMask = 0;
    [self addChild:bar];
}

-(void)generateRandomColoredBar:(int)barDirection
{
//    int direction = arc4random() % 4;
//    if(direction == barDirection)
//    {
//        direction = (direction + 1)%4;
//    }
//    if(direction == 0 || direction == 2)
//    {
//        coloredBar = [[Bar alloc] initWithDirectionAndImageName:direction SecondValue:(self.frame.size) ImageName:@"LRRedBar"];
//        coloredBar.size = CGSizeMake(coloredBar.size.width*COLOREDBAR_SIZE_FACTOR, coloredBar.size.height*COLOREDBAR_SIZE_FACTOR);
//    }
//    else{
//        coloredBar = [[Bar alloc] initWithDirectionAndImageName:direction SecondValue:(self.frame.size) ImageName:@"TDRedBar"];
//        coloredBar.size = CGSizeMake(coloredBar.size.width*COLOREDBAR_SIZE_FACTOR, coloredBar.size.height*COLOREDBAR_SIZE_FACTOR);
//    }
//    coloredBar.physicsBody.categoryBitMask = coloredBarBitMask;
//    //bar.physicsBody.categoryBitMask = 0;
//    //bar.physicsBody.contactTestBitMask = ballBitMask;
//    coloredBar.physicsBody.collisionBitMask = 0;
//    [self addChild:coloredBar];
}

-(void)barChanged
{
    [self restoreEmitterSpeed];
    lineAbled = true;
    combo =false;
    if([ball getTurnDamageLeft] > [bar getLifePoint])
    {
        [ball turnDamageWeaken:[bar getLifePoint]];
        comboPoints+=[bar getLifePoint];
        [comboNumber combo:comboPoints];
        combo = true;
    }
    else if([ball getTurnDamageLeft] == [bar getLifePoint])
    {
        [ball turnDamageWeaken:[bar getLifePoint]];
        comboPoints+=[bar getLifePoint];
        [comboNumber combo:comboPoints];
        [ball increaseAttack];
    }
    else
    {
        [bar damaged:[ball getTurnDamageLeft]];
        comboPoints+=[ball getTurnDamageLeft];
        [comboNumber combo:comboPoints];
        //NSLog(@"Second Bar collision bitmask: %i", bar.physicsBody.collisionBitMask);
        [ball turnDamageWeaken:1];
        barDamage = false;
        [self createBarDamaged:bar.position];
        [ball increaseAttack];
        return;
    }
    [self createBarExplosion:bar.position];
    [NSObject cancelPreviousPerformRequestsWithTarget:bar];
    [bar removeFromParent];
    [self generateRandomBar];
    
    if(combo)
    {
        [self speedUpEmitterSpeed];
        lineAbled = false;
        barDamage = true;
        [ball speedUpTowardPoint:bar.position];
    }
//    if(coloredBar)
//    {
//        [coloredBar gone];
//    }
//    int coloredBarBool = arc4random()%1;
//    if(coloredBarBool == 0)
//    {
//        [self generateRandomColoredBar:[bar getDirection]];
//    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!lineAbled){return;}
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    //SKNode *node = [self nodeAtPoint:touchPoint];
    [shapeNode removeFromParent];
    shapeNode.strokeColor = [UIColor blackColor];
    touchBeginX = touchPoint.x;
    touchBeginY = touchPoint.y;
    
    shapeNode = [SKShapeNode node];
    shapeNode.strokeColor = [UIColor whiteColor];
    shapeNode.lineWidth = 5.0f;
    [self addChild:shapeNode];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!lineAbled){return;}
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(touchBeginX, -touchBeginY + ScreenHeight)];
    [path addLineToPoint:CGPointMake(touchPoint.x, -touchPoint.y + ScreenHeight)];
    shapeNode.path = path.CGPath;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    if(beforeGame && playOnScreen && [playButton containsPoint:CGPointMake(touchPoint.x, -touchPoint.y+ScreenHeight)])
    {
        //NSLog(@"playTouched");
        [playButton removeFromParent];
        [helpButton removeFromParent];
        [self startGame];
        beforeGame = false;
        return;
    }
    else if(beforeGame && [helpButton containsPoint:CGPointMake(touchPoint.x, -touchPoint.y+ScreenHeight)])
    {
        [self hideToShowHelp];
        [self addChild:backButton];
        return;
    }
    else if(beforeGame && !playOnScreen && [backButton containsPoint:CGPointMake(touchPoint.x, -touchPoint.y+ScreenHeight)])
    {
        [self returnMenu];
        [backButton removeFromParent];
        return;
    }
    if(!lineAbled){return;}
    touchMoveX = touchPoint.x; touchMoveY = touchPoint.y;
    if(touchBeginX == touchMoveX && touchBeginY == touchMoveY)
    {
        return;
    }
    [path moveToPoint:CGPointMake(touchBeginX, -touchBeginY + ScreenHeight)];
    [path addLineToPoint:CGPointMake(touchPoint.x, -touchPoint.y + ScreenHeight)];
    shapeNode.path = path.CGPath;
    shapeNode.strokeColor = [UIColor blackColor];
    shapeNode.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path.CGPath];
    shapeNode.physicsBody.categoryBitMask = lineBitMask;
    shapeNode.physicsBody.collisionBitMask = 0;
    lineReady = true;
    lineAbled = false;
    [ball speedUp];
    [self speedUpEmitterSpeed];
    [ball resetTurnDamage];
    [self createLineSetEmitter:CGPointMake((touchBeginX+touchMoveX)/2, -(touchBeginY+touchMoveY)/2 + ScreenHeight)];
    blackHoleReady = false;
    barDamage = true;
}

- (SKEmitterNode *) createBarExplosion:(CGPoint)p
{
    NSString *barExplo = [[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"sks"];
    SKEmitterNode *explode = [NSKeyedUnarchiver unarchiveObjectWithFile:barExplo];
    [explode setTargetNode:self];
    explode.numParticlesToEmit = 50;
    explode.particlePosition = p;
    [self addChild:explode];
    SKAction *delayAction = [SKAction waitForDuration:4];
    SKAction *selfRemoveAction = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime)
                                  {
                                      [NSObject cancelPreviousPerformRequestsWithTarget:explode];
                                      [explode removeFromParent];
                                  }];
    SKAction* sequence = [SKAction sequence:[NSArray arrayWithObjects:delayAction,selfRemoveAction, nil]];
    [self runAction: sequence];
    return explode;
}

- (SKEmitterNode *) createBarDamaged:(CGPoint)p
{
    NSString *barDamage = [[NSBundle mainBundle] pathForResource:@"BarDamagedEmitter" ofType:@"sks"];
    SKEmitterNode *damage = [NSKeyedUnarchiver unarchiveObjectWithFile:barDamage];
    [damage setTargetNode:self];
    damage.numParticlesToEmit = 25;
    damage.particlePosition = p;
    [self addChild:damage];
    SKAction *delayAction = [SKAction waitForDuration:2];
    SKAction *selfRemoveAction = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime)
                                  {
                                      [NSObject cancelPreviousPerformRequestsWithTarget:damage];
                                      [damage removeFromParent];
                                  }];
    SKAction* sequence = [SKAction sequence:[NSArray arrayWithObjects:delayAction,selfRemoveAction, nil]];
    [self runAction: sequence];
    return damage;
}

- (SKEmitterNode *) createBallEmitterGreen
{
    NSString *ballEmitter = [[NSBundle mainBundle] pathForResource:@"BallEmitterGreen" ofType:@"sks"];
    SKEmitterNode *ball = [NSKeyedUnarchiver unarchiveObjectWithFile:ballEmitter];
    [ball setTargetNode:self];
    return ball;
}

- (SKEmitterNode *) createBallEmitterRed
{
    NSString *ballEmitter = [[NSBundle mainBundle] pathForResource:@"BallEmitterRed" ofType:@"sks"];
    SKEmitterNode *ball = [NSKeyedUnarchiver unarchiveObjectWithFile:ballEmitter];
    [ball setTargetNode:self];
    return ball;
}

- (SKEmitterNode *) createBallEmitterBlue
{
    NSString *ballEmitter = [[NSBundle mainBundle] pathForResource:@"BallEmitterBlue" ofType:@"sks"];
    SKEmitterNode *ball = [NSKeyedUnarchiver unarchiveObjectWithFile:ballEmitter];
    [ball setTargetNode:self];
    return ball;
}

- (SKEmitterNode *) createBallEmitterPurple
{
    NSString *ballEmitter = [[NSBundle mainBundle] pathForResource:@"BallEmitterPurple" ofType:@"sks"];
    SKEmitterNode *ball = [NSKeyedUnarchiver unarchiveObjectWithFile:ballEmitter];
    [ball setTargetNode:self];
    return ball;
}

-(void)createBlackHole:(Ball*) ball createPosition:(CGPoint)p
{
    //NSLog(@"blackholechecked");
    BlackHole* bh = [[BlackHole alloc] initWithImageNamed:@"BlackHole"];
    bh.position = CGPointMake(p.x, -p.y+ScreenHeight);
    bh.size = CGSizeMake(40, 40);
    bh.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bh.size];
    bh.physicsBody.categoryBitMask = blackHoleBitMask;
    bh.physicsBody.collisionBitMask = 0;
    [self addChild:bh];
    [bh pullParticle:ballEmitterBlue];
    [bh pullParticle:ballEmitterGreen];
    [bh pullParticle:ballEmitterPurple];
    [bh pullParticle:ballEmitterRed];
    [bh pullBall:ball];
}


- (SKEmitterNode *) createLineSetEmitter:(CGPoint)p
{
    NSString *s = [[NSBundle mainBundle] pathForResource:@"LineSet" ofType:@"sks"];
    SKEmitterNode *lineSetEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:s];
    [lineSetEmitter setTargetNode:self];
    lineSetEmitter.position = p;
    lineSetEmitter.numParticlesToEmit = 40;
    [self addChild:lineSetEmitter];
    SKAction *delayAction = [SKAction waitForDuration:0.5];
    SKAction *selfRemoveAction = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:lineSetEmitter];
            [lineSetEmitter removeFromParent];
          }];
    SKAction* sequence = [SKAction sequence:[NSArray arrayWithObjects:delayAction,selfRemoveAction, nil]];
    [self runAction: sequence];
    return lineSetEmitter;
}

- (SKEmitterNode *) createLineTouchedEmitter:(CGPoint)p
{
    NSString *s = [[NSBundle mainBundle] pathForResource:@"LineTouchedEmitter" ofType:@"sks"];
    SKEmitterNode *lineTouched = [NSKeyedUnarchiver unarchiveObjectWithFile:s];
    [lineTouched setTargetNode:self];
    lineTouched.position = p;
    lineTouched.numParticlesToEmit = 20;
    [self addChild:lineTouched];
    SKAction *delayAction = [SKAction waitForDuration:0.5];
    SKAction *selfRemoveAction = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime)
                                  {
                                      [NSObject cancelPreviousPerformRequestsWithTarget:lineTouched];
                                      [lineTouched removeFromParent];
                                  }];
    SKAction* sequence = [SKAction sequence:[NSArray arrayWithObjects:delayAction,selfRemoveAction, nil]];
    [self runAction: sequence];
    return lineTouched;
}

- (SKEmitterNode *) createBallDamagedEmitter:(CGPoint)p
{
    NSString *s = [[NSBundle mainBundle] pathForResource:@"BallDamaged" ofType:@"sks"];
    SKEmitterNode *lineTouched = [NSKeyedUnarchiver unarchiveObjectWithFile:s];
    [lineTouched setTargetNode:self];
    lineTouched.position = p;
    lineTouched.numParticlesToEmit = 30;
    [self addChild:lineTouched];
    SKAction *delayAction = [SKAction waitForDuration:2];
    SKAction *selfRemoveAction = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime)
                                  {
                                      [NSObject cancelPreviousPerformRequestsWithTarget:lineTouched];
                                      [lineTouched removeFromParent];
                                  }];
    SKAction* sequence = [SKAction sequence:[NSArray arrayWithObjects:delayAction,selfRemoveAction, nil]];
    [self runAction: sequence];
    return lineTouched;
}


- (SKEmitterNode *) createBallDestroyedEmitter:(CGPoint)p
{
    NSString *s = [[NSBundle mainBundle] pathForResource:@"BallDestroyed" ofType:@"sks"];
    SKEmitterNode *lineTouched = [NSKeyedUnarchiver unarchiveObjectWithFile:s];
    [lineTouched setTargetNode:self];
    lineTouched.position = p;
    lineTouched.numParticlesToEmit = 50;
    [self addChild:lineTouched];
    SKAction *delayAction = [SKAction waitForDuration:2];
    SKAction *selfRemoveAction = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime)
                                  {
                                      [NSObject cancelPreviousPerformRequestsWithTarget:lineTouched];
                                      [lineTouched removeFromParent];
                                  }];
    SKAction* sequence = [SKAction sequence:[NSArray arrayWithObjects:delayAction,selfRemoveAction, nil]];
    [self runAction: sequence];
    return lineTouched;
}


-(void)speedUpEmitterSpeed
{
    ballEmitterGreen.particleBirthRate = 15;
    ballEmitterRed.particleBirthRate = 15;
    ballEmitterBlue.particleBirthRate = 15;
    ballEmitterPurple.particleBirthRate = 15;
}

-(void)restoreEmitterSpeed
{
    ballEmitterGreen.particleBirthRate = 1;
    ballEmitterRed.particleBirthRate = 1;
    ballEmitterBlue.particleBirthRate = 1;
    ballEmitterPurple.particleBirthRate = 1;
}

-(void)setupBounder
{
    //SKSpriteNode* top = [SKSpriteNode node];
    top = [[SKSpriteNode alloc] initWithImageNamed:@"TBBar1"];
    left= [[SKSpriteNode alloc] initWithImageNamed:@"LRBar1"];
    bottom=  [[SKSpriteNode alloc] initWithImageNamed:@"TBBar1"];
    right= [[SKSpriteNode alloc] initWithImageNamed:@"LRBar1"];
    
    top.position = CGPointMake(ScreenWidth/2, ScreenHeight+ADJUSTMENT_);
    top.size = CGSizeMake(ScreenWidth, 0.01);
    top.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:top.size];
    top.physicsBody.categoryBitMask = boundaryBitMask;
    top.physicsBody.collisionBitMask = 0;
    top.physicsBody.contactTestBitMask = 0;
    top.zPosition = -1;
    left.position = CGPointMake(-ADJUSTMENT_, ScreenHeight/2);
    left.size = CGSizeMake(0.01, ScreenHeight);
    left.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:left.size];
    left.physicsBody.categoryBitMask = boundaryBitMask;
    left.physicsBody.collisionBitMask = 0;
    left.zPosition = -1;
    left.physicsBody.contactTestBitMask = 0;
    right.position = CGPointMake(ScreenWidth+ADJUSTMENT_, ScreenHeight/2);
    right.size = CGSizeMake(0.01, ScreenHeight);
    right.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:right.size];
    right.physicsBody.categoryBitMask = boundaryBitMask;
    right.physicsBody.collisionBitMask = 0;
    right.physicsBody.contactTestBitMask = 0;
    right.zPosition = -1;
    bottom.position = CGPointMake(ScreenWidth/2, -ADJUSTMENT_);
    bottom.size =CGSizeMake(ScreenWidth, 0.01);
    bottom.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottom.size];
    bottom.physicsBody.categoryBitMask = boundaryBitMask;
    bottom.physicsBody.collisionBitMask = 0;
    bottom.physicsBody.contactTestBitMask = 0;
    bottom.zPosition = -1;
    [self addChild:top];
    [self addChild:left];
    [self addChild:right];
    [self addChild:bottom];
}


-(void)gameOver
{
    [self ballExplode];
    [self removeChildFromScene];
    [NSObject cancelPreviousPerformRequestsWithTarget:bar];
    [bar removeFromParent];
    [self displayEndGameLabels];
    [self updateHighestScore:[ts getScore]];
    [self displayHighestScore];
    lineAbled = false;
}

-(void)ballExplode
{
    [ball removeAllActions];
}

-(void)displayEndGameLabels
{
    [self addChild:playButton];
    [self addChild:helpButton];
}

-(void)displayHighestScore
{
    highestScoreLabel.alpha = 1;
    highestScoreLabel.text = [NSString stringWithFormat:@"Highest Score: %li", (long)highestScore];
}

-(void)updateHighestScore:(int)score
{
    NSUserDefaults* data = [NSUserDefaults standardUserDefaults];
    highestScore = [data integerForKey:@"highestScore"];
    int currentScore = [ts getScore];
    if(!highestScore)
    {
        highestScore = currentScore;
        [data setInteger:highestScore forKey:@"highestScore"];
        return;
    }
    if(currentScore > highestScore)
    {
        highestScore = currentScore;
        [data setInteger:highestScore forKey:@"highestScore"];
    }
}

-(void)hideToShowHelp
{
    playOnScreen = false;
    [playButton removeFromParent];
    [helpButton removeFromParent];
    [instruction displayInstructions];
    [ts removeFromParent];
    [highestScoreLabel removeFromParent];
}

-(void)returnMenu
{
    playOnScreen = true;
    [self addChild:playButton];
    [self addChild:helpButton];
    [instruction hideInstructions];
    [self addChild:ts];
    [self addChild:highestScoreLabel];
    
}

@end
