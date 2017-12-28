//
//  EnergyGameScene.swift
//  PlayInGreen
//
//  Created by Arturo Iafrate on 30/05/17.
//  Copyright © 2017 iOSFoundation. All rights reserved.
//

import SpriteKit
import AudioToolbox

class EnergyGameScene: SKScene
{
    private var bulbs : [SKSpriteNode?] = [] //array di lampadine
    private var isOn : [Bool] = [false , false , false , false , false , false] //lampadine tutte spente
    private var background : SKSpriteNode? //background
    private var timer : Int = 30 //conto alla rovescia
    private var timerLabel : SKLabelNode? //label correlata al timer
    private var score : Int = 0 //punteggio
    private var scoreLabel : SKLabelNode? //label correlata al pungeggio
    private var currentBg : Int = 1
    private var disableTouch : Bool = false //per impedire di fare altri punti
    private var gameOverBg : SKSpriteNode?
    private var okButton : SKSpriteNode?
    private let bgMusic : SKAudioNode = SKAudioNode(fileNamed: "sounds/energyGameMusic.wav")
    private var backButton : SKNode?
    private var musicControl : SKNode?
    private var miniGameIcon : SKNode?
    private var finalPhrase : SKNode?
    //Caricamento e salvataggio dei settaggi
    private var saved : Bool = false
    private var maxScore : Int = 0
    private var newRecord: Bool = false
    
    //Adattamento interfaccia
    private let deviceType: String = UIDevice.current.model/*ELIMINARE*/
    
    override func didMove(to view: SKView) //Innescata quando visualizzo la view
    {
        DataManager.defaultManager.loadSavedSettings()
        maxScore = DataManager.defaultManager.getEnergyGameScore()
        if !DataManager.defaultManager.isMusicEnabled() //Se la musica è disabilitata cambio icona
        {
            let tmp = self.childNode(withName: "musicControl") as? SKSpriteNode
            tmp!.texture = SKTexture(imageNamed: "musicOff")
        }
        self.backButton = self.childNode(withName: "backButton")
        self.miniGameIcon = self.childNode(withName: "miniGameIcon")
        self.musicControl = self.childNode(withName: "musicControl")
        self.finalPhrase = self.childNode(withName: "finalPhrase")
        self.finalPhrase!.isHidden = true
        self.miniGameIcon!.isHidden = true
        self.bgMusic.name = "bgMusic"
        self.timerLabel = self.childNode(withName: "alarmLabel") as? SKLabelNode //collego la variabile alla label
        self.scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode //come sopra
        for i in 1...6
        {
            self.bulbs += [self.childNode(withName: "camera\(i)") as? SKSpriteNode]//Collego le 6 stanze
        }
        self.background = self.childNode(withName: "background") as? SKSpriteNode
        self.okButton = self.childNode(withName: "okButton") as? SKSpriteNode
        self.okButton!.isHidden = true
        self.gameOverBg = self.childNode(withName: "gameOverBg") as? SKSpriteNode
        self.gameOverBg!.isHidden = true
        self.loadGameTutorial()
    }
    
    private func loadGameTutorial() {
        var imageName = "energyGameTutorial"
        var initialWidth = 168
        var initialHeight = 280
        var finalWidth = 670
        var finalHeight = 1120
        if DataManager.defaultManager.deviceType == "iPad" {
            imageName = "iPad-energyGameTuorial"
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
    
    private func moveBackground()
    {
        let wait = SKAction.wait(forDuration: 0.5)
        let block = SKAction.run {
            self.currentBg += 1
            if self.currentBg > 4
            {
                self.currentBg = 1
            }
            let loadTexture = SKTexture(imageNamed: "bg\(self.currentBg)")
            self.background?.texture = loadTexture
        }
        let sequence = SKAction.sequence([wait , block])
        self.run(SKAction.repeatForever(sequence))
    }
    
    private func getRandomFinalPhrase()
    {
        let randNum : UInt = UInt(arc4random_uniform(4)) + 1//Genero un numero da 1 a 4
        let phrase = self.childNode(withName: "finalPhrase") as? SKSpriteNode
        phrase!.texture = SKTexture(imageNamed: "energyGamePhrase\(randNum)")
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
    
    private func record()
    {
        newRecord = DataManager.defaultManager.saveEnergyGameScore(score: score) //Salvo il punteggio se è maggiore di quello precedente
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
    
    private func decreaseTimer() //funzione per il timer
    {
        let wait = SKAction.wait(forDuration: 1.0)
        let block = SKAction.run {
            //Decremento il timer se è maggiore di 0
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
                //Termino il gioco
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
    
    private func changeState()
    {
        let wait = SKAction.wait(forDuration: TimeInterval(1.5))//Ogni 1.5 sec si accendono/spengono lampadine
        let block = SKAction.run
        {
            if self.okButton!.isHidden//se stiamo ancora giocando
            {
                var i : Int = 0
                for x in self.bulbs
                {
                    let choice = UInt(arc4random_uniform(2))
                    if choice == 0
                    { //spegni
                        if self.isOn[i]
                        {
                            self.isOn[i] = false
                            x!.texture = SKTexture(imageNamed: "camera\(i+1)-off")
                        }
                    }
                    else
                    { //accendi
                        if !self.isOn[i]
                        {
                            self.isOn[i] = true
                            x!.texture = SKTexture(imageNamed: "camera\(i+1)-on")
                        }
                    }
                    i += 1
                }
            }
        }
        let sequence = SKAction.sequence([ wait , block ])
        self.run(SKAction.repeatForever(sequence))
    }
    
    private func startMiniGame()
    {
        self.decreaseTimer()
        self.changeState()
        self.moveBackground()
        self.backgroundMusicControl()
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first
        if !self.disableTouch
        {
            let splashImage = self.childNode(withName: "tutorial")
            if splashImage != nil && splashImage!.contains(touch!.location(in: self))
            {
                self.removeChildren(in: [splashImage!])
                self.startMiniGame()
            }
            else
            {
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
                if self.backButton!.contains(touch!.location(in: self))
                {
                    DataManager.defaultManager.saveSettings()
                    self.bgMusic.run(SKAction.stop())
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
                var j : Int = 0
                for i in bulbs
                {
                    let tmp = self.childNode(withName: i!.name!)
                    if tmp!.contains(touch!.location(in: self))
                    {
                        if self.isOn[j]//Spegni lampadina e incrementa punteggio
                        {
                            self.isOn[j]=false
                            i!.texture = SKTexture(imageNamed: "camera\(j+1)-off")
                            self.score += 1
                            self.scoreLabel!.text = String(self.score)
                        }
                        else
                        {
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                    }
                    j += 1
                }
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
    
}
