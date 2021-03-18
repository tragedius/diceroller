#!/bin/bash
# Dice roller for World of Darkness's RPGs

DEFAULT_DICES=10
DEFAULT_TARGET_NUMBER=6
DEFAULT_SKILL_DICES=0
set ROLLITUP
unset ADDROLL

if [[ `tput colors` -gt 7 ]]
then
      WEHAVECOLORS=1
fi

function number_of_dices {
	echo "Enter total number of dices (${DEFAULT_DICES}):"
	read DICES
	if [ -z ${DICES} ]
	then
		DICES=${DEFAULT_DICES}
	else
		if [[ ${DICES} -lt 1 ]]
		then
			echo "If I don't have any die, how you expect I will roll?"
			number_of_dices
		fi

	fi
	}

function skill {
	echo "skill dices of it (${DEFAULT_SKILL_DICES})"
	read SKILL_DICES
	if [ -z ${SKILL_DICES} ]
	then
		SKILL_DICES=${DEFAULT_SKILL_DICES}
	fi
	}	

function target {
	echo "Enter target number (${DEFAULT_TARGET_NUMBER})"
	read TARGET_NUMBER
	if [ -z ${TARGET_NUMBER} ]
	then
		TARGET_NUMBER=${DEFAULT_TARGET_NUMBER}
	fi
	}

function addroll {
	echo "Add roll 10s on skill dices? (y/N)?"
	read ADDROLL
	if [ "${ADDROLL}" != "y" ]
	then
		unset ADDROLL
	fi
	}

function roll {
	# params: <number of dices>, <reroll boolean>
	local dice_count=1
	while [[ $dice_count -le ${1} ]]
       	do
		local R=$(($RANDOM%10+1))
		local ROLLS="${ROLLS} ${R}"
		if [[ ${R} -ge ${TARGET_NUMBER} ]]
		then
			SUCCESSES=$((${SUCCESSES}+1))
			if [ $2 ]
			then
				if [[ ${R} -eq 10 ]]
				then
					REROLLS=$((${REROLLS}+1))
					local RR=$(($RANDOM%10+1))
					local ROLLS="${ROLLS} (${RR})"
					if [[ $RR -ge $TARGET_NUMBER ]]
					then
						SUCCESSES=$(($SUCCESSES+1))
					fi
				fi
			fi
		elif [[ ${R} -eq 1 ]]
		then
			BOTCH=$((${BOTCH}+1))
		fi
		dice_count=$(($dice_count+1))
	done
	if [ $WEHAVECOLORS ]
	then
		for dice_roll in $ROLLS
		do
			if [[ $dice_roll -ge $TARGET_NUMBER ]]
			then
				printf "\e[1;49;32m$dice_roll\e[0m "
			elif [[ $dice_roll -eq 1 ]]
			then
				printf "\e[1;49;31m$dice_roll\e[0m "
			else
				printf "$dice_roll "
			fi
		done
		echo
	else 
		echo $ROLLS
	fi
	}

echo "DICE ROLLER"
echo "for World of Darkness's RPGs"
echo

until [ $ROLLITUP ]
do
	SUCCESSES=0
	BOTCH=0
	REROLLS=0
	number_of_dices
	skill
	ATTRIBUTE_DICES=$((${DICES}-${SKILL_DICES}))
	if [[ ${ATTRIBUTE_DICES} -lt 0 ]]
	then
		echo "You can't have more skill then attribute dices!"
		skill
	fi
	target
	if [[ ${SKILL_DICES} -gt 0 ]]
	then
		addroll
	fi

	echo
	echo "Alea acta est!"
	echo
	printf "Attribute dices rolls: "
	roll ${ATTRIBUTE_DICES}
	if [[ ${SKILL_DICES} -gt 0 ]]
	then 
		printf "Skill dices rolls: "
		if [ ${ADDROLL} ]
		then
			roll ${SKILL_DICES} 1
		else
			roll ${SKILL_DICES}
		fi
	fi

	# ------------------------------ RESULT ------------------------------

	if [[ ${BOTCH} -gt ${SUCCESSES} ]]
	then
		echo
		echo "!!! BOTCH !!!"
		echo "Your roll have more crtical failures then successes"
	else 
		if [ -n "$BOTCH" ]
		then
			FINAL_SUCCESSES=$((${SUCCESSES}-${BOTCH}))
			echo "Substracted dies: ${BOTCH}"
		else
			FINAL_SUCCESSES="$SUCCESSES"
		fi
		echo
		echo "Final number of successes: ${FINAL_SUCCESSES}"
	fi
	echo
	echo "Another roll? (Y/n)"
	read ANOTHER_ROLL
	if [ -n "${ANOTHER_ROLL}" ]
	then
		if [ ${ANOTHER_ROLL} != "y" ]
		then
			exit 0
		fi
	fi
done
