//
//  NoInsetHostingView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 15.08.2024.
//

import SwiftUI

class NoInsetHostingView<V>: NSHostingView<V> where V: View {
    override var safeAreaInsets: NSEdgeInsets {
        return .init()
    }
}
