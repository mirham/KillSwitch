//
//  AddressApisEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import SwiftUI

struct MenuBarStatusEditView: View {
    @State var list = [
        DragableImage(image: NSImage(systemSymbolName: "figure.badminton", accessibilityDescription: nil)!, label: "One"),
        DragableImage(image: NSImage(systemSymbolName: "figure.cricket", accessibilityDescription: nil)!,
                      label: "Two"),
        DragableImage(image: NSImage(systemSymbolName: "figure.fencing", accessibilityDescription: nil)!,
                      label: "Three")
    ]
    
    @State var list2: [DragableImage] = [
    ]
    
    var body: some View {
        VStack {
            Text("Active items")
                .font(.title3)
                .padding(.top)
            
            HStack {
                ForEach(list, id: \.id) { item in
                    item
                }
            }
            .background(Rectangle().fill(.gray).border(.green))
            .frame(minWidth: 200, minHeight: 30)

            Text("Inactive items")
                .font(.title3)
                .padding(.top)
            
            Spacer().frame(height: 10)
            
            HStack {
                HStack {
                    ForEach(list2, id: \.id) { item in
                        item
                    }
                }.background(.gray)
                Rectangle()
                    .frame(width: 150, height: 150)
            }.background(Rectangle().fill(Color.gray))
                .frame(width: 300, height: 300)
                .dropDestination(for: Data.self) { items, location in
                    if(items.first != nil)
                    {
                        let im = DragableImage(image: NSImage(data: items.first!)!, label: "One")
                        list2.append(im)
                        //
                    }
                    return true
                }
        }
    }
}

#Preview {
    MenuBarStatusEditView()
}
