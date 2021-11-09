# Log with Timesamp in PowerShell
This is a sample script to show how I've created my own WriteLog function that enables logging to both file and Stdout with a timestamp.

To know more, check out my blog post here: https://lexdsolutions.com/2021/11/how-to-log-with-timestamps-in-powershell/

If you have any suggestions to make this any better, I am open to any pull requests :)

## Example - Logging to File
```
PS C:\> .\logging_sample.ps1

PS C:\> Get-Content "C:\Temp\Logs\my_20211109.log"
[09/11/21 21:11:43] Hello World!
[09/11/21 21:11:43] Cleaning logs older than 7 days
```
