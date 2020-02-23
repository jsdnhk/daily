# Hacker Scripts

根據 *[真實故事](https://www.jitbit.com/alexblog/249-now-thats-what-i-call-a-hacker/)*  改編:

> xxx: 是這樣的，我們的構建工程師離職去了另外一家公司，這貨基本算是生活在終端裏。 你知道麼，這人熱愛Vim，用Dot作圖，甚至用MarkDown來寫維基帖子...，如果有什麼事情要花上他超過90秒，她一定會整個腳本來讓這件事變得“自動化”。

> xxx: 我們現在坐在他的工位上，看着他留下來的這些，呃，“遺產”？

> xxx: 我覺得你們會喜歡這些的

> xxx: [`smack-my-bitch-up.sh(拍老婆馬屁腳本)`](https://github.com/NARKOZ/hacker-scripts/blob/master/smack-my-bitch-up.sh) - 它會給他的老婆（很明顯是他老婆）發送一條“今晚要加班了”的短信，再自動從文本庫中隨機地選擇一條理由。這個腳本被設置爲定時觸發，而且只有在工作日晚9點以後，服務器上還有他登陸的SSH進程在運行時纔會執行。

> xxx: [`kumar-asshole.sh（庫馬爾個傻*）`](https://github.com/NARKOZ/hacker-scripts/blob/master/kumar-asshole.sh) - 這個腳本會自動掃描郵箱，如果發現其中有庫馬爾（庫馬爾是我們客戶公司的一位數據庫管理員）發來的郵件，就會在其中尋找關鍵字如“求助”，“遇到麻煩了”，“抱歉”等等，如果發現了這些關鍵字，這個腳本會通過SSH連接上客戶公司的服務器，把中間數據庫（staging database）回滾到最新一次的可用備份。然後它會給郵件發送回覆，“沒事了哥們，下次小心點哈”。

> xxx: [`hangover.sh（宿醉）`](https://github.com/NARKOZ/hacker-scripts/blob/master/hangover.sh) - 同樣是個定時執行的任務，被設置爲在特定日期觸發，它會自動發送諸如“今天不太舒服”或“今天我在家上班”之類的郵件，同樣會從文本庫裏隨機選取一條理由。這個任務會在工作日清晨8點45分以後服務器上仍然沒有可交互的SSH進程時真正執行。

> xxx: (最牛的就是接下來這個) [`fucking-coffee.sh（**的咖啡）`](https://github.com/NARKOZ/hacker-scripts/blob/master/fucking-coffee.sh) - 這個腳本在啓動之後，會先等待恰好17秒（！），然後啓動一個登錄進程連接到我們的咖啡機（淦，我們之前完全不知道我們的咖啡機是聯網的，上面還運行着Linux系統，甚至還跑着TCP socket連接！），然後它會發送類似“系統！開始煮咖啡！”之類的消息，結果這條消息會讓咖啡機開始工作，煮一杯 中杯大小、半咖啡因的拿鐵，再等待恰好24秒（！）後，才倒進咖啡杯裏。這些時間加起來剛好就是這位程序員從自己的工位走到機器前要的時間。

> xxx: 天了嚕我要把這些保留下來。

原文: http://bash.im/quote/436725 (俄語)

歡迎使用其它語言來實現 (Python, Perl, Shell等等)並提交PR。

## 用法

你需要以下這些環境變量：

```bash
# used in `smack-my-bitch-up` and `hangover` scripts
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

# used in `kumar_asshole` script
GMAIL_USERNAME=admin@example.org
GMAIL_PASSWORD=password
```

爲了執行Ruby腳本，你需要安裝gems: `gem install dotenv twilio-ruby gmail`

## 定時任務

```bash
# Runs `smack-my-bitch-up.sh` monday to friday at 9:20 pm.
20 21 * * 1-5 /path/to/scripts/smack-my-bitch-up.sh >> /path/to/smack-my-bitch-up.log 2>&1

# Runs `hangover.sh` monday to friday at 8:45 am.
45 8 * * 1-5 /path/to/scripts/hangover.sh >> /path/to/hangover.log 2>&1

# Runs `kumar-asshole.sh` every 10 minutes.
*/10 * * * * /path/to/scripts/kumar-asshole.sh

# Runs `fucking-coffee.sh` hourly from 9am to 6pm on weekdays.
0 9-18 * * 1-5 /path/to/scripts/fucking-coffee.sh
```

------

代碼的使用遵循WTFPL（Do What The Fuck You Want To Public License）協議。