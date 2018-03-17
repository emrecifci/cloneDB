#!/bin/bash
#############################################
# written by Runitas Technologies           #
# incase of a failure please contact with   #
#      info@runitas.com                     #
#############################################

if [ $# -lt 1 ]
then
echo "usage: $0 clone.conf";
exit 1
fi

echo "############################################"
echo "PLEASE DO NOT HIT THE ENTER BUTTON!...."
echo "############################################"
# Getting cloneDB variables from configuration file. 
source $1;  
##### Including function scripts ############
source ${SCRIPT_PATH}/RT_functions.lib
mkdir -p  ${SCRIPT_PATH}/clone_files

set_env
now=$(date +%Y%m%d-%T)
export now
CONTROL_PMON=$(ps -ef | grep -v grep | grep ora_pmon_${ORACLE_SID} | wc -l) 
if [ "${CONTROL_PMON}" -gt 0 ] ; then
	read -p "There is an exisisting clone database on your system. Would you like to shut down the existing clone database?(y/n) " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
    then
    	echo "Clone Database is Shutting Down!..."
		run_sql "shutdown abort;"
	else
		printf " \nplease choose another ORACLE_SID or shutdown the clone database manually.\n"
		exit -1;
	fi
fi
echo "umounting clone shares";

CONTROL_STALE_MOUNT_POINTS=$(ps -ef | grep -v grep | grep Stale | wc -l)
if [ "${CONTROL_STALE_MOUNT_POINTS}" -gt 0 ] ; then
	echo "There some Stale NFS file handle in your system.  Please unmount them and re-run the script...."
	exit -1;
fi

clone_umount $CLONE_PATH
CONTROL_CLONE_PATH=$(ps -ef | grep -v grep | grep $CLONE_PATH | wc -l)
if [ "${CONTROL_CLONE_PATH}" -gt 0 ] ; then
	echo "$CLONE_PATH could not be unmounted. Please unmount them and re-run the script...."
	exit -1;
else
	echo "Shares are unmounted!..";
fi
	


echo "destroying ZFS clone projects";
if [ ${NUMBER_OF_CONTROLLER} -eq 1 ]
then
 
	CONTROL_DESTROY_CLONE=$(destroy_clone root@${ZFS_IP_ADDRESS_1} ${POOL_NAME_1} ${CLONE_PROJECT_NAME})
	if [ ${CONTROL_DESTROY_CLONE} -eq 1 ]
		echo "Specified pool does not exist. Please check the pool name!...";
		exit -1;
	elif [ ${CONTROL_DESTROY_CLONE} -eq 2 ]
		echo "Clone project destroyed";
	elif [ ${CONTROL_DESTROY_CLONE} -eq 3 ]
		echo "Clone project could not be destroyed. Please check the clone project name...";
		exit -1;
	fi
		
else
	CONTROL_DESTROY_CLONE1=$(destroy_clone root@${ZFS_IP_ADDRESS_1} ${POOL_NAME_1} ${CLONE_PROJECT_NAME})
	if [ ${CONTROL_DESTROY_CLONE1} -eq 1 ]
		echo "Specified pool does not exist. Please check the pool name!...";
		exit -1;
	elif [ ${CONTROL_DESTROY_CLONE1} -eq 2 ]
		echo "Clone project destroyed";
	elif [ ${CONTROL_DESTROY_CLONE1} -eq 3 ]
		echo "Clone project could not be destroyed. Please check the clone project name...";
		exit -1;
	fi
	CONTROL_DESTROY_CLONE2=$(destroy_clone root@${ZFS_IP_ADDRESS_2} ${POOL_NAME_2} ${CLONE_PROJECT_NAME})
	if [ ${CONTROL_DESTROY_CLONE2} -eq 1 ]
		echo "Specified pool does not exist. Please check the pool name!...";
		exit -1;
	elif [ ${CONTROL_DESTROY_CLONE2} -eq 2 ]
		echo "Clone project destroyed";
	elif [ ${CONTROL_DESTROY_CLONE2} -eq 3 ]
		echo "Clone project could not be destroyed. Please check the clone project name...";
		exit -1;
	fi
fi

echo "setting environment";
set_env 
if [ ${NUMBER_OF_CONTROLLER} -eq 1 ]
then
	print_snap root@${ZFS_IP_ADDRESS_1} ${POOL_NAME_1} ${BACKUP_PROJECT_NAME}
	echo "Please type snapName for backup project:"
	read snap
	CONTROL_CLONE_PROJECT=$(clone_shares root@${ZFS_IP_ADDRESS_1} ${POOL_NAME_1} ${BACKUP_PROJECT_NAME} $snap ${CLONE_PROJECT_NAME} ${NFS_EXCEPTION_IPV4})
	if [ ${CONTROL_CLONE_PROJECT} -eq 1 ]
		echo "Specified pool does not exist. Please check the pool name!...";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT} -eq 2 ]
		echo "Clone already exists - double-check you really want to do this and destroy the clone if appropriate.";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT} -eq 3 ]
		echo "Unable to create snapshot...";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT} -eq 4 ]
		echo "Error cloning shares in project";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT} -eq 5 ]
		echo "Cloning of project completed";
		exit -1;	
	fi
	
else
	print_snap root@${ZFS_IP_ADDRESS_1} ${POOL_NAME_1} ${BACKUP_PROJECT_NAME}
	echo "Please type snapName for backup project :"
	read snap
	CONTROL_CLONE_PROJECT1=$(clone_shares root@${ZFS_IP_ADDRESS_1} ${POOL_NAME_1} ${BACKUP_PROJECT_NAME} $snap ${CLONE_PROJECT_NAME} ${NFS_EXCEPTION_IPV4})
	if [ ${CONTROL_CLONE_PROJECT1} -eq 1 ]
		echo "Specified pool does not exist. Please check the pool name!...";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT1} -eq 2 ]
		echo "Clone already exists - double-check you really want to do this and destroy the clone if appropriate.";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT1} -eq 3 ]
		echo "Unable to create snapshot...";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT1} -eq 4 ]
		echo "Error cloning shares in project";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT1} -eq 5 ]
		echo "Cloning of project completed";
		exit -1;	
	fi
	CONTROL_CLONE_PROJECT1=$(clone_shares root@${ZFS_IP_ADDRESS_2} ${POOL_NAME_2} ${BACKUP_PROJECT_NAME} $snap ${CLONE_PROJECT_NAME} ${NFS_EXCEPTION_IPV4})
	if [ ${CONTROL_CLONE_PROJECT2} -eq 1 ]
		echo "Specified pool does not exist. Please check the pool name!...";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT2} -eq 2 ]
		echo "Clone already exists - double-check you really want to do this and destroy the clone if appropriate.";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT2} -eq 3 ]
		echo "Unable to create snapshot...";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT2} -eq 4 ]
		echo "Error cloning shares in project";
		exit -1;
	elif [ ${CONTROL_CLONE_PROJECT2} -eq 5 ]
		echo "Cloning of project completed";
		exit -1;	
	fi
	
	
fi


echo "mounting clone shares"
if [ ${NUMBER_OF_CONTROLLER} -eq 1 ]
then
	clone_mount ${CLONE_PATH} ${ZFS_IP_ADDRESS_1} ${ZFS_IP_ADDRESS_1} ${CLONE_PROJECT_NAME}
	CONTROL_CLONE_PATH1=$(ps -ef | grep -v grep | grep $CLONE_PATH | wc -l)
	if [ "${CONTROL_CLONE_PATH1}" -gt 0 ] ; then
		echo "Shares are mounted..."
	else
		echo "Shares are could not be mounted. Please check the system...";
		exit -1;
	fi

else
	clone_mount ${CLONE_PATH} ${ZFS_IP_ADDRESS_1} ${ZFS_IP_ADDRESS_2} ${CLONE_PROJECT_NAME}
	CONTROL_CLONE_PATH1=$(ps -ef | grep -v grep | grep $CLONE_PATH | wc -l)
	if [ "${CONTROL_CLONE_PATH1}" -gt 0 ] ; then
		echo "Shares are mounted..."
	else
		echo "Shares are could not be mounted. Please check the system...";
		exit -1;
	fi

fi


sudo chown -R oracle:oinstall ${CLONE_PATH}
echo "Dublicated files are cleaning..";
clear_dublicated_files
echo "Dublicated files are cleared.";
create_controlfile_script
CONTROL_CREATE_CONTROLFILE_SCRIPT=$(ls ${SCRIPT_PATH}/clone_files/${CLONE_DB_SID}createcf.sql| wc -l)
if [ "${CONTROL_CREATE_CONTROLFILE_SCRIPT}" -gt 0 ] ; then
	echo "${CONTROL_CREATE_CONTROLFILE_SCRIPT} created"
else
	echo "${CONTROL_CREATE_CONTROLFILE_SCRIPT} could not be created. Please check the file...";
	exit -1;
fi

create_pfile

CONTROL_PFILE=$(ls ${ORACLE_HOME}/dbs/init${CLONE_DB_SID}.ora| wc -l)
if [ "${CONTROL_PFILE}" -gt 0 ] ; then
	echo "${CONTROL_PFILE} created"
else
	echo "${CONTROL_PFILE} could not be created. Please check the file...";
	exit -1;
fi
run_sql "@${SCRIPT_PATH}/clone_files/${CLONE_DB_SID}createcf.sql"

echo "This script will recover the clone database until the minumum scn that all the datafiles are consistent. If you specify a date, script will recover databse to desired date.";
read -p "Would you like to recover database to a specific date?(y/n) "
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
echo "Please type the date with following date format: ( yyyy-mm-dd:hh24:mi:ss )"
    read TARGET_DATE;
    
    CONTROL_TARGET_DATE="1";
	while [ ${CONTROL_TARGET_DATE} -eq 1 ]
	do
		if [[ $TARGET_DATE =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]
		then
			CONTROL_TARGET_DATE="0";
    	echo "OK";
		else
			echo "Please type the date with following date format: ( yyyy-mm-dd:hh24:mi:ss )"
    		read TARGET_DATE;
		fi
	done

    print_snap root@${ZFS_IP_ADDRESS_2} ${POOL_NAME_2} ${BACKUP_PROJECT_NAME}
    echo "Please copy and paste the next snapshot name:"
    read snap
    clone_next_day_arch root@${ZFS_IP_ADDRESS_1} ${POOL_NAME_1} ${BACKUP_PROJECT_NAME} $snap ${CLONE_PROJECT_NAME} ${ARCH1_PATH}
    clone_next_day_arch root@${ZFS_IP_ADDRESS_2} ${POOL_NAME_2} ${BACKUP_PROJECT_NAME} $snap ${CLONE_PROJECT_NAME} ${ARCH2_PATH}
    mkdir -p ${CLONE_PATH}/${ARCH1_PATH}_next
    mkdir -p ${CLONE_PATH}/${ARCH2_PATH}_next
    sudo mount -t nfs -o rw,bg,hard,rsize=1048576,wsize=1048576,vers=3,nointr,timeo=600,tcp,actimeo=0 ${ZFS_IP_ADDRESS_1}:/export/${CLONE_PROJECT_NAME}/${ARCH1_PATH}_next ${CLONE_PATH}/${ARCH1_PATH}_next
    sudo mount -t nfs -o rw,bg,hard,rsize=1048576,wsize=1048576,vers=3,nointr,timeo=600,tcp,actimeo=0 ${ZFS_IP_ADDRESS_2}:/export/${CLONE_PROJECT_NAME}/${ARCH2_PATH}_next ${CLONE_PATH}/${ARCH2_PATH}_next
    rman target /<<EOF
    catalog start with '${CLONE_PATH}/${ARCH1_PATH}_next/arch' noprompt;
    catalog start with '${CLONE_PATH}/${ARCH2_PATH}_next/arch' noprompt;
EOF
	rman target / log ${SCRIPT_PATH}/clone_files/${ORACLE_SID}_${now}recover.log<<EOF
    	run {
			allocate channel ch01 device type disk;
            allocate channel ch02 device type disk;
            allocate channel ch03 device type disk;
            allocate channel ch04 device type disk;
            allocate channel ch05 device type disk;
            allocate channel ch06 device type disk;
            allocate channel ch07 device type disk;
            allocate channel ch08 device type disk;
            allocate channel ch09 device type disk;
            allocate channel ch10 device type disk;
            allocate channel ch11 device type disk;
            allocate channel ch12 device type disk;
            allocate channel ch13 device type disk;
            allocate channel ch14 device type disk;
            allocate channel ch15 device type disk;
            allocate channel ch16 device type disk;
            set until time "to_date('${TARGET_DATE}', 'yyyy-mm-dd:hh24:mi:ss')";
            recover database;
            alter database open resetlogs;
        }
EOF

else
	rman target /<<EOF
		catalog start with '\${CLONE_PATH}/${ARCH1_PATH}/' noprompt;
		catalog start with '\${CLONE_PATH}/${ARCH2_PATH}/' noprompt;
EOF

# Getting maximum abbsoulte system change number for fuzzy datafiles. 
	max_abbs_scn=$( run_sql "SELECT to_char(MAX(FHAFS),9999999999999999999) FROM x\$kcvfh;" )
	if [ "$max_abbs_scn" = 0 ]; then
		rman target / log ${SCRIPT_PATH}/clone_files/${ORACLE_SID}_${now}recover.log <<EOF
	    run {
	    	recover database;
	    }
EOF
	else
		rman target / log ${SCRIPT_PATH}/clone_files/${ORACLE_SID}_${now}recover.log <<EOF
       		run {
       		   	allocate channel ch01 device type disk;
       		   	allocate channel ch02 device type disk;
       		   	allocate channel ch03 device type disk;
       		   	allocate channel ch04 device type disk;
       		   	allocate channel ch05 device type disk;
       		   	allocate channel ch06 device type disk;
       		  	allocate channel ch07 device type disk;
       		  	allocate channel ch08 device type disk;
       		   	allocate channel ch09 device type disk;
       		   	allocate channel ch10 device type disk;
       		   	allocate channel ch11 device type disk;
       		   	allocate channel ch12 device type disk;
       		  	allocate channel ch13 device type disk;
       		  	allocate channel ch14 device type disk;
       		   	allocate channel ch15 device type disk;
       		   	allocate channel ch16 device type disk;
       		   	set until scn $max_abbs_scn;
				recover database;
				}
EOF
		rman target / log ${SCRIPT_PATH}/clone_files/${ORACLE_SID}_${now}recover.log <<EOF
			run {
				alter database open resetlogs;
			}
EOF
	fi
	db_open_mode=$( run_sql " select open_mode from v\$database;" )
	if [ "$db_open_mode" == "MOUNTED" ]; then
		max_consistent_scn=$( run_sql " select to_char(next_change#) from v\$archived_log where first_time=(select max(first_time) from v\$archived_log where name like '/zfssa%'); " )
		rman target / log ${SCRIPT_PATH}/clone_files/${ORACLE_SID}_${now}recover.log <<EOF
			run {
				allocate channel ch01 device type disk;
				allocate channel ch02 device type disk;
				allocate channel ch03 device type disk;
				allocate channel ch04 device type disk;
				allocate channel ch05 device type disk;
				allocate channel ch06 device type disk;
				allocate channel ch07 device type disk;
				allocate channel ch08 device type disk;
				allocate channel ch09 device type disk;
				allocate channel ch10 device type disk;
				allocate channel ch11 device type disk;
				allocate channel ch12 device type disk;
				allocate channel ch13 device type disk;
				allocate channel ch14 device type disk;
				allocate channel ch15 device type disk;
				allocate channel ch16 device type disk;
				set until scn $max_consistent_scn;
				recover database;
				alter database open resetlogs;
            }
EOF
	fi
fi


#################Altering database to ARCHIVELOGMODE ##################
run_sql "shutdown immediate;"
run_sql "startup mount;"
run_sql "alter database archivelog;"
run_sql "alter database open;"

db_open_mode1=$( run_sql " select open_mode from v\$database; ")
echo ${db_open_mode1};
