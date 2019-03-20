//
//  ViewController.swift
//  zBA Audio
//
//  Created by Syon on 11/03/19.
//  Copyright © 2019 Syon. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    
    // MARK: Property
    var soundPlayer: AVAudioPlayer!
    var soundRecorder: AVAudioRecorder!

//    var fileName: String = "audioFile.wav"
    var fileName: String = "audioFile.m4a"
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        print("FilePath  ::::  \(filePath)")
        
        setupRecorder()
        btnPlay.isEnabled = false
    }
    
    // MARK: Actions
    @IBAction func recordTapped(_ sender: Any) {
        if btnRecord.titleLabel?.text == "Record" {
            soundRecorder.record()
            btnRecord.setTitle("Stop", for: .normal)
            btnPlay.isEnabled = false
        } else {
            soundRecorder.stop()
            btnRecord.setTitle("Record", for: .normal)
            btnPlay.isEnabled = true
        }
    }
    
    @IBAction func playTapped(_ sender: Any) {
        if btnPlay.titleLabel?.text == "Play" {
            btnPlay.setTitle("Stop", for: .normal)
            btnRecord.isEnabled = false
            setupPlayer()
            soundPlayer.play()
        } else {
            soundPlayer.stop()
            btnPlay.setTitle("Play", for: .normal)
            btnRecord.isEnabled = false
        }
    }
    
    //MARK: Custom Methods
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setupRecorder() {
        let audioFileName = getDocumentsDirectory().appendingPathComponent(fileName)
        let recordSetting = [ AVFormatIDKey: kAudioFormatAppleLossless,
                              AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey: 320000,
                              AVNumberOfChannelsKey: 2,
                              AVSampleRateKey: 44100.2 ] as [String: Any]
        do {
            soundRecorder = try AVAudioRecorder(url: audioFileName, settings: recordSetting)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    func setupPlayer() {
        let audioFileName = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFileName)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        } catch {
            print(error)
        }
    }
    
}

// MARK: Extensions
// Audio player delegates
extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        btnPlay.isEnabled = true
    }
}

// Audio recorder delegates
extension ViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        btnRecord.isEnabled = true
        btnPlay.setTitle("Play", for: .normal)
    }
}

