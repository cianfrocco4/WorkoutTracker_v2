//
//  EditWorkoutView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/23/23.
//

import SwiftUI

struct EditWorkoutView: View {
    @Binding var workout : Workout
    @Binding var isShowingEditWorkout : Bool
    
    @State var workouts : [Workout]
    
    @StateObject private var viewModel = EditWorkoutViewModel()
    
    @EnvironmentObject var dbMgr : DbManager
    
    var body: some View {
        VStack {
            HStack {
                Text("Workout Name: ")
                TextField("WorkoutName", text: $workout.name)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: workout.name) {
                        // Only save the workout if it is a unique name
                        print("Workout name changed to: " + String($0))
//                            workout.name = $0
                        viewModel.saveWorkout(workout: workout)
                    }
            }
            .padding(.leading)
            
            HStack {
                Button {
                    isShowingEditWorkout = false
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
        .background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color(uiColor: UIColor.systemBackground)))
        .onAppear() {
            self.viewModel.setup(self.dbMgr, workoutName: workout.name)
        }
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")

    static var previews: some View {
        EditWorkoutView(workout: .constant(MockData.sampleWorkout1),
                        isShowingEditWorkout: .constant(true),
                        workouts: [MockData.sampleWorkout1])
        .environmentObject(dbMgr)
    }
}
