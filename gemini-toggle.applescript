property geminiUrl : "https://gemini.google.com/app"
property defaultWidth : 460
property defaultHeight : 760
property rightMargin : 24
property topMargin : 72
property stateDirName : "Gemini Tool"
property windowIdFileName : "window-id.txt"

on run
  do shell script "mkdir -p " & quoted form of stateDirPath()

  set storedWindowId to readStoredWindowId()
  if storedWindowId is not missing value then
    if focusGeminiWindow(storedWindowId) then
      return
    end if
  end if

  set existingWindowIds to chromeWindowIds()
  openGeminiAppWindow()
  set newWindowId to waitForNewGeminiWindow(existingWindowIds)

  if newWindowId is not missing value then
    storeWindowId(newWindowId)
    focusGeminiWindow(newWindowId)
    placeGeminiWindow(newWindowId)
  end if
end run

on stateDirPath()
  return POSIX path of (path to application support from user domain) & stateDirName
end stateDirPath

on windowIdFilePath()
  return stateDirPath() & "/" & windowIdFileName
end windowIdFilePath

on readStoredWindowId()
  try
    set idText to do shell script "cat " & quoted form of windowIdFilePath()
    if idText is not "" then return idText
  end try
  return missing value
end readStoredWindowId

on storeWindowId(windowId)
  do shell script "printf %s " & quoted form of (windowId as text) & " > " & quoted form of windowIdFilePath()
end storeWindowId

on chromeWindowIds()
  set ids to {}
  if application "Google Chrome" is not running then return ids

  try
    with timeout of 5 seconds
      tell application "Google Chrome"
        repeat with chromeWindow in windows
          set end of ids to (id of chromeWindow as text)
        end repeat
      end tell
    end timeout
  on error errMsg number errNum
    error "无法读取 Chrome 窗口。请确认已允许这个工具控制 Google Chrome。原始错误：" & errMsg number errNum
  end try

  return ids
end chromeWindowIds

on openGeminiAppWindow()
  do shell script "open -na 'Google Chrome' --args --app='" & geminiUrl & "'"
end openGeminiAppWindow


on waitForNewGeminiWindow(existingWindowIds)
  repeat 25 times
    delay 0.2
    if application "Google Chrome" is running then
      try
        with timeout of 5 seconds
          tell application "Google Chrome"
            repeat with chromeWindow in windows
              set currentId to id of chromeWindow as text
              if existingWindowIds does not contain currentId then
                if (count of tabs of chromeWindow) > 0 then
                  set tabUrl to URL of active tab of chromeWindow
                  if tabUrl contains "gemini.google.com" then return currentId
                end if
              end if
            end repeat
          end tell
        end timeout
      on error errMsg number errNum
        error "等待 Gemini 窗口时无法读取 Chrome。请确认已允许这个工具控制 Google Chrome。原始错误：" & errMsg number errNum
      end try
    end if
  end repeat
  return missing value
end waitForNewGeminiWindow

on focusGeminiWindow(targetWindowId)
  if application "Google Chrome" is not running then return false

  try
    with timeout of 5 seconds
      tell application "Google Chrome"
        repeat with chromeWindow in windows
          if (id of chromeWindow as text) is (targetWindowId as text) then
            if (count of tabs of chromeWindow) > 0 then
              set tabUrl to URL of active tab of chromeWindow
              if tabUrl contains "gemini.google.com" then
                activate
                set index of chromeWindow to 1
                return true
              end if
            end if
          end if
        end repeat
      end tell
    end timeout
  on error errMsg number errNum
    error "无法聚焦 Gemini 窗口。请确认已允许这个工具控制 Google Chrome。原始错误：" & errMsg number errNum
  end try

  return false
end focusGeminiWindow

on placeGeminiWindow(targetWindowId)
  try
    with timeout of 5 seconds
      tell application "Finder"
        set screenBounds to bounds of window of desktop
      end tell
    end timeout
  on error
    set screenBounds to {0, 0, 1440, 900}
  end try

  set screenRight to item 3 of screenBounds
  set x1 to screenRight - defaultWidth - rightMargin
  set y1 to topMargin
  set x2 to screenRight - rightMargin
  set y2 to topMargin + defaultHeight

  try
    with timeout of 5 seconds
      tell application "Google Chrome"
        repeat with chromeWindow in windows
          if (id of chromeWindow as text) is (targetWindowId as text) then
            set bounds of chromeWindow to {x1, y1, x2, y2}
            return
          end if
        end repeat
      end tell
    end timeout
  on error errMsg number errNum
    error "无法调整 Gemini 窗口大小。请确认已允许这个工具控制 Google Chrome。原始错误：" & errMsg number errNum
  end try
end placeGeminiWindow
