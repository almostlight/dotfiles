#!/bin/bash

# Battery notification script for Sway
# Save as ~/.config/sway/scripts/battery-notify.sh
# Make executable: chmod +x ~/.config/sway/scripts/battery-notify.sh

# Configuration
LOW_BATTERY=20
CRITICAL_BATTERY=10
CHECK_INTERVAL=60  # seconds

# Notification IDs (to replace previous notifications)
NOTIFY_ID_LOW=1000
NOTIFY_ID_CRITICAL=1001
NOTIFY_ID_FULL=1002
NOTIFY_ID_CHARGING=1003

# Icons (use your preferred icon theme)
ICON_BATTERY_LOW="󰁺"
ICON_BATTERY_CRITICAL="󰁻"
ICON_BATTERY_FULL="󰁹"
ICON_BATTERY_CHARGING="󰂄"
ICON_BATTERY_DISCHARGING="󰂃"
ICON_PLUG="󰚥"

# Colors for notifications
COLOR_LOW="#FFA500"    # Orange
COLOR_CRITICAL="#FF0000" # Red
COLOR_NORMAL="#00FF00"  # Green
COLOR_FULL="#0080FF"    # Blue

# Function to get battery info
get_battery_info() {
    # Try to get battery info from upower
    if command -v upower &> /dev/null; then
        BATTERY_INFO=$(upower -i $(upower -e | grep BAT) 2>/dev/null)
        
        if [ -n "$BATTERY_INFO" ]; then
            PERCENTAGE=$(echo "$BATTERY_INFO" | grep percentage | awk '{print $2}' | sed 's/%//')
            STATE=$(echo "$BATTERY_INFO" | grep state | awk '{print $2}')
            TIME_REMAINING=$(echo "$BATTERY_INFO" | grep "time to" | awk '{print $4 " " $5}')
            
            # If PERCENTAGE is empty, try another method
            if [ -z "$PERCENTAGE" ]; then
                PERCENTAGE=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
                STATE=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
            fi
        fi
    fi
    
    # Fallback to sysfs
    if [ -z "$PERCENTAGE" ] || [ -z "$STATE" ]; then
        if [ -f /sys/class/power_supply/BAT0/capacity ]; then
            PERCENTAGE=$(cat /sys/class/power_supply/BAT0/capacity)
            STATE=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
            
            # Get time remaining (estimate)
            if [ -f /sys/class/power_supply/BAT0/charge_now ] && [ -f /sys/class/power_supply/BAT0/current_now ]; then
                CHARGE_NOW=$(cat /sys/class/power_supply/BAT0/charge_now)
                CURRENT_NOW=$(cat /sys/class/power_supply/BAT0/current_now)
                
                if [ "$CURRENT_NOW" -gt 0 ]; then
                    if [ "$STATE" = "Discharging" ]; then
                        SECONDS_REMAINING=$((CHARGE_NOW * 3600 / CURRENT_NOW))
                        HOURS=$((SECONDS_REMAINING / 3600))
                        MINUTES=$(((SECONDS_REMAINING % 3600) / 60))
                        TIME_REMAINING="${HOURS}h ${MINUTES}m"
                    fi
                fi
            fi
        else
            # Try BAT1 if BAT0 doesn't exist
            if [ -f /sys/class/power_supply/BAT1/capacity ]; then
                PERCENTAGE=$(cat /sys/class/power_supply/BAT1/capacity)
                STATE=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo "Unknown")
            fi
        fi
    fi
    
    # Default values if still empty
    PERCENTAGE=${PERCENTAGE:-0}
    STATE=${STATE:-Unknown}
    
    echo "$PERCENTAGE $STATE $TIME_REMAINING"
}

# Function to send notification
send_notification() {
    local id="$1"
    local message="$2"
    local urgency="$3"
    local icon="$4"
    local color="$5"
    
    # Use notify-send with Dunst
    notify-send -r "$id" -u "$urgency" -i "$icon" \
        -h "string:hlcolor:$color" \
        "Battery Status" "$message"
    
    # Also log to syslog for debugging
    logger -t "battery-notify" "$message"
}

# Function to check ASUS battery health (if asusctl is available)
check_asus_battery() {
    if command -v asusctl &> /dev/null; then
        BATTERY_HEALTH=$(asusctl battery-health 2>/dev/null | grep -oP '\d+%')
        if [ -n "$BATTERY_HEALTH" ]; then
            echo " (Health: $BATTERY_HEALTH)"
        fi
    fi
}

# Function to play sound (optional)
play_sound() {
    local sound="$1"
    if command -v paplay &> /dev/null && [ -f "/usr/share/sounds/freedesktop/stereo/$sound.oga" ]; then
        paplay "/usr/share/sounds/freedesktop/stereo/$sound.oga" &
    fi
}

# Main monitoring loop
previous_percentage=""
previous_state=""
low_notified=false
critical_notified=false
full_notified=false

while true; do
    # Get battery info
    read percentage state time_remaining <<< $(get_battery_info)
    
    # Skip if we couldn't get percentage
    if [ -z "$percentage" ] || [ "$percentage" = "0" ]; then
        sleep $CHECK_INTERVAL
        continue
    fi
    
    # Get battery health info
    health_info=$(check_asus_battery)
    
    # State change notifications
    if [ "$state" != "$previous_state" ]; then
        case "$state" in
            "charging"|"Charging")
                send_notification $NOTIFY_ID_CHARGING \
                    "Battery is now charging ($percentage%)$health_info" \
                    "normal" "$ICON_BATTERY_CHARGING" "$COLOR_NORMAL"
                low_notified=false
                critical_notified=false
                ;;
            "discharging"|"Discharging")
                send_notification $NOTIFY_ID_CHARGING \
                    "Battery is now discharging ($percentage%)$health_info" \
                    "normal" "$ICON_BATTERY_DISCHARGING" "$COLOR_NORMAL"
                full_notified=false
                ;;
            "full"|"Full")
                if [ "$full_notified" = false ]; then
                    send_notification $NOTIFY_ID_FULL \
                        "Battery is fully charged$health_info" \
                        "normal" "$ICON_BATTERY_FULL" "$COLOR_FULL"
                    full_notified=true
                    play_sound "complete"
                fi
                ;;
        esac
    fi
    
    # Critical battery level (10% or below)
    if [ "$percentage" -le "$CRITICAL_BATTERY" ] && [ "$state" = "discharging" ] || [ "$state" = "Discharging" ]; then
        if [ "$critical_notified" = false ]; then
            message="Battery critically low! ($percentage%)"
            if [ -n "$time_remaining" ]; then
                message="$message - $time_remaining remaining"
            fi
            message="$message$health_info\nPlug in your charger immediately!"
            
            send_notification $NOTIFY_ID_CRITICAL "$message" "critical" "$ICON_BATTERY_CRITICAL" "$COLOR_CRITICAL"
            play_sound "dialog-warning"
            
            # Optionally, trigger system action
            if [ "$percentage" -le 5 ]; then
                # Suspend at 5% if still discharging
                notify-send -u critical "System will suspend in 60 seconds!" "Battery extremely low"
                sleep 60
                # Check if still critical
                read new_percentage new_state <<< $(get_battery_info)
                if [ "$new_percentage" -le 5 ] && [ "$new_state" = "discharging" ] || [ "$new_state" = "Discharging" ]; then
                    systemctl suspend
                fi
            fi
            
            critical_notified=true
        fi
    
    # Low battery level (20% or below)
    elif [ "$percentage" -le "$LOW_BATTERY" ] && [ "$state" = "discharging" ] || [ "$state" = "Discharging" ]; then
        if [ "$low_notified" = false ]; then
            message="Battery low ($percentage%)"
            if [ -n "$time_remaining" ]; then
                message="$message - ~$time_remaining remaining"
            fi
            message="$message$health_info\nConsider connecting to power."
            
            send_notification $NOTIFY_ID_LOW "$message" "normal" "$ICON_BATTERY_LOW" "$COLOR_LOW"
            play_sound "dialog-information"
            low_notified=true
        fi
    
    # Reset notifications when charging above thresholds
    elif [ "$state" = "charging" ] || [ "$state" = "Charging" ]; then
        if [ "$percentage" -gt "$LOW_BATTERY" ]; then
            low_notified=false
        fi
        if [ "$percentage" -gt "$CRITICAL_BATTERY" ]; then
            critical_notified=false
        fi
    fi
    
    # Update previous values
    previous_percentage="$percentage"
    previous_state="$state"
    
    # Sleep before next check
    sleep $CHECK_INTERVAL
done
