# Random Small Programs

A repository for random small scripts and programs I write. 

## Strava

Script to get info from Strava API. Currently supports viewing one of your activities by ID, and a segment by ID.  
Uses a bash script for the main functionality and calls a Python script to get the segment leaderboard because it's not included in the Strava API free functionality.  
**ToDo:** 
* Add ability to upload a ride
* Easier way to select activities and segments than using the ID

### Setup

Dependancies: `glow`, `jq`, `python requests` and `python BeautifulSoup4`  

Run `./strava.sh` and follow instructions 

### Usage 

Activity Information: `./strava.sh -r *activity_id*`  
Segment Information: `./strava.sh -s *segment_id*`

## Pro Cycling Stats

Python script to get current race information, at the moment only displays time gaps. 
**ToDo:**
* Display more information
* Work with TTs

### Setup

Dependancies: `python requests` and `python BeautifulSoup4`

### Usage

`python3 getInfo.py *refresh_Duration* (optional, default 10(s))` will display currently active races, enter the number corresponding to the race you want and it will display current time gaps and general race stats. **Note:** does not currently work for time trials as they are formatted differently. 
