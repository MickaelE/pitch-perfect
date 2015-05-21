//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Mickael Eriksson on 2015-05-13.
//  Copyright (c) 2015 Mickenet. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    @IBOutlet weak var SlowButtonOutlet: UIButton!
    @IBOutlet weak var FastSoundButtonOutlet: UIButton!
    var audioPlayer:AVAudioPlayer!;
    var audioPlayer2:AVAudioPlayer!;
    var reverbPlayers:[AVAudioPlayer] = []
    var recievedAudio:RecordedAudio!;
     let unitReverb = AVAudioUnitReverb()
    
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioPlayer = AVAudioPlayer(contentsOfURL:recievedAudio.filePathUrl, error:nil);
        audioPlayer2 = AVAudioPlayer(contentsOfURL:recievedAudio.filePathUrl, error:nil); //Used for Echo, no need for rate enabled.
        audioPlayer.enableRate = true;
        audioEngine = AVAudioEngine();
        audioFile = AVAudioFile(forReading: recievedAudio.filePathUrl, error: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func FastButtonAction(sender: AnyObject) {
        println("FastButton");
        playAudio(2.0);
    }
    
    @IBAction func slowButtonAction(sender: AnyObject) {
        println("slowButton");
        playAudio(0.5);
        
    }
  
    @IBAction func playChipmunkAudio(sender: AnyObject) {
        println("chipmunkButton");
        playPitchedAudio(1000);
    }
    
    @IBAction func playDarthvaderAudio(sender: AnyObject) {
        println("dathvaderButton");
        playPitchedAudio(-1000);
    }
    
    @IBAction func playReverbAudio(sender: AnyObject) {
        println("reverbButton");
        playReverb();
    }
    
    @IBAction func playEchoAudio(sender: AnyObject) {
        println("echoButton");
        playEcho(0.1);//100ms
    }
    
    @IBAction func StopPlayingAction(sender: UIButton) {
        if(audioEngine.running){
            audioEngine.stop();
            audioEngine.reset();
        }

        audioPlayer.stop();
    }
    
    //
    // Function to play sound with reverb.
    //
    func playReverb(){
        if(audioEngine.running){
            audioEngine.stop();
            audioEngine.reset();
        }
        var inputNode: AVAudioInputNode!
        inputNode = audioEngine.inputNode
        audioEngine.attachNode(unitReverb)
        
        let format = unitReverb.inputFormatForBus(0)
        audioEngine.connect(inputNode, to: unitReverb, format: format)
        audioEngine.connect(unitReverb, to: audioEngine.outputNode, format: format)
        
        audioEngine.startAndReturnError(nil)
    
    }
    
    //
    // Function to play sound with eco. Supply intervall between echo.
    //
    func playEcho(delay:NSTimeInterval){
        if(audioEngine.running){
            audioEngine.stop();
            audioEngine.reset();
        }
        audioPlayer.stop();
        audioPlayer.currentTime = 0;
        audioPlayer.play()
        var playtime:NSTimeInterval;
        playtime = audioPlayer.deviceCurrentTime + delay;
        
        audioPlayer2.currentTime=0;
        audioPlayer2.playAtTime(playtime);
        
    }
    
    //
    //Function to play sound with variable pitch. Supply pitch.
    //
    func playPitchedAudio(pitch: Float) {
        if(audioEngine.running){
            audioPlayer.stop()
            audioEngine.stop()
            audioEngine.reset()
        }
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var changePitch = AVAudioUnitTimePitch()
        changePitch.pitch = pitch
        audioEngine.attachNode(changePitch)
        audioEngine.connect(audioPlayerNode, to: changePitch, format: nil)
        audioEngine.connect(changePitch, to: audioEngine.outputNode, format: nil)
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
    //
    // Function to play with variable rate. Supplying rate.
    //
    func playAudio(rate:Float){
        if(audioEngine.running){
            audioEngine.stop();
            audioEngine.reset();
        }
        audioPlayer.stop();
        audioPlayer.currentTime=0;
        audioPlayer.rate = rate;
        audioPlayer.play();
    }
   
}
