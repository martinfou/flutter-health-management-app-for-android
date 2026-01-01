# User Requirements Discovery: Exercise Tracking

Discovery session to understand how the user wants to track physical activities.

Date: 2025-01-27  
Status: Complete

---

## Questions & Answers

### Workflow & Daily Usage

Q1: When you work out, do you typically follow a plan/schedule, or do you decide what to do on the spot?  
I like to follow a plan but sometime I like to generate a random workout.

Q2: How do you currently track your workouts? (notebook, another app, memory, etc.)  
When I do, I have an app that tells me how many reps and how much weight I am supposed to use for each exercices.

Q3: When logging a workout session, what information is most important to you? (sets/reps/weight, duration, how you felt, notes, etc.)  
all of the above

Q4: Do you want to log workouts during the session (live) or after you're done?  
during the session

Q5: Do you do the same workout multiple times (e.g., repeat "Monday Workout" every Monday), or do you vary your workouts?  
yes I do the same multiple times.

---

### Plans & Scheduling

Q6: When you create a plan, are you planning individual workouts, or are you planning a schedule of when to do certain workouts?  
I do both

Q7: Do you want to be able to "start a workout from a plan" (like selecting "Monday Workout" from your plan and logging it)?  
yes

Q8: Should a plan be repeatable? (e.g., complete "4-Week Plan", then start it again)  
yes

Q9: Can you have multiple plans active at once, or just one active plan?  
I can have multiple plan

Q10: Do you want to see progress within a plan? (e.g., "Week 2 of 4 completed")  
yes

---

### Exercise Library & Templates

Q11: Do you reuse the same exercises frequently, or do you often try new exercises?  
I reuse a lot but I like experimenting with new exercises

Q12: When you log an exercise, do you want to select it from your library first, or type it in each time?  
Option C: Both - search/select from library first, but if it's not there, type a new one and it gets added to the library

Q13: Should the exercise library remember your typical sets/reps/weight for each exercise? (e.g., "Bench Press: usually 3x10 @ 100kg")  
yes and it should pre fill out the form but it is changeable too

Q14: Do you want to create workout templates in your library? (e.g., save "Push Day" as a reusable template)  
yes

---

### History & Progress Tracking

Q15: How do you want to view your workout history? By date? By exercise? By plan?  
all of the above

Q16: Do you want to see trends over time? (e.g., "Bench Press weight increased from 90kg to 100kg over 2 months")  
yes

Q17: When viewing past workouts, what details matter most? (exact sets/reps, notes, how you felt, etc.)  
notes and how I felt

Q18: Do you want to compare workouts? (e.g., "This Monday vs Last Monday")  
yes

---

### Goals & Metrics

Q19: Do you have fitness goals you're tracking? (e.g., "Bench 100kg by March", "Run 5km in under 25 minutes")  
yes  
Examples: Do 50 pushups in a row, Run 5k under 35 minutes

Q20: Do you want to track progress toward goals in the app?  
yes

Q21: What metrics matter most to you? (total volume, PRs, consistency, completion rate, etc.)  
consistency

---

### Special Cases & Flexibility

Q22: Can you skip exercises in a planned workout? (e.g., plan says 5 exercises, but you only do 3 today)  
yes

Q23: Can you add extra exercises not in the plan? (e.g., plan has 4 exercises, but you add 2 more)  
yes

Q24: Do you ever do multiple workouts in one day? (e.g., morning run + evening gym)  
yes

Q25: Do you want to log "failed" or incomplete workouts? (e.g., "Tried to do plan but only finished 2 exercises")  
yes

Q26: Can you edit past workouts? (e.g., realize you logged wrong weight, fix it later)  
yes

Q27: Do you want to delete workouts, or should they be permanent records?  
I want to be able to delete

---

### Workout Details & Customization

Q28: For the same exercise, do you always do the same sets/reps, or do you vary it? (e.g., sometimes 3x10, sometimes 5x5)  
I can vary

Q29: Do you track rest time between sets/exercises?  
Yes, I use an external timer app. It would be nice if this health app automatically logged the rest time (built-in timer preferred)

Q30: Do you want to add photos/videos to workouts? (progress photos, form videos)  
yes

Q31: Do you track how you felt during/after workouts? (energy level, difficulty, mood)  
yes

Q32: Do you want to add notes to individual exercises, or just to the whole workout?  
both

---

### Integration & External Data

Q33: Do you use a fitness tracker (smartwatch, Fitbit, etc.)? Do you want that data integrated?  
yes I use a garmin fenix 6

Q34: Do you want to track heart rate, steps, calories burned during workouts?  
yes

Q35: Should the app sync with Google Fit / Apple Health / other services?  
google fit to start

---

### Sharing & Social

Q36: Do you want to share your workouts with others? (trainer, friends, social media)  
yes but not urgent

Q37: Do you want to see what others are doing, or is this purely personal tracking?  
yes but not urgent

---

### Plan Creation & Management

Q38: When creating a plan, do you want to:
- Create workouts from scratch?
- Use workout templates from your library?
- Copy/modify existing plans?

yes to all above

Q39: Can plans be shared with others, or are they always personal?  
yes

Q40: Do you want plans to have different phases? (e.g., "Week 1-2: Build-up", "Week 3-4: Intensity")  
yes

---

### Quick Actions & Efficiency

Q41: What's the fastest way you'd want to log a simple workout? (e.g., "Just ran 5km", "Did my usual gym routine")  
Option F: Combination of quick-add options (most recent workout, scheduled workout, quick templates, voice input, copy from previous)

Q42: Do you want quick-add buttons for your most common exercises/workouts?  
yes

Q43: Should the app suggest workouts based on what you did last time?  
yes

---

### Notifications & Reminders

Q44: Do you want workout reminders? (e.g., "Time for your Monday workout")  
yes

Q45: Do you want to be reminded if you miss a planned workout?  
yes

Q46: Do you want streak tracking? (e.g., "7 day workout streak")  
yes

---

## Use Cases Identified

Based on the discovery session, the following use cases have been identified:

### Core Workout Logging

UC1: Log Workout During Session (Live Logging)
- User starts a workout session and logs exercises in real-time as they complete them
- Supports logging sets, reps, weight, rest time, notes, and how they felt
- Can log multiple workouts in one day (e.g., morning run + evening gym)
- Can edit or delete workouts after logging

UC2: Log Exercise with Library Integration
- User searches/selects exercise from library (frequently used exercises)
- If exercise not found, user can type new exercise name (adds to library)
- App pre-fills typical sets/reps/weight for that exercise (changeable)
- User can vary sets/reps/weight for same exercise on different days

UC3: Quick Workout Logging
- Multiple quick-add options: most recent workout, scheduled workout, quick templates, voice input, copy previous
- Quick-add buttons for most common exercises/workouts
- App suggests workouts based on previous sessions

UC4: Log Incomplete/Failed Workout
- User can log partial workouts (e.g., only completed 2 of 5 planned exercises)
- User can skip exercises in planned workout
- User can add extra exercises not in the plan

### Workout Plans & Scheduling

UC5: Create and Manage Workout Plans
- User can create plans with individual workouts OR schedule of when to do certain workouts
- Multiple methods: create from scratch, use workout templates, copy/modify existing plans
- Plans can have different phases (e.g., "Week 1-2: Build-up", "Week 3-4: Intensity")
- User can have multiple active plans simultaneously
- Plans are repeatable (complete, then start again)
- Plans can be shared with others

UC6: Start Workout from Plan
- User selects a planned workout (e.g., "Monday Workout") from their active plans
- Workout template loads with exercises pre-filled
- User can modify, skip, or add exercises during the session
- Plan progress is tracked (e.g., "Week 2 of 4 completed")

UC7: Generate Random Workout
- User can generate a random workout when not following a plan
- Useful for variety and experimentation

### Exercise Library & Templates

UC8: Manage Exercise Library
- Library remembers exercises user has used before
- Each exercise stores typical sets/reps/weight (pre-filled but changeable)
- User can experiment with new exercises (added to library automatically)
- Search/select from library OR type new exercise name

UC9: Create and Use Workout Templates
- User can save frequently used workouts as templates (e.g., "Push Day")
- Templates can be reused in plans or started directly
- Templates can be modified without affecting past workouts

### History & Progress Tracking

UC10: View Workout History
- View by date, by exercise, or by plan
- Most important details: notes and how user felt
- Can compare workouts (e.g., "This Monday vs Last Monday")

UC11: Track Progress & Trends
- See trends over time (e.g., "Bench Press weight increased from 90kg to 100kg over 2 months")
- Track progress toward goals (e.g., "Do 50 pushups in a row", "Run 5k under 35 minutes")
- Consistency metrics are most important
- Streak tracking (e.g., "7 day workout streak")

### Goals & Metrics

UC12: Set and Track Fitness Goals
- User can set specific goals (e.g., "50 pushups in a row", "Run 5k under 35 minutes")
- App tracks progress toward goals
- Primary focus: consistency metrics

### Workout Details & Customization

UC13: Log Comprehensive Workout Data
- Sets, reps, weight, duration, rest time, notes, how user felt
- Rest timer built into app (automatically logs rest time)
- Add photos/videos (progress photos, form videos)
- Notes at both exercise level and workout level
- Track energy level, difficulty, mood

### Integration & External Data

UC14: Integrate with Fitness Trackers
- Sync with Garmin Fenix 6
- Track heart rate, steps, calories burned during workouts
- Sync with Google Fit (to start, Apple Health later)

### Notifications & Reminders

UC15: Workout Reminders
- Reminders for scheduled workouts (e.g., "Time for your Monday workout")
- Reminders if user misses a planned workout
- Streak tracking notifications

---

## Key Requirements Summary

### Must-Have Features (MVP)

- Live workout logging during session
- Exercise library with search/select + add new
- Pre-filled typical sets/reps/weight (changeable)
- Workout plans with scheduling (multiple active plans)
- Workout templates
- Start workout from plan
- Edit/delete workouts
- Skip/add exercises in planned workouts
- View history by date/exercise/plan
- Track progress toward goals
- Consistency metrics and streak tracking
- Notes (exercise and workout level)
- Track how user felt (energy, difficulty, mood)
- Rest timer (automatic logging)
- Workout reminders and missed workout alerts
- Multiple workouts per day
- Log incomplete/failed workouts

### Nice-to-Have (Post-MVP)

- Photos/videos to workouts
- Garmin Fenix 6 integration
- Google Fit sync
- Share workouts with others
- Share plans with others
- Social features (see what others are doing)
- Voice input for quick logging
- Plan phases/different intensity periods

### Data Points to Track

- Sets, reps, weight
- Duration
- Rest time (automatic via timer)
- Notes (exercise + workout level)
- How user felt (energy, difficulty, mood)
- Photos/videos
- Heart rate, steps, calories (from tracker)
- Date/time
- Plan association
- Goal progress

---

Next Steps:
1. Review use cases for completeness
2. Propose data model updates based on requirements
3. Create UI/UX mockups for key flows
4. Prioritize features for MVP vs Post-MVP
