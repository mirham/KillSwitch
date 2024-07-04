//
//  ConfirmationDialogView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 27.06.2024.
//

import SwiftUI

struct KillProcessesConfirmationDialogView : View {
    @EnvironmentObject var appState: AppState
    
    let processesService = ProcessesService.shared
    
    @State var isPresented = false
    
    var body: some View {
        EmptyView()
        .frame(width: 0, height: 0)
        .sheet(isPresented: $isPresented, content: {
            VStack(alignment: .center){
                Image(nsImage: NSImage(imageLiteralResourceName: "AppIcon"))
                    .resizable()
                    .frame(width: 60, height: 60)
                Spacer()
                    .frame(height: 15)
                Text(Constants.dialogHeaderCloseApps)
                    .font(.title3)
                    .bold()
                Spacer().frame(height: 10)
                Text(Constants.dialogBodyCloseApps)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 10))
                Spacer().frame(height: 20)
                VStack(alignment: .leading) {
                    ForEach(appState.system.processesToClose, id: \.pid) { processInfo in
                        HStack {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: processInfo.url))
                            Text(processInfo.name)
                        }
                    }
                }
                HStack {
                    Button(action: primaryButtonClickEventHandler) {
                        Text(Constants.dialogButtonYes)
                            .frame(width: 100, height: 25)
                            .background(.red, in: RoundedRectangle(cornerRadius: 5))
                    }
                    Spacer()
                        .frame(width: 20)
                    Button(action: secondaryButtonClickEventHandler) {
                        Text(Constants.dialogButtonNo)
                            .frame(width: 100, height: 25)
                    }
                }.padding()
            }
            .frame(width: 300)
            .padding()
        })
        .onAppear(perform: {
            AppHelper.setViewToTop(viewName: Constants.windowIdKillProcessesConfirmationDialog)
            isPresented = true
        })
        .onDisappear(perform: {
            disappearDialod()
        })
    }
    
    // MARK: Private function
    
    private func primaryButtonClickEventHandler() {
        processesService.killActiveProcesses()
        disappearDialod()
    }
    
    private func secondaryButtonClickEventHandler() {
        disappearDialod()
    }
    
    private func disappearDialod() {
        appState.views.isKillProcessesConfirmationDialogShowed = false
        isPresented = false
    }
}
