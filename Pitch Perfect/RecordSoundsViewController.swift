//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Jeff Newell on 3/15/15.
//  Copyright (c) 2015 Jeff Newell. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    var recordingStatusLabelDfltColor:UIColor!
    var recordBtnDfltBkgColor:UIColor!
    let recordBtnBlinkBkgColor = UIColor.redColor()
    var pauseMode:Bool = false
    var blinkTimer:NSTimer!
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var isRecordingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    /*----viewcontroller overrides-------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        recordBtnDfltBkgColor = recordButton.backgroundColor
        recordingStatusLabelDfltColor = isRecordingLabel.textColor
    }
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
        pauseButton.hidden = true
        recordButton.enabled = true
        isRecordingLabel.textColor =  recordingStatusLabelDfltColor
        recordButton.backgroundColor=recordBtnDfltBkgColor
        resetIsRecordingLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*-----actions---------*/
    @IBAction func recordAudio(sender: UIButton) {
        isRecordingLabel.text = "Recording in progress"
        stopButton.hidden = false
        recordButton.enabled=false
        pauseButton.hidden = false
        pauseButton.enabled=true
        
        if pauseMode {
            pauseMode = false
            blinkTimer.invalidate()
            recordButton.backgroundColor = recordBtnDfltBkgColor
            isRecordingLabel.textColor =  recordingStatusLabelDfltColor
        }else{
            //set up for record
            let docPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
            let curDateTime = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            let recordingName = formatter.stringFromDate(curDateTime) + ".wav"
            let pathArray = [docPath,recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)
            print(filePath)
            
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            } catch _ {
            }
            
            audioRecorder = try? AVAudioRecorder(URL: filePath!, settings: [String: AnyObject]())
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled=true
        }
        audioRecorder.record()
    }
    
    func resetIsRecordingLabel(){
        isRecordingLabel.textColor =  recordingStatusLabelDfltColor
        isRecordingLabel.text = "Tap to Record"
    }
    @IBAction func stopRecord(sender: UIButton) {
        if pauseMode {
            blinkTimer.invalidate()
        }
        resetIsRecordingLabel()
        recordButton.enabled = true
        pauseButton.hidden = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch _ {
        }
    }
    @IBAction func pauseRecording(sender: UIButton) {
        pauseMode=true
        blinkTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("blink"), userInfo: nil, repeats: true)
        pauseButton.enabled=false
        recordButton.enabled = true
        isRecordingLabel.textColor = UIColor.redColor()
        isRecordingLabel.text = "Recording is paused"
        
        audioRecorder.pause()
    }
    func blink(){
        recordButton.backgroundColor =
            (recordButton.backgroundColor == recordBtnDfltBkgColor ? recordBtnBlinkBkgColor : recordBtnDfltBkgColor)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag){
            recordedAudio = RecordedAudio(audioUrl: recorder.url, audioTitle: recorder.url.lastPathComponent)
            //pass the info to the next VC..
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }else{
            recordButton.enabled=true
            stopButton.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecording" {
            let targetVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            targetVC.lastRecordedAudio = data
        }
    }
    
    
    
    
    
    
}

