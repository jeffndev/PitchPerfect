//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Jeff Newell on 3/22/15.
//  Copyright (c) 2015 Jeff Newell. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var auEngine:AVAudioEngine!
    var player:AVAudioPlayer!
    var lastRecordedAudio:RecordedAudio!
    var lastRecordedAFile:AVAudioFile!
    
    let EFFECT_CLEAN:Int = 0
    let EFFECT_REVERB:Int = 1
    let EFFECT_DISTORTION:Int = 2

    
    @IBOutlet weak var effectsToggle: UISegmentedControl!
    
    /*----viewcontroller overrides-------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        auEngine = AVAudioEngine()
        player = try? AVAudioPlayer(contentsOfURL: lastRecordedAudio.filePathUrl)
        lastRecordedAFile = try? AVAudioFile(forReading: lastRecordedAudio.filePathUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*-----actions---------*/
    @IBAction func changeEffect(sender: UISegmentedControl) {
        stopPlaybackAction()
    }
    @IBAction func playSlow(sender: UIButton) {
        playAudioWithVarPitchTime(0.0, rate: 0.5)
    }
    
    @IBAction func playFast(sender: UIButton) {
        playAudioWithVarPitchTime(0.0, rate: 1.8)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVarPitchTime(1000, rate: 1.0);
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playAudioWithVarPitchTime(-800, rate: 1.0)
    }
    
    @IBAction func stopPlayback(sender: UIButton) {
        stopPlaybackAction()
    }
    
    /* -------helper methods---------*/
    func stopPlaybackAction(){
        player.stop()
        auEngine.stop()
        auEngine.reset()
    }
    
    func playAudioWithVarPitchTime(pitch:Float, rate:Float){
        player.stop()
        auEngine.stop()
        auEngine.reset()
        
        let auPlayerNode = AVAudioPlayerNode()
        auEngine.attachNode(auPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        changePitchEffect.rate = rate
        auEngine.attachNode(changePitchEffect)
        auEngine.connect(auPlayerNode, to: changePitchEffect, format: nil)
        if effectsToggle.selectedSegmentIndex == EFFECT_REVERB{
            let reverb = AVAudioUnitReverb()
            reverb.loadFactoryPreset(.Cathedral)
            reverb.wetDryMix = 20
            auEngine.attachNode(reverb)
            auEngine.connect(changePitchEffect, to: reverb, format: nil)
            auEngine.connect(reverb, to: auEngine.outputNode, format: nil)
        }else if effectsToggle.selectedSegmentIndex == EFFECT_DISTORTION{
            let distortion = AVAudioUnitDistortion()
            distortion.loadFactoryPreset(.SpeechGoldenPi)
            distortion.wetDryMix = 50
            auEngine.attachNode(distortion)
            auEngine.connect(changePitchEffect, to: distortion, format: nil)
            auEngine.connect(distortion, to: auEngine.outputNode, format: nil)
        }else{
            auEngine.connect(changePitchEffect, to: auEngine.outputNode, format: nil)
        }
        auPlayerNode.scheduleFile(lastRecordedAFile, atTime: nil, completionHandler: nil)
        do {
            try auEngine.start()
        } catch _ {
        };
        
        auPlayerNode.play()
    }
    
    func playAtSpeed(theRate:Float, doRestart:Bool){
        //a simpler version, perhaps deprecated now..
        auEngine.stop()
        auEngine.reset()
        player.enableRate=true
        player.rate = theRate
        if(doRestart){player.currentTime = 0.0}
        player.play()
    }
}
