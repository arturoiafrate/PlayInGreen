//
//  DataManager.swift
//  playingreen
//
//  Created by Arturo Iafrate on 13/07/17.
//  Copyright © 2017 iOSFoundation. All rights reserved.
//

import Foundation

class DataManager {
    // Manager statico
    static var defaultManager = DataManager()
    // Tipo di device su cui gira l'applicazione
    private var _deviceType: String = "iPhone"
    public var deviceType: String {
        get {
            return _deviceType
        }
        set {
            _deviceType = newValue
        }
    }
    /*******MUSICA********/
    //Controlli per abilitare e disabilitare la musica
    private var _musicEnabled: Bool = true
    public func enableMusic() {
        _musicEnabled = true
    }
    public func disableMusic() {
        _musicEnabled = false
    }
    public func isMusicEnabled() -> Bool {
        return _musicEnabled
    }
    /*******SETTAGGI********/
    //Per il caricamento e il salvataggio dei settaggi
    private var _settings: UserDefaults = UserDefaults.standard
    public func loadSavedSettings() {//Carico e applico i settaggi
        let tmp = _settings.value(forKey: "isMusicEnabled") as? Bool
        if tmp != nil {
            _musicEnabled = tmp!
        }
        else {
            _musicEnabled = true;
        }
    }
    public func saveSettings() { //Salvo i settaggi
        _settings.set(_musicEnabled, forKey: "isMusicEnabled")
    }
    /*******RECORD********/
    //Per il caricamento ed il salvataggio dei record
    private var _scores: UserDefaults = UserDefaults.standard
    private var _energyScore: Int = 0
    private var _recycleScore: Int = 0
    private var _plantScore: Int = 0
    //METODI PER IL GIOCO DELLE LUCI
    public func getEnergyGameScore() -> Int { //Ritorna il punteggio salvato del primo minigioco; ritorna 0 se questo non esiste
        let tmp = _scores.value(forKey: "maxEnergyGameScore") as? Int
        if tmp != nil {
            _energyScore = tmp!
            return _energyScore
        }
        else { return 0 }
    }
    
    public func saveEnergyGameScore(score: Int) -> Bool {//Permette di salvare il punteggio passato in input se questo è maggiore del punteggio salvato
        if score > _energyScore {
            _scores.set(score, forKey: "maxEnergyGameScore")
            _energyScore = score
            return true
        }
        else { return false }
    }
    
    //METODI PER IL GIOCO DEL RICICLO
    public func getRecycleGameScore() -> Int { //Ritorna il punteggio salvato del secondo minigioco; ritorna 0 se questo non esiste
        let tmp = _scores.value(forKey: "maxRecycleGameScore") as? Int
        if tmp != nil {
            _recycleScore = tmp!
            return _recycleScore
        }
        else { return 0 }
    }
    
    public func saveRecycleGameScore(score: Int) -> Bool {//Permette di salvare il punteggio passato in input se questo è maggiore del punteggio salvato
        if score > _recycleScore {
            _scores.set(score, forKey: "maxRecycleGameScore")
            _recycleScore = score
            return true
        }
        else { return false }
    }

    //METODI PER IL GIOCO DELLA PIANTA
    public func getPlantGameScore() -> Int { //Ritorna il punteggio salvato del terzo minigioco; ritorna 0 se questo non esiste
        let tmp = _scores.value(forKey: "maxPlantGameScore") as? Int
        if tmp != nil {
            _plantScore = tmp!
            return _plantScore
        }
        else { return 0 }
    }
    
    public func savePlantGameScore(score: Int) -> Bool {//Permette di salvare il punteggio passato in input se questo è maggiore del punteggio salvato
        if score > _plantScore {
            _scores.set(score, forKey: "maxPlantGameScore")
            _plantScore = score
            return true
        }
        else { return false }
    }

}
