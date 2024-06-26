//
//  MonitoringStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI

struct ProcessesStatusView : View {
    @EnvironmentObject var processesService : ProcessesService
    
    @State private var showOverText = false
    
    var body: some View {
        Section() {
            VStack{
                Text("Applications".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Section {
                    Text(processesService.activeProcessesToClose.count.description)
                        .frame(width: 60, height: 60)
                        .background(.yellow)
                        .foregroundColor(.black.opacity(0.5))
                        .font(.system(size: 18))
                        .bold()
                        .clipShape(Circle())
                        .onTapGesture(perform: {
                            processesService.killActiveProcesses()
                            showOverText = false
                        })
                        .pointerOnHover()
                }
                .onHover(perform: { hovering in
                    showOverText = hovering
                })
                .popover(isPresented: $showOverText, content: {
                    VStack {
                        Text("Click to close:")
                        ForEach(processesService.activeProcessesToClose, id: \.pid) { processInfo in
                            HStack {
                                Image(nsImage: NSWorkspace.shared.icon(forFile: processInfo.url))
                                Text(processInfo.name)
                            }
                        }
                    }
                    .padding()
                    .interactiveDismissDisabled()
                })
            }
        }
        .isHidden(hidden:processesService.activeProcessesToClose.isEmpty, remove: true)
    }
}

#Preview {
    MonitoringStatusView()
}
