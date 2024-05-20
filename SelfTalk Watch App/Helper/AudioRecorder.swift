//
//  AudioRecorder.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 19/05/24.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder!
    private var filePath: URL?
    
    func requestMicrophoneAccess(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func startRecording() {
        requestMicrophoneAccess { granted in
            guard granted else {
                print("Microphone access denied")
                return
            }
            let audioSession = AVAudioSession.sharedInstance()
            let timestamp = Date().timeIntervalSince1970
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default)
                try audioSession.setActive(true)
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let audioFilePath = documentsPath.appendingPathComponent("\(timestamp)-mindfulSession.m4a")
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
                ] as [String : Any]
                print("start recording")
                self.filePath = audioFilePath
                self.audioRecorder = try AVAudioRecorder(url: audioFilePath, settings: settings)
                self.audioRecorder.delegate = self
                self.audioRecorder?.prepareToRecord()
                self.audioRecorder.record()
            } catch {
                print("Error recording audio: \(error.localizedDescription)")
            }
        }
    }

    func stopRecording() {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            print("recording stopped. saved to \(String(describing: filePath))")
        } catch {
            print("Error stopping audio recording: \(error.localizedDescription)")
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Audio recording finished successfully.")
        } else {
            print("Audio recording failed.")
        }
    }
}
