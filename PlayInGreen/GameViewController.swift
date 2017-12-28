//
//  GameViewController.swift
//  PlayInGreen
//
//  Created by Arturo Iafrate on 30/05/17.
//  Copyright © 2017 iOSFoundation. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Carico i settaggi salvati della mia applicazione (se esistono)
        DataManager.defaultManager.loadSavedSettings()
        if let view = self.view as! SKView? {
            //Controllo su che device sta girando la mia app
            DataManager.defaultManager.deviceType = UIDevice.current.model
            //E carico la rispettiva scena ottimizzata
            if DataManager.defaultManager.deviceType == "iPad"
            {
                if let scene = SKScene(fileNamed: "iPadMainScene") {
                    scene.scaleMode = .aspectFit
                    view.presentScene(scene)
                }
            }
            else
            {
                if let scene = SKScene(fileNamed: "MainScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFit
                    // Present the scene
                    view.presentScene(scene)
                }
            }
            
            view.ignoresSiblingOrder = true
            
            //view.showsFPS = true
            //view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
