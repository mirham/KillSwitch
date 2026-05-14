//
//  WindowController.swift
//  KillSwitch
//
//  Created by UglyGeorge on 14.05.2026.
//

import AppKit

class WindowController: NSWindowController {
    convenience init(
        viewName: String,
        contentView: NSView,
        size: CGSize? = nil,
        hideTitleBar: Bool = false,
        resizable: Bool = true) {
        var styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable]
        
        if resizable {
            styleMask.insert(.resizable)
        }
        
        if hideTitleBar {
            styleMask.insert(.fullSizeContentView)
        }
        
        let window = NSWindow(
            contentRect: .zero,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        
        window.identifier = NSUserInterfaceItemIdentifier(viewName)
        window.contentView = contentView
        
        if hideTitleBar {
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.isMovableByWindowBackground = true
        }
        
        if let size {
            window.setContentSize(size)
        } else {
            window.setContentSize(contentView.fittingSize)
        }
        
        window.center()
        self.init(window: window)
    }
    
    func open(onTop: Bool = false, hideButtons: Bool = false) {
        guard let window
        else { return }
        
        configure(onTop: onTop, hideButtons: hideButtons)
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        
        if onTop {
            DispatchQueue.main.async {
                window.level = .floating
                window.orderFrontRegardless()
            }
        }
    }
    
    func setTopmost(onTop: Bool) {
        guard let window
        else { return }
        
        window.level = onTop ? .floating : .normal
        window.collectionBehavior = onTop
            ? [.canJoinAllSpaces, .fullScreenAuxiliary]
            : []
        
        if onTop {
            window.orderFrontRegardless()
        }
    }
    
    private func configure(onTop: Bool, hideButtons: Bool) {
        guard let window
        else { return }
        
        window.level = onTop ? .floating : .normal
        window.collectionBehavior = onTop
        ? [.canJoinAllSpaces, .fullScreenAuxiliary]
        : []
        
        if hideButtons {
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.closeButton)?.isHidden = true
        }
    }
}
