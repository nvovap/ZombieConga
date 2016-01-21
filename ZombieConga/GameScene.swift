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
    let cameraNode = SKCameraNode()
    var invincibleZombie = false
    
    var lives = 5
    var gameOver = false
    
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    let zombieMovePointsPerSec: CGFloat = 480.0
    let catsTrainMovePointsPerSec: CGFloat = 480.0
    let zombieRotateRadiansPerSec: CGFloat  = 4.0 * π
    let cameraMovePointsPerSec: CGFloat = 200.0
    
    
    var velocity: CGPoint = CGPoint.zero
    var lastTouchLocation: CGPoint?
    var lastAngle: CGFloat = 0
    
    //playable rectangle 
    let playableRect: CGRect
    
    let zombieAnimation: SKAction
    
    
    let hitCatSoubd = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let hitCatLadySound = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    let livesLable = SKLabelNode(fontNamed: "Chalkduster")
    
    var cameraRect: CGRect {
        return CGRect(x: getCameraPosition().x - size.width/2 + (size.width - playableRect.width)/2,
                      y: getCameraPosition().y - size.height/2 + (size.height - playableRect.height)/2,
                      width: playableRect.width, height: playableRect.height)
    }
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        var textures: [SKTexture] = []
        
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        
        super.init(size: size)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        
        
        playBackgroundMusic("backgroundMusic.mp3")
        //backgroundMusicPlayer.stop()
        
        //Create background
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            background.zPosition = -1
            addChild(background)
        }
        
        
        //background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
       
        
        //        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        //
        //        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
        //            background.zRotation = CGFloat(M_PI) / 8
        //        }
        
        
        zombie = SKSpriteNode(imageNamed: "zombie1")
        
        zombie.position = CGPoint(x: 400, y: 400)
        
        zombie.zPosition = 100
        
        addChild(zombie)
        
        //  zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
        
      //  debugDrawPlayableArea()
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock({ () -> Void in
            self.spawnEnemy()
        }), SKAction.waitForDuration(2.0)])))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)])))
        
        addChild(cameraNode)
        
        camera = cameraNode
        
        setCameraPosition(CGPoint(x: size.width/2, y: size.height/2))
        
        
        livesLable.text = "Lives: X"
        livesLable.fontColor = SKColor.blackColor()
        livesLable.fontSize = 100
        livesLable.zPosition = 100
        
        livesLable.horizontalAlignmentMode = .Left
        livesLable.verticalAlignmentMode = .Bottom
        
        livesLable.position = CGPoint(x: -playableRect.size.width/2 + CGFloat(20), y: -playableRect.size.height/2 +  CGFloat(20) + overlapAmount()/2)
        
        cameraNode.addChild(livesLable)
        
    }
    
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize(width: background1.size.width+background2.size.width, height: background1.size.height)
        
        return backgroundNode
    }
    
    
    //MARK: - Camera movement compensation
    func overlapAmount() -> CGFloat {
        guard let view = self.view else {
            return 0
        }
        
        let scale = view.bounds.size.width / self.size.width
        let scaledHeight = self.size.height * scale
        let scaleOverlap = scaledHeight - view.bounds.size.height
        
        return scaleOverlap / scale
        
    }
    
    func getCameraPosition() -> CGPoint {
        return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + overlapAmount()/2)
    }
    
    func setCameraPosition(position: CGPoint) {
        cameraNode.position = CGPoint(x: position.x, y: position.y - overlapAmount()/2)
    }
    
    //MARK: - Helper method to draw "Playable rectangle"
    
    func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodesWithName("background") { (node, _) -> Void in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x + background.size.width*2, y: background.position.y)
                
            }
        }
    }
    
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
        
        lastTouchLocation = touchLocation
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        lastTouchLocation = touchLocation
        sceneTouched(touchLocation)
    }
    
    //=========================================
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: CGRectGetMinX(cameraRect), y: CGRectGetMinY(cameraRect))
        let topRight   = CGPoint(x: CGRectGetMaxX(cameraRect), y: CGRectGetMaxY(cameraRect))
        
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
        
        
//        if let lastTouchLocation = lastTouchLocation {
//            let offset = lastTouchLocation - zombie.position
//            let length = offset.length() - zombieMovePointsPerSec * CGFloat(dt)
//            
//            //print(length)
//            
//            if length <= 0 {
//                velocity = CGPoint.zero
//                zombie.position = lastTouchLocation
//            }
//        }
        
        
        
        
    }
    
    
    //MARK: -  HIT
    func zombieHitCat(cat: SKSpriteNode) {
        //cat.removeFromParent()
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0
        
        cat.runAction(SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor: 100, duration: 2))
        
        runAction(hitCatSoubd)
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode) {
        enemy.removeFromParent()
        runAction(hitCatLadySound)
        
        //Blink action 
        //let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) { (node, elapsedTime) -> Void in
           // let slice  = duration / blinkTimes
            let remainder = Double(elapsedTime) % 0.3
            node.hidden = remainder > 0.15 //slince/2
        }
        
        invincibleZombie = true
        
        zombie.runAction(blinkAction) { () -> Void in
            self.invincibleZombie = false
            self.zombie.hidden    = false
        }
        
        loseCats()
        lives--
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        
        enumerateChildNodesWithName("cat") { (node, _) -> Void in
        let cat = node as! SKSpriteNode
        if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
            hitCats.append(cat)
        }
        }
        
        for cat in hitCats {
            zombieHitCat(cat)
        }
        
        if invincibleZombie != true {
            var hitEnemies: [SKSpriteNode] = []
            enumerateChildNodesWithName("enemy") { (node, _) -> Void in
                let enemy = node as! SKSpriteNode
                if CGRectIntersectsRect(CGRectInset(enemy.frame, 20, 20), self.zombie.frame) {
                    hitEnemies.append(enemy)
                }
            }
        
            for enemy in hitEnemies {
                zombieHitEnemy(enemy)
            }
        }
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: CGRectGetMaxX(cameraRect) + enemy.size.width/2 , y: CGFloat.random(min: CGRectGetMinY(cameraRect) + enemy.size.height/2, max: CGRectGetMaxY(cameraRect) - enemy.size.height/2))
        addChild(enemy)
        
       // let actionMove = SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        let actionMove = SKAction.moveByX(-playableRect.width, y: 0.0, duration: 2.0)
        
        let actionRemove = SKAction.removeFromParent()
        
        
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
        
        enemy.name =  "enemy"
    }
    
    func loseCats() {
        
        var loseCount = 0
        
        enumerateChildNodesWithName("train") { (node, stop) -> Void in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            
            node.name = ""
            
            node.runAction(SKAction.sequence([
                SKAction.group([
                    SKAction.rotateByAngle(π*4, duration: 1.0),
                    SKAction.moveTo(randomSpot, duration: 1.0),
                    SKAction.scaleXTo(0, duration: 1.0)
                                ]),
                    SKAction.removeFromParent()
                ]))
            
            loseCount++
            if loseCount >= 2 {
                stop.memory = true
            }
            
            
            
        }
        
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(x: CGFloat.random(min: CGRectGetMinX(cameraRect), max:  CGRectGetMaxX(cameraRect))
            , y: CGFloat.random(min: CGRectGetMinY(cameraRect), max:  CGRectGetMaxY(cameraRect)))
        cat.zPosition = 50
        cat.setScale(0)
        
        addChild(cat)
        
        
        //Cats wiggle
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
       // let wiggleWait = SKAction.repeatAction(fullWiggle, count: 10)
        
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        
        //Cats appear
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
       // let wait = SKAction.waitForDuration(10.0)
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        
        
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
        
        cat.name = "cat"
    }
    
    func startZombieAnimation() {
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeActionForKey("animation")
    }
    

    
    
    override func update(currentTime: CFTimeInterval) {
        //zombie.position = CGPoint(x: zombie.position.x + 8 , y: zombie.position.y)
        //moveSprite(zombie, velocity: CGPoint(x: zombieMovePointsPerSec, y: 0))
       
        
        moveSprite(zombie, velocity: velocity)
        rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
        
        if let lastTouchLocation = lastTouchLocation {
            let distance = lastTouchLocation - zombie.position
            
            if distance.length() <= (zombieMovePointsPerSec * CGFloat(dt)) {
                zombie.position = lastTouchLocation
                velocity = CGPoint.zero
                stopZombieAnimation()
            }
            
        }
        
        boundsCheckZombie()
        
        moveTrain()
      //  print("\(dt * 1000) milliseconds since last update")
        moveCamera()
        
        
        if lives <= 0 && gameOver == false {
            gameOver = true
            print("You lose!")
            
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
       // cameraNode.position = zombie.position
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    
    
    //MARK: - Movement Zombie
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate  
        
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        //let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        
    //    print("Amount to move: \(amountToMove)")
        
       // sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
        
        let amountToMove = velocity * CGFloat(dt)
        
        sprite.position += amountToMove
        
        
    }
    
    func moveTrain() {
        var targetPosition = zombie.position
        
        var trainCount = 0
        
        enumerateChildNodesWithName("train"){
            node, _ in
            
            trainCount++
            
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catsTrainMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                
                let moveToMove = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
                
                node.runAction(moveToMove)
                
            }
            
            targetPosition = node.position
            
        }
        
        if trainCount >= 15 // && !gameOver {
        {
            gameOver = true
            print("You win!")
            
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            
            
            view?.presentScene(gameOverScene, transition: reveal)
            
        }
    }
    
    func moveZombieToward(location: CGPoint) {
        /*let offset = CGPoint(x: location.x - zombie.position.x, y: location.y - zombie.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        
        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec, y: direction.y * zombieMovePointsPerSec)*/
        
        let offset = location - zombie.position
       
        let direction = offset.normalized()
        
        velocity = direction * zombieMovePointsPerSec
        
        startZombieAnimation()
    }
}
