//
//  AudioFilesView.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 21/05/24.
//

import SwiftUI

struct AudioFilesView: View {
    @StateObject var audioPlayerManager: AudioPlayer = AudioPlayer()
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("Today's records")
                Spacer()
            }
            .foregroundStyle(.mint)
            List {
                ForEach(audioPlayerManager.audioFiles, id: \.self) { filename in
                    Button {
                        Router.shared.path.append(.audioPlayer(filename: filename))
                    } label: {
                        Text(filename)
                    }
                    
                }
            }
        }
        .onAppear {
            audioPlayerManager.getFilesForToday()
        }
    }
}

#Preview {
    AudioFilesView()
}
