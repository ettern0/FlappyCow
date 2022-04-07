//
//  GameScene.swift
//  NotificationContentExtension
//
//  Created by Alexey Salangin on 06.04.2022.
//  Copyright © 2022 Granda L. All rights reserved.
//

import AVFoundation
import SpriteKit

final class GameScene: SKScene {
    private let impact = UIImpactFeedbackGenerator()
    
    private let pipeTextureUp: SKTexture = {
        $0.filteringMode = .nearest
        return $0
    }(SKTexture(imageNamed: "PipeUp"))

    private let pipeTextureDown: SKTexture = {
        $0.filteringMode = .nearest
        return $0
    }(SKTexture(imageNamed: "PipeDown"))

    private let groundTexture: SKTexture = {
        $0.filteringMode = .nearest
        return $0
    }(SKTexture(imageNamed: "land"))

    private var cowTextures = [SKTexture(), SKTexture(), SKTexture()]
    private var skyNodes = [SKSpriteNode]()
    
    private let verticalPipeGap: CGFloat = 130.0
    private var moving = SKNode()
    private var pipes = SKNode()
    
    private var score = 0 {
        didSet {
            scoreLabelNode.text = String(score)
            scoreLabelNodeInside.text = String(score)
        }
    }
    
    private var firstTouch = false
    private var afterGameOver = false
    private var gameOverDisplayed = false
    private var hitGround = false
    
    private let notification = UINotificationFeedbackGenerator()
    
    private lazy var scoreLabelNode: SKLabelNode = {
        $0.fontColor = SKColor.black
        $0.fontSize = 50
        $0.position = CGPoint(x: width / 2, y: 3 * height / 4)
        $0.zPosition = ZPosition.score
        return $0
    }(SKLabelNode(fontNamed: "inside"))

    private lazy var scoreLabelNodeInside: SKLabelNode = {
        $0.fontColor = SKColor.white
        $0.fontSize = 50
        $0.position = CGPoint(x: width / 2 - 1.5, y: 3 * height / 4 + 1.5)
        $0.zPosition = ZPosition.score + 1
        return $0
    }(SKLabelNode(fontNamed: "inside"))

    private lazy var gameover: SKSpriteNode = {
        $0.texture?.filteringMode = .nearest
        $0.setScale(1.5)
        $0.zPosition = ZPosition.score
        $0.position = CGPoint(x: width / 2, y: (height / 2) + 210)
        return $0
    }(SKSpriteNode(texture: SKTexture(imageNamed: "gameover")))
    
      private lazy var getReady: SKSpriteNode = {
          $0.texture?.filteringMode = .nearest
        $0.setScale(1.2)
        $0.position = CGPoint(x: width / 2, y: (height / 2) + 130)
        return $0
    }(SKSpriteNode(texture: SKTexture(imageNamed: "get-ready")))
    
    private lazy var taptap: SKSpriteNode = {
        $0.texture?.filteringMode = .nearest
        $0.setScale(1.5)
        $0.position = CGPoint(x: width / 2, y: height / 2)
        return $0
    }(SKSpriteNode(texture: SKTexture(imageNamed: "taptap")))
    
    private lazy var cow: SKSpriteNode = {
        $0.texture?.filteringMode = .nearest
        $0.setScale(1.5)
        $0.zPosition = ZPosition.hero
        $0.position = CGPoint(x: (width / 2), y: (height / 2) + 75)

        let body = SKPhysicsBody(circleOfRadius: $0.height / 2.0)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.hero
        body.collisionBitMask = PhysicsCategory.land | PhysicsCategory.pipe
        body.contactTestBitMask = PhysicsCategory.land | PhysicsCategory.pipe

        $0.physicsBody = body
        return $0
    }(SKSpriteNode(texture: SKTexture(imageNamed: "classic-cow-1")))
    
    private let floatUpAndDown = SKAction.sequence([
        SKAction.moveBy(x: 0, y: 35, duration: 1.0),
        SKAction.moveBy(x: 0, y: -35, duration: 1.0)
    ])
    
    private func setRandomcowTextures() {
        let randomNewcow = ["classic-cow"].randomElement()!
        for n in 0...2 {
            let texture = SKTexture(imageNamed: "\(randomNewcow)-\(n + 1)")
            texture.filteringMode = .nearest
            cowTextures[n] = texture
        }
        let anim = SKAction.animate(with: [cowTextures[0], cowTextures[1], cowTextures[2], cowTextures[1]], timePerFrame: 0.1)
        cow.run(SKAction.repeatForever(anim))
    }
    
    private lazy var ground: SKNode = {
        $0.position = CGPoint(x: 0, y: groundTexture.height)
        $0.zPosition = ZPosition.land
        let body = SKPhysicsBody(rectangleOf: CGSize(width: width, height: groundTexture.height * 2.0))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.land
        $0.physicsBody = body
        return $0
    }(SKNode())

    private func setGravityAndPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -12.0)
        physicsWorld.contactDelegate = self
    }
    
    private func setGroundMoving() {
        let groundWidth = groundTexture.width * 2.0
        let moveGroundSprite = SKAction.moveBy(x: -groundWidth, y: 0, duration: TimeInterval(0.005 * groundWidth))
        let resetGroundSprite = SKAction.moveBy(x: groundWidth, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        for i in 0..<3 + Int(width / groundWidth) {
            let child = SKSpriteNode(texture: groundTexture)
            child.setScale(2.0)
            child.position = CGPoint(x: CGFloat(i) * (child.width - 1), y: child.height / 2.0)
            child.run(moveGroundSpritesForever)
            moving.addChild(child)
        }
    }
    
    private func setRandomSkyTexture() {
        let skyTexture = SKTexture(imageNamed: "day-sky")
        let skyWidth = skyTexture.width * 1.5
        let moveSkySprite = SKAction.moveBy(x: -skyWidth, y: 0, duration: TimeInterval(0.1 * skyWidth))
        let resetSkySprite = SKAction.moveBy(x: skyWidth, y: 0, duration: 0.0)
        let moveSkySpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkySprite, resetSkySprite]))
        for i in 0..<2 + Int(width / skyWidth) {
            let spriteNode = SKSpriteNode(texture: skyTexture)
            spriteNode.setScale(1.5)
            spriteNode.zPosition = ZPosition.sky
            spriteNode.position = CGPoint(x: CGFloat(i) * (spriteNode.width - 1), y: spriteNode.height / 3.5 + groundTexture.height * 2.0)
            spriteNode.run(moveSkySpritesForever)

            if skyNodes.count < 2 + Int(width / skyWidth) {
                skyNodes.append(spriteNode)
            } else {
                skyNodes[i].removeFromParent()
                skyNodes[i] = spriteNode
            }
            moving.addChild(spriteNode)
        }
    }
    
    private func spawnPipesForever() {
        let spawn = SKAction.run(spawnPipes)
        let delay = SKAction.wait(forDuration: 1.0)
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(spawnThenDelay))
    }
    
    private var pipeUp: SKSpriteNode = SKSpriteNode()
    private var pipeDown: SKSpriteNode = SKSpriteNode()
    
    private func spawnPipes() {
        let height = UInt32(self.height / 4)
        let y = CGFloat(arc4random_uniform(height) + height)

        do {
            pipeDown = SKSpriteNode(texture: pipeTextureDown)
            pipeDown.setScale(2.0)
            pipeDown.position = CGPoint(x: 0.0, y: y + pipeDown.height + verticalPipeGap)
            let body = SKPhysicsBody(rectangleOf: pipeDown.size)
            body.isDynamic = false
            body.categoryBitMask = PhysicsCategory.pipe
            body.contactTestBitMask = PhysicsCategory.hero
            pipeDown.physicsBody = body
        }

        do {
            pipeUp = SKSpriteNode(texture: pipeTextureUp)
            pipeUp.setScale(2.0)
            pipeUp.position = CGPoint(x: 0.0, y: y)
            let body = SKPhysicsBody(rectangleOf: pipeUp.size)
            body.isDynamic = false
            body.categoryBitMask = PhysicsCategory.pipe
            body.contactTestBitMask = PhysicsCategory.hero
            pipeUp.physicsBody = body
        }

        let contactNode = SKNode()

        do {
            contactNode.position = CGPoint(x: pipeDown.width - 60 + cow.width / 2, y: self.height / 2)
            let size = CGSize(width: pipeUp.width, height: self.height)
            let body = SKPhysicsBody(rectangleOf: size)
            body.isDynamic = false
            body.categoryBitMask = PhysicsCategory.score
            body.contactTestBitMask = PhysicsCategory.hero
            contactNode.physicsBody = body
        }

        let distanceToMove = (width + 2.0 * pipeTextureUp.width) + 25
        let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.005 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        let movePipesAndRemove = SKAction.sequence([movePipes, removePipes])

        do {
            let node = SKNode()
            node.position = CGPoint(x: width + pipeTextureUp.width * 2, y: 0)
            node.zPosition = ZPosition.pipe
            node.addChild(pipeDown)
            node.addChild(pipeUp)
            node.addChild(contactNode)
            node.run(movePipesAndRemove)

            pipes.addChild(node)
        }
    }
    
    override func didMove(to view: SKView) {
        setGravityAndPhysics()
        setGroundMoving()
        setRandomSkyTexture()
        setRandomcowTextures()
        spawnPipesForever()

        addChild(moving)
        moving.addChild(pipes)
        addChild(cow)
        addChild(ground)
        
        score = 0
        moving.speed = 1
        cow.speed = 1
        pipes.setScale(0)


        if self.afterGameOver {
            self.resetScene()
            self.afterGameOver = false
        } else {
            self.cow.removeAction(forKey: "float")
            self.addChild(self.taptap)
            self.addChild(self.getReady)
            self.addChild(self.scoreLabelNode)
            self.addChild(self.scoreLabelNodeInside)
            self.cow.position = CGPoint(x: self.width / 2.5, y: self.height / 2)
        }
        self.cow.run(SKAction.repeatForever(self.floatUpAndDown), withKey: "float")
        self.firstTouch = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

       if firstTouch {
            cow.removeAction(forKey: "float")
            taptap.run(SKAction.sequence([
                SKAction.scale(to: 0.0, duration: 0.1),
                SKAction.removeFromParent(),
                SKAction.scale(to: 1.5, duration: 0.0)
            ]))
            
            getReady.run(SKAction.sequence([
                SKAction.scale(to: 0.0, duration: 0.1),
                SKAction.removeFromParent(),
                SKAction.scale(to: 1.2, duration: 0.0)
            ]))
            pipes.setScale(1)
            
            cow.physicsBody?.isDynamic = true
            firstTouch = false
        }
        
        touchAction()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if hitGround { return }
        
        let cowRotation = cow.physicsBody!.velocity.dy * (cow.physicsBody!.velocity.dy < 0.4 ? 0.003 : 0.001)
        cow.run(SKAction.rotate(toAngle: min(max(-1.57, cowRotation), 0.6), duration: 0.08))
        if cowRotation < -0.7 {
            cow.speed = 2
        } else {
            cow.speed = 1
        }
    }

    private func touchAction() {
        if moving.speed > 0 {
            if(!(cow.position.y >= (self.frame.height + 20))){
                cow.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                cow.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 22))
            }
        }
    }
    
    private func gameOver() {
        gameOverDisplayed = true
        firstTouch = true

        notification.notificationOccurred(.error)

        flashScreen(color: UIColor.white, fadeInDuration: 0.1, peakAlpha: 0.9, fadeOutDuration: 0.25)
        
        cow.physicsBody?.isDynamic = false
        cow.physicsBody?.collisionBitMask = PhysicsCategory.land
        cow.physicsBody?.isDynamic = true
        
        let anim = SKAction.animate(with: [cowTextures[0], cowTextures[1], cowTextures[2], cowTextures[1]], timePerFrame: 0.1)
        cow.run(SKAction.repeatForever(anim))

        gameover.setScale(0)
        addChild(gameover)
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.run {
                self.scoreLabelNode.removeFromParent()

            },
            SKAction.run {
                self.scoreLabelNodeInside.removeFromParent()

            },
            SKAction.run {
                self.scaleTwice(node: self.gameover, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.25, secondScaleDuration: 0.1)

            },
        ]))
        moving.speed = 0
    }
    
    func resetScene() {
        pipes.removeAllChildren()
        gameover.removeFromParent()
        
        setRandomSkyTexture()
        setRandomcowTextures()
        
        addChild(taptap)
        addChild(getReady)
        addChild(scoreLabelNode)
        addChild(scoreLabelNodeInside)
        scoreLabelNode.run(SKAction.scale(to: 1.0, duration: 0.0))
        scoreLabelNodeInside.run(SKAction.scale(to: 1.0, duration: 0.0))
        
        gameOverDisplayed = false
        hitGround = false
        pipes.setScale(0)
        score = 0
        moving.speed = 1
        cow.speed = 1
        cow.zRotation = 0.0
        cow.position = CGPoint(x: width / 2.5, y: height / 2)
        cow.physicsBody?.isDynamic = false
        cow.physicsBody?.isDynamic = false
        cow.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        cow.physicsBody?.collisionBitMask = PhysicsCategory.land | PhysicsCategory.pipe
    }
    
    private func scaleTwice(
        node: SKNode,
        firstScale: CGFloat,
        firstScaleDuration: TimeInterval,
        secondScale: CGFloat,
        secondScaleDuration: TimeInterval
    ) {
        node.run(SKAction.sequence([
            SKAction.scale(to: firstScale, duration: firstScaleDuration),
            SKAction.scale(to: secondScale, duration: secondScaleDuration)
        ]))
    }
    
    private func flashScreen(color: UIColor, fadeInDuration: TimeInterval, peakAlpha: CGFloat, fadeOutDuration: TimeInterval){
        let flash = SKShapeNode(rect: CGRect(x: -5, y: -5, width: width + 10 ,height: height + 10))
        flash.zPosition = ZPosition.flash
        flash.fillColor = color
        flash.alpha = 0.0
        self.addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: peakAlpha, duration: fadeInDuration),
            SKAction.fadeAlpha(to: 0.0, duration: fadeOutDuration),
            SKAction.removeFromParent()
        ]))
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if (cow.speed == 1 || cow.speed == 2) && !gameOverDisplayed && ((contact.bodyA.categoryBitMask & PhysicsCategory.score) == PhysicsCategory.score || (contact.bodyB.categoryBitMask & PhysicsCategory.score) == PhysicsCategory.score) {
            score += 1
            
            impact.impactOccurred()
            
            scaleTwice(node: scoreLabelNode, firstScale: 1.5, firstScaleDuration: 0.1, secondScale: 1.0, secondScaleDuration: 0.1)
            scaleTwice(node: scoreLabelNodeInside, firstScale: 1.5, firstScaleDuration: 0.1, secondScale: 1.0, secondScaleDuration: 0.1)
        } else if !gameOverDisplayed && ((contact.bodyA.categoryBitMask & PhysicsCategory.pipe) == PhysicsCategory.pipe || (contact.bodyB.categoryBitMask & PhysicsCategory.pipe) == PhysicsCategory.pipe) {
            gameOver()
            cow.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            cow.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        } else if !hitGround && (contact.bodyA.categoryBitMask & PhysicsCategory.land) == PhysicsCategory.land || (contact.bodyB.categoryBitMask & PhysicsCategory.land) == PhysicsCategory.land {
            hitGround = true
            cow.speed = 0.5
            
            if !gameOverDisplayed {
                gameOver()
            }
            
            cow.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            let addResultNode = SKAction.run {
                self.afterGameOver = true
            }
            run(SKAction.sequence([SKAction.wait(forDuration: 0.8), SKAction.run { self.cow.speed = 0 }, SKAction.wait(forDuration: 0.2), addResultNode]))
        }
    }
}
