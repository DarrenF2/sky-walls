//
//  GameScene.swift
//  Space_game1
//
//  Created by Darren Freeman on 7/15/18.
//  Copyright © 2018 Darren Freeman. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit
import CoreMotion

struct physicsCategory {
    static let player : UInt32 = 0x1 << 1
    
    
   
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Starfield:SKEmitterNode!
    var player:SKSpriteNode!
    
    var pointsLabel:SKLabelNode!
    var points:Int = 0 {
        didSet  {
            pointsLabel.text = "points = \(points)"
            
        }
        
    }
    
    
    let enemiesCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    let wallPairCategory:UInt32 = 0x1 << 0
    let ScoreGoalCategory:UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        Starfield = SKEmitterNode(fileNamed: "Starfield")
        Starfield.position = CGPoint(x:436, y:1472)
        Starfield.advanceSimulationTime(10)
        self.addChild(Starfield)
        
        Starfield.zPosition = -1
        
        
        player = SKSpriteNode(imageNamed: "redship")
        
        player.position = CGPoint(x: self.frame.size.width / 2 , y: player.size.height / 2 + 20)
        self.anchorPoint = CGPoint(x:0 , y:0)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.frame.height / 2)
        player.physicsBody?.categoryBitMask = physicsCategory.player
        player.physicsBody?.collisionBitMask = wallPairCategory
        player.physicsBody?.contactTestBitMask = ScoreGoalCategory | wallPairCategory
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        
        self.addChild(player)
        
        
        pointsLabel = SKLabelNode(text: "points = 0")
        pointsLabel.position = CGPoint(x: 160, y: self.frame.size.height - 60)
        pointsLabel.fontName = "Futura-CondensedExtraBold"
        pointsLabel.fontSize = 58
        pointsLabel.fontColor = UIColor.white
        points = 0
        
        self.addChild(pointsLabel)
        
       
        
       motionManager.accelerometerUpdateInterval = 0
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        
    }
   
        createWalls()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }
    
    func fireTorpedo() {
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let torpedoNode = SKSpriteNode(imageNamed:"torpedo")
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = enemiesCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        
        let animationDuration:TimeInterval = 0.3
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
       
        torpedoNode.run(SKAction.sequence(actionArray))
        
        
        
    }
    func createWalls(){
        
        let scoreNode = SKSpriteNode()
        
        scoreNode.size = CGSize(width: 200, height: 1)
        scoreNode.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 460)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.categoryBitMask = ScoreGoalCategory
        scoreNode.physicsBody?.contactTestBitMask = physicsCategory.player
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        
       
        
        let wallPair = SKSpriteNode()
        
        let randomWallPosition = GKRandomDistribution(lowestValue: -212, highestValue: 212)
        let position = CGFloat(randomWallPosition.nextInt())
        
        let leftWall = SKSpriteNode(imageNamed: "wall1")
        let rightWall = SKSpriteNode(imageNamed: "wall2")
        
        leftWall.position = CGPoint(x: self.frame.width / 2 - 350, y: self.frame.height / 460)
         rightWall.position = CGPoint(x: self.frame.width / 2 + 350, y: self.frame.height / 460)
        wallPair.addChild(scoreNode)
    
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody?.categoryBitMask = wallPairCategory
        leftWall.physicsBody?.collisionBitMask = physicsCategory.player
        leftWall.physicsBody?.contactTestBitMask = physicsCategory.player
        leftWall.physicsBody?.isDynamic = true
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.usesPreciseCollisionDetection = true
        
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.categoryBitMask = wallPairCategory
        rightWall.physicsBody?.collisionBitMask = physicsCategory.player
        rightWall.physicsBody?.contactTestBitMask = physicsCategory.player
        rightWall.physicsBody?.isDynamic = true
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.usesPreciseCollisionDetection = true
        
        
        
        leftWall.setScale(0.5)
        rightWall.setScale(0.5)
        
        wallPair.addChild(leftWall)
        wallPair.addChild(rightWall)
        
        self.addChild(wallPair)
      
        wallPair.position = CGPoint(x: position, y: self.frame.size.height + wallPair.size.height * 2)
        
        wallPair.physicsBody = SKPhysicsBody(rectangleOf: wallPair.size)
        wallPair.physicsBody?.categoryBitMask = wallPairCategory
        wallPair.physicsBody?.contactTestBitMask = physicsCategory.player
        wallPair.physicsBody?.isDynamic = true
        wallPair.physicsBody?.usesPreciseCollisionDetection = true
        
        let animationDuration:TimeInterval = 3.2
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: wallPair.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        
        
        wallPair.run(SKAction.sequence(actionArray))
       
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
    
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
       
        if firstBody.categoryBitMask == physicsCategory.player && secondBody.categoryBitMask == ScoreGoalCategory || firstBody.categoryBitMask == ScoreGoalCategory && secondBody.categoryBitMask == physicsCategory.player {
            points += 1
        }
        func didBegin(_contact: SKPhysicsContact) {
            var firstBody:SKPhysicsBody
            var secondBody:SKPhysicsBody
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
            
        if (firstBody.categoryBitMask & physicsCategory.player) != 0 && (secondBody.categoryBitMask & wallPairCategory) != 0 {
            playerDidCollideWithWall(playerNode: firstBody.node as! SKSpriteNode, wallNode: secondBody.node as! SKSpriteNode)
        }
    }
        func playerDidCollideWithWall(playerNode: SKSpriteNode, wallNode: SKSpriteNode){
           let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = playerNode.position
            self.addChild(explosion)
            
            self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
            
            playerNode.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
                
            }
        }
                
        
        }

    
    override func didSimulatePhysics() {
        
        player.position.x += xAcceleration * 50
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
   
                
            }
    override func update(_ currentTime: TimeInterval) {
        // called before eache frame is rendered
    }
    
    }
    

