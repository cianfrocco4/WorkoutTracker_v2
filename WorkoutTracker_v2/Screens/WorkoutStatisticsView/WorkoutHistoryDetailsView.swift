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
            Button {
                print("Deleting workout history")
            } label: {
                Text("Delete")
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
            .background(Color(UIColor.tertiarySystemBackground))
        }
        .buttonStyle(.bordered)
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
