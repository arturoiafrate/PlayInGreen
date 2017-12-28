//
//  RecycleGameScene.swift
//  PlayInGreen
//
//  Created by Arturo Iafrate on 31/05/17.
//  Copyright © 2017 iOSFoundation. All rights reserved.
//

import SpriteKit
import AudioToolbox

class RecycleGameScene: SKScene
{
    private var backButton : SKNode?
    private var basket0 : SKNode?
    private var basket1 : SKNode?
    private var basket2 : SKNode?
    private var rubbish : SKSpriteNode?
    private var type : String? //tipo di rifiuto
    //tempo rimasto
    private var timeLeftLabel : SKLabelNode?
    private var timeLeft : Int = 30
    //punteggio
    private var scoreLabel : SKLabelNode?
    private var score : Int = 0
    private var disableTouch : Bool = false //per impedire di fare altri punti
    //per gestire lancio del rifiuto
    private var touching : Bool = false
    private var touchPoint: CGPoint = CGPoint()
    private var okButton : SKSpriteNode?
    private let bgMusic : SKAudioNode = SKAudioNode(fileNamed: "sounds/recycleGameMusic.wav")
    private var musicControl : SKNode?
    private var musicEnabled : Bool = true
    
    //Caricamento e salvataggio dei settaggi
    private var defaults : UserDefaults = UserDefaults.standard
    private var saved : Bool = false
    private var maxScore : Int = 0
    private var miniGameIcon : SKNode?
    private var finalPhrase : SKNode?
    private var gameOverBg : SKSpriteNode?
    private var newRecord: Bool = false
    

    
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
        //bocca del cestino per intersezioni
        self.basket0 = self.childNode(withName: "basket0")//carta
        self.basket1 = self.childNode(withName: "basket1")//plastica
        self.basket2 = self.childNode(withName: "basket2")//umido
        self.rubbish = self.childNode(withName: "rubbish") as? SKSpriteNode //rifiuto
        self.timeLeftLabel = self.childNode(withName: "timeLeftLabel") as? SKLabelNode
        self.scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode
        self.okButton = self.childNode(withName: "okButton") as? SKSpriteNode
        self.miniGameIcon = self.childNode(withName: "miniGameIcon")
        self.finalPhrase = self.childNode(withName: "finalPhrase")
        self.finalPhrase!.isHidden = true
        self.miniGameIcon!.isHidden = true
        self.okButton!.isHidden = true
        self.gameOverBg = self.childNode(withName: "gameOverBg") as? SKSpriteNode
        self.gameOverBg!.isHidden = true
        self.saved = false
        self.loadGameTutorial()
        //Imposto la splash screen
//        let tmp = SKSpriteNode(texture: SKTexture(imageNamed: "recycleGameTutorial"))//texture da caricare
//        tmp.size = CGSize(width: 168, height: 280)//dimensione iniziale
//        tmp.zPosition = 10
//        tmp.name = "tutorial"//nome del nodo
//        self.addChild(tmp)//aggiungo il nodo alla scena
//        let zoom = SKAction.scale(to: CGSize(width: 670, height: 1120), duration: 0.5)//dimensione finale, da raggiungere entro duration secondi
//        tmp.run(zoom)//eseguo l'azione
        self.musicControl = self.childNode(withName: "musicControl")
        self.bgMusic.name = "bgMusic"
    }
    
    private func loadGameTutorial() {
        var imageName = "recycleGameTutorial"
        var initialWidth = 168
        var initialHeight = 280
        var finalWidth = 670
        var finalHeight = 1120
        if DataManager.defaultManager.deviceType == "iPad" {
            imageName = "iPad-recycleGameTutorial"
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
    
    private func playBackgroundMusic()//effetto fade-in per la musica in background
    {
        let start = SKAction.changeVolume(to: 0.05, duration: 0.0)
        let increment = SKAction.changeVolume(by: 0.1, duration: 1)
        let play = SKAction.play()
        let wait = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([start, play, increment, wait, increment, wait, increment])
        self.bgMusic.run(sequence)
    }
    
    private func getRandomFinalPhrase()
    {
        let randNum : UInt = UInt(arc4random_uniform(4)) + 1//Genero un numero da 1 a 4
        let phrase = self.childNode(withName: "finalPhrase") as? SKSpriteNode
        phrase!.texture = SKTexture(imageNamed: "recycleGamePhrase\(randNum)")
        self.finalPhrase!.zPosition = 15
        self.finalPhrase!.isHidden = false
    }
    
    private func showEndView()
    {
        let bestScoreLabel = self.childNode(withName: "bestScoreLabel") as? SKLabelNode
        let myScoreLabel = self.childNode(withName: "myScoreLabel") as? SKLabelNode
        let myScoreNumber = self.childNode(withName: "myScoreNumber") as? SKLabelNode
        let bestScoreNumber = self.childNode(withName: "bestScoreNumber") as? SKLabelNode
        //gestione del titolo in base al punteggio
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
    
    private func record() {
        newRecord = DataManager.defaultManager.saveRecycleGameScore(score: score) //Salvo il punteggio se è maggiore di quello precedente
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
    
    private func getRubbish()
    {
        let randKind : UInt = UInt(arc4random_uniform(18)) + 1//Genero un numero da 1 a 9
        if randKind <= 6 //Se il numero generato è da 1 a 3 il tipo di rifiuto sarà carta
        {
            self.type = "paper"
        }
        else
        {
            if randKind > 6 && randKind <= 12 // se è da 4 a 6 sarà umido
            {
                self.type = "organic"
            }
            else //altrimenti plastic
            {
                self.type = "plastic"
            }
        }
        self.rubbish!.texture = SKTexture(imageNamed: "rubbish\(randKind)")//texture da caricare
        self.rubbish!.alpha = CGFloat(1)
        self.rubbish!.position = CGPoint(x: 0, y: -500)
        self.rubbish!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
    }
    
    private func muteBackgroundMusic()
    {
        let tmp = self.childNode(withName: "bgMusic")
        if tmp != nil
        {
            self.bgMusic.run(SKAction.stop())
        }
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
    
    private func decreaseTimer() //funzione per il timer
    {
        let wait = SKAction.wait(forDuration: 1.0)
        let block = SKAction.run {
            if self.timeLeft > 0
            {
                self.timeLeft -= 1
                self.timeLeftLabel!.text = String(self.timeLeft)
                if self.timeLeft == 5
                {
                    self.timeLeftLabel!.fontColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
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
    
    private func showWrongBasket(basket : Int)
    {
        //basket 0 = paper
        //basket 1 = organic
        //basket 2 = plastic
        switch basket {
        case 0:
            let basketSelected = self.childNode(withName: "wrongBasketPaper") as? SKLabelNode
            let wait = SKAction.wait(forDuration: 1)
            let block = SKAction.run {
                if basketSelected!.isHidden
                {
                    basketSelected!.isHidden = false
                }
                else
                {
                    basketSelected!.isHidden = true
                }
            }
            let sequence = SKAction.sequence([block, wait, block])
            self.run(sequence)
        case 1:
            let basketSelected = self.childNode(withName: "wrongBasketOrganic") as? SKLabelNode
            let wait = SKAction.wait(forDuration: 1)
            let block = SKAction.run {
                if basketSelected!.isHidden
                {
                    basketSelected!.isHidden = false
                }
                else
                {
                    basketSelected!.isHidden = true
                }
            }
            let sequence = SKAction.sequence([block, wait, block])
            self.run(sequence)
        case 2:
            let basketSelected = self.childNode(withName: "wrongBasketPlastic") as? SKLabelNode
            let wait = SKAction.wait(forDuration: 1)
            let block = SKAction.run {
                if basketSelected!.isHidden
                {
                    basketSelected!.isHidden = false
                }
                else
                {
                    basketSelected!.isHidden = true
                }
            }
            let sequence = SKAction.sequence([block, wait, block])
            self.run(sequence)
        default:
            let basketSelected = self.childNode(withName: "wrongBasketPaper") as? SKLabelNode
            let wait = SKAction.wait(forDuration: 1)
            let block = SKAction.run {
                if basketSelected!.isHidden
                {
                    basketSelected!.isHidden = false
                }
                else
                {
                    basketSelected!.isHidden = true
                }
            }
            let sequence = SKAction.sequence([block, wait, block])
            self.run(sequence)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if !self.disableTouch
        {
            let touch = touches.first
            let location = touch!.location(in: self)
            if rubbish!.frame.contains(location)
            {
                self.touchPoint = location
                self.touching = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if !disableTouch
        {
            let touch = touches.first
            let location = touch!.location(in: self)
            self.touchPoint = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.touching = false
        let touch = touches.first
        if !self.disableTouch
        {
            let splashImage = self.childNode(withName: "tutorial")
            if splashImage != nil && splashImage!.contains(touch!.location(in: self))
            {
                self.removeChildren(in: [splashImage!])
                self.startMiniGame()
            }
            if self.backButton!.contains(touch!.location(in: self))
            {
                self.bgMusic.run(SKAction.stop())
                DataManager.defaultManager.saveSettings()
                self.itemSelectedSound()
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
                    self.itemSelectedSound()
                }
                DataManager.defaultManager.saveSettings()
            }
        }
        else
        {
            if self.okButton!.contains(touch!.location(in: self))
            {
                self.itemSelectedSound()
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
    
    override func update(_ currentTime: TimeInterval)
    {
        // Called before each frame is rendered
        if !self.disableTouch
        {
            if self.touching//per lanciare il rifiuto
            {
                var denominatore: Double = 20
                if DataManager.defaultManager.deviceType == "iPad" {
                    denominatore = 40
                }
                //let dt : CGFloat = 1.0/20.0 //diminuisci il denominatore per rallentare
                let dt : CGFloat = CGFloat(1.0/denominatore)
                let distance = CGVector(dx: self.touchPoint.x-self.rubbish!.position.x, dy: self.touchPoint.y-self.rubbish!.position.y)
                let velocity = CGVector(dx: distance.dx/dt, dy: distance.dy/dt)
                self.rubbish!.physicsBody!.velocity = velocity
            }
            else
            {
                if  self.rubbish!.intersects(self.basket0!)//Se il rifiuto va nel cestino della carta
                {
                    if self.type! == "paper" //incrementa punteggio
                    {
                        self.score += 1
                        self.scoreLabel!.text = String(self.score)
                    }
                    else//decrementa punteggio
                    {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        if self.score > 0
                        {
                            self.showWrongBasket(basket: 0)
                            self.score -= 1
                            self.scoreLabel!.text = String(self.score)
                        }
                    }
                    self.getRubbish()
                }
                else
                {
                    if  self.rubbish!.intersects(self.basket1!)//Se il rifiuto va nel cestino dell'organico
                    {
                        if self.type! == "organic" //incrementa punteggio
                        {
                            self.score += 1
                            self.scoreLabel!.text = String(self.score)
                        }
                        else//decrementa punteggio
                        {
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            if self.score > 0
                            {
                                self.showWrongBasket(basket: 1)
                                self.score -= 1
                                self.scoreLabel!.text = String(self.score)
                            }
                        }
                        self.getRubbish()
                    }
                    else
                    {
                        if  self.rubbish!.intersects(self.basket2!)//Se il rifiuto va nel cestino della plastica
                        {
                            if self.type! == "plastic" //incrementa punteggio
                            {
                                self.score += 1
                                self.scoreLabel!.text = String(self.score)
                            }
                            else//decrementa punteggio
                            {
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                if self.score > 0
                                {
                                    self.showWrongBasket(basket: 2)
                                    self.score -= 1
                                    self.scoreLabel!.text = String(self.score)
                                }
                            }
                            self.getRubbish()
                        }
                    }
                }
            }
        }
    }
    
    private func startMiniGame()
    {
        self.decreaseTimer()
        self.backgroundMusicControl()
        self.getRubbish()
    }
}
