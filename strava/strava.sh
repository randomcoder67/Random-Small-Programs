#!/usr/bin/env bash

dirName="$HOME/Programs/smallPrograms/strava"
dirTemp="$HOME/Programs/output/.temp"

# Function to get tokens if you don't already have them
getTokens () {
	echo "Visit https://www.strava.com/settings/api and create an application, then copy and paste the Client ID and Client Secret into the following prompts:"
	read -p "Client ID: " inputClientID
	read -p "Client Secret: " inputClientSecret
	# Uses this URL to request access to your account 
	echo "Visit this URL: https://www.strava.com/oauth/authorize?client_id=$inputClientID&response_type=code&redirect_uri=http%3A%2F%2Flocalhost&scope=activity:read_all,activity:write&state=mystate&approval_prompt=force, grant access and then copy the code from the URL"
	read -p "Code: " inputCode
	# Exchanges the code you recieved for a refresh and access token 
	exchangeRequest=$(curl -s -X POST https://www.strava.com/oauth/token -F client_id="$inputClientID" -F client_secret="$inputClientSecret" -F code="$inputCode" -F grant_type=authorization_code)
	
	echo $exchangeRequest
	accessTokenA=$(echo "$exchangeRequest" | jq -r .access_token)
	refreshTokenA=$(echo "$exchangeRequest" | jq -r .refresh_token)
	expiryA=$(echo "$exchangeRequest" | jq .expires_at)
	
	# Saves everything to a file and encrypts
	echo "$refreshTokenA" > "$dirName/strava.txt"
	echo "$accessTokenA" >> "$dirName/strava.txt"
	echo "$inputClientID" >> "$dirName/strava.txt"
	echo "$inputClientSecret" >> "$dirName/strava.txt"
	echo "$expiryA" >> "$dirName/strava.txt"
	
	gpg -c "$dirName/strava.txt"
}

if [ ! -f "$dirName/strava.txt.gpg" ]; then
	getTokens
fi

# Gets the tokens from the encrypted file, and if neccessary requests a new access token
init () {
	encryptedOutput=$(gpg -q -d "$dirName/strava.txt.gpg")
	refreshA=$(echo "$encryptedOutput" | sed -n "1p")
	accessA=$(echo "$encryptedOutput" | sed -n "2p")
	clientA=$(echo "$encryptedOutput" | sed -n "3p")
	clientSecretA=$(echo "$encryptedOutput" | sed -n "4p")
	expireTimeEpoch=$(echo "$encryptedOutput" | sed -n "5p")
	currentTimeEpoch=$(date +"%s")

	# If not expired, don't need to anything else
	if (( "$((currentTimeEpoch-expireTimeEpoch))" < 0 )); then
		#rm "strava$1.txt"
		return
	fi
	echo "Requesting New Tokens: $refreshA"
	newAccessRequest=$(curl -X POST "https://www.strava.com/api/v3/oauth/token" -d client_id=$clientA -d client_secret=$clientSecretA -d grant_type=refresh_token -d refresh_token=$refreshA | jq -r '.access_token, .expires_at')
	echo "Got New Tokens"
	accessA=$(echo "$newAccessRequest" | sed -n "1p")
	expireTimeEpoch=$(echo "$newAccessRequest" | sed -n "2p")

	rm "$dirName/strava.txt.gpg"
	#rm "strava$1.txt"

	echo "$refreshA" > "$dirName/strava.txt"
	echo "$accessA" >> "$dirName/strava.txt"
	echo "$clientA" >> "$dirName/strava.txt"
	echo "$clientSecretA" >> "$dirName/strava.txt"
	echo "$expireTimeEpoch" >> "$dirName/strava.txt"

	gpg -q -c "$dirName/strava.txt"
	rm "$dirName/strava.txt"
}

makeGlowActivity () {
	echo "# Testing Activies" > "$dirTemp/glow.md"

	echo "| Key | Value |" >> "$dirTemp/glow.md"
	echo "| :--: | :--: |" >> "$dirTemp/glow.md"

	echo "| Name | $activityName |" >> "$dirTemp/glow.md"
	echo "| Distance | $(awk -v var="$activityDistance" 'BEGIN{sum=var/1000; printf "%.2f km\n", sum}') |" >> "$dirTemp/glow.md"
	echo "| Moving Time | $(date -d@$activityMovingTime -u +"%H:"%M:"%S") |" >> "$dirTemp/glow.md"
	echo "| Elapsed Time | $(date -d@$activityElapsedTime -u +"%H:"%M:"%S") |" >> "$dirTemp/glow.md"
	echo "| Elevation Gain | $activityElevationGain" m" |" >> "$dirTemp/glow.md"
	echo "| Start Time | $(echo $activityStartTime | tr 'T' ' ' | tr 'Z' ' ' | awk '{$1=$1};1') |" >> "$dirTemp/glow.md"
	echo "| City | $activityCity |" >> "$dirTemp/glow.md"
	echo "| State | $activityState |" >> "$dirTemp/glow.md"
	echo "| Country | $activityCountry |" >> "$dirTemp/glow.md"
	echo "| Achievements | $activityAchievements" Achievements" |" >> "$dirTemp/glow.md"
	echo "| Kudos | $activityKudos" Kudos" |" >> "$dirTemp/glow.md"
	echo "| Athletes | $activitiesAthleteCount" Athletes" |" >> "$dirTemp/glow.md"
	echo "| Average Speed | $(awk -v var="$activityAverageSpeed" 'BEGIN{sum=var*3.6; printf "%.2f km/h\n", sum}') |" >> "$dirTemp/glow.md"
	echo "| Max Speed | $(awk -v var="$activityMaxSpeed" 'BEGIN{sum=var*3.6; printf "%.2f km/h\n", sum}') |" >> "$dirTemp/glow.md"
	echo "| Highest Elevation | $activityElevHigh" m" |" >> "$dirTemp/glow.md"
	echo "| Lowest Elevation | $activityElevLow" m" |" >> "$dirTemp/glow.md"
	echo "| PRs | $activityPRCount" PRs" |" >> "$dirTemp/glow.md"
	echo "| Lap One Time | $(date -d@$lapOneTime -u +"%H:"%M:"%S") |" >> "$dirTemp/glow.md"
}


makeGlowSegment () {
	echo "# Testing Segments" > "$dirTemp/glow.md"

	echo "| Key | Value |" >> "$dirTemp/glow.md"
	echo "| :--: | :--: |" >> "$dirTemp/glow.md"

	echo "| Name | $segmentName |" >> "$dirTemp/glow.md"
	echo "| Distance | $(awk -v var="$segmentDistance" 'BEGIN{sum=var/1000; printf "%.2f km\n", sum}') |" >> "$dirTemp/glow.md"
	echo "| Average Grade | $segmentAverageGrade"%" |" >> "$dirTemp/glow.md"
	echo "| Maximum Grade | $segmentMaximumGrade"%" |" >> "$dirTemp/glow.md"
	echo "| Highest Elevation | $segmentEvelHigh" m" |" >> "$dirTemp/glow.md"
	echo "| Lowest Elevation | $segmentEvelLow" m" |" >> "$dirTemp/glow.md"
	echo "| Climb Category | "Category "$segmentClimbCategory |" >> "$dirTemp/glow.md"
	echo "| State | $segmentState |" >> "$dirTemp/glow.md"
	echo "| Country | $segmentCountry |" >> "$dirTemp/glow.md"
	echo "| Elevation Gain | $segmentElevGain" m" |" >> "$dirTemp/glow.md"
	echo "| Atheletes | $segmentAthleteCount" Athletes" |" >> "$dirTemp/glow.md"
	echo "| My PR Time | $(date -d@$segmentMyBestTime -u +"%H:"%M:"%S") |" >> "$dirTemp/glow.md"
	echo "| My PR Date | $(echo $segmentMyBestDate | tr 'T' ' ' | tr 'Z' ' ' | awk '{$1=$1};1') |" >> "$dirTemp/glow.md"
	echo "| My PR ID | "ID: "$segmentMyBestID |" >> "$dirTemp/glow.md"
	echo "| My PR Efforts | $segmentMyEfforts" Efforts" |" >> "$dirTemp/glow.md"
	echo "| KOM | $(date -d@$(awk -v mins="$(echo $segmentKOM | cut -d ":" -f 1)" -v secs="$(echo $segmentKOM | cut -d ":" -f 2)" 'BEGIN{sum=mins*60+secs; printf "%d\n", sum}') -u +"%H:"%M:"%S") |" >> "$dirTemp/glow.md"
	echo "| QOM | $(date -d@$(awk -v mins="$(echo $segmentQOM | cut -d ":" -f 1)" -v secs="$(echo $segmentQOM | cut -d ":" -f 2)" 'BEGIN{sum=mins*60+secs; printf "%d\n", sum}') -u +"%H:"%M:"%S") |" >> "$dirTemp/glow.md"
}

# Add new activity 
if [[ "$1" == "-a" ]]; then
	init
	# Read in activity details from user
	read -p "Name of Activity: " nameA
	read -p "Description of Activity: " descriptionA
	read -p "Trainer? (y/N): " trainerYN
	read -p "Commute? (y/N): " commuteYN
	
	# Assign trainer value to true of false depending on user input
	if [[ "$trainerYN" == "y" ]]; then
		trainerA="true"
	elif [[ "$trainerYN" == "n" ]] || [[ "$trainerYN" == "" ]]; then
		trainerA="false"
	fi
	
	# Assign commute value to true of false depending on user input
	if [[ "$commuteYN" == "y" ]]; then
		commuteA="true"
	elif [[ "$commuteYN" == "n" ]] || [[ "$commuteYN" == "" ]]; then
		commuteA="false"
	fi
	
	# Get file type
	fileNameA=$(basename "$2")
	dataTypeA="${fileNameA##*.}"
	echo $dataTypeA
	echo $fileNameA
	#exit
	
	# Send curl request and capture returned json
	returnedJSON=$(curl -X POST "https://www.strava.com/api/v3/uploads" -F file="@""$2" -F name="$nameA" -F description="$descriptionA" -F trainer="$trainerA" -F commute="$commuteA" -F data_type="$dataTypeA" -H "Authorization: Bearer $accessA")
	uploadID=$(echo "$returnedJSON" | jq .id)
	sleep 3
	finishedUpload=$(curl "https://www.strava.com/api/v3/uploads/$uploadID" -h "Authorization: Bearer $accessA")
	rideID=$(echo "$finishedUpload" | jq .activity_id)
	"$dirName/strava.sh" -r "$rideID"
# View information for segment
elif [[ "$1" == "-s" ]]; then
	init
	returnedJSON=$(curl -s -G "https://www.strava.com/api/v3/segments/{$2}" -H "Authorization: Bearer $accessA")

	oldIFS=$IFS
	IFS='|'
	read -r segmentName segmentDistance segmentAverageGrade segmentMaximumGrade segmentEvelHigh segmentEvelLow segmentClimbCategory segmentState segmentCountry segmentElevGain segmentAthleteCount segmentMyBestTime segmentMyBestDate segmentMyBestID segmentMyEfforts segmentKOM segmentQOM <<<$(echo $returnedJSON | jq -r '[.name,.distance,.average_grade,.maximum_grade,.elevation_high,.elevation_low,.climb_category,.state,.country,.total_elevation_gain,.athlete_count,.athlete_segment_stats.pr_elapsed_time,.athlete_segment_stats.pr_date,.athlete_segment_stats.pr_activity_id,.athlete_segment_stats.effort_count,.xoms.kom,.xoms.qom] | join ("|")')
	IFS=$oldIFS
	makeGlowSegment
	python3 "$dirName/segmentLeaderboard.py" "$2"
	echo ""
	paste <(unbuffer glow -w 50 "$dirTemp/glow.md") <(unbuffer glow -w 62 "$dirTemp/table.md") | column -s $'\t' -tne$
# View information for ride
elif [[ "$1" == "-r" ]]; then
	init read
	returnedJSON=$(curl -s -G "https://www.strava.com/api/v3/activities/{$2}?include_all_efforts=" -H "Authorization: Bearer $accessA")

	oldIFS=$IFS
	IFS='|'
	read -r activityName activityDistance activityMovingTime activityElapsedTime activityElevationGain activityStartTime activityCity activityState activityCountry activityAchievements activityKudos activitiesAthleteCount activityAverageSpeed activityMaxSpeed activityElevHigh activityElevLow activityPRCount lapOneTime <<<$(echo $returnedJSON | jq -r '[.name,.distance,.moving_time,.elapsed_time,.total_elevation_gain,.start_date_local,.location_city,.location_state,.location_country,.achievement_count,.kudos_count,.athlete_count,.average_speed,.max_speed,.elev_high,.elev_low,.pr_count,.laps[0].elapsed_time] | join("|")')
	IFS=$oldIFS
	makeGlowActivity
	glow "$dirTemp/glow.md"
	
# Print help info
else
	echo "Usage:"
	echo "  -a FILENAME = Add Ride"
	echo "  -s SEGMENT_ID = Get Segment Leaderboard and Stats"
	echo "  -r ACTIVITY_ID = Get Activity Stats"
fi
