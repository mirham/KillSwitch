//
//  EnableNetworkDialogView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 25.07.2024.
//

import SwiftUI

struct EnableNetworkDialogView : View {
    @EnvironmentObject var appState: AppState
    
    let networkService = NetworkService.shared
    
    @State var isPresented = false
    
    @State private var interfaceToEnable: String? = nil
    
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
                Text(Constants.dialogHeaderEnableNetwork)
                    .font(.title3)
                    .bold()
                Spacer().frame(height: 10)
                Text(Constants.dialogBodyEnableNetwork)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 10))
                Spacer().frame(height: 20)
                VStack(alignment: .leading) {
                    ForEach(appState.network.physicalNetworkInterfaces, id: \.id) { networkInterface in
                        HStack {
                            RadioButton(
                                id: networkInterface.name,
                                label: networkInterface.localizedName ?? networkInterface.name,
                                size: 12,
                                color: Color.primary,
                                textSize: 11,
                                isMarked: interfaceToEnable == networkInterface.name,
                                callback: { _ in interfaceToEnable = networkInterface.name }
                            )
                        }
                    }
                }
                HStack {
                    Button(action: primaryButtonClickHandler) {
                        Text(Constants.enable)
                            .frame(height: 25)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .background(
                                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(
                                    interfaceToEnable == nil ? Color.gray : Color.green)
                            )
                    }.buttonStyle(.plain)
                    Spacer()
                        .frame(width: 20)
                    Button(action: secondaryButtonClickHandler) {
                        Text(Constants.cancel)
                            .frame(width: 100, height: 25)
                    }
                }.padding()
            }
            .frame(width: 300)
            .padding()
        })
        .onAppear(perform: {
            interfaceToEnable = appState.current.mainNetworkInterface
            AppHelper.setUpView(
                viewName: Constants.windowIdEnableNetworkDialog,
                onTop: true)
            isPresented = true
        })
        .onDisappear(perform: {
            closeDialog()
        })
    }
    
    // MARK: Private function
    
    private func primaryButtonClickHandler() {
        if (interfaceToEnable != nil) {
            networkService.enableNetworkInterface(interfaceName: interfaceToEnable!)
            closeDialog()
        }
    }
    
    private func secondaryButtonClickHandler() {
        closeDialog()
    }
    
    private func closeDialog() {
        appState.views.isEnableNetworkDialogShown = false
        isPresented = false
    }
}

#Preview {
    EnableNetworkDialogView().environmentObject(AppState())
}
