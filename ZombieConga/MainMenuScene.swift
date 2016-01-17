//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Владимир Невинный on 17.01.16.
//  Copyright © 2016 nvovap. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    
    override func didMoveToView(view: SKView) {
        
       // self.backgroundColor = UIColor(patternImage: UIImage(named: "MainMenu")!)
        
        
        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        addChild(background)
    }
    
    func tab() {
        let wait = SKAction.waitForDuration(3.0)
        let block = SKAction.runBlock { () -> Void in
            let myScene = GameScene(size: self.size)
            
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene(myScene, transition: reveal)
            
            
            
        }
        
        self.runAction(SKAction.sequence([wait, block]))
    }
    
    
    
    
}