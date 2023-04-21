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
    
    var body: some View {
        NavigationView {
            VStack {
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
        SettingsView()
            .environmentObject(dbMgr)
    }
}
