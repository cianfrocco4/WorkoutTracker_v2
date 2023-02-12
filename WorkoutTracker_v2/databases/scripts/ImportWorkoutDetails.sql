PRAGMA foreign_keys = ON;
delete from WorkoutDetails;
.import --csv --skip 1 /Users/anthony/Documents/Projects/WorkoutTracker_v2/WorkoutTracker_v2/databases/data/WorkoutDetailsData.csv WorkoutDetails
