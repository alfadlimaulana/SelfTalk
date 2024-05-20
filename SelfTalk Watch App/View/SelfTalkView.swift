//
//  SelfTalkView.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 17/05/24.
//

import SwiftUI

struct SelfTalkView: View {
    @State var lottieFile: String = "soundwave"
    @State var timerManager: TimerManager = TimerManager()
    
    @StateObject var audioManager: AudioRecorder = AudioRecorder()
    @ObservedObject var viewModel: LottieViewModel = .init()
    @EnvironmentObject var healthManager: HealthViewModel
    
    var body: some View {
        ZStack {
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFit()
                .onAppear {
                    self.viewModel.loadAnimationFromFile(filename: lottieFile)
                }
            Text("\(timerManager.durationCounter.elapsedTime)").bold()
        }
        .onAppear {
            timerManager.startTimer()
            audioManager.startRecording()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Stop", systemImage: "multiply", action: {
                    Router.shared.path.removeAll()
                })
                .tint(.gray.opacity(0.24))
                .labelStyle(.iconOnly)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Continue", systemImage: "checkmark", action: {
                    timerManager.stopTimer()
//                    audioManager.stopRecording()
                    let mindfulMinutesInSeconds = (timerManager.durationCounter.minutes * 60)
                    healthManager.saveMindfulMinutes(timerManager.durationCounter.seconds < 30 ? mindfulMinutesInSeconds : mindfulMinutesInSeconds + 60)
                    Router.shared.path.removeAll()
                })
                .foregroundColor(.white)
                .tint(.gray.opacity(0.24))
                .labelStyle(.iconOnly)
            }
        }
        .navigationBarBackButtonHidden()
        
    }
}

//#Preview {
//    NavigationStack {
//        SelfTalkView()
//    }
//}
