# Top 150 Common Linux Commands

Linux企業運維人員最常用150個命令彙總，
由[貼文](http://blog.51cto.com/oldboy/1951107)轉載。

#### 線上查詢及幫助命令(2個)
| COMMAND | DESCRIPTION |
| ------ | ------ |
| man | 查看命令幫助，命令的詞典，更複雜的還有info，但不常用。 |
| help | 查看Linux內置命令的幫助，比如cd命令。 |
#### 文件和目錄操作命令(18個)
| COMMAND | DESCRIPTION |
| ------ | ------ |
| ls | 全拼list，功能是列出目錄的內容及其內容屬性信息。 |
| cd | 全拼change directory，功能是從當前工作目錄切換到指定的工作目錄。 |
| cp | 全拼copy，其功能為複製文件或目錄。 |
| find | 查找的意思，用於查找目錄及目錄下的文件。 |
| mkdir | 全拼make directories，其功能是創建目錄。 |
| mv | 全拼move，其功能是移動或重命名文件。 |
| pwd | 全拼print working directory，其功能是顯示當前工作目錄的絕對路徑。 |
| rename | 用於重命名文件。 |
| rm | 全拼remove，其功能是刪除一個或多個文件或目錄。 |
| rmdir | 全拼remove empty directories，功能是刪除空目錄。 |
| touch | 創建新的空文件，改變已有文件的時間戳屬性。 |
| tree | 功能是以樹形結構顯示目錄下的內容。 |
| basename | 顯示文件名或目錄名。 |
| dirname | 顯示文件或目錄路徑。 |
| chattr | 改變文件的擴展屬性。 |
| lsattr | 查看文件擴展屬性。 |
| file | 顯示文件的類型。 |
| md5sum | 計算和校驗文件的MD5值。 |
#### 查看文件及內容處理命令（21個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| cat | 全拼concatenate，功能是用於連接多個文件並且打印到屏幕輸出或重定向到指定文件中。 |
| tac | tac是cat的反向拼寫，因此命令的功能為反向顯示文件內容。 |
| more | 分頁顯示文件內容。 |
| less | 分頁顯示文件內容，more命令的相反用法。 |
| head | 顯示文件內容的頭部。 |
| tail | 顯示文件內容的尾部。 |
| cut | 將文件的每一行按指定分隔符分割並輸出。 |
| split | 分割文件為不同的小片段。 |
| paste | 按行合併文件內容。 |
| sort | 對文件的文本內容排序。 |
| uniq | 去除重複行。 |
| wc | 統計文件的行數、單詞數或字節數。 |
| iconv | 轉換文件的編碼格式。 |
| dos2unix | 將DOS格式文件轉換成UNIX格式。 |
| diff | 全拼difference，比較文件的差異，常用於文本文件。 |
| vimdiff | 命令行可視化文件比較工具，常用於文本文件。 |
| rev | 反向輸出文件內容。 |
| grep/egrep | 過濾字符串，三劍客老三。 |
| join | 按兩個文件的相同字段合併。 |
| tr | 替換或刪除字符。 |
| vi/vim | 命令行文本編輯器。 |
#### 文件壓縮及解壓縮命令（4個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| tar | 打包壓縮。 |
| unzip | 解壓文件。 |
| gzip | gzip壓縮工具。 |
| zip | 壓縮工具。 |
#### 信息顯示命令（11個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| uname | 顯示操作系統相關信息的命令。 |
| hostname | 顯示或者設置當前系統的主機名。 |
| dmesg | 顯示開機信息，用於診斷系統故障。 |
| uptime | 顯示系統運行時間及負載。 |
| stat | 顯示文件或文件系統的狀態。 |
| du | 計算磁盤空間使用情況。 |
| df | 報告文件系統磁盤空間的使用情況。 |
| top | 實時顯示系統資源使用情況。 |
| free | 查看系統內存。 |
| date | 顯示與設置系統時間。 |
| cal | 查看日曆等時間信息。 |
#### 搜索文件命令（4個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| which | 查找二進制命令，按環境變量PATH路徑查找。 |
| find | 從磁盤遍歷查找文件或目錄。 |
| whereis | 查找二進制命令，按環境變量PATH路徑查找。 |
| locate | 從數據庫 (/var/lib/mlocate/mlocate.db) 查找命令，使用updatedb更新庫。 |
#### 用戶管理命令（10個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| useradd | 添加用戶。 |
| usermod | 修改系統已經存在的用戶屬性。 |
| userdel | 刪除用戶。 |
| groupadd | 添加用戶組。 |
| passwd | 修改用戶密碼。 |
| chage | 修改用戶密碼有效期限。 |
| id | 查看用戶的uid,gid及歸屬的用戶組。 |
| su | 切換用戶身份。 |
| visudo | 編輯/etc/sudoers文件的專屬命令。 |
| sudo | 以另外一個用戶身份（默認root用戶）執行事先在sudoers文件允許的命令。 |
#### 基礎網絡操作命令（11個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| telnet | 使用TELNET協議遠程登錄。 |
| ssh | 使用SSH加密協議遠程登錄。 |
| scp | 全拼secure copy，用於不同主機之間複製文件。 |
| wget | 命令行下載文件。 |
| ping | 測試主機之間網絡的連通性。 |
| route | 顯示和設置linux系統的路由表。 |
| ifconfig | 查看、配置、啟用或禁用網絡接口的命令。 |
| ifup | 啟動網卡。 |
| ifdown | 關閉網卡。 |
| netstat | 查看網絡狀態。 |
| ss | 查看網絡狀態。 |
#### 深入網絡操作命令（9個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| nmap | 網絡掃瞄命令。 |
| lsof | 全名list open files，也就是列舉系統中已經被打開的文件。 |
| mail | 發送和接收郵件。 |
| mutt | 郵件管理命令。 |
| nslookup | 交互式查詢互聯網DNS服務器的命令。 |
| dig | 查找DNS解析過程。 |
| host | 查詢DNS的命令。 |
| traceroute | 追蹤數據傳輸路由狀況。 |
| tcpdump | 命令行的抓包工具。 |
#### 有關磁盤與文件系統的命令（16個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| mount | 掛載文件系統。 |
| umount | 卸載文件系統。 |
| fsck | 檢查並修復Linux文件系統。 |
| dd | 轉換或複製文件。 |
| dumpe2fs | 導出ext2/ext3/ext4文件系統信息。 |
| dump | ext2/3/4文件系統備份工具。 |
| fdisk | 磁盤分區命令，適用於2TB以下磁盤分區。 |
| parted | 磁盤分區命令，沒有磁盤大小限制，常用於2TB以下磁盤分區。 |
| mkfs | 格式化創建Linux文件系統。 |
| partprobe | 更新內核的硬盤分區表信息。 |
| e2fsck | 檢查ext2/ext3/ext4類型文件系統。 |
| mkswap | 創建Linux交換分區。 |
| swapon | 啟用交換分區。 |
| swapoff | 關閉交換分區。 |
| sync | 將內存緩衝區內的數據寫入磁盤。 |
| resize2fs | 調整ext2/ext3/ext4文件系統大小。 |
#### 系統權限及用戶授權相關命令（4個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| chmod | 改變文件或目錄權限。 |
| chown | 改變文件或目錄的屬主和屬組。 |
| chgrp | 更改文件用戶組。 |
| umask | 顯示或設置權限掩碼。 |
#### 查看系統用戶登陸信息的命令（7個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| whoami | 顯示當前有效的用戶名稱，相當於執行id -un命令。 |
| who | 顯示目前登錄系統的用戶信息。 |
| w | 顯示已經登陸系統的用戶列表，並顯示用戶正在執行的指令。 |
| last | 顯示登入系統的用戶。 |
| lastlog | 顯示系統中所有用戶最近一次登錄信息。 |
| users | 顯示當前登錄系統的所有用戶的用戶列表。 |
| finger | 查找並顯示用戶信息。 |
#### 內置命令及其它（19個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| echo | 打印變量，或直接輸出指定的字符串。 |
| printf | 將結果格式化輸出到標準輸出。 |
| rpm | 管理rpm包的命令。 |
| yum | 自動化簡單化地管理rpm包的命令。 |
| watch | 週期性的執行給定的命令，並將命令的輸出以全屏方式顯示。 |
| alias | 設置系統別名。 |
| unalias | 取消系統別名。 |
| date | 查看或設置系統時間。 |
| clear | 清除屏幕，簡稱清屏。 |
| history | 查看命令執行的歷史紀錄。 |
| eject | 彈出光驅。 |
| time | 計算命令執行時間。 |
| nc | 功能強大的網絡工具。 |
| xargs | 將標準輸入轉換成命令行參數。 |
| exec | 調用並執行指令的命令。 |
| export | 設置或者顯示環境變量。 |
| unset | 刪除變量或函數。 |
| type | 用於判斷另外一個命令是否是內置命令。 |
| bc | 命令行科學計算器。 |
#### 系統管理與性能監視命令(9個)
| COMMAND | DESCRIPTION |
| ------ | ------ |
| chkconfig | 管理Linux系統開機啟動項。 |
| vmstat | 虛擬內存統計。 |
| mpstat | 顯示各個可用CPU的狀態統計。 |
| iostat | 統計系統IO。 |
| sar | 全面地獲取系統的CPU、運行隊列、磁盤 I/O、分頁（交換區）、內存、 CPU中斷和網絡等性能數據。 |
| ipcs | 用於報告Linux中進程間通信設施的狀態，顯示的信息包括消息列表、共享內存和信號量的信息。 |
| ipcrm | 用來刪除一個或更多的消息隊列、信號量集或者共享內存標識。 |
| strace | 用於診斷、調試Linux用戶空間跟蹤器。我們用它來監控用戶空間進程和內核的交互，比如系統調用、信號傳遞、進程狀態變更等。 |
| ltrace | 命令會跟蹤進程的庫函數調用,它會顯現出哪個庫函數被調用。 |
#### 關機/重啟/註銷和查看系統信息的命令（6個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| shutdown | 關機。 |
| halt | 關機。 |
| poweroff | 關閉電源。 |
| logout | 退出當前登錄的Shell。 |
| exit | 退出當前登錄的Shell。 |
| Ctrl+d | 退出當前登錄的Shell的快捷鍵。 |
#### 進程管理相關命令（15個）
| COMMAND | DESCRIPTION |
| ------ | ------ |
| bg | 將一個在後台暫停的命令，變成繼續執行  （在後台執行）。 |
| fg | 將後台中的命令調至前台繼續運行。 |
| jobs | 查看當前有多少在後台運行的命令。 |
| kill | 終止進程。 |
| killall | 通過進程名終止進程。 |
| pkill | 通過進程名終止進程。 |
| crontab | 定時任務命令。 |
| ps | 顯示進程的快照。 |
| pstree | 樹形顯示進程。 |
| nice/renice | 調整程序運行的優先級。 |
| nohup | 忽略掛起信號運行指定的命令。 |
| pgrep | 查找匹配條件的進程。 |
| runlevel | 查看系統當前運行級別。 |
| init | 切換運行級別。 |
| service | 啟動、停止、重新啟動和關閉系統服務，還可以顯示所有系統服務的當前狀態。 |
