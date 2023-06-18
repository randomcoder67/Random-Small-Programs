#!/usr/bin/env bash

getTokens () {
	echo "Visit https://www.strava.com/settings/api and create an application, then copy and paste the Client ID and Client Secret into the following prompts:"
	read -p "Client ID: " inputClientID
	read -p "Client Secret: " inputClientSecret
	echo "Visit this URL: https://www.strava.com/oauth/authorize?client_id=$inputClientID&response_type=code&redirect_uri=http%3A%2F%2Flocalhost&scope=activity:raed_all,write&state=mystate&approval_prompt=force, grant access and then copy the code from the URL"
	read -p "Code: " inputCode
	exchangeRequest=$(curl -s -X POST https://www.strava.com/oauth/token -F client_id="$inputClientID" -F client_secret="$inputClientSecret" -F code="$inputCode" -F grant_type=authorization_code)
	
	echo $exchangeRequest
	accessTokenA=$(echo "$exchangeRequest" | jq -r .access_token)
	refreshTokenA=$(echo "$exchangeRequest" | jq -r .refresh_token)
	expiryA=$(echo "$exchangeRequest" | jq .expires_at)
	
	echo "$refreshTokenA" > "strava.txt"
	echo "$accessTokenA" >> "strava.txt"
	echo "$inputClientID" >> "strava.txt"
	echo "$inputClientSecret" >> "strava.txt"
	echo "$expiryA" >> "strava.txt"
	
	#gpg -c "strava.txt"
}

if [ ! -f strava.txt.gpg ]; then
	getTokens
fi

init () {
	encryptedOutput=$(gpg -q -d "strava.txt.gpg")
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

	rm "strava.txt.gpg"
	#rm "strava$1.txt"

	echo "$refreshA" > "strava.txt"
	echo "$accessA" >> "strava.txt"
	echo "$clientA" >> "strava.txt"
	echo "$clientSecretA" >> "strava.txt"
	echo "$expireTimeEpoch" >> "strava.txt"

	gpg -q -c "strava.txt"
	rm "strava.txt"
}

makeGlowActivity () {
	echo "# Testing Activies" > glow.md

	echo "| Key | Value |" >> glow.md
	echo "| :--: | :--: |" >> glow.md

	echo "| Name | $activityName |" >> glow.md
	echo "| Distance | $(awk -v var="$activityDistance" 'BEGIN{sum=var/1000; printf "%.2f km\n", sum}') |" >> glow.md
	echo "| Moving Time | $(date -d@$activityMovingTime -u +"%H:"%M:"%S") |" >> glow.md
	echo "| Elapsed Time | $(date -d@$activityElapsedTime -u +"%H:"%M:"%S") |" >> glow.md
	echo "| Elevation Gain | $activityElevationGain" m" |" >> glow.md
	echo "| Start Time | $(echo $activityStartTime | tr 'T' ' ' | tr 'Z' ' ' | awk '{$1=$1};1') |" >> glow.md
	echo "| City | $activityCity |" >> glow.md
	echo "| State | $activityState |" >> glow.md
	echo "| Country | $activityCountry |" >> glow.md
	echo "| Achievements | $activityAchievements" Achievements" |" >> glow.md
	echo "| Kudos | $activityKudos" Kudos" |" >> glow.md
	echo "| Athletes | $activitiesAthleteCount" Athletes" |" >> glow.md
	echo "| Average Speed | $(awk -v var="$activityAverageSpeed" 'BEGIN{sum=var*3.6; printf "%.2f km/h\n", sum}') |" >> glow.md
	echo "| Max Speed | $(awk -v var="$activityMaxSpeed" 'BEGIN{sum=var*3.6; printf "%.2f km/h\n", sum}') |" >> glow.md
	echo "| Highest Elevation | $activityElevHigh" m" |" >> glow.md
	echo "| Lowest Elevation | $activityElevLow" m" |" >> glow.md
	echo "| PRs | $activityPRCount" PRs" |" >> glow.md
}


makeGlowSegment () {
	echo "# Testing Segments" > glow.md

	echo "| Key | Value |" >> glow.md
	echo "| :--: | :--: |" >> glow.md

	echo "| Name | $segmentName |" >> glow.md
	echo "| Distance | $(awk -v var="$segmentDistance" 'BEGIN{sum=var/1000; printf "%.2f km\n", sum}') |" >> glow.md
	echo "| Average Grade | $segmentAverageGrade"%" |" >> glow.md
	echo "| Maximum Grade | $segmentMaximumGrade"%" |" >> glow.md
	echo "| Highest Elevation | $segmentEvelHigh" m" |" >> glow.md
	echo "| Lowest Elevation | $segmentEvelLow" m" |" >> glow.md
	echo "| Climb Category | "Category "$segmentClimbCategory |" >> glow.md
	echo "| State | $segmentState |" >> glow.md
	echo "| Country | $segmentCountry |" >> glow.md
	echo "| Elevation Gain | $segmentElevGain" m" |" >> glow.md
	echo "| Atheletes | $segmentAthleteCount" Athletes" |" >> glow.md
	echo "| My PR Time | $(date -d@$segmentMyBestTime -u +"%H:"%M:"%S") |" >> glow.md
	echo "| My PR Date | $(echo $segmentMyBestDate | tr 'T' ' ' | tr 'Z' ' ' | awk '{$1=$1};1') |" >> glow.md
	echo "| My PR ID | "ID: "$segmentMyBestID |" >> glow.md
	echo "| My PR Efforts | $segmentMyEfforts" Efforts" |" >> glow.md
	echo "| KOM | $(date -d@$(awk -v mins="$(echo $segmentKOM | cut -d ":" -f 1)" -v secs="$(echo $segmentKOM | cut -d ":" -f 2)" 'BEGIN{sum=mins*60+secs; printf "%d\n", sum}') -u +"%H:"%M:"%S") |" >> glow.md
	echo "| QOM | $(date -d@$(awk -v mins="$(echo $segmentQOM | cut -d ":" -f 1)" -v secs="$(echo $segmentQOM | cut -d ":" -f 2)" 'BEGIN{sum=mins*60+secs; printf "%d\n", sum}') -u +"%H:"%M:"%S") |" >> glow.md
}


if [[ "$1" == "-a" ]]; then
	init
	echo -a
elif [[ "$1" == "-s" ]]; then
	init
	returnedJSON=$(curl -s -G "https://www.strava.com/api/v3/segments/{$2}" -H "Authorization: Bearer $accessA")

	oldIFS=$IFS
	IFS='|'
	read -r segmentName segmentDistance segmentAverageGrade segmentMaximumGrade segmentEvelHigh segmentEvelLow segmentClimbCategory segmentState segmentCountry segmentElevGain segmentAthleteCount segmentMyBestTime segmentMyBestDate segmentMyBestID segmentMyEfforts segmentKOM segmentQOM <<<$(echo $returnedJSON | jq -r '[.name,.distance,.average_grade,.maximum_grade,.elevation_high,.elevation_low,.climb_category,.state,.country,.total_elevation_gain,.athlete_count,.athlete_segment_stats.pr_elapsed_time,.athlete_segment_stats.pr_date,.athlete_segment_stats.pr_activity_id,.athlete_segment_stats.effort_count,.xoms.kom,.xoms.qom] | join ("|")')
	IFS=$oldIFS
	makeGlowSegment
	python3 segmentLeaderboard.py "$2"

	paste <(unbuffer glow -w 50 glow.md) <(unbuffer glow -w 62 table.md) | column -s $'\t' -tne$
elif [[ "$1" == "-r" ]]; then
	init read
	returnedJSON=$(curl -s -G "https://www.strava.com/api/v3/activities/{$2}?include_all_efforts=" -H "Authorization: Bearer $accessA")

	oldIFS=$IFS
	IFS='|'
	read -r activityName activityDistance activityMovingTime activityElapsedTime activityElevationGain activityStartTime activityCity activityState activityCountry activityAchievements activityKudos activitiesAthleteCount activityAverageSpeed activityMaxSpeed activityElevHigh activityElevLow activityPRCount <<<$(echo $returnedJSON | jq -r '[.name,.distance,.moving_time,.elapsed_time,.total_elevation_gain,.start_date_local,.location_city,.location_state,.location_country,.achievement_count,.kudos_count,.athlete_count,.average_speed,.max_speed,.elev_high,.elev_low,.pr_count] | join("|")')
	IFS=$oldIFS
	makeGlowActivity

	glow glow.md
else
	echo "Usage:"
	echo "  -a FILENAME = Add Ride"
	echo "  -s SEGMENT_ID = Get Segment Leaderboard and Stats"
	echo "  -r ACTIVITY_ID = Get Activity Stats"
fi
