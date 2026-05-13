//
//  PermissionsView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 11.05.2026.
//

import SwiftUI
import CoreWLAN
import CoreLocation
import Factory

struct PermissionsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.controlActiveState) private var controlActiveState
    
    @Injected(\.locationService) private var locationService
    
    private let locationManager = CLLocationManager()
    
    private var areLocationServicesEnabled: Bool {
        get { return locationService.areLocationServicesEnabled() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            infoHeader
            locationPermissionRow
            Spacer()
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var infoHeader: some View {
        HStack {
            Image(systemName: Constants.iconInfoFill)
                .asInfoIcon()
            Text(Constants.hintPermissions)
                .padding(.top)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private var locationPermissionRow: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.blue.opacity(0.12))
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: Constants.iconLocation)
                    .foregroundStyle(.blue))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(Constants.settingsElementLocationAccess)
                    .font(.system(size: 14, weight: .medium))
                Text(Constants.hintNetworkDetails)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            switch locationManager.authorizationStatus {
                case .notDetermined:
                    Text(Constants.notDetermined)
                    Button(Constants.allow) {
                        locationManager.requestWhenInUseAuthorization()
                    }
                case .authorized, .authorizedAlways:
                    Label(Constants.granted, systemImage: Constants.iconGranted)
                        .foregroundStyle(.green)
                case .denied, .restricted:
                    Label(areLocationServicesEnabled
                            ? Constants.denied
                            : Constants.restricted,
                          systemImage: Constants.iconDenied)
                        .foregroundStyle(areLocationServicesEnabled
                            ? .red
                            : .orange)
                    Button(Constants.settingsElementOpenSettings) {
                        NSWorkspace.shared.open(
                            URL(string: Constants.sspLocationServices)!)
                    }
                @unknown default:
                    EmptyView()
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func helpIcon(for hint: String) -> some View {
        Image(systemName: Constants.iconQuestionMark)
            .asHelpIcon()
    }
}

private extension Image {
    func asHelpIcon() -> some View {
        self.resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(.blue)
            .padding(.top)
            .padding(.trailing)
    }
}

#Preview {
    LeaksEditView().environmentObject(AppState())
}
