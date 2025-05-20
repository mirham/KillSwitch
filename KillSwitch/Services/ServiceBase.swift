//
//  ServiceBase.swift
//  KillSwitch
//
//  Created by UglyGeorge on 26.06.2024.
//

import Foundation
import Factory

class ServiceBase {
    let appState = AppState.shared
    
    @LazyInjected(\.loggingService) var loggingService
}
