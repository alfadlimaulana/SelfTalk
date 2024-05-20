//
//  AudioPlayer.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 20/05/24.
//

import Foundation
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
        
    @Published var audioFiles = [String]()
    @Published var isPlaying: Bool = false
    
    func startPlayback(recordingFileName: String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilePath = documentsPath.appendingPathComponent(recordingFileName)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: audioFilePath.path) {
            let fileSize = try? fileManager.attributesOfItem(atPath: audioFilePath.path)[.size] as? Int
            print("File size: \(fileSize ?? 0) bytes")
        } else {
            print("File does not exist at \(audioFilePath.path)")
        }
        
        do {
            print("Attempting to play audio from: \(audioFilePath)")
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilePath)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            if audioPlayer?.play() == true {
                isPlaying = true
                print("Audio is playing")
                print("Duration: \(audioPlayer?.duration ?? 0) seconds")
                print("Current Time: \(audioPlayer?.currentTime ?? 0) seconds")
            } else {
                print("Audio failed to play")
            }
            isPlaying = true
            print("Audio is playing")
        } catch {
            print("Error starting audio playback: \(error.localizedDescription)")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            print("stopped")
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio telah selesai")
        isPlaying = false
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    func deleteOldRecordings() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles)
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            for fileURL in fileURLs {
                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                if let modificationDate = attributes[.modificationDate] as? Date, modificationDate < oneWeekAgo {
                    try fileManager.removeItem(at: fileURL)
                    print("Old recording \(fileURL.lastPathComponent) deleted.")
                }
            }
        } catch {
            print("Error deleting old recordings: \(error.localizedDescription)")
        }
    }
    
    func getFilesForToday() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileManager = FileManager.default
        let today = Date()

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            let filesForToday = fileURLs
            DispatchQueue.main.async {
                self.audioFiles = filesForToday.map { $0.lastPathComponent }
            }
        } catch {
            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
        }
    }
}
