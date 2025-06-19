//
//  KillProcessesConfirmationDialogView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 27.06.2024.
//

import SwiftUI
import Factory

struct KillProcessesConfirmationDialogView : View {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.processService) private var processService
    
    @State var isPresented = false
    
    var body: some View {
        EmptyView()
        .frame(width: 0, height: 0)
        .sheet(isPresented: $isPresented, content: {
            VStack(alignment: .center){
                Image(nsImage: NSImage(imageLiteralResourceName: Constants.iconApp))
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
                    .frame(minHeight: 30)
                Spacer().frame(height: 20)
                VStack(alignment: .leading) {
                    ForEach(appState.system.processesToKill, id: \.pid) { processInfo in
                        HStack {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: processInfo.url))
                            Text(processInfo.name)
                        }
                    }
                }
                HStack {
                    Button(action: primaryButtonClickHandler) {
                        Text(Constants.yes)
                            .frame(height: 25)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .background(
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.red)
                            )
                    }.buttonStyle(.plain)
                    Spacer()
                        .frame(width: 20)
                    Button(action: secondaryButtonClickHandler) {
                        Text(Constants.no)
                            .frame(width: 100, height: 25)
                    }
                }.padding()
            }
            .frame(width: 300)
            .padding()
        })
        .onAppear(perform: {
            openDialog()
        })
        .onDisappear(perform: {
            closeDialog()
        })
    }
    
    // MARK: Private function
    
    private func primaryButtonClickHandler() {
        self.processService.killActiveProcesses()
        closeDialog()
    }
    
    private func secondaryButtonClickHandler() {
        closeDialog()
    }
    
    private func openDialog() {
        appState.views.shownWindows.append(Constants.windowIdKillProcessesConfirmationDialog)
        AppHelper.setUpView(
            viewName: Constants.windowIdKillProcessesConfirmationDialog,
            onTop: true)
        isPresented = true
    }
    
    private func closeDialog() {
        appState.views.shownWindows.removeAll(where: {$0 == Constants.windowIdKillProcessesConfirmationDialog})
        isPresented = false
        
        if appState.views.shownWindows.contains(where: {$0 == Constants.windowIdMain}) {
            AppHelper.activateView(viewId: Constants.windowIdMain)
        }
    }
}

#Preview {
    KillProcessesConfirmationDialogView().environmentObject(AppState())
}
