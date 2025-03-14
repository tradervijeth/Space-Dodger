# Space Dodger

A simple arcade-style iOS game built with SpriteKit where you control a spaceship to avoid incoming asteroids.

## Game Overview

In Space Dodger, players control a spaceship at the bottom of the screen while asteroids fall from the top. The goal is to survive as long as possible by avoiding collisions with the asteroids. Your score increases over time, and the game becomes progressively more difficult as asteroids spawn more frequently.

## Technical Details

### Technologies Used
- Swift 5
- SpriteKit for 2D game rendering
- GameplayKit for game logic
- iOS 15.6+ compatibility

### Game Features
- Smooth touch-based controls for moving the spaceship
- Dynamic difficulty scaling (asteroids spawn faster as score increases)
- Visual particle effects for:
  - Spaceship engine thrust
  - Engine trail
  - Explosions on collision
- Background starfield effect
- Simple score tracking
- Game over and restart functionality

### Code Structure
- **GameScene.swift**: Main game scene with game logic, physics, and player controls
- **GameViewController.swift**: Main view controller that sets up and presents the game scene
- **AppDelegate.swift**: Standard iOS app delegate
- **Particle Effects**:
  - EngineTrailParticle.sks
  - ThrustParticle.sks
  - ExplosionParticle.sks

### Physics Implementation
The game uses SpriteKit's physics engine with the following categories:
```swift
struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let spaceship : UInt32 = 0b1        // 1
    static let asteroid  : UInt32 = 0b10       // 2
    static let star      : UInt32 = 0b100      // 4
}
```

## How to Play
1. Drag your finger horizontally to move the spaceship left and right
2. Avoid incoming asteroids that fall from the top of the screen
3. Your score increases automatically the longer you survive
4. The game gets more difficult as your score increases
5. When you crash into an asteroid, the game ends
6. Tap anywhere on the screen to restart after game over

## Running the Project
1. Clone the repository
2. Open "Space Dodger.xcodeproj" in Xcode
3. Build and run on a simulator or device running iOS 15.6 or newer

## Future Improvements
- Add sound effects and background music
- Implement persistent high scores
- Add power-ups and collectible items
- Include multiple spaceship types or customization
- Add different asteroid types with varying behaviors
- Implement level progression or mission objectives

## Created By
Vithushan Jeyapahan (2025)
