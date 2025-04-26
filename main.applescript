--------------------------------------------------------------------------
--          Migrator: backup/restore applications with their settings
--          Autor: Dmitry Chushkin
--          Version: 2.5.5
--          Released under GNU Public License (GPL)
--          https://github.com/telenkor/migrator
--          dev@36pix.ru
--------------------------------------------------------------------------

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
use script "Myriad Tables Lib" version "1.0.13"

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- 					   	Functions
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- 					Function to sort list rows
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
to qsort(array, leftEnd, rightEnd) -- Hoare's QuickSort Algorithm
	script A
		property L : array
	end script
	set {i, j} to {leftEnd, rightEnd}
	set v to item ((leftEnd + rightEnd) div 2) of A's L -- pivot in the middle
	repeat while (j > i)
		repeat while (item i of A's L < v)
			set i to i + 1
		end repeat
		repeat while (item j of A's L > v)
			set j to j - 1
		end repeat
		if (not i > j) then
			tell (a reference to A's L) to set {item i, item j} to {item j, item i} -- swap
			set {i, j} to {i + 1, j - 1}
		end if
	end repeat
	if (leftEnd < j) then qsort(A's L, leftEnd, j)
	if (rightEnd > i) then qsort(A's L, i, rightEnd)
end qsort

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- 						Adaptive path short
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Remove /Volumes, 25 first and 24 last symbols
to pathShort(ln)
	set my text item delimiters to "/Volumes/"
	set split_list to every text item of ln
	set my text item delimiters to "/"
	set ln to split_list as string
	set my text item delimiters to ""
	
	if (length of ln) ≤ 49 then
		set shortLn to ln as string
	else
		set lnLen to length of ln
		set head to items 25 thru 1 of ln as string
		set tail to items (lnLen - 24) thru -1 of ln as string
		set shortLn to head & "..." & tail
	end if
	return shortLn
end pathShort


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- 					  		 	Main
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

set config_Location to (do shell script "dirname " & quoted form of (POSIX path of (path to me))) & "/config.plist"
set list_app_Name to {} -- list with applications names
set list_config_Paths to {} -- list with paths from config.plist
set signature_Comment to "Migrator backup" -- comment for backup directories

-- Language auto selection
if (user locale of (system info)) = "ru_RU" then
	
	-- По-русски
	set msg_task_qwe to "Сохранить бэкап или установить из него?"
	set msg_task_btn_bck to "Сохранить"
	set msg_task_btn_inst to "Установить"
	
	set msg_btn_cancel to "Отменить"
	
	set msg_alert to "Продолжение невозможно"
	set msg_warn to "Осторожно!"
	set msg_config_alert to "Файл конфигурации config.plist не найден."
	set msg_files_alert to "Бэкапы, созданные в Migrator, не найдены."
	set msg_files_exist to "Приложение может переписать имеющиеся данные."
	set msg_files_noexist to "Данный исходный файл не был найден:"
	set msg_files_nosyst to "Программа работает только с системным диском." & return & "Пути /Volumes/... не обрабатываются."
	
	set msg_dst_dir_qwe to "Куда сохраняем бэкап?"
	
	set msg_ch_bck to "Бэкап приложений"
	set msg_btn_go to "Продолжить"
	
	set msg_prog_desc_bck to "Сохранение приложений и настроек..."
	set msg_prog_add_desc to "Подготовка к копированию"
	set msg_prog_stat to "Обработано приложений: "
	set msg_prog_stat_out to " из "
	set msg_prog_stat_inwk to "В работе: "
	
	set msg_src_dir_qwe to "Откуда берем бэкап?"
	
	set msg_ch_inst to "Установка приложений"
	set msg_ch_inst_application to "Приложение"
	set msg_ch_inst_version to "Версия"
	set msg_ch_inst_mod_date to "Дата бэкапа"
	
	set msg_prog_desc_inst to "Установка приложений и настроек..."
	set msg_prog_desc_exit to "Работа завершена"
	
	set msg_disp_notif_bck to "Расположение файлов: "
	set msg_disp_title_bck to "Бэкап успешно сохранен"
	
	set msg_disp_notif_inst to "Расположение исходных файлов: "
	set msg_disp_title_inst to "Приложения успешно установлены"
	
else
	
	-- In English
	set msg_task_qwe to "Backup Applications or install them?"
	set msg_task_btn_bck to "Save"
	set msg_task_btn_inst to "Install"
	
	set msg_btn_cancel to "Cancel"
	
	set msg_alert to "Can't continue"
	set msg_warn to "Caution!"
	set msg_config_alert to "The configuration file config.plist not found."
	set msg_files_alert to "Backups created in Migrator not found."
	set msg_files_exist to "Application can overwrite existing data."
	set msg_files_noexist to "This source file was not found:"
	set msg_files_nosyst to "The program works only with the system drive." & return & "Paths /Volumes/... are not processed."
	
	set msg_dst_dir_qwe to "Where do save the backup?"
	
	set msg_ch_bck to "Backup those Applications:"
	set msg_btn_go to "Continue"
	
	set msg_prog_desc_bck to "Backuping Apps and Settings..."
	set msg_prog_add_desc to "Preparing to copy"
	set msg_prog_stat to "Apps processed: "
	set msg_prog_stat_out to " out of "
	set msg_prog_stat_inwk to "Work in progress: "
	
	set msg_src_dir_qwe to "Where do get the backup?"
	
	set msg_ch_inst to "Install those Applications:"
	set msg_ch_inst_application to "Application"
	set msg_ch_inst_version to "Version"
	set msg_ch_inst_mod_date to "Backup date"
	
	set msg_prog_desc_inst to "Installing Apps and Settings..."
	set msg_prog_desc_exit to "Job completed"
	
	set msg_disp_notif_bck to "File locations: "
	set msg_disp_title_bck to "Backup successfully saved"
	
	set msg_disp_notif_inst to "Location of source files: "
	set msg_disp_title_inst to "Apps successfully installed"
	
end if

-- Task selector
display dialog return & msg_task_qwe & return with icon alias ((path to me) & "Contents:Resources:icon.icns" as string) buttons {msg_task_btn_bck, msg_task_btn_inst, msg_btn_cancel} ¬
	default button 1 cancel button 3 with title "Migrator"
set answer to button returned of the result

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- 					  	 Backup Task
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

if answer is msg_task_btn_bck then
	
	-- Checking the location of the configuration file next to the application
	try
		POSIX file config_Location as alias
	on error
		display alert msg_alert message msg_config_alert as critical buttons {msg_btn_cancel} default button msg_btn_cancel giving up after 10
		tell me to quit
	end try
	
	-- Set destination directory
	set destination_Location to POSIX path of (choose folder with prompt msg_dst_dir_qwe)
	
	-- Prepare GUI list: only for applications names
	tell application "System Events"
		set the plist_File to property list file config_Location
		set item_Nodes to property list items of plist_File
		
		-- Get list of all application names
		repeat with i from 1 to number of items in item_Nodes
			
			-- Get application name and ignore with an asterisk in their name
			if name of item i of item_Nodes contains "*" then
			else
				set app_Name to name of item i of item_Nodes
				copy app_Name to the end of the list_app_Name
			end if
		end repeat
	end tell
	
	-- Sort the lines with the GUI list of programs alphabetically
	qsort(list_app_Name, 1, (length of list_app_Name))
	
	-- Choosing applications for backup
	set Table to make new table with data list_app_Name with title "Migrator" initially selected rows {1} column headings {} with prompt msg_ch_bck row template {text} with multiple selections allowed
	modify table Table grid style grid both dashed between rows OK button name msg_btn_go cancel button name msg_btn_cancel with alternate backgrounds
	set theResult to display table Table
	set app_Selected to values selected of theResult
	
	-- Legacy choosing applications for backup
	--set app_Selected to choose from list list_app_Name with title "Migrator" with prompt msg_ch_bck OK button name msg_btn_go cancel button name msg_btn_cancel default items {item 1 of lst_app_name} with multiple selections allowed
	--if app_Selected is false then return
	
	-- Count of selected applications
	set cnt to length of app_Selected
	
	-- Applications counter
	set f to -1
	
	delay 1
	-- Initialize progress-bar
	set progress total steps to cnt
	set progress completed steps to 0
	set progress description to msg_prog_desc_bck
	set progress additional description to return & msg_prog_add_desc & return
	delay 1
	
	-- Processing selected applications
	repeat with i from 1 to number of items in item_Nodes
		
		if f < 1 then set f to f + 1
		
		set app_Name to name of item i of item_Nodes
		
		if app_Selected contains app_Name then
			
			tell application "System Events"
				
				-- Get paths for each application
				set app_Value to value of item i of item_Nodes
				set list_config_Paths to app_Value as list
				
			end tell
			
			set progress additional description to ¬
				return & msg_prog_stat & f & msg_prog_stat_out & cnt & return & msg_prog_stat_inwk & app_Name
			
			-- Set new unique name for backup directory
			-- Scan destination directory for old backups
			set dest_Location_scan to paragraphs of (do shell script "find " & quoted form of destination_Location & " -mindepth 1 -maxdepth 1 -type d \\( ! -regex '.*/\\..*' \\)" & " | sed 's~//~/~g'") -- this sed remove double slash; \( ! -regex '.*/\..*' \) for exclude hidden objects
			repeat with i in dest_Location_scan
				if i contains app_Name then
					set app_Name to app_Name & space & "[" & (do shell script "date '+%Y.%m.%d.%H%M'") & "]"
					exit repeat
				end if
			end repeat
			
			-- Sync directories and backup
			repeat with i in list_config_Paths
				try
					do shell script "rsync -Rra " & quoted form of i & space & quoted form of (destination_Location & app_Name) & "/" with administrator privileges -- in case the file's permissions forbid even reading it
					-- If file or folder not found
				on error errMsg number errNum
					if errNum = 23 then
						display alert msg_alert message msg_files_noexist & return & i as critical buttons {msg_btn_cancel} default button msg_btn_cancel
						do shell script "rm -rf " & quoted form of (destination_Location & app_Name)
						tell me to quit
					end if
				end try
			end repeat
			
			-- Create a comment for each application main directory
			set HFS_main_Dir to POSIX file (destination_Location & app_Name)
			tell application "Finder"
				tell folder HFS_main_Dir
					set comment to signature_Comment
					set modification date to (current date)
				end tell
			end tell
			
			set f to f + 1
			
			set progress additional description to ¬
				return & msg_prog_stat & f & msg_prog_stat_out & cnt & return & msg_prog_stat_inwk & app_Name
			set progress completed steps to f
			
		end if
		
	end repeat
	
	
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	-- 					  		Install Task
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --	
	
else
	
	-- Set source directory
	set source_Location to POSIX path of (choose folder with prompt msg_src_dir_qwe)
	
	-- Scan source directory
	set source_Location_scan to paragraphs of (do shell script "find " & quoted form of source_Location & " -mindepth 1 -maxdepth 1 -type d \\( ! -regex '.*/\\..*' \\)" & " | sed 's~//~/~g'") -- this sed remove double slash; \( ! -regex '.*/\..*' \) for exclude hidden objects
	
	set list_Names to {}
	set list_VerApp to {}
	set list_ModDates to {}
	
	-- Get list of all application names
	repeat with i in source_Location_scan
		
		-- Check folder commentary
		set HFS_i to POSIX file i
		tell application "Finder"
			tell its item HFS_i
				if comment = signature_Comment then
					set {name:app_Name} to (info for i)
					-- Get application version
					try
						set list_DirApp to paragraphs of (do shell script "find " & quoted form of i & " -mindepth 1 -type d -iname \"*.app\"")
						-- Find the line with the shortest path and take it as the application path 
						set minLine to some item in list_DirApp
						repeat with j in list_DirApp
							set {name:name_J} to (info for j)
							if name_J contains app_Name then
								set minLine to j
								exit repeat
							else
								set lengthMin to (get length of ((do shell script "dirname " & quoted form of minLine) as string))
								set lengthLine to (get length of ((do shell script "dirname " & quoted form of j) as string))
								if lengthMin > lengthLine then set minLine to j's contents
							end if
						end repeat
						
						tell application "System Events"
							tell property list file (minLine & "/Contents/Info.plist")
								set ver_App to value of property list item "CFBundleShortVersionString" -- application version		
							end tell
						end tell
					on error errMsg
						set ver_App to "—"
					end try
					
					
					set {modification date:mod_Date} to (info for i)
					copy app_Name to the end of the list_Names
					copy ver_App to the end of the list_VerApp
					copy mod_Date to the end of the list_ModDates
				end if
			end tell
		end tell
		
	end repeat
	
	set list_app_Name to swap columns and rows in {list_Names, list_VerApp, list_ModDates}
	
	-- Check source directory
	if list_app_Name is {} then
		display alert msg_alert message msg_files_alert as critical buttons {msg_btn_cancel} default button msg_btn_cancel giving up after 10
		tell me to quit
	end if
	
	-- Warning that installation may overwrite existing files
	display alert msg_warn message msg_files_exist as critical buttons {msg_btn_cancel, msg_btn_go} default button msg_btn_go cancel button msg_btn_cancel
	
	-- Choosing applications for install
	set Table to make new table with data list_app_Name with title "Migrator" initially selected rows {1} column headings {msg_ch_inst_application, msg_ch_inst_version, msg_ch_inst_mod_date} with prompt msg_ch_inst row template {text, text, date} with multiple selections allowed
	modify table Table grid style grid both dashed between rows OK button name msg_btn_go cancel button name msg_btn_cancel with alternate backgrounds
	modify columns in table Table head alignment align center
	modify columns in table Table columns list {2, 3} entry alignment align center
	set theResult to display table Table
	set app_Selected to values selected of theResult
	
	-- Count of selected applications
	set cnt to length of app_Selected
	
	-- Applications counter
	set f to -1
	
	delay 1
	-- Initialize progress-bar
	set progress total steps to cnt
	set progress completed steps to 0
	set progress description to msg_prog_desc_inst
	set progress additional description to return & msg_prog_add_desc & return
	delay 1
	
	-- Processing selected applications
	repeat with i in source_Location_scan
		
		if f < 1 then set f to f + 1
		
		set {name:app_Name} to (info for i)
		if (app_Selected as text) contains app_Name then
			
			set progress additional description to ¬
				return & msg_prog_stat & f & msg_prog_stat_out & cnt & return & msg_prog_stat_inwk & app_Name
			
			set list_backup_Paths to paragraphs of (do shell script "find " & quoted form of i & " -mindepth 1 -maxdepth 1 -type d" & " ! -path " & "'" & "*/System Volume Information/*" & "'" & " ! -path " & "'" & "*/.*" & "'" & " ! -path " & "'" & "*/*RECYCLE.BIN/*" & "'" & " ; true")
			
			repeat with j in list_backup_Paths
				
				-- Source directory must start from the Root partition System drive, not /Volumes/...
				if (name of (info for j)) = "Volumes" then
					display alert msg_alert message msg_files_nosyst as critical buttons {msg_btn_cancel} default button msg_btn_cancel giving up after 10
					tell me to quit
					
					-- Get name current source directory
				else if (name of (info for j)) is not "Users" then
					do shell script "rsync -a " & quoted form of j & "/." & space & quoted form of ("/" & (name of (info for j))) with administrator privileges -- /. copy all content of current directory
				else
					set username_from_Path to (name of (info for (do shell script "find " & quoted form of j & " -mindepth 1 -maxdepth 1 -type d" & " ! -path " & "'" & "*/System Volume Information/*" & "'" & " ! -path " & "'" & "*/.*" & "'" & " ! -path " & "'" & "*/*RECYCLE.BIN/*" & "'" & " ; true")))
					
					-- Always assign current Username to destination directory
					do shell script "rsync -a " & quoted form of (j & "/" & username_from_Path) & "/." & space & quoted form of ("/" & (name of (info for j)) & "/" & (short user name of (system info))) with administrator privileges
					
				end if
				
			end repeat
			
			-- Reset list all files of application
			set list_backup_Paths to {}
			
			set f to f + 1
			
			set progress additional description to ¬
				return & msg_prog_stat & f & msg_prog_stat_out & cnt & return & msg_prog_stat_inwk & app_Name
			set progress completed steps to f
			
		end if
	end repeat
end if


#################################################
#							End of Program
#################################################

-- Reset progress-bar
set progress total steps to 0
set progress completed steps to 0
set progress description to msg_prog_desc_exit
set progress additional description to return & msg_prog_stat & cnt & return
delay 2

-- Create notifications
if answer is msg_task_btn_bck then
	display notification msg_disp_notif_bck & pathShort(destination_Location) with title msg_disp_title_bck subtitle msg_prog_stat & cnt
else
	display notification msg_disp_notif_inst & pathShort(source_Location) with title msg_disp_title_inst subtitle msg_prog_stat & cnt
end if
