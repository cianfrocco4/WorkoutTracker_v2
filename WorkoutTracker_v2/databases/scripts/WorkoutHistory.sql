CREATE TABLE WorkoutHistory ( workoutName STRING NOT NULL, 
                              date STRING NOT NULL,
                              notes STRING,
                              PRIMARY KEY (workoutName, date),
                              FOREIGN KEY (workoutName) REFERENCES Workout (name) ); 
