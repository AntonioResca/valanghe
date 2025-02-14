# programma l'esecuzione dello script euregio.ps1
$directory = "C:\Users\anton\valanghe"
$azione = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File euregio.ps1" -WorkingDirectory $directory
$trigger = New-ScheduledTaskTrigger -Once -At 3:27pm -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration (New-TimeSpan -Hours 11) 
# Registra l'attività
Register-ScheduledTask -TaskName "EseguiEuregioOgni15Minuti" -Action $azione -Trigger $trigger -User "SYSTEM"