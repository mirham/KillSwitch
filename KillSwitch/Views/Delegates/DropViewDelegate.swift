//
//  DropViewDelegate.swift
//  KillSwitch
//
//  Created by UglyGeorge on 28.07.2024.
//

import SwiftUI

struct DropViewDelegate: DropDelegate {
    @Binding var draggedItem: MenuBarElement?
    @Binding var sourceItems: [MenuBarElement]
    @Binding var destinationItems: [MenuBarElement]
    
    let item: MenuBarElement
    let keepLastItem: Bool
    
    private let start = 0
    private let step = 1
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }
        
        let from = sourceItems.firstIndex(of: draggedItem) != nil ? sourceItems.firstIndex(of: draggedItem) : nil
        let to = sourceItems.firstIndex(of: item) != nil ? sourceItems.firstIndex(of: item)! : start
        
        withAnimation(.default) {
            if (from == to && destinationItems.isEmpty) {
                destinationItems.append(draggedItem)
                sourceItems.removeAll(where: {$0.id == draggedItem.id})
            }
            
            if(from != nil) {
                sourceItems.move(
                    fromOffsets: IndexSet(integer: from!),
                    toOffset: to > from! ? to == start ? to : to + step : to)
            }
            else {
                if (keepLastItem) {
                    if (destinationItems.count == 1) {
                        return
                    }
                    else {
                        sourceItems.insert(draggedItem, at: to == start ? to : to + step)
                        destinationItems.removeAll(where: {$0.id == draggedItem.id})
                    }
                }
                else {
                    sourceItems.insert(draggedItem, at: to == start ? to : to + step)
                    destinationItems.removeAll(where: {$0.id == draggedItem.id})
                }
            }
        }
    }
}
