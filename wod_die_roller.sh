#!/bin/bash
# Dice roller for World of Darkness's RPGs

default_dices=10
default_target_number=6
default_skill_dices=0
set rollitup
unset addroll

if [[ $(tput colors) -gt 7 ]]
then
      wehavecolors=1
fi

function number_of_dices {
	echo "Enter total number of dices (${default_dices}):"
	read -r dices
	if [ -z "${dices}" ]
	then
		dices="${default_dices}"
	else
		if [[ "${dices}" -lt 1 ]]
		then
			echo "If I don't have any die, how you expect I will roll?"
			number_of_dices
		fi

	fi
	}

function skill {
	echo "skill dices of it (${default_skill_dices})"
	read -r skill_dices
	if [ -z "${skill_dices}" ]
	then
		skill_dices="${default_skill_dices}"
	fi
	}	

function target {
	echo "Enter target number (${default_target_number})"
	read -r target_number
	if [ -z "${target_number}" ]
	then
		target_number="${default_target_number}"
	fi
	}

function addroll {
	echo "Add roll 10s on skill dices? (y/N)?"
	read -r addroll
	if [ "${addroll}" != "y" ]
	then
		unset addroll
	fi
	}

function roll {
	# params: <number of dices>, <reroll boolean>
	local dice_count=1
	while [[ "${dice_count}" -le "${1}" ]]
       	do
		local r=$((RANDOM%10+1))
		local rolls="${rolls} ${r}"
		if [[ "${r}" -ge "${target_number}" ]]
		then
			successes=$((successes+1))
			if [ "${2}" ]
			then
				if [[ "${r}" -eq 10 ]]
				then
					rerolls=$((rerolls+1))
					local rr=$((RANDOM%10+1))
					local rolls="${rolls} (${rr})"
					if [[ "${rr}" -ge "${target_number}" ]]
					then
						successes=$((successes+1))
					fi
				fi
			fi
		elif [[ "${r}" -eq 1 ]]
		then
			botch=$((botch+1))
		fi
		dice_count=$((dice_count+1))
	done
	if [ "${wehavecolors}" ]
	then
		for die_roll in ${rolls}
		do
			if [[ "${die_roll}" -ge "${target_number}" ]]
			then
				printf "\e[1;49;32m%s\e[0m " "${die_roll}"
			elif [[ "${die_roll}" -eq 1 ]]
			then
				printf "\e[1;49;31m%s\e[0m " "${die_roll}"
			else
				printf "%s " "${die_roll}"
			fi
		done
		echo
	else 
		echo "${rolls}"
	fi
	}

echo "DICE ROLLER"
echo "for World of Darkness's RPGs"
echo

until [ "${rollitup}" ]
do
	successes=0
	botch=0
	rerolls=0
	number_of_dices
	skill
	attribute_dices=$((dices-skill_dices))
	if [[ "${attribute_dices}" -lt 0 ]]
	then
		echo "You can't have more skill then attribute dices!"
		skill
	fi
	target
	if [[ "${skill_dices}" -gt 0 ]]
	then
		addroll
	fi

	echo
	echo "Alea acta est!"
	echo
	printf "Attribute dices rolls: "
	roll "${attribute_dices}"
	if [[ "${skill_dices}" -gt 0 ]]
	then 
		printf "Skill dices rolls: "
		if [ "${addroll}" ]
		then
			roll "${skill_dices}" 1
		else
			roll "${skill_dices}"
		fi
	fi

	# ------------------------------ RESULT ------------------------------

	if [[ "${botch}" -gt "${successes}" ]]
	then
		echo
		printf "\e[1;49;31m !!! BOTCH !!! \e[0m "
		echo
		echo "You roll more crtical failures then successes."
	else 
		if [ -n "${botch}" ]
		then
			final_successes=$((successes-botch))
			echo "Substracted dies: ${botch}"
		else
			final_successes="${successes}"
		fi
		echo
		echo "Final number of successes: ${final_successes}"
	fi
	echo
	echo "Another roll? (Y/n)"
	read -r another_roll
	if [ -n "${another_roll}" ]
	then
		if [ "${another_roll}" != "y" ]
		then
			exit 0
		fi
	fi
done
