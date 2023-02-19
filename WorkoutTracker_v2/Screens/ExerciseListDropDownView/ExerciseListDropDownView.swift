//
//  ExerciseListView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/4/23.
//

import SwiftUI

struct ExerciseListDropDownView: View {
    
    @State var workout  : Workout
    @State var exercise : Exercise
    
    @StateObject private var viewModel = ExerciseDropDownViewModel()
    
    @EnvironmentObject var dbMgr : DbManager
    
    @Binding var repsArr : [TextBindingManager]
    @Binding var weightArr : [TextBindingManager]
    
    var body: some View {
        VStack {
            VStack (alignment: .trailing) {
                ForEach(0..<exercise.sets, id: \.self) { i in
                    HStack {
                        Spacer()
                        Text("Set \(i + 1):")
                        
                        HStack {
                            Text("Reps:")
                            TextField("Reps", text: $repsArr[i].text)
                        }
                        
                        HStack {
                            Text("Weight: ")
                            TextField("Wgt", text: $weightArr[i].text)
                                .multilineTextAlignment(.trailing)
                            Text("lbs")
                        }
                    }
                    .font(.body)
                    .allowsTightening(true)
                    .lineLimit(1)
                    .keyboardType(.numberPad)
                    .padding(.leading)
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
            
            Button {
                viewModel.save(workout: workout,
                               exercise: exercise,
                               repsArr: repsArr,
                               weightArr: weightArr)
            } label: {
                Text("Save")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(width: 260, height: 30)
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
            .buttonStyle(.bordered)
            .background(Color.buttonBackground)
        }
        .padding()
        .frame(width: .infinity, height: .infinity)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 4)
            )
        .onAppear {
          self.viewModel.setup(self.dbMgr)
        }
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static var previews: some View {
        ExerciseListDropDownView(workout: MockData.sampleWorkout1,
                                 exercise: MockData.sampleExercises[0],
                                 repsArr: .constant(MockData.sampleRepsWeightArr),
                                 weightArr: .constant(MockData.sampleRepsWeightArr))
            .environmentObject(dbMgr)
    }
}
