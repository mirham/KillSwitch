//
//  KillProcessesDialogView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 27.06.2024.
//

import SwiftUI
import Factory

struct KillProcessesDialogView: View {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.processService) private var processService
    
    @State private var isDialogPresented = false
    
    var body: some View {
        EmptyView()
            .frame(width: 0, height: 0)
            .sheet(isPresented: $isDialogPresented) {
                dialogContent
            }
            .onAppear(perform: openDialog)
            .onDisappear(perform: closeDialog)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var dialogContent: some View {
        VStack(alignment: .center) {
            appIcon
            Spacer()
                .frame(height: 15)
            Text(Constants.dialogHeaderCloseApps)
                .font(.title3)
                .bold()
            Spacer()
                .frame(height: 10)
            messageText
            Spacer()
                .frame(height: 20)
            processesList
            HStack {
                yesButton
                Spacer()
                    .frame(width: 20)
                noButton
            }
            .padding()
        }
        .frame(width: 300)
        .padding()
        .safeGlassEffect()
    }
    
    @ViewBuilder
    private var appIcon: some View {
        Image(nsImage: NSImage(imageLiteralResourceName: Constants.iconApp))
            .resizable()
            .frame(width: 60, height: 60)
    }
    
    @ViewBuilder
    private var messageText: some View {
        Text(Constants.dialogBodyCloseApps)
            .multilineTextAlignment(.center)
            .font(.system(size: 10))
            .lineLimit(3...5)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    private var processesList: some View {
        VStack(alignment: .leading) {
            ForEach(appState.system.killingProcesses, id: \.pid) { processInfo in
                HStack {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: processInfo.url))
                        .frame(width: 32, height: 32)
                    Text(processInfo.name)
                }
            }
        }
    }
    
    @ViewBuilder
    private var yesButton: some View {
        Button(action: handleYesButtonClick) {
            Text(Constants.yes)
                .frame(height: 25)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color.red)
                )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var noButton: some View {
        Button(action: handleNoButtonClick) {
            Text(Constants.no)
                .frame(width: 100, height: 25)
        }
    }
    
    // MARK: Private functions
    
    private func handleYesButtonClick() {
        processService.killActiveProcesses()
        closeDialog()
    }
    
    private func handleNoButtonClick() {
        closeDialog()
    }
    
    private func openDialog() {
        appState.views.shownWindows.append(Constants.windowIdKillProcessesConfirmationDialog)
        
        AppHelper.setUpView(
            viewName: Constants.windowIdKillProcessesConfirmationDialog,
            onTop: true
        )
        
        isDialogPresented = true
    }
    
    private func closeDialog() {
        appState.views.shownWindows.removeAll { $0 == Constants.windowIdKillProcessesConfirmationDialog }
        isDialogPresented = false
        
        let mainWindowIsShown = appState.views.shownWindows.contains { $0 == Constants.windowIdMain }
        if mainWindowIsShown {
            AppHelper.activateView(viewId: Constants.windowIdMain)
        }
    }
}

#Preview {
    KillProcessesDialogView().environmentObject(AppState())
}
