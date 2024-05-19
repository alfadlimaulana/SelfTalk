//
//  Router.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 17/05/24.
//

import Foundation
import SwiftUI

class Router: ObservableObject {
    @Published var path = [Pages]()
    
    static var shared = Router()
}

enum Pages {
    case selfTalk
}

