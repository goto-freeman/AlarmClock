import Foundation
import PlaygroundSupport
import AudioToolbox


PlaygroundPage.current.needsIndefiniteExecution = true


class Alarm {
    var timer: Timer?
    var settingTime: String
    let snoozeOnOff: Bool
    var snoozeTimes: Int
    let snoozeInterval: Int
    
    init(settingTime: String, snoozeOnOff: Bool,snoozeTimes: Int, snoozeInterval: Int) {
        self.settingTime = settingTime
        self.snoozeOnOff = snoozeOnOff
        self.snoozeTimes = snoozeOnOff ? snoozeTimes : 0
        self.snoozeInterval = snoozeInterval
    }
    
    // アラーム設定時刻の文字列が「h:mm:ss」型になっているか検証
    func isMatch(_ timeText: String) -> Bool {
        let pattern = "(^[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let result = regex.matches(in: timeText, range: NSRange(0..<timeText.count))
        return result.count > 0
    }
    
    // 表示する時刻のフォーマット
    var dateFormatter: DateFormatter {
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .none
        dateFormat.timeStyle = .medium
        dateFormat.timeZone = .current
        dateFormat.locale = Locale(identifier: "ja_JP")
        return dateFormat
    }
    
    // アラームスタートメソッド
    func start() {
        // アラーム設定時刻の型を検証
        guard isMatch(settingTime) else {
            print("アラームの時刻が正しく設定されていません。「h:mm:ss」形式で設定してください。")
            return
        }
        
        // アラーム開始
        print("\(settingTime) にアラームをセットしました。\n")
        
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(wakeUp),
            userInfo: nil,
            repeats: true
        )
    }
    
    // タイマークラスのインターバルごとに実行するメソッド
    @objc func wakeUp() {
        // 現在時刻を表示
        let now = dateFormatter.string(from: Date())
        print(now)
        
        // アラーム設定時刻になった際の処理
        if now == settingTime {
            print("\n\(now) になりました！")
            let soundIdRing: SystemSoundID = 1000
            AudioServicesPlaySystemSound(soundIdRing)
            
            snooze()
        }
    }
    
    // 残りスヌーズ回数に応じた処理
    func snooze() {
        if snoozeTimes > 0 {
            let newSettingTime = Calendar.current.date(byAdding: .second, value: snoozeInterval, to: Date())!
            settingTime = dateFormatter.string(from: newSettingTime)
            snoozeTimes -= 1
            print("（snooze）\n")
        } else {
            timer?.invalidate()
        }
    }
}

// 各種設定
let settingTime: String = "4:06:00" // アラームの設定時刻を h:mm:ss で指定
let snoozeOnOff: Bool = true       // スヌーズ ON:true, OFF:false
let snoozeTimes: Int = 2            // スヌーズの回数を指定
let snoozeInterval: Int = 5         // スヌーズのインターバルを秒で指定

// Alarmクラスをインスタンス化しstartメソッドを実行
let alarm = Alarm(settingTime: settingTime, snoozeOnOff: snoozeOnOff, snoozeTimes: snoozeTimes, snoozeInterval: snoozeInterval)
alarm.start()

