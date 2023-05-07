//
//  SettingsView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/25/23.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
            
    @EnvironmentObject var dbMgr : DbManager
    
    @Binding var useSystemBackgroundColor : Bool
    
    @Binding var colorSelection : ColorScheme
    
    // Key for system background color in NSUserDefaults
    static let useSystemBackgroundKey = "useSystemBackground"
    
    // Key for app background color in NSUserDefaults
    static let useDarkMode = "useDarkMode"
    
    var body: some View {
        NavigationView {
            VStack {
                
                Toggle(isOn: $useSystemBackgroundColor, label: {
                    Text("Use System Background Color")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                })
                .onChange(of: useSystemBackgroundColor) { val in
                    viewModel.updateUseSystemBackgroundSetting(val: val)
                    
                    let defaults = UserDefaults.standard
                    defaults.set(val, forKey: SettingsView.useSystemBackgroundKey)
                    
                }
                .padding([.leading, .trailing])
                
                Picker (selection: $colorSelection, label: Text("Color")) {
                    Text("Light").tag(ColorScheme.light)
                    Text("Dark").tag(ColorScheme.dark)
                }
                .onChange(of: colorSelection) { val in
                    viewModel.updateBackgroundColorSetting(val: val)
                    
                    let defaults = UserDefaults.standard
                    defaults.set(val == .dark, forKey: SettingsView.useDarkMode)
                }
                .pickerStyle(.segmented)
                .disabled(useSystemBackgroundColor)
                .blur(radius: useSystemBackgroundColor ? 0.5 : 0)

                HStack {
                    Button {
                        print("Export database clicked")
                        viewModel.exportDb()
                    } label: {
                        Text("Export Database")
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(width: 150, height: 30)
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.bordered)
                    .padding()
                    
                    Text(viewModel.exportLoc ?? "")
                        .disabled(viewModel.exportLoc == nil)
                    
                    Spacer()
                }
                
                HStack {
                    Text("Install New Database")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(width: 200, height: 30)
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                        .onLongPressGesture() {
                            print("Install new database clicked")
                            viewModel.installDb()
                        }
                    Spacer()
                }
                
                HStack {
                    Button {
                        print("Update database clicked")
                        viewModel.updateDb()
                    } label: {
                        Text("Update Database")
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(width: 150, height: 30)
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.bordered)
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
            }
            .navigationTitle("Settings ⚙️")
        }
        .onAppear() {
            viewModel.setup(dbMgr)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")

    static var previews: some View {
        SettingsView(useSystemBackgroundColor: .constant(true),
                     colorSelection: .constant(.dark))
            .environmentObject(dbMgr)
    }
}
