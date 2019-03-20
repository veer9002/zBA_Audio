//
//  AudioKitViewController.swift
//  zBA Audio
//
//  Created by Syon on 14/03/19.
//  Copyright © 2019 Syon. All rights reserved.
//

import UIKit
import AVFoundation
import SoundWave
import Floaty

class AudioKitViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voiceImageView: UIButton!
    @IBOutlet weak var audioVisualizationView: AudioVisualizationView!
    @IBOutlet weak var lblTimer: UILabel!
//    @IBOutlet weak var floatingBtn: UIButton!
    
    // properties
    var numberOfRecords = 0
    var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recordings = [Recordings]()
    
    // Timer
    var timer = Timer()
    var counter = 0
    var isPlaying = false
    
    private var audioFile: AVAudioFile?
    private var renderTs: Double = 0
    private var recordingTs: Double = 0
    private var silenceTs: Double = 0
    let audioEngine = AVAudioEngine()
    let settings = [AVFormatIDKey: kAudioFormatLinearPCM, AVLinearPCMBitDepthKey: 16, AVLinearPCMIsFloatKey: true, AVSampleRateKey: Float64(44100), AVNumberOfChannelsKey: 1] as [String : Any]
    
    let floaty = Floaty()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // File path
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        print("FilePath  ::::  \(filePath!)")
    
        if let number = UserDefaults.standard.object(forKey: "Records") as? Int {
            numberOfRecords = number
        }
        permissionForAudio()
        voiceImageView.cornerRadiusWithoutAnimation(cornerRadius: self.voiceImageView.frame.height / 2)
        floatyButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecordings()
    }
    
    // MARK:- Data
    func loadRecordings() {
        self.recordings.removeAll()
        let filemanager = FileManager.default
        let documentsDirectory = filemanager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let paths = try filemanager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            
            for path in paths {
                let recording = Recordings(title: path.lastPathComponent, path: path)
                self.recordings.append(recording)
            }
            self.tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    @IBAction func voiceAction(_ sender: Any) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
   
    func startRecording() {
        numberOfRecords += 1
        let audioFilename = getDirectory().appendingPathComponent("Recording \(numberOfRecords).wav")

        do {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self

            audioRecorder.prepareToRecord()
            UserDefaults.standard.set(numberOfRecords, forKey: "Records")
            voiceImageView.cornerRadius(cornerRadius: self.voiceImageView.frame.height / 2)
            voiceImageView.setBackgroundImage(UIImage(named: "ic_pause"), for: .normal)
            self.tableView.reloadData()
        } catch {
            finishRecording(success: false)
        }
        
        do {
            try recordingSession.setActive(true)
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            audioRecorder.record()
        } catch  {
            
        }
    }
    
    // MARK:- Recording
//    private func startRecording() {
//        if let d = self.delegate {
//            d.didStartRecording()
//        }
//
//        self.recordingTs = NSDate().timeIntervalSince1970
//        self.silenceTs = 0
//
//        do {
//            let session = AVAudioSession.sharedInstance()
//            try session.setCategory(.playAndRecord, mode: .default)
//            try session.setActive(true)
//        } catch let error as NSError {
//            print(error.localizedDescription)
//            return
//        }
//
//        let inputNode = self.audioEngine.inputNode
//        guard let format = self.format() else {
//            return
//        }
//
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) in
//            let level: Float = -50
//            let length: UInt32 = 1024
//            buffer.frameLength = length
//            let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(buffer.format.channelCount))
//            var value: Float = 0
//            vDSP_meamgv(channels[0], 1, &value, vDSP_Length(length))
//            var average: Float = ((value == 0) ? -100 : 20.0 * log10f(value))
//            if average > 0 {
//                average = 0
//            } else if average < -100 {
//                average = -100
//            }
//            let silent = average < level
//            let ts = NSDate().timeIntervalSince1970
//            if ts - self.renderTs > 0.1 {
//                let floats = UnsafeBufferPointer(start: channels[0], count: Int(buffer.frameLength))
//                let frame = floats.map({ (f) -> Int in
//                    return Int(f * Float(Int16.max))
//                })
//                DispatchQueue.main.async {
//                    let seconds = (ts - self.recordingTs)
//                    self.timeLabel.text = seconds.toTimeString
//                    self.renderTs = ts
//                    let len = self.audioView.waveforms.count
//                    for i in 0 ..< len {
//                        let idx = ((frame.count - 1) * i) / len
//                        let f: Float = sqrt(1.5 * abs(Float(frame[idx])) / Float(Int16.max))
//                        self.audioView.waveforms[i] = min(49, Int(f * 50))
//                    }
//                    self.audioView.active = !silent
//                    self.audioView.setNeedsDisplay()
//                }
//            }
//
//            let write = true
//            if write {
//                if self.audioFile == nil {
//                    self.audioFile = self.createAudioRecordFile()
//                }
//                if let f = self.audioFile {
//                    do {
//                        try f.write(from: buffer)
//                    } catch let error as NSError {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        }
//        do {
//            self.audioEngine.prepare()
//            try self.audioEngine.start()
//        } catch let error as NSError {
//            print(error.localizedDescription)
//            return
//        }
//        self.updateUI(.recording)
//    }
    

    @objc func UpdateTimer() {
        counter += 1
        lblTimer.text = String(format: "%02d:%02d", (counter % 3600) / 60, (counter % 3600) % 60)
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        timer.invalidate()
//        lblTimer.text = "00:00"
        removeAnimation()
        
        if success {
            voiceImageView.setBackgroundImage(UIImage(named: "mic"), for: .normal)
            UserDefaults.standard.set(numberOfRecords, forKey: "Records")
        } else {
            voiceImageView.setBackgroundImage(UIImage(named: "mic"), for: .normal)
        }
    }
    
    // MARK: Custom Methods
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func format() -> AVAudioFormat? {
        let format = AVAudioFormat(settings: self.settings)
        return format
    }
    
    private func isRecording() -> Bool {
        if self.audioEngine.isRunning {
            return true
        }
        return false
    }
    
    private func stopRecording() {
        self.audioFile = nil
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.audioEngine.stop()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch  let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    func floatyButton() {
       
        let notifications = FloatyItem()
        notifications.buttonColor = UIColor.blue
        notifications.title = "Notifications"
        Floaty.global.button.addItem(item: notifications)
        
        let analytics = FloatyItem()
        analytics.buttonColor = UIColor.blue
        analytics.title = "Analytics"
        Floaty.global.button.addItem(item: analytics)
        
        let call = FloatyItem()
        call.buttonColor = UIColor.blue
        call.title = ""
        Floaty.global.button.addItem(item: call)
        
        Floaty.global.button.addItem(title: "Call Customer Care") { (callItem) in
            // alert for calling
            call.buttonColor = UIColor.blue
            print("Action added")
            
        }
    
//        Floaty.global.button.addItem(item: analytics)
        
        Floaty.global.show()
//        let item = FloatyItem()
//        item.buttonColor = UIColor.blueColor()
//        item.title = "Custom item"
//        Floaty.global.button.addItem(item: item)
        
        
        
    }
    
    // MARK:- Paths and files
    private func createAudioRecordPath() -> URL? {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss-SSS"
        let currentFileName = "recording-\(format.string(from: Date()))" + ".wav"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsDirectory.appendingPathComponent(currentFileName)
        return url
    }

    private func createAudioRecordFile() -> AVAudioFile? {
        guard let path = self.createAudioRecordPath() else {
            return nil
        }
        do {
            let file = try AVAudioFile(forWriting: path, settings: self.settings, commonFormat: .pcmFormatFloat32, interleaved: true)
            return file
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // MARK:- Handle interruption
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let key = userInfo[AVAudioSessionInterruptionTypeKey] as? NSNumber
            else { return }
        if key.intValue == 1 {
            DispatchQueue.main.async {
                if self.isRecording() {
                    self.stopRecording()
                }
            }
        }
    }
    
    //MARK: Permission access
    func permissionForAudio() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Permission allowed")
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
}

// MARK: Extensions
extension AudioKitViewController: AVAudioRecorderDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !flag {
            self.finishRecording(success: false)
        }
    }
}

extension AudioKitViewController: AVAudioPlayerDelegate {
    
}

// MARK: Table View Data Source
extension AudioKitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecordingsCell
        cell.txtTitle.delegate = self
        
//        cell.textLabel?.text = String(indexPath.row + 1)
//        if recordings.count != 0 {
//            cell.textLabel?.text = "\(recordings[indexPath.row].title)"
//        } else {
//           print("No recordings found")
//        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
}

// MARK: Table View Delegate
extension AudioKitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(indexPath.row + 1).wav")
        print(path)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch {
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            print("Add action tapped")
        }
        deleteAction.backgroundColor = .red
        

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

// MARK: Textfield Delegates
extension AudioKitViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
