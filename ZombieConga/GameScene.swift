//
//  GameScene.swift
//  ZombieConga
//
//  Created by nvovap on 12/29/15.
//  Copyright (c) 2015 nvovap. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var zombie: SKSpriteNode!
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity: CGPoint = CGPoint.zero
    
    //playable rectangle 
    let playableRect: CGRect
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        super.init(size: size)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //helper method to draw "Playable rectangle"
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        //shape.zPosition = 2.0
        addChild(shape)
    }
    
    //
    
    func sceneTouched(touchLocation: CGPoint) {
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        sceneTouched(touchLocation)
    }
    
    //=========================================
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
        
        
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        let background = SKSpriteNode(imageNamed: "background1")
        
        background.zPosition = -1
        
        addChild(background)
        
        //background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        background.anchorPoint = CGPoint.zero
        
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
//        
//        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
//            background.zRotation = CGFloat(M_PI) / 8
//        }
        
        
        zombie = SKSpriteNode(imageNamed: "zombie1")
        
        zombie.position = CGPoint(x: 400, y: 400)
        
        addChild(zombie)
        
        debugDrawPlayableArea()
        
        
        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        //zombie.position = CGPoint(x: zombie.position.x + 8 , y: zombie.position.y)
        //moveSprite(zombie, velocity: CGPoint(x: zombieMovePointsPerSec, y: 0))
        moveSprite(zombie, velocity: velocity)
        rotateSprite(zombie, direction: velocity)
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
        
        boundsCheckZombie()
        
      //  print("\(dt * 1000) milliseconds since last update")
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = CGFloat(atan2(direction.y, direction.x))
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        
    //    print("Amount to move: \(amountToMove)")
        
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
        
        
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - zombie.position.x, y: location.y - zombie.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        
        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec, y: direction.y * zombieMovePointsPerSec)
        
    }
}