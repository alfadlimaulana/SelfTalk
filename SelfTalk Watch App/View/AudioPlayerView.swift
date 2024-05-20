//
//  AudioPlayerView.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 20/05/24.
//

import SwiftUI

struct AudioPlayerView: View {
    @State var lottieFile: String = "soundwave"
    
    var audioFileName: String
    
    @ObservedObject var viewModel: LottieViewModel = .init()
    @EnvironmentObject var audioPlayerManager: AudioPlayer
    
    var body: some View {
        ZStack {
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFit()
                .onAppear {
                    self.viewModel.loadAnimationFromFile(filename: lottieFile)
                }
            Button(action: {
                audioPlayerManager.stopPlayback()
                Router.shared.path.popLast()
            }, label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 24))
            })
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
        }
        .onAppear {
            audioPlayerManager.startPlayback(recordingFileName: audioFileName)
        }
        .onDisappear {
            audioPlayerManager.stopPlayback()
        }
    }
}

//#Preview {
//    AudioPlayerView()
//}
