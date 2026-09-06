#!/bin/bash

set -euo pipefail

if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
	printf 'airq requires curl and jq. Install them and try again.\n' >&2
	exit 1
fi

location=$(curl -fsSL --max-time 10 https://ipapi.co/json/)
latitude=$(jq -er '.latitude' <<<"$location")
longitude=$(jq -er '.longitude' <<<"$location")
city=$(jq -r '.city // "Unknown location"' <<<"$location")
region=$(jq -r '.region // empty' <<<"$location")
country=$(jq -r '.country_name // empty' <<<"$location")

air_quality=$(curl -fsSL --max-time 15 \
	"https://air-quality-api.open-meteo.com/v1/air-quality?latitude=${latitude}&longitude=${longitude}&current=us_aqi,european_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone&timezone=auto")

location_label="$city"
[[ -n "$region" ]] && location_label+=" - $region"
[[ -n "$country" ]] && location_label+=" - $country"

us_aqi=$(jq -r '.current.us_aqi // "n/a"' <<<"$air_quality")
aqi_label="Unavailable"
if [[ "$us_aqi" =~ ^[0-9]+$ ]]; then
	if (( us_aqi <= 50 )); then
		aqi_label="Good"
	elif (( us_aqi <= 100 )); then
		aqi_label="Moderate"
	elif (( us_aqi <= 150 )); then
		aqi_label="Unhealthy for sensitive groups"
	elif (( us_aqi <= 200 )); then
		aqi_label="Unhealthy"
	elif (( us_aqi <= 300 )); then
		aqi_label="Very unhealthy"
	else
		aqi_label="Hazardous"
	fi
fi

value() {
	jq -r ".current.$1 // \"n/a\"" <<<"$air_quality"
}

printf '\033[1;36mAir quality\033[0m  %s\n' "$location_label"
printf '  Coordinates  %s, %s\n' "$latitude" "$longitude"
printf '  Updated      %s\n\n' "$(value time)"
printf '\033[1m  %-28s %10s  %s\033[0m\n' "Measure" "Value" "Unit"
printf '  %-28s %10s  %s\n' "US AQI ($aqi_label)" "$us_aqi" "index"
printf '  %-28s %10s  %s\n' "European AQI" "$(value european_aqi)" "index"
printf '  %-28s %10s  %s\n' "PM2.5" "$(value pm2_5)" "ug/m3"
printf '  %-28s %10s  %s\n' "PM10" "$(value pm10)" "ug/m3"
printf '  %-28s %10s  %s\n' "Ozone" "$(value ozone)" "ug/m3"
printf '  %-28s %10s  %s\n' "Nitrogen dioxide" "$(value nitrogen_dioxide)" "ug/m3"
printf '  %-28s %10s  %s\n' "Sulphur dioxide" "$(value sulphur_dioxide)" "ug/m3"
printf '  %-28s %10s  %s\n' "Carbon monoxide" "$(value carbon_monoxide)" "ug/m3"
