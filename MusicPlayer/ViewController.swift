//
//  ViewController.swift
//  MusicPlayer
//
//  Created by bready on 2023/07/02.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    // MARK: Properties
    var player: AVAudioPlayer!
    var timer: Timer!
    
    // MARK: IBOutlets
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var progressSlider: UISlider!
    
    
    // MARK: - Methods
    // MARK: Custom Methods
    func initializePlayer() {
        // 음원을 가져오는 NSDataAsset클래스 객체를 생성해 "sound" 애셋을 가져옴
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else {
            print("cannot retrieve music assets")
            return
        }
        
        // 음원 데이터를 가지는 AVAudioPlayer 객체를 player에 할당
        do {
            try self.player = AVAudioPlayer(data: soundAsset.data)
            self.player.delegate = self // self(화면)이 player 객체의 이벤트에 대해 처리하도록 위임(delegate)
        } catch let error as NSError {
            print("player initialization failed!")
            print("errorCode : \(error.code), errorMessage: \(error.localizedDescription)")
        }
        
        // 슬라이더에 max, min, 현재 값 할당
        self.progressSlider.maximumValue = Float(self.player.duration)
        self.progressSlider.minimumValue = 0
        self.progressSlider.value = Float(self.player.currentTime)
    }
    
    func updateTimeLabel(time: TimeInterval) {
        let min: Int = Int(time / 60)
        let sec: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisec: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        // 형식 지정자를 이용해 주어진 시간들을 형식에 맞게 text로 변경
        let labelTxt: String = String(format: "%02d:%02d:%02d", min, sec, milisec)
        self.timeLabel.text = labelTxt
    }
    
    func makeAndFireTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: {
            [unowned self](timer: Timer) in
            
            if self.progressSlider.isTracking { return }
            
            self.updateTimeLabel(time: self.player.currentTime)
            self.progressSlider.value = Float(self.player.currentTime)
        })
        self.timer.fire()
    }
    
    func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializePlayer()
    }



    // MARK: IBActions
    @IBAction func touchUpPlayPauseButton(_ sender: UIButton) {
        // 터치할 때마다 반대로 설정
        sender.isSelected = !sender.isSelected
        
        // 버튼이 눌리면 플레이, 아니면 멈춤
        if sender.isSelected == true {
            self.player?.play()
            self.makeAndFireTimer()
        } else {
            self.player?.pause()
            self.invalidateTimer()
        }
    }
    
    
    @IBAction func valueChangeProgressSlider(_ sender: UISlider) {
        self.updateTimeLabel(time: TimeInterval(sender.value)) // 타임 래이블을 업데이트
        if sender.isTracking { return } // 유저가 slider를 컨트롤할 때 함수 종료
        self.player?.currentTime = TimeInterval(sender.value) // 플레이어 재생 시간을 슬라이더의 시간으로 세팅
    }
    
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("fin")
        self.playPauseButton.isSelected = false
        self.progressSlider.value = 0
        self.updateTimeLabel(time: 0)
        self.invalidateTimer()
    }
}


