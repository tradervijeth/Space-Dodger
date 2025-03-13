//
//  GameViewController.swift
//  Space Dodger
//
//  Created by Vithushan Jeyapahan on 13/03/2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.swift'
            let scene = GameScene(size: view.bounds.size)
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            // SpriteKit performance settings
            view.showsFPS = true
            view.showsNodeCount = true
            
            // Enable physics visualization for debugging
            // view.showsPhysics = true  // Uncomment for debugging
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
