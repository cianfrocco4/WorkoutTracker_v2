//
//  ExerciseDropDownTableView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/4/23.
//

import SwiftUI
import Combine

struct ExerciseDropDownTableView: View {
    
    @State var exercise : Exercise
    @State var restTime : UInt
        
    @StateObject private var viewModel = ExerciseDropDownViewModel()
    
    @EnvironmentObject private var selectedWkout : Workout
    
    @Binding var repsArr : [TextBindingManager]
    @Binding var weightArr : [TextBindingManager]
    @Binding var entries : [ExerciseEntry]
    @Binding var notes : String
    @Binding var restTimeRunning : Bool
    @Binding var restTimeRemaining : UInt
    var isRestTimerOn : Bool
    
    let formatter: NumberFormatter = {
         let formatter = NumberFormatter()
         formatter.numberStyle = .decimal
         formatter.maximumIntegerDigits = 3
         formatter.maximumFractionDigits = 1
         return formatter
     }()
    
    var body: some View {
        VStack {
            VStack {
                TextField("Notes", text: $notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    // set
                    VStack {
                        Text("Set")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach($entries, id: \.self) { $entry in
                            Text(entry.setString)
                        }
                        .frame(height: 34)
                    }
                    
                    // Prev Wgt
                    VStack {
                        Text("Prev")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach($entries, id: \.self) { $entry in
                            Text((entry.prevWgtLbs != nil) ? entry.prevWgtLbsString : "-")
                        }
                        .frame(height: 34)
                    }
                    
                    // Wgt (lbs)
                    VStack {
                        Text("lbs")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach(entries.indices, id: \.self) { index in
                            TextField("Wgt",
                                      value: Binding(
                                        // Default to 0 if the value is nil
                                        get: { entries[index].wgtLbs ?? 0},
                                        // Only set the value if the formatter does not return nil
                                        set: { entries[index].wgtLbs = $0 == nil ? entries[index].wgtLbs : $0 }),
                                      formatter: formatter)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 50)
                                .padding(3)
                                .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.tertiarySystemBackground)))
                                .keyboardType(.decimalPad)
                        }
                        .frame(height: 34)
                    }
                    
                    // Reps
                    VStack {
                        Text("Reps")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach(entries.indices, id: \.self) { index in
                            TextField("Reps", value: $entries[index].reps, format: .number)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 40)
                                .padding(3)
                                .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.tertiarySystemBackground)))
                                .keyboardType(.numberPad)
                        }
                        .frame(minHeight: 34)
                    }
                    
                    // Save
                    VStack {
                        Text("Save")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach(entries.indices, id: \.self) { index in
                            Button {
                                if entries[index].saved {
                                    viewModel.unsave(workout: selectedWkout,
                                                     exercise: exercise,
                                                     set: entries[index].set)
                                }
                                else {
                                    viewModel.save(workout: selectedWkout,
                                                   exercise: exercise,
                                                   set: entries[index].set,
                                                   entries: entries,
                                                   notes: notes)
                                    
                                    if isRestTimerOn {
                                        restTimeRunning = true  // start the rest time timer
                                        restTimeRemaining = selectedWkout.restTimeSec
                                        let _ = DbManager.shared.insertCurrentRestTimerStartTime(restTimeOffset: selectedWkout.restTimeSec)
                                        
                                        let center = UNUserNotificationCenter.current()
                                        
                                        let addRequest = {
                                            let content = UNMutableNotificationContent()
                                            content.title = "Rest time is complete!"
                                            content.subtitle = ""
                                            content.sound = UNNotificationSound.default
                                            
                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(selectedWkout.restTimeSec), repeats: false)
                                            
                                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                            
                                            center.add(request)
                                        }
                                        
                                        center.getNotificationSettings { settings in
                                            if settings.authorizationStatus == .authorized {
                                                addRequest()
                                            } else {
                                                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                                    if success {
                                                        addRequest()
                                                    } else {
                                                        print("Rest timer notficiations request denied")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                entries[index].saved = !(entries[index].saved)
                                hideKeyboard()

                            } label: {
                                Image(systemName: entries[index].saved ?
                                      "checkmark.rectangle.portrait.fill" :
                                        "checkmark.rectangle.portrait")
                                .imageScale(.medium)
                                .foregroundColor(entries[index].saved ? .green : .primary)
                            }
                            .buttonStyle(.bordered)
                            .background(Color.buttonBackground)
                            
                        }
                        .frame(height: 34)
                    }
                }
                .padding(.bottom, 10)
                
                Button {
                    viewModel.saveAll(workout: selectedWkout,
                                      exercise: exercise,
                                      entries: entries,
                                      exerciseNotes: notes)
                    hideKeyboard()
                    
                    for set in 0..<entries.count {
                        // Update all entries to be saved
                        entries[set].saved = true
                    }
                } label: {
                    Text("Save All")
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
        }
        .padding()
        .frame(width: .infinity, height: .infinity)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 4)
            )
    }
}

struct ExerciseDropDownTableView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDropDownTableView(exercise: MockData.sampleExercises[0],
                                  restTime: 60,
                                  repsArr: .constant(MockData.sampleRepsWeightArr),
                                  weightArr: .constant(MockData.sampleRepsWeightArr),
                                  entries: .constant(MockData.sampleEntries),
                                  notes: .constant(""),
                                  restTimeRunning: .constant(false),
                                  restTimeRemaining: .constant(60),
                                  isRestTimerOn: false)
            .environmentObject(MockData.sampleWorkout1)
    }
}

// Textfield that will not trigger a re-draw of the Nav View when inputting a character
struct CustomTextField: View {
    @Binding var owner : Int
    @State var label : String
    @State var value = "" // updates only local view

    var body: some View {
        let text = Binding(get: { self.value }, set: {
            self.value = $0; self.owner = Int($0) ?? 0;  // transfer the value
        })
        return TextField(label, text: text)
    }
}

struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.red, lineWidth: 3)
        ).padding()
    }
}
