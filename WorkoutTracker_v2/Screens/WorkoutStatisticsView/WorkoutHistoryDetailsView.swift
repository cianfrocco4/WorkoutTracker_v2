//
//  WorkoutHistoryDetailsView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/30/23.
//

import SwiftUI

struct WorkoutHistoryDetailsView: View {
    @State var wkoutHistory : Workout
    
    @Binding var isShowingWorkoutHistoryDetails : Bool
    
    var body: some View {
        VStack {
            Text("\(wkoutHistory.name)")
                .font(.title3)
            Button {
                print("Deleting workout history")
            } label: {
                Text("Delete")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(width: 130, height: 30)
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
            
            Button {
                isShowingWorkoutHistoryDetails = false
            } label: {
                Text("Ok")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(width: 130, height: 30)
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
        }
        .buttonStyle(.bordered)
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill( Color(UIColor.tertiarySystemBackground)))
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 4)
            )
    }
}

struct WorkoutHistoryDetailsView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static var previews: some View {
        WorkoutHistoryDetailsView(wkoutHistory: MockData.sampleWorkout1,
                                  isShowingWorkoutHistoryDetails: .constant(true))
            .environmentObject(dbMgr)
    }
}
