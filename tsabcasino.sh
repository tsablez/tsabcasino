#!/bin/bash

cd tsabCasino ||  exit 1

USER_SET="Difficulty_${USE_NAME}.cfg"

main_game() {
	local UL=$1 #User Limit
	local UATT=$2 #User Attempts
	local UN=$3 #User name

	local KEY=$(( RANDOM % UL + 1 ))
	
	echo -e "\n ===/// tsabCasino ///=== \n"
	echo -e "\n Уровень: $UN. Попробуй отгадать число от 1 до $UL. У тебя $UATT попыток. Удачи! \n"
	
	for (( i=1; i<=UATT; i++ ))
	do
		read -e -p "Попытка $i из $UATT: => " UA
		
		if [[ $UA -eq $KEY ]]; then
			echo "Успех! Ты угадал число $KEY с $i-й попытки!"
			exit 0
		elif [[ $UA -lt $KEY ]]; then
			echo -e "Загаданное число ВЫШЕ. \n"
		else
			echo -e "Загаданное число НИЖЕ. \n"
		fi
	done
	
	echo -e "К сожалению, ты не смог угадать мое число. Ответ: $KEY"
	exit 0
}

while true; do
	echo -e "\n ===/// tsabCasino ///=== \n"
	echo "1. Легкий уровень"
	echo "2. Средный уровень"
	echo "3. Тяжелый уровень"

	if [[ -f "$USER_SET" ]]; then
		source "$USER_SET"
		echo "4. Своя сложность ($US_NAME) - [Лимит - $USL, попыток - $USA]"
	else
		echo "4. Своя сложность (Выбрать)"
	fi

	echo "5. Редактор сложностей"
	echo -e "6. Выход \n"
	read -e -p "Выбери пункт меню (1-6): " MC #Menu choice

	case $MC in
		1)
			main_game 10 5 "Легкий уровень"
			;;
		2)
			main_game 50 7 "Средний уровень"
			;;
		3)
			main_game 100 3 "Тяжелый уровень"
			;;
		4)
			shopt -s nullglob
			cfg_files=( Difficulty_*.cfg )
			shopt -u nullglob
			if [[ ${#cfg_files[@]} -eq 0 ]]; then
				echo -e "\nОшибка! Сохраненных сложностей не найдено.\n"
			else
				echo -e "\n ===/// Созданные сложности ///=== \n"

				for i in "${!cfg_files[@]}"; do
					full_name="${cfg_files[$i]}"
					display_name="${full_name#Difficulty_}"
					display_name="${display_name%.cfg}"
					echo "$((i+1)). $display_name"	
				done
				read -e -p "Выберите сложность: " file_choice

				if [[ "$file_choice" -gt 0 && "$file_choice" -le "${#cfg_files[@]}" ]]; then
					SELECTED_CFG="${cfg_files[$((file_choice-1))]}"
					source "$SELECTED_CFG"
					main_game $USL $USA "Пользовательский: $US_NAME"
				else
					echo -e "\nВыбран неверный уровень. \n"
				fi
			fi
			;;
		5)
			echo -e "\n /-/-/- Редактор своей сложности /-/-/- \n"
			read -e -p "Введите название сложности: " USE_NAME
			read -e -p "Введите максимальное число (лимит): " USEL
			read -e -p "Введите колиечство попыток: " USEA

			USER_SET="Difficulty_${USE_NAME}.cfg"

			echo "US_NAME=\"$USE_NAME\"" > "$USER_SET"
			echo "USL=$USEL" >> "$USER_SET"
			echo "USA=$USEA" >> "$USER_SET"

			echo -e "\nНастройки успешно сохранены в $USER_SET! \n"
			;;
		6)
			exit 0
			;;
		*)
			echo "Неверный выбор. Попробуйте еще раз."
			;;
	esac
done
