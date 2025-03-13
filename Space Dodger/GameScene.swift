//
//  GameScene.swift
//  Space Dodger
//
//  Created by Vithushan Jeyapahan on 13/03/2025.
//

import SpriteKit
import GameplayKit

// Physics collision categories
struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let spaceship : UInt32 = 0b1        // 1
    static let asteroid  : UInt32 = 0b10       // 2
    static let star      : UInt32 = 0b100      // 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Game nodes
    private var spaceship: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    
    // Game properties
    private var score = 0
    private var gameStarted = false
    private var gameOver = false
    private var lastUpdateTime: TimeInterval = 0
    private var asteroidSpawnRate: TimeInterval = 1.0
    private var timeSinceLastAsteroid: TimeInterval = 0
    private var thrustParticle: SKEmitterNode?
    private var engineTrailParticle: SKEmitterNode?
    
    // MARK: - Scene Setup
    
    override func didMove(to view: SKView) {
        setupPhysics()
        setupBackground()
        setupSpaceship()
        setupScoreLabel()
        setupStars()
        
        startGame()
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    private func setupBackground() {
        // Create a solid color background (no image needed)
        let background = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0.1, alpha: 1.0), size: self.size)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -100
        addChild(background)
        
        // Add some simple star dots directly
        for _ in 0..<100 {
            let starSize = CGFloat.random(in: 1...3)
            let star = SKShapeNode(circleOfRadius: starSize)
            star.fillColor = .white
            star.strokeColor = .white
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.3...1.0)
            star.zPosition = -99
            addChild(star)
        }
    }
    
    private func setupSpaceship() {
        // Create the spaceship
        spaceship = SKSpriteNode(imageNamed: "spaceship")
        spaceship.position = CGPoint(x: size.width/2, y: size.height * 0.2)
        spaceship.setScale(0.15) // Adjust scale as needed
        
        // Setup physics for the spaceship
        spaceship.physicsBody = SKPhysicsBody(circleOfRadius: spaceship.size.width/2.5)
        spaceship.physicsBody?.isDynamic = true
        spaceship.physicsBody?.categoryBitMask = PhysicsCategory.spaceship
        spaceship.physicsBody?.contactTestBitMask = PhysicsCategory.asteroid
        spaceship.physicsBody?.collisionBitMask = PhysicsCategory.none
        spaceship.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(spaceship)
        
        // Add particle effects
        setupParticleEffects()
    }
    
    private func setupParticleEffects() {
        // Engine trail particle effect
        if let engineTrail = SKEmitterNode(fileNamed: "EngineTrailParticle") {
            engineTrail.position = CGPoint(x: 0, y: -spaceship.size.height/2)
            engineTrail.targetNode = self
            engineTrailParticle = engineTrail
            spaceship.addChild(engineTrail)
        }
        
        // Thrust particle effect
        if let thrust = SKEmitterNode(fileNamed: "ThrustParticle") {
            thrust.position = CGPoint(x: 0, y: -spaceship.size.height/2)
            thrust.targetNode = self
            thrustParticle = thrust
            thrustParticle?.isPaused = true  // Start paused
            spaceship.addChild(thrust)
        }
    }
    
    private func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width - 100, y: size.height - 40)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.zPosition = 50
        addChild(scoreLabel)
    }
    
    private func setupStars() {
        // Create a repeating star generation
        let createStarAction = SKAction.run { [weak self] in
            self?.createStar()
        }
        let waitAction = SKAction.wait(forDuration: 0.5)
        let sequenceAction = SKAction.sequence([createStarAction, waitAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        
        run(repeatAction)
    }
    
    private func startGame() {
        score = 0
        updateScoreLabel()
        gameStarted = true
        gameOver = false
        timeSinceLastAsteroid = 0
        asteroidSpawnRate = 1.0  // Start with 1-second spawn rate
    }
    
    // MARK: - Game Elements Creation
    
    private func createStar() {
        let star = SKSpriteNode(imageNamed: "star")
        let randomX = CGFloat.random(in: 0...size.width)
        let randomScale = CGFloat.random(in: 0.01...0.05)
        
        star.position = CGPoint(x: randomX, y: size.height + star.size.height)
        star.setScale(randomScale)
        star.alpha = CGFloat.random(in: 0.3...1.0)
        star.zPosition = -90
        
        // Create a physics body just for category, no actual physics
        star.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        star.physicsBody?.isDynamic = true
        star.physicsBody?.categoryBitMask = PhysicsCategory.star
        star.physicsBody?.contactTestBitMask = PhysicsCategory.none
        star.physicsBody?.collisionBitMask = PhysicsCategory.none
        star.physicsBody?.affectedByGravity = false
        
        addChild(star)
        
        // Move the star down the screen
        let moveAction = SKAction.moveTo(y: -star.size.height, duration: 5.0)
        let removeAction = SKAction.removeFromParent()
        star.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    private func spawnAsteroid() {
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        
        // Random size
        let randomScale = CGFloat.random(in: 0.1...0.2)
        asteroid.setScale(randomScale)
        
        // Random horizontal position
        let randomX = CGFloat.random(in: 0...size.width)
        asteroid.position = CGPoint(x: randomX, y: size.height + asteroid.size.height)
        
        // Setup physics
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.size.width/2.5)
        asteroid.physicsBody?.isDynamic = true
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.asteroid
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.spaceship
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(asteroid)
        
        // Random rotation
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: TimeInterval.random(in: 2...10))
        let repeatRotation = SKAction.repeatForever(rotateAction)
        
        // Movement
        let randomDuration = TimeInterval.random(in: 4...8)
        let moveAction = SKAction.moveTo(y: -asteroid.size.height, duration: randomDuration)
        let removeAction = SKAction.removeFromParent()
        
        // Execute actions
        asteroid.run(repeatRotation)
        asteroid.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    // MARK: - Game Logic
    
    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    
    private func increaseScore() {
        score += 1
        updateScoreLabel()
        
        // Increase difficulty every 10 points
        if score % 10 == 0 && asteroidSpawnRate > 0.2 {
            asteroidSpawnRate -= 0.1
        }
    }
    
    private func gameOverSequence() {
        if gameOver { return }
        
        gameOver = true
        gameStarted = false
        
        // Create explosion
        if let explosion = SKEmitterNode(fileNamed: "ExplosionParticle") {
            explosion.position = spaceship.position
            explosion.zPosition = 10
            addChild(explosion)
            
            // Run the explosion for 2 seconds, then remove
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.removeFromParent()
            ])
            explosion.run(removeAction)
        }
        
        // Remove the spaceship
        spaceship.removeFromParent()
        
        // Show game over text
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        gameOverLabel.zPosition = 100
        addChild(gameOverLabel)
        
        // Show tap to restart
        let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 20
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        restartLabel.zPosition = 100
        addChild(restartLabel)
    }
    
    private func restartGame() {
        // Remove all game over nodes
        self.removeAllChildren()
        
        // Reset and setup the game again
        setupBackground()
        setupSpaceship()
        setupScoreLabel()
        setupStars()
        
        startGame()
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver {
            restartGame()
            return
        }
        
        // Activate thrust particle
        thrustParticle?.isPaused = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !gameOver else { return }
        
        let touchLocation = touch.location(in: self)
        
        // Move the spaceship horizontally, keeping the same vertical position
        let newPosition = CGPoint(x: touchLocation.x, y: spaceship.position.y)
        
        // Create a move action
        let moveAction = SKAction.move(to: newPosition, duration: 0.1)
        spaceship.run(moveAction)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Deactivate thrust particle
        thrustParticle?.isPaused = true
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Deactivate thrust particle
        thrustParticle?.isPaused = true
    }
    
    // MARK: - Game Update Loop
    
    override func update(_ currentTime: TimeInterval) {
        // First frame - initialize lastUpdateTime
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        // Calculate delta time
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if gameStarted && !gameOver {
            // Increment score over time
            increaseScore()
            
            // Spawn asteroids
            timeSinceLastAsteroid += deltaTime
            if timeSinceLastAsteroid >= asteroidSpawnRate {
                spawnAsteroid()
                timeSinceLastAsteroid = 0
            }
        }
    }
    
    // MARK: - Physics Contact Delegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Sort the bodies by their category bitmask
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Check if the spaceship hit an asteroid
        if (firstBody.categoryBitMask & PhysicsCategory.spaceship != 0) &&
           (secondBody.categoryBitMask & PhysicsCategory.asteroid != 0) {
            // Spaceship hit an asteroid
            gameOverSequence()
        }
    }
}
