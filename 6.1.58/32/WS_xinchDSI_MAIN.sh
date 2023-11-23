#Set up the script to run the interpreter
#!/bin/bash

SCREEN_TYPE_ALL=(
	"28"                                            		#"2_8INCH"
	"40"                                              		#"4INCH"
	"70C"                                              		#"7INCH"
	"RESERVE1"       										#"10_1INCH_8INCH_LVDS_1280X720_ICN6211_SSD2828"
	"RESERVE2"                              				#"10_1INCH_LVDS_1280X800"
	"79"													#"7_9_INCH"
	"119"													#"11_9_INCH"
	"RESERVE3"               								#"10_1INCH_8INCH_LVDS_1280X720_ICN6202"
	
#Note: The 80C and 101C drivers are the same and will be handled in the script below
	"80C"                       							#"10_1INCH_8INCH_MIPI_1280X800"

	"34C"						         				#"3_4INCH_MIPI_800X800"						
	"40C"							     				#"4INCH_MIPI_720X720"							
	"RESERVE6"	                             				#"2_8INCH_MIPI_480X480"	
)

I2C_TYPE_ALL=(
	"I2C0" 
	"I2C1"
)

Type_print(){
	echo "    SCREEN_TYPE: ${SCREEN_TYPE_ALL[@]} 101C" 
	echo "    I2C_TYPE:    ${I2C_TYPE_ALL[@]} "
}

if [ $# -ne 2 ]; then
	echo "The script runs with two parameters in the following format"
	Type_print
	echo "example:  "
	echo "    sudo $0 SCREEN_TYPE I2C_TYPE"
	exit 1
fi


#----------------------------------------Set up to use that screen driver START----------------------------------------

SCREEN_TYPE=${SCREEN_TYPE_ALL[@]} 
#echo This driver supports SCREEN_TYPE is ${SCREEN_TYPE[@]} 


SCREEN_TYPE_SIZE=${#SCREEN_TYPE[*]}
#echo This driver supports SCREEN_TYPE num is $SCREEN_TYPE_SIZE


#Find if the parameters match the DSI SCREEN_TYPE
SCREEN_TYPE_PARAM="$1"


SCREEN_TYPE_i=0
SCREEN_TYPE_INDEX=255
INDEX_80C=0
for i in ${SCREEN_TYPE[@]} 
do  
	if [ "$SCREEN_TYPE_PARAM" = "$i" ];then
		SCREEN_TYPE_INDEX=$SCREEN_TYPE_i
#		echo "Correctly matched to the SCREEN_TYPE list $SCREEN_TYPE_INDEX"
	fi

	if [ "80C" = "$i" ];then
		INDEX_80C=$SCREEN_TYPE_i
	fi

	if [ "$SCREEN_TYPE_PARAM" = "101C" ];then
		SCREEN_TYPE_INDEX=$INDEX_80C
	fi

	let SCREEN_TYPE_i++
done  

if [ $SCREEN_TYPE_INDEX -eq 255 ]; then
	printf "The parameter is not found in the SCREEN_TYPE list. Check whether the parameter is correct  \n"
	echo "    SCREEN_TYPE: ${SCREEN_TYPE_ALL[@]} "
	exit 1
fi

DRIVE_PARAM1="SCREEN_type=$SCREEN_TYPE_INDEX"
#echo DRIVE_PARAM1=$DRIVE_PARAM1
#-----------------------------------------Set up to use that screen driver END-----------------------------------------



#-------------------------------------------Set up to use that I2C bus START-------------------------------------------

I2C_TYPE=${I2C_TYPE_ALL[@]} 
#echo This driver supports I2C_TYPE is ${I2C_TYPE[@]} 


I2C_TYPE_SIZE=${#I2C_TYPE[*]}
#echo This driver supports I2C_TYPE num is $I2C_TYPE_SIZE


#Find if the parameters match the DSI I2C_TYPE
I2C_TYPE_PARAM="$2"


I2C_TYPE_i=0
I2C_TYPE_INDEX=255
for i in ${I2C_TYPE[@]} 
do  
	if [ "$I2C_TYPE_PARAM" = "$i" ];then
		I2C_TYPE_INDEX=$I2C_TYPE_i
#		echo "Correctly matched to the I2C_TYPE list $I2C_TYPE_INDEX"
	fi
	let I2C_TYPE_i++
done  

if [ $I2C_TYPE_INDEX -eq 255 ]; then
	printf "The parameter is not found in the I2C_TYPE list. Check whether the parameter is correct  \n"
	echo "    I2C_TYPE:    ${I2C_TYPE_ALL[@]} "
	exit 1
fi

if [ $I2C_TYPE_INDEX -eq 0 ]; then
	I2C_TYPE_INDEX=10
fi
if [ $I2C_TYPE_INDEX -eq 1 ]; then
	I2C_TYPE_INDEX=1
fi
DRIVE_PARAM2="I2C_bus=$I2C_TYPE_INDEX"
#echo DRIVE_PARAM2=$DRIVE_PARAM2
echo $DRIVE_PARAM1,$DRIVE_PARAM2
#--------------------------------------------Set up to use that I2C bus END--------------------------------------------


Hardware_PATH="/proc/device-tree/model"
Hardware_Message(){

	if grep -q "Raspberry Pi 4" $Hardware_PATH ; then
		ret=1
	elif grep -q "Raspberry Pi Compute Module 4" $Hardware_PATH ; then
		ret=2
	elif grep -q "Raspberry Pi 3" $Hardware_PATH ; then
		ret=3
	elif grep -q "Raspberry Pi Compute Module 3" $Hardware_PATH ; then
		ret=4
	else
		ret=255
	fi
	
	echo ${ret}
}
 

Hardware_Message_Value=`Hardware_Message`


if [ $Hardware_Message_Value -eq 1 ]; then
	printf "The raspberry PI hardware platform is pi4\n"
	cd ./pi4
elif [ $Hardware_Message_Value -eq 2 ]; then
	printf "The raspberry PI hardware platform is CM4\n"
	cd ./pi4
elif [ $Hardware_Message_Value -eq 3 ]; then
	printf "The raspberry PI hardware platform is pi3\n"
	cd ./pi3
elif [ $Hardware_Message_Value -eq 4 ]; then
	printf "The raspberry PI hardware platform is CM3\n"
	cd ./pi3
else
	printf "The raspberry PI hardware platform is not supported\n"
fi

if [ $Hardware_Message_Value -ne 255 ]; then
	sudo chmod 777 WS_xinchDSI.sh
	sudo ./WS_xinchDSI.sh $DRIVE_PARAM1 $DRIVE_PARAM2
fi

 

