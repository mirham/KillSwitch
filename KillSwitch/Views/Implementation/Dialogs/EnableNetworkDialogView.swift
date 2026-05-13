//
//  EnableNetworkDialogView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 25.07.2024.
//

import SwiftUI
import Factory

struct EnableNetworkDialogView: View {
    @EnvironmentObject var appState: AppState
    @Injected(\.networkService) private var networkService
    
    @State private var isDialogPresented = false
    @State private var selectedInterfaceName: String?
    
    private var enableButtonColor: Color {
        selectedInterfaceName == nil ? .gray : .green
    }
    
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
            Text(Constants.dialogHeaderEnableNetwork)
                .font(.title3)
                .bold()
            Spacer()
                .frame(height: 10)
            messageText
            Spacer()
                .frame(height: 20)
            networkInterfacesList
            HStack {
                enableButton
                Spacer()
                    .frame(width: 20)
                cancelButton
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
        Text(Constants.dialogBodyEnableNetwork)
            .multilineTextAlignment(.center)
            .font(.system(size: 10))
            .lineLimit(3...5)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    private var networkInterfacesList: some View {
        VStack(alignment: .leading) {
            ForEach(appState.network.physicalNetworkInterfaces, id: \.name) { networkInterface in
                RadioButton(
                    id: networkInterface.name,
                    label: networkInterface.localizedName ?? networkInterface.name,
                    size: 12,
                    color: .primary,
                    textSize: 11,
                    isMarked: selectedInterfaceName == networkInterface.name,
                    callback: { _ in selectedInterfaceName = networkInterface.name }
                )
            }
        }
    }
    
    @ViewBuilder
    private var enableButton: some View {
        Button {
            Task { await enableNetworkAsync() }
        } label: {
            Text(Constants.enable)
                .frame(height: 25)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(enableButtonColor)
                )
        }
        .buttonStyle(.plain)
        .disabled(selectedInterfaceName == nil)
    }
    
    @ViewBuilder
    private var cancelButton: some View {
        Button(action: cancel) {
            Text(Constants.cancel)
                .frame(width: 100, height: 25)
        }
    }
    
    // MARK: Private functions
    
    private func enableNetworkAsync() async {
        guard let interfaceName = selectedInterfaceName
        else { return }
        
        await networkService.enableNetworkInterfaceAsync(
            interfaceName: interfaceName)
        closeDialog()
    }
    
    private func cancel() {
        closeDialog()
    }
    
    private func openDialog() {
        appState.views.shownWindows.append(Constants.windowIdEnableNetworkDialog)
        selectedInterfaceName = appState.current.mainNetworkInterface
        
        AppHelper.setUpView(
            viewName: Constants.windowIdEnableNetworkDialog,
            onTop: true,
            hideButtons: true
        )
        
        isDialogPresented = true
    }
    
    private func closeDialog() {
        appState.views.shownWindows.removeAll {
            $0 == Constants.windowIdEnableNetworkDialog
        }
        
        isDialogPresented = false
        
        AppHelper.activateView(viewId: Constants.windowIdMain)
    }
}

#Preview {
    EnableNetworkDialogView().environmentObject(AppState())
}
