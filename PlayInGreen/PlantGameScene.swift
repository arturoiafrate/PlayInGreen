//
//  PlantGameScene.swift
//  PlayInGreen
//
//  Created by Arturo Iafrate on 01/06/17.
//  Copyright © 2017 iOSFoundation. All rights reserved.
//

import SpriteKit
import AudioToolbox

class PlantGameScene: SKScene
{
    private var background : SKSpriteNode?
    private var flowerPot : SKSpriteNode?
    private var intersectionFlowerPot : SKNode?
    private var backButton : SKNode?
    private var seeds : SKNode?
    private var seeds_ : SKSpriteNode?
    private var seedsInitialPostition : CGPoint = CGPoint()
    private var sand : SKNode?
    private var sand_ : SKSpriteNode?
    private var sandInitialPostition : CGPoint = CGPoint()
    private var wateringCan : SKNode?
    private var wateringCan_ : SKSpriteNode?
    private var wateringCanInitialPosition : CGPoint = CGPoint()
    private var sun : SKNode?
    private var sun_ : SKSpriteNode?
    private var sunInitialPosition : CGPoint = CGPoint()
    private var touchingSeeds : Bool = false
    private var touchingSand : Bool = false
    private var touchingWateringCan : Bool = false
    private var touchingSun : Bool = false
    private var touchPoint : CGPoint = CGPoint()
    private var plantStep1 : SKSpriteNode?
    private var plantStep2 : SKSpriteNode?
    private var plantStep3 : SKSpriteNode?
    private let bgMusic : SKAudioNode = SKAudioNode(fileNamed: "sounds/plantGameMusic.wav")
    private var disableTouch : Bool = false
    private var timer : Int = 30 //conto alla rovescia
    private var timerLabel : SKLabelNode? //label correlata al timer
    private var score : Int = 0 //punteggio
    private var scoreLabel : SKLabelNode? //label correlata al pungeggio
    private var okButton : SKNode?
    private var musicControl : SKNode?
    private var musicEnabled : Bool = true
    //Caricamento e salvataggio dei settaggi
    private var defaults : UserDefaults = UserDefaults.standard
    private var timerColor : UIColor?
    
    //per l'ordine delle operazioni
    //ordine corretto:
    // turno 0 -> terreno
    // turno 1 -> semi
    // turno 2 -> terreno
    // turno 3 -> acqua
    // turno 4 -> sole
    // turno 5 -> acqua
    private var turn : Int = 0
    private var sandUsed1 : Bool = false
    private var sandUsed2 : Bool = false
    private var seedUsed : Bool = false
    private var wateringCanUsed1 : Bool = false
    private var wateringCanUsed2 : Bool = false
    private var sunUsed : Bool = false
    private var secondSand : Bool = false
    private var secondWater : Bool = false
    private var canStartSand : Bool = true
    private var saved : Bool = false
    private var maxScore : Int = 0
    private var newRecord: Bool = false
    //
    private var miniGameIcon : SKNode?
    private var finalPhrase : SKNode?
    private var gameOverBg : SKSpriteNode?
    
    //Adattamento interfaccia
    private var moveDim: Int = 240
    private var defaultDim: Int = 120
    



    
    override func didMove(to view: SKView)
    {
        DataManager.defaultManager.loadSavedSettings()
        maxScore = DataManager.defaultManager.getRecycleGameScore()
        if !DataManager.defaultManager.isMusicEnabled() //Se la musica è disabilitata cambio icona
        {
            let tmp = self.childNode(withName: "musicControl") as? SKSpriteNode
            tmp!.texture = SKTexture(imageNamed: "musicOff")
        }
        self.backButton = self.childNode(withName: "backButton")
        self.scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode
        self.timerLabel = self.childNode(withName: "timerLabel") as? SKLabelNode
        self.timerColor = self.timerLabel!.fontColor
        self.scoreLabel!.text = String(self.score)
        self.timerLabel!.text = String(self.timer)
        self.okButton = self.childNode(withName: "okButton")
        self.okButton!.isHidden = true
        self.miniGameIcon = self.childNode(withName: "miniGameIcon")
        self.finalPhrase = self.childNode(withName: "finalPhrase")
        self.finalPhrase!.isHidden = true
        self.miniGameIcon!.isHidden = true
        self.gameOverBg = self.childNode(withName: "gameOverBg") as? SKSpriteNode
        self.gameOverBg!.isHidden = true
        self.plantStep1 = self.childNode(withName: "plantStep1") as? SKSpriteNode
        self.plantStep1!.isHidden = true
        self.plantStep2 = self.childNode(withName: "plantStep2") as? SKSpriteNode
        self.plantStep2!.isHidden = true
        self.plantStep3 = self.childNode(withName: "plantStep3") as? SKSpriteNode
        self.plantStep3!.isHidden = true
        self.background = self.childNode(withName: "background") as? SKSpriteNode
        self.flowerPot = self.childNode(withName: "flowerPot") as? SKSpriteNode
        self.intersectionFlowerPot = self.childNode(withName: "intersectFlowerPot")
        self.seeds = self.childNode(withName: "seeds")
        self.seeds_ = self.childNode(withName: "seeds") as? SKSpriteNode
        self.seedsInitialPostition = self.seeds!.position
        self.sand = self.childNode(withName: "sand")
        self.sand_ = self.childNode(withName: "sand") as? SKSpriteNode
        self.sandInitialPostition = self.sand!.position
        self.wateringCan = self.childNode(withName: "water")
        self.wateringCan_ = self.childNode(withName: "water") as? SKSpriteNode
        self.wateringCanInitialPosition = self.wateringCan!.position
        self.sun = self.childNode(withName: "sun")
        self.sun_ = self.childNode(withName: "sun") as? SKSpriteNode
        self.sunInitialPosition = self.sun!.position
        self.musicControl = self.childNode(withName: "musicControl")
        self.bgMusic.name = "bgMusic"
        self.saved = false
        self.getRandomFlower()
        self.loadGameTutorial()
        if DataManager.defaultManager.deviceType == "iPad"
        {
            self.moveDim = 280
            self.defaultDim = 170
        }
    }
    
    private func getRandomFlower() {
        let randomFlower = Int(arc4random_uniform(7)) + 1
        self.plantStep3!.texture = SKTexture(imageNamed: "plantStep3-\(randomFlower)")
    }
    
    private func loadGameTutorial() {
        var imageName = "plantGameTutorial"
        var initialWidth = 168
        var initialHeight = 280
        var finalWidth = 670
        var finalHeight = 1120
        if DataManager.defaultManager.deviceType == "iPad" {
            imageName = "iPad-plantGameTutorial"
            initialWidth = 200
            initialHeight = 200
            finalWidth = 1150
            finalHeight = 1150
        }
        let tutorialNode = SKSpriteNode(texture: SKTexture(imageNamed: imageName))//texture da caricare
        tutorialNode.size = CGSize(width: initialWidth, height: initialHeight)//dimensione iniziale
        tutorialNode.zPosition = 10
        tutorialNode.name = "tutorial"
        self.addChild(tutorialNode)
        self.saved = false
        let zoom = SKAction.scale(to: CGSize(width: finalWidth, height: finalHeight), duration: 0.5)//dimensione finale, da raggiungere entro duration secondi
        tutorialNode.run(zoom)
    }
    
    private func record() {
        newRecord = DataManager.defaultManager.savePlantGameScore(score: score)//Salvo il punteggio se è maggiore di quello precedente
        if DataManager.defaultManager.isMusicEnabled() {
            if newRecord {
                let newRecordSound : SKAction = SKAction.playSoundFileNamed("sounds/newRecord.wav", waitForCompletion: true)
                self.scene!.run(newRecordSound)
            }
            else {
                let noRecordSound : SKAction = SKAction.playSoundFileNamed("sounds/noRecord.wav", waitForCompletion: true)
                self.scene!.run(noRecordSound)
            }
        }
        saved = true
    }
    
    private func itemSelectedSound()
    {
        if DataManager.defaultManager.isMusicEnabled()
        {
            let itemSelectedSound : SKAction = SKAction.playSoundFileNamed("sounds/itemSelect.wav", waitForCompletion: true)
            self.scene!.run(itemSelectedSound)
        }
    }
    
    private func lastStepSound()
    {
        if DataManager.defaultManager.isMusicEnabled()
        {
            let lastStep : SKAction = SKAction.playSoundFileNamed("sounds/lastStepCompleted.wav", waitForCompletion: true)
            self.scene!.run(lastStep)
        }
    }
    
    private func getRandomFinalPhrase()
    {
        let randNum : UInt = UInt(arc4random_uniform(4)) + 1//Genero un numero da 1 a 4
        let phrase = self.childNode(withName: "finalPhrase") as? SKSpriteNode
        phrase!.texture = SKTexture(imageNamed: "plantGamePhrase\(randNum)")
        self.finalPhrase!.zPosition = 15
        self.finalPhrase!.isHidden = false
    }
    
    private func getEndTitle()
    {
        let endTitle = self.childNode(withName: "endTitle") as? SKLabelNode
        if newRecord
        {
            endTitle!.text = "Good job!"
        }
        else
        {
            endTitle!.text = "Try again!"
        }
        endTitle!.zPosition = 15
        endTitle!.isHidden = false
    }
    
    private func showEndView()
    {
        let bestScoreLabel = self.childNode(withName: "bestScoreLabel") as? SKLabelNode
        let myScoreLabel = self.childNode(withName: "myScoreLabel") as? SKLabelNode
        let myScoreNumber = self.childNode(withName: "myScoreNumber") as? SKLabelNode
        let bestScoreNumber = self.childNode(withName: "bestScoreNumber") as? SKLabelNode
        self.miniGameIcon!.zPosition = 15
        self.miniGameIcon!.isHidden = false
        myScoreNumber!.text = String(self.score)
        bestScoreNumber!.text = String(self.maxScore)
        self.getRandomFinalPhrase()
        self.gameOverBg!.isHidden = false
        self.gameOverBg!.zPosition = 14
        self.getEndTitle()
        self.okButton!.isHidden = false
        self.okButton!.zPosition = 15
        bestScoreLabel!.isHidden = false
        bestScoreLabel!.zPosition = 15
        myScoreLabel!.isHidden = false
        myScoreLabel!.zPosition = 15
        myScoreNumber!.isHidden = false
        myScoreNumber!.zPosition = 15
        bestScoreNumber!.isHidden = false
        bestScoreNumber!.zPosition = 15
    }
    
    private func playBackgroundMusic()//effetto fade-in per la musica in background
    {
        let start = SKAction.changeVolume(to: 0.05, duration: 0.0)
        let increment = SKAction.changeVolume(by: 0.1, duration: 1)
        let play = SKAction.play()
        let wait = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([start, play, increment, wait, increment, wait, increment])
        self.bgMusic.run(sequence)
    }
    
    private func backgroundMusicControl()
    {
        if DataManager.defaultManager.isMusicEnabled()
        {
            let tmp = self.childNode(withName: "bgMusic")
            if tmp == nil
            {
                self.addChild(self.bgMusic)
            }
            self.playBackgroundMusic()
        }
        else
        {
            let tmp = self.childNode(withName: "musicControl") as? SKSpriteNode
            tmp!.texture = SKTexture(imageNamed: "musicOff")
            let tmp2 = self.childNode(withName: "bgMusic")
            if tmp2 != nil
            {
                self.stopBackgroundMusic()
            }
        }
    }
    
    private func stopBackgroundMusic()
    {
        DataManager.defaultManager.disableMusic()
        let tmp = self.childNode(withName: "bgMusic")
        if tmp != nil
        {
            self.bgMusic.run(SKAction.stop())
        }
    }
    
    private func resumeBackgroundMusic()
    {
        DataManager.defaultManager.enableMusic()
        let tmp = self.childNode(withName: "bgMusic")
        if tmp == nil
        {
            self.addChild(self.bgMusic)
        }
        else
        {
            self.bgMusic.run(SKAction.play())
        }
    }
    
    private func muteBackgroundMusic()
    {
        let tmp = self.childNode(withName: "bgMusic")
        if tmp != nil
        {
            self.bgMusic.run(SKAction.stop())
        }
    }
    
    
    private func startMiniGame()
    {
        self.backgroundMusicControl()
        self.decreaseTimer()
    }
    
    private func resetGame()
    {
        self.resetSand()
        self.resetSun()
        self.resetSeeds()
        self.resetWateringCan()
        self.turn = 0
        self.sandUsed1 = false
        self.sandUsed2 = false
        self.seedUsed = false
        self.wateringCanUsed1 = false
        self.wateringCanUsed2 = false
        self.sunUsed = false
        self.plantStep1!.isHidden = true
        self.plantStep2!.isHidden = true
        self.plantStep3!.isHidden = true
        self.secondSand = false
        self.secondWater = false
        self.flowerPot!.texture = SKTexture(imageNamed: "emptyFlowerPot")
        self.background!.texture = SKTexture(imageNamed: "plantBackground")
        self.getRandomFlower()
    }
    
    private func decreaseTimer() //funzione per il timer
    {
        let wait = SKAction.wait(forDuration: 1.0)
        let block = SKAction.run {
            if self.timer > 0
            {
                self.timer -= 1
                self.timerLabel!.text = String(self.timer)
                if self.timer == 5
                {
                    self.timerLabel!.fontColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
                }
            }
            else
            {
                self.disableTouch = true
                if !self.saved
                {
                    self.muteBackgroundMusic()
                    self.record()
                    DataManager.defaultManager.saveSettings()
                    self.showEndView()
                }
            }
        }
        let sequence = SKAction.sequence([wait,block])
        self.run(SKAction.repeatForever(sequence))
    }
    
    private func sunshineAnimation()
    {
        let wait = SKAction.wait(forDuration: 0.3)
        let block1 = SKAction.run {
            let loadTexture = SKTexture(imageNamed: "plantBackground2")
            self.background!.texture = loadTexture
        }
        let block2 = SKAction.run {
            let loadTexture = SKTexture(imageNamed: "plantBackground3")
            self.background!.texture = loadTexture
        }
        let block3 = SKAction.run {
            let loadTexture = SKTexture(imageNamed: "plantBackground4")
            self.background!.texture = loadTexture
        }
        let sequence = SKAction.sequence([block1, wait, block2, wait, block3, wait, block1])
        self.run(sequence)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first
        let location = touch!.location(in: self)
        if !self.disableTouch
        {
            //SEME
            if seeds!.frame.contains(location)
            {
                self.touchPoint = location
                self.seeds_!.size = CGSize(width: self.moveDim, height: self.moveDim)
                self.seeds!.zPosition = 3
                self.touchingSeeds = true
            }
            else
            {
                //TERRENO
                if sand!.frame.contains(location)
                {
                    self.touchPoint = location
                    self.sand_!.size = CGSize(width: self.moveDim, height: self.moveDim)
                    self.sand!.zPosition = 3
                    self.touchingSand = true
                }
                else
                {
                    //ACQUA
                    if wateringCan!.frame.contains(location)
                    {
                        self.touchPoint = location
                        self.wateringCan_!.size = CGSize(width: self.moveDim, height: self.moveDim)
                        self.wateringCan!.zPosition = 3
                        self.touchingWateringCan = true
                    }
                    else
                    {
                        //SOLE
                        if sun!.frame.contains(location)
                        {
                            self.touchPoint = location
                            self.sun_!.size = CGSize(width: self.moveDim, height: self.moveDim)
                            self.sun!.zPosition = 3
                            self.touchingSun = true
                        }
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        //UGUALI PER TUTTI GLI OGGETTI DELLA SCENA
        let touch = touches.first
        let location = touch!.location(in: self)
        self.touchPoint = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first
        let location = touch!.location(in: self)
        self.canStartSand = true
        if !self.disableTouch
        {
            let splashImage = self.childNode(withName: "tutorial")
            if splashImage != nil && splashImage!.contains(touch!.location(in: self))
            {
                self.removeChildren(in: [splashImage!])
                self.startMiniGame()
            }
            if self.backButton!.contains(location)
            {
                self.bgMusic.run(SKAction.stop())
                self.itemSelectedSound()
                DataManager.defaultManager.saveSettings()
                if DataManager.defaultManager.deviceType == "iPhone"
                {
                    let scene = MainScene(fileNamed: "MainScene")
                    scene?.scaleMode = .aspectFit
                    view?.presentScene(scene!, transition: SKTransition.doorway(withDuration: 0.5))
                }
                else
                {
                    let scene = MainScene(fileNamed: "iPadMainScene")
                    scene?.scaleMode = .aspectFit
                    view?.presentScene(scene!, transition: SKTransition.doorway(withDuration: 0.5))
                }
            }
            if musicControl!.contains(touch!.location(in: self))
            {
                //controllo musica
                if DataManager.defaultManager.isMusicEnabled()
                {//se abilitata disabilita
                    let tmp = self.childNode(withName: "musicControl") as? SKSpriteNode
                    tmp!.texture = SKTexture(imageNamed: "musicOff")
                    self.stopBackgroundMusic()
                    let posStart = SKAction.rotate(byAngle: 0.2, duration: 0.1)
                    let posEnd = SKAction.rotate(byAngle: -0.4, duration: 0.1)
                    let posMiddle1 = SKAction.rotate(byAngle: 0.8, duration: 0.1)
                    let posMiddle2 = SKAction.rotate(byAngle: -1.6, duration: 0.1)
                    let posMiddle3 = SKAction.rotate(byAngle: 1.6, duration: 0.1)
                    let lastPos = SKAction.rotate(byAngle: -0.6, duration: 0.1)
                    let sequence = SKAction.sequence([posStart, posEnd, posMiddle1, posMiddle2, posMiddle3, lastPos])
                    self.musicControl!.run(sequence)
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
                else
                {//se disabilitata abilita
                    let tmp4 = self.childNode(withName: "musicControl") as? SKSpriteNode
                    tmp4!.texture = SKTexture(imageNamed: "musicOn")
                    self.resumeBackgroundMusic()
                }
                DataManager.defaultManager.saveSettings()
            }
            //SEME
            if self.touchingSeeds
            {
                self.touchingSeeds = false
                self.seeds_!.size = CGSize(width: self.defaultDim, height: self.defaultDim)
                self.seeds!.position = self.seedsInitialPostition
                self.seeds!.zPosition = 1
                self.seeds!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                if self.turn == 1
                {
                    self.turn += 1
                }
            }
            else
            {
                //TERRENO
                if self.touchingSand
                {
                    self.touchingSand = false
                    self.sand_!.size = CGSize(width: self.defaultDim, height: self.defaultDim)
                    self.sand!.position = self.sandInitialPostition
                    self.sand!.zPosition = 1
                    self.sand!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    self.sand_!.texture = SKTexture(imageNamed: "sand")
                    if self.turn == 0 || self.turn == 2
                    {
                        self.turn += 1
                    }
                }
                else
                {
                    //ACQUA
                    if self.touchingWateringCan
                    {
                        self.touchingWateringCan = false
                        self.wateringCan_!.size = CGSize(width: self.defaultDim, height: self.defaultDim)
                        self.wateringCan!.position = self.wateringCanInitialPosition
                        self.wateringCan!.zPosition = 1
                        self.wateringCan!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                        self.wateringCan_!.texture = SKTexture(imageNamed: "wateringCan")
                        if self.turn == 3 || self.turn == 5
                        {
                            self.turn += 1
                        }
                    }
                    else
                    {
                        //SOLE
                        if self.touchingSun
                        {
                            self.touchingSun = false
                            self.sun_!.size = CGSize(width: self.defaultDim, height: self.defaultDim)
                            self.sun!.position = self.sunInitialPosition
                            self.sun!.zPosition = 1
                            self.sun!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                            if self.turn == 4
                            {
                                self.turn += 1
                            }
                        }
                    }
                }
            }
        }
        else
        {
            if self.okButton!.contains(touch!.location(in: self))
            {
                if DataManager.defaultManager.deviceType == "iPhone"
                {
                    let scene = MainScene(fileNamed: "MainScene")
                    scene?.scaleMode = .aspectFit
                    view?.presentScene(scene!, transition: SKTransition.doorway(withDuration: 0.5))
                }
                else
                {
                    let scene = MainScene(fileNamed: "iPadMainScene")
                    scene?.scaleMode = .aspectFit
                    view?.presentScene(scene!, transition: SKTransition.doorway(withDuration: 0.5))
                }
            }

        }
    }
    
    private func resetSeeds()
    {
        self.touchingSeeds = false
        self.seeds_!.size = CGSize(width: self.defaultDim, height: self.defaultDim)
        self.seeds!.position = self.seedsInitialPostition
        self.seeds!.zPosition = 1
        self.seeds!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
    }
    
    private func resetSand()
    {
        self.touchingSand = false
        self.sand_!.size = CGSize(width: self.defaultDim, height: self.defaultDim)
        self.sand!.position = self.sandInitialPostition
        self.sand!.zPosition = 1
        self.sand!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        self.sand_!.texture = SKTexture(imageNamed: "sand")
    }
    
    private func resetWateringCan()
    {
        self.touchingWateringCan = false
        self.wateringCan_!.size = CGSize(width: self.defaultDim, height: self.defaultDim)
        self.wateringCan!.position = self.wateringCanInitialPosition
        self.wateringCan!.zPosition = 1
        self.wateringCan!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
    }
    
    private func resetSun()
    {
        self.touchingSun = false
        self.sun_!.size = CGSize(width: self.defaultDim, height: self.defaultDim)
        self.sun!.position = self.sunInitialPosition
        self.sun!.zPosition = 1
        self.sun!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        //gestione del movimento del seme
        if self.touchingSeeds
        {
            let dt : CGFloat = 1.0/10.0
            let distance = CGVector(dx: self.touchPoint.x - self.seeds!.position.x , dy: self.touchPoint.y - self.seeds!.position.y)
            let velocity = CGVector(dx: distance.dx/dt, dy: distance.dy/dt)
            self.seeds!.physicsBody!.velocity = velocity
        }
        else
        {
            //gestione del movimento del terreno
            if self.touchingSand
            {
                let dt : CGFloat = 1.0/10.0
                let distance = CGVector(dx: self.touchPoint.x - self.sand!.position.x , dy: self.touchPoint.y - self.sand!.position.y)
                let velocity = CGVector(dx: distance.dx/dt, dy: distance.dy/dt)
                self.sand!.physicsBody!.velocity = velocity
            }
            else
            {
                //gestione del movimento dell'innaffiatoio
                if self.touchingWateringCan
                {
                    let dt : CGFloat = 1.0/10.0
                    let distance = CGVector(dx: self.touchPoint.x - self.wateringCan!.position.x , dy: self.touchPoint.y - self.wateringCan!.position.y)
                    let velocity = CGVector(dx: distance.dx/dt, dy: distance.dy/dt)
                    self.wateringCan!.physicsBody!.velocity = velocity
                }
                else
                {
                    //gestione del movimento del sole
                    if self.touchingSun
                    {
                        let dt : CGFloat = 1.0/10.0
                        let distance = CGVector(dx: self.touchPoint.x - self.sun!.position.x , dy: self.touchPoint.y - self.sun!.position.y)
                        let velocity = CGVector(dx: distance.dx/dt, dy: distance.dy/dt)
                        self.sun!.physicsBody!.velocity = velocity
                    }
                }
            }
        }
        //INTERSEZIONE CON SEME
        if self.seeds!.intersects(self.intersectionFlowerPot!)
        {
            if self.turn == 1
            {
                if !self.seedUsed
                {
                    self.seedUsed = true
                    self.itemSelectedSound()
                    self.secondSand = true
                    self.flowerPot!.texture = SKTexture(imageNamed: "filledFlowerPot2")
                }
            }
            else
            {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.canStartSand = false
                self.resetGame()
            }
        }
        else
        {
            //INTERSEZIONE CON TERRENO
            if self.sand!.intersects(self.intersectionFlowerPot!)
            {
                if self.turn == 0 || self.turn == 2
                {
                    self.sand_!.texture = SKTexture(imageNamed: "sand2")
                    //Prima intersezione con il terreno
                    if !self.sandUsed1 && self.canStartSand
                    {
                        self.itemSelectedSound()
                        self.sandUsed1 = true
                        self.flowerPot!.texture = SKTexture(imageNamed: "filledFlowerPot")
                    }
                    else
                    {
                        //seconda intersezione con il terreno
                        if !self.sandUsed2 && self.secondSand
                        {
                            self.sandUsed2 = true
                            self.itemSelectedSound()
                            self.flowerPot!.texture = SKTexture(imageNamed: "filledFlowerPot3")
                        }
                    }
                }
                else
                {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.canStartSand = false
                    self.resetGame()
                }

            }
            else
            {
                //INTERSEZIONE CON ACQUA
                if self.wateringCan!.intersects(self.intersectionFlowerPot!)
                {
                    if self.turn == 3 || self.turn == 5
                    {
                        self.wateringCan_!.texture = SKTexture(imageNamed: "wateringCan2")
                        //Prima intersezione con l'innaffiatoio
                        if !self.wateringCanUsed1
                        {
                            //self.turn += 1
                            self.itemSelectedSound()
                            self.wateringCanUsed1 = true
                            self.plantStep1!.isHidden = false
                        }
                        else
                        {
                            //seconda intersezione con l'innaffatoio
                            if !self.wateringCanUsed2 && self.secondWater
                            {
                                //Se arrivo qui significa che la piantina è cresciuta correttamente
                                //Lanciare un diverso suono 
                                self.lastStepSound()
                                self.wateringCanUsed2 = true
                                self.plantStep3!.isHidden = false
                                //3 secondi di bonus
                                let wait = SKAction.wait(forDuration: 1.0)
                                self.timer += 3
                                self.score += 1
                                let tmp = self.childNode(withName: "secondsGained") as? SKLabelNode
                                let viewSeconds = SKAction.run {
                                    if tmp!.isHidden
                                    {
                                        tmp!.isHidden = false
                                    }
                                    else
                                    {
                                        tmp!.isHidden = true
                                    }
                                }
                                let seq = SKAction.sequence([viewSeconds, wait, viewSeconds])
                                self.run(seq)
                                if self.timer > 5
                                {
                                    self.timerLabel!.fontColor = self.timerColor!
                                }
                                self.scoreLabel!.text = String(score)
                                let operation = SKAction.run {
                                    self.resetGame()
                                }
                                let sequence = SKAction.sequence([wait, operation])
                                self.run(sequence)
                            }
                        }
                    }
                    else
                    {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.canStartSand = false
                        self.resetGame()
                    }
                }
                else
                {
                    //INTERSEZIONE CON SOLE
                    if self.sun!.intersects(self.intersectionFlowerPot!)
                    {
                        if self.turn == 4
                        {
                            if !self.sunUsed
                            {
                                //cambia sfondo
                                self.sunshineAnimation()
                                self.itemSelectedSound()
                                self.sunUsed = true
                                self.plantStep2!.isHidden = false
                                self.secondWater = true
                            }
                        }
                        else
                        {
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            self.canStartSand = false
                            self.resetGame()
                        }
                    }
                }
            }
        }
    }
}
