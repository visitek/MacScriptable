-- Get the path to the script
set scriptFilePath to POSIX path of (path to me)

-- Remove the script's file name to get only the directory
set AppleScript's text item delimiters to "/"
set scriptDir to (text items 1 thru -2 of scriptFilePath) as text
set AppleScript's text item delimiters to ""

-- Log or display the script directory
log "Script directory: " & scriptDir

on removeFiles(scriptDir)
  -- Remove the output files from the script directory
  do shell script "rm -f " & scriptDir & "/_output.wav && rm -f " & scriptDir & "/_output.log && rm -f " & scriptDir & "/_output.txt"
end removeFiles

-- Define the FFmpeg command to record audio from the default microphone
removeFiles(scriptDir)
set ffmpegCommand to "PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin; ffmpeg -f avfoundation -i :1 " & scriptDir & "/_output.wav >> " & scriptDir & "/_output.log 2>&1 & echo $!"

-- Start recording and get the process ID (PID) of the FFmpeg process
try
    set ffmpegPID to do shell script ffmpegCommand
on error errMsg
    removeFiles(scriptDir)

    display dialog "Error starting FFmpeg: " & errMsg

    return
end try

log "ffmpegPID: " & ffmpegPID

-- Show dialog with "Czech" and "English" buttons
set userResponse to button returned of (display dialog "Speak now!" & return & return & "Listening..." & return & return & "...select the spoken language to transcribe" buttons {"cs", "en", "Close"} default button "cs")

-- Set the selected language into the variable
set lang to userResponse

if lang is "Close" then
  -- Stop the FFmpeg recording process using the PID
  log "Stopping the FFmpeg recording process..."
  try
    do shell script "kill -INT " & ffmpegPID
  on error errMsg
      display dialog "Error stopping FFmpeg: " & errMsg
  end try

  return
end if

-- Stop the FFmpeg recording process using the PID
log "Stopping the FFmpeg recording process..."
try
    do shell script "kill -INT " & ffmpegPID
on error errMsg
    removeFiles(scriptDir)

    display dialog "Error stopping FFmpeg: " & errMsg

    return
end try

delay 0.2

-- Check if openai.txt exists and read the API key
set openaiFilePath to scriptDir & "/openai.txt"
set useOpenAI to false
set apiKey to ""
try
    set apiKey to do shell script "cat " & openaiFilePath
    set useOpenAI to true
on error
    log "openai.txt not found, using local Whisper"
end try

if useOpenAI then
    set whisperCommand to "curl -X POST https://api.openai.com/v1/audio/transcriptions -H 'Authorization: Bearer " & apiKey & "' -F file=@" & scriptDir & "/_output.wav -F model=whisper-1 -F language=" & lang & " -F response_format=text > " & scriptDir & "/_output.txt"

    display notification "Processing with OpenAI API..." with title "MacScriptable"
else
    set whisperCommand to "PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin; whisper " & scriptDir & "/_output.wav --output_dir " & scriptDir & " --language " & lang & " --model turbo --output_format txt --task transcribe >> " & scriptDir & "/_output.log"

    display notification "Processing with local whisper..." with title "MacScriptable"
end if

log "Running transcribe..."
try
    do shell script whisperCommand
on error errMsg
    removeFiles(scriptDir)

    display dialog "Error running Whisper: " & errMsg

    return
end try

-- Read the transcribed text from the output filewww.hradeckralove.org
try
  set transcription to do shell script "cat " & scriptDir & "/_output.txt"
on error errMsg
  removeFiles(scriptDir)

  display dialog "Error reading the transcribed text: " & errMsg

  return
end try
log "Transcription: " & transcription

removeFiles(scriptDir)

-- Set the clipboard to the transcribed text
set the clipboard to transcription

display notification "Transcription in clipboard :-)" with title "MacScriptable"

-- Paste the transcribed text into the current focused input
tell application "System Events"
  tell application "System Events"
    set lastApp to item 1 of (get name of processes whose frontmost is true)
  end tell
  do shell script "open -a " & quoted form of lastApp

  delay 0.2

  keystroke "v" using command down
end tell

log "Done..."



