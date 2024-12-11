# Install

- brew install ffmpg
- brew install openai-whisper

or compile from the source

# Create automator Quick Action
- add `Run Shell Script` action
- add: `osascript <full path to the project>/transcribe.scpt`
- Save as `Transcribe`

# Go to System Preferences
- Security & Privacy -> Privacy -> Accessibility - Add Automator
- Keyboard -> Shortcuts -> Services -> Add Shortcut for `Transcribe`

# Debug
- First of all, check if the ffmpeg is around version 7 :-)
- Check if it records the correct audio stream. I use `avfoundation -i :1` (`[1] MacBook Pro Microphone`).
  - Try `ffmpeg -f avfoundation -list_devices true -i ""`
- **Try if the whisper works well. If you don't have the model downloaded, whisper will download it for you. eg. `turbo` is around 6GB!**
