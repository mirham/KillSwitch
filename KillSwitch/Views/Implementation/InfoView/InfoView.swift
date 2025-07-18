//
//  InfoView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 30.07.2024.
//

import SwiftUI

struct InfoView: View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) var controlActiveState
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                let version = Bundle.main.object(forInfoDictionaryKey: Constants.aboutVersionKey) as? String
                let data = Data(base64Encoded: Constants.aboutSupportMail)
                let mail = String(data: data!, encoding: .utf8) ?? String()
                
                Text(String(format: Constants.aboutVersion, version!))
                    .font(.system(size: 18))
                    .padding(.bottom, 10)
                HStack {
                    Text(Constants.aboutGetSupport)
                    Link(mail, destination: URL(string: String(format: Constants.aboutMailTo, mail))!)
                        .buttonStyle(.plain)
                }
                Link(Constants.aboutGitHub, destination: URL(string: Constants.aboutGitHubLink)!)
            }
            .padding(.top, 70)
            .padding(.leading, 120)
        }
        .background() {
            Image(nsImage: NSImage(named: Constants.aboutBackground) ?? NSImage())
                .resizable()
                .frame(minWidth: 360, maxWidth: 360, minHeight: 220, maxHeight: 220)
        }
        .onAppear(perform: {
            openDialog()
        })
        .onDisappear(perform: {
            closeDialog()
        })
        .opacity(getViewOpacity(state: controlActiveState))
    }
    
    // MARK: Private functions
    
    private func openDialog() {
        appState.views.shownWindows.append(Constants.windowIdInfo)
        AppHelper.setUpView(
            viewName: Constants.windowIdInfo,
            onTop: appState.userData.onTopOfAllWindows)
    }
    
    private func closeDialog() {
        appState.views.shownWindows.removeAll(where: {$0 == Constants.windowIdInfo})
    }
}

#Preview {
    InfoView().environmentObject(AppState())
}
