#!/bin/bash
#
# zabbix-mysql-backupconf.sh
# v0.4 - 20120302 Incorporated mysqldump options suggested by Jonathan Bayer
# v0.3 - 20120206 Backup of Zabbix 1.9.x / 2.0.0, removed unnecessary use of
#                 variables (DATEBIN etc) for commands that use to be in $PATH
# v0.2 - 20111105
#
# Configuration Backup for Zabbix 2.0 w/MySQL
#
# Author: Ricardo Santos (rsantos at gmail.com)
# http://zabbixzone.com
#
# modified by Jens Berthold, 2012
#
# Thanks for suggestions from:
# - Oleksiy Zagorskyi (zalex)
# - Petr Jendrejovsky
# - Jonathan Bayer
#

# mysql config
DBHOST="localhost"
DBNAME="zabbix"
DBUSER="zabbix"
DBPASS="YOURMYSQLPASSWORDHERE"

# target path
MAINDIR="/var/lib/zabbix/backupconf"
DUMPDIR="${MAINDIR}/`date +%Y%m%d-%H%M`"

mkdir -p "${DUMPDIR}"

# configuration tables
CONFTABLES=( actions applications autoreg_host conditions config dchecks \
dhosts drules dservices escalations expressions functions globalmacro \
globalvars graph_discovery graph_theme graphs graphs_items groups help_items \
host_inventory hostmacro hosts hosts_groups hosts_templates housekeeper \
httpstep httpstepitem httptest httptestitem icon_map icon_mapping ids images \
interface item_discovery items items_applications maintenances \
maintenances_groups maintenances_hosts maintenances_windows mappings media \
media_type node_cksum nodes opcommand opcommand_grp opcommand_hst opconditions \
operations opgroup opmessage opmessage_grp opmessage_usr optemplate profiles \
proxy_autoreg_host proxy_dhistory proxy_history regexps rights screens \
screens_items scripts service_alarms services services_links services_times \
sessions slides slideshows sysmap_element_url sysmap_url sysmaps \
sysmaps_elements sysmaps_link_triggers sysmaps_links timeperiods \
trigger_depends trigger_discovery triggers user_history users users_groups \
usrgrp valuemaps )

# tables with large data
DATATABLES=( acknowledges alerts auditlog_details auditlog events \
history history_log history_str history_str_sync history_sync history_text \
history_uint history_uint_sync trends trends_uint )

DUMPFILE="${DUMPDIR}/zbx-conf-bkup-`date +%Y%m%d-%H%M`.sql"


# CONFTABLES
for table in ${CONFTABLES[*]}; do
	echo "Backuping table ${table}"
	mysqldump -R --opt --single-transaction --skip-lock-tables --extended-insert=FALSE \
		-h ${DBHOST} -u ${DBUSER} -p${DBPASS} ${DBNAME} --tables ${table} >>"${DUMPFILE}"
done

# DATATABLES
for table in ${DATATABLES[*]}; do
	echo "Backuping schema table ${table}"
	mysqldump -R --opt --single-transaction --skip-lock-tables --no-data	\
		-h ${DBHOST} -u ${DBUSER} -p${DBPASS} ${DBNAME} --tables ${table} >>"${DUMPFILE}"
done

gzip -f "${DUMPFILE}"

echo
echo "Backup Completed - ${DUMPDIR}"
