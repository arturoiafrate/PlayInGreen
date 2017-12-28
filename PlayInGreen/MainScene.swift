//
//  GameScene.swift
//  PlayInGreen
//
//  Created by Arturo Iafrate on 30/05/17.
//  Copyright © 2017 iOSFoundation. All rights reserved.
//

/*Classe per gestire la view con la scelta dei minigiochi*/

import SpriteKit
import AudioToolbox

class MainScene: SKScene {
    //Controlli vari sulla scena
    private var energyGameButton : SKNode? //Bottone primo minigame
    private var recycleGameButton : SKNode? //Bottone secondo minigame
    private var plantGameButton : SKNode? //Bottone terzo minigame
    private var musicControl : SKNode? //Bottone controllo del volume
    private let bgMusic : SKAudioNode = SKAudioNode(fileNamed: "sounds/mainMusic.wav") //Musica di sottofondo
    private let selectedItemSound : SKAction = SKAction.playSoundFileNamed("sounds/itemSelect.wav", waitForCompletion: true) //Suono di selezione
    
    /*****OPERAZIONI CHE EFFETTUO QUANDO VIENE CARICATA LA SCENA*****/
    override func didMove(to view: SKView)
    {
        //Assegno ai bottoni sulla scena un controller
        self.energyGameButton = self.childNode(withName: "energyGameButton")
        self.recycleGameButton = self.childNode(withName: "recycleGameButton")
        self.plantGameButton = self.childNode(withName: "plantGameButton")
        self.musicControl = self.childNode(withName: "musicControl")
        self.bgMusic.name = "bgMusic"
        if DataManager.defaultManager.isMusicEnabled() {
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
    
    /*METODO PER DARE UN EFFETTO FADE IN PER LA MUSICA IN BACKGROUND*/
    private func playBackgroundMusic()
    {
        let start = SKAction.changeVolume(to: 0.05, duration: 0.0)
        let increment = SKAction.changeVolume(by: 0.1, duration: 1)
        let play = SKAction.play()
        let wait = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([start, play, increment, wait, increment, wait, increment])
        self.bgMusic.run(sequence)
    }
    /*METODO PER FERMARE LA MUSICA IN BACKGROUND*/
    private func stopBackgroundMusic()
    {
        DataManager.defaultManager.disableMusic()
        let tmp = self.childNode(withName: "bgMusic")
        if tmp != nil
        {
            self.bgMusic.run(SKAction.stop())
        }
    }
    /*METODO PER RIPRENDERE L'ESECUZIONE DELLA MUSICA IN BACKGROUND*/
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
    
    
    
    /****METODI PER LA GESTIONE DEI TAP SUI NODI DELLA SCENA****/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first
        if musicControl!.contains(touch!.location(in: self))//Controllo se il tocco c'è stato sul nodo gestore audio
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
                let tmp = self.childNode(withName: "musicControl") as? SKSpriteNode
                tmp!.texture = SKTexture(imageNamed: "musicOn")
                self.scene?.run(selectedItemSound)
                self.resumeBackgroundMusic()
            }
            DataManager.defaultManager.saveSettings()
        }
        if energyGameButton!.contains(touch!.location(in: self))//Primo mini-gioco
        {
            self.bgMusic.run(SKAction.stop())
            if DataManager.defaultManager.isMusicEnabled()
            {
                self.scene!.run(selectedItemSound)
            }
            if DataManager.defaultManager.deviceType == "iPhone"
            {
                let scene = EnergyGameScene(fileNamed: "EnergyGameScene")
                scene?.scaleMode = .aspectFit
                DataManager.defaultManager.saveSettings()
                view?.presentScene(scene!, transition: SKTransition.doorway(withDuration: 0.5))
            }
            else
            {
                let scene = EnergyGameScene(fileNamed: "iPadEnergyGameScene")
                scene?.scaleMode = .aspectFit
                DataManager.defaultManager.saveSettings()
                view?.presentScene(scene!, transition: SKTransition.doorway(withDuration: 0.5))
            }
        }
        else
        {
            if recycleGameButton!.contains(touch!.location(in: self))//secondo mini-gioco
            {
                self.bgMusic.run(SKAction.stop())
                if DataManager.defaultManager.isMusicEnabled()
                {
                    self.scene!.run(selectedItemSound)
                }
                if DataManager.defaultManager.deviceType == "iPhone"
                {
                    let scene = RecycleGameScene(fileNamed: "RecycleGameScene")
                    scene?.scaleMode = .aspectFit
                    DataManager.defaultManager.saveSettings()
                    view?.presentScene(scene!, transition: SKTransition.doorway(withDuration: 0.5))
                }
                else
                {
                    let scene = EnergyGameScene(fileNamed: "iPadRecycleGameScene")
                    scene?.scaleMode = .aspectFit
                    DataManager.defaultManager.saveSettings()
                    view?.presentScene(scene!, transition: SKTransition.doorway(withDuration: 0.5))
                }
            }
            else
            {
                if plantGameButton!.contains(touch!.location(in: self))//secondo mini-gioco
                {
                    self.bgMusic.run(SKAction.stop())
                    if DataManager.defaultManager.isMusicEnabled()
                    {
                        self.scene!.run(selectedItemSound)
                    }
                    if DataManager.defaultManager.deviceType == "iPhone"
                    {
                        let scene = RecycleGameScene(fileNamed: "PlantGameScene")
                        scene?.scaleMode = .aspectFit
                        DataManager.defaultManager.saveSettings()
                        view?.presentScene(scene!, transition: SKTransition.doorway(withDuration: 0.5))
                    }
                    else
                    {
                        let scene = EnergyGameScene(fileNamed: "iPadPlantGameScene")
                        scene?.scaleMode = .aspectFit
                        DataManager.defaultManager.saveSettings()
                        view?.presentScene(scene!, transition: SKTransition.doorway(withDuration: 0.5))
                    }
                }
                else
                {
                    for i in 1...6
                    {
                        let lockedGameButton = self.childNode(withName: "lockedGameButton\(i)")
                        if lockedGameButton!.contains(touch!.location(in: self))
                        {
                            let posStart = SKAction.rotate(byAngle: 0.2, duration: 0.1)
                            let posEnd = SKAction.rotate(byAngle: -0.4, duration: 0.1)
                            let posMiddle1 = SKAction.rotate(byAngle: 0.8, duration: 0.1)
                            let posMiddle2 = SKAction.rotate(byAngle: -1.6, duration: 0.1)
                            let posMiddle3 = SKAction.rotate(byAngle: 1.6, duration: 0.1)
                            let lastPos = SKAction.rotate(byAngle: -0.6, duration: 0.1)
                            let sequence = SKAction.sequence([posStart, posEnd, posMiddle1, posMiddle2, posMiddle3, lastPos])
                            lockedGameButton!.run(sequence)
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            
                        }
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
