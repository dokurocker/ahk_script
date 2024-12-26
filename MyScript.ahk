SetWinDelay 0
SetKeyDelay 40

U_Lower := "c"
U_Raise := ","
U_AltTapTab := "x"
U_CtlTapSpc := "v"
U_ShtTapEnt := "m"
U_WinTapEsc := "."


; グローバル変数で状態管理する
IsPressedAnyKey := false

; デバイスのキーボード
U_DeviceKeyMap := [
  ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "^", "\"],
   ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "@", "["],
    ["a", "s", "d", "f", "g", "h", "j", "k", "l", ";", ":", "]"],
     ["z", "x", "c", "v", "b", "n", "m", ",", ".", "/"]
]

; 左右の小指位置
U_LeftLittleFingerPos := 0
U_RightLittleFingerPos := 11

; デフォルトレイヤー
DefaultLayerKeyMap := Map(
  "L15","'", "L14",",", "L13",".", "L12","p", "L11","y", "R11","f", "R12","g", "R13","c", "R14","r", "R15","l",
  "L25","a", "L24","o", "L23","e", "L22","u", "L21","i", "R21","d", "R22","h", "R23","t", "R24","n", "R25","s",
  "L35",";", "L34","q", "L33","j", "L32","k", "L31","x", "R31","b", "R32","m", "R33","w", "R34","v", "R35","z",

  "+L15","2", "+L14",",", "+L13",".", "+L12","p", "+L11","y", "+R11","f", "+R12","g", "+R13","c", "+R14","r", "+R15","l",
  "+L25","a", "+L24","o", "+L23","e", "+L22","u", "+L21","i", "+R21","d", "+R22","h", "+R23","t", "+R24","n", "+R25","s",
  "+L35",":+","+L34","q", "+L33","j", "+L32","k", "+L31","x", "+R31","b", "+R32","m", "+R33","w", "+R34","v", "+R35","z",

  "^L21","Del^", "^R21","Backspace^",  

  "*L15","q", "*L14","w", "*L13","e", "*L12","r", "*L11","t", "*R11","y", "*R12","u", "*R13","i", "*R14","o", "*R15","p",
  "*L25","a", "*L24","s", "*L23","d", "*L22","f", "*L21","g", "*R21","h", "*R22","j", "*R23","k", "*R24","l", "*R25",";",
  "*L35","z", "*L34","x", "*L33","c", "*L32","v", "*L31","b", "*R31","n", "*R32","m", "*R33",",", "*R34",".", "*R35","/"
)

; Lowerレイヤー
LowerLayerKeyMap := Map(
  "L15","1", "L14","2", "L13","3", "L12","4", "L11","5", "R11","6", "R12","7", "R13","8", "R14","9", "R15","0",
  "L25","Ctrl", "L24","Tab", "L23","e", "L22","u", "L21","i", "R21","Left", "R22","Down", "R23","Up", "R24","Right", "R25","RCtrl",
  "L35","Shift", "L34","F2", "L33","F3", "L32","F4", "L31","F5", "R31","F11", "R32","F12", "R33","w", "R34","v", "R35","RShift",

  "b","+Enter",

  "+L15","!", "+L14","@", "+L13","#", "+L12","$", "+L11","%", "+R11","^", "+R12","&", "+R13","*", "+R14","(", "+R15",")",
  "+L25","Ctrl", "+L24","Tab", "+L23","e", "+L22","u", "+L21","i", "+R21","Left", "+R22","Down", "+R23","Up", "+R24","Right", "+R25","RCtrl",
  "+L35","Shift", "+L34","F2", "+L33","F3", "+L32","F4", "+L31","F5", "+R31","F11", "+R32","F12", "+R33","w", "+R34","v", "+R35","RShift"
)

; Raiseレイヤー
RaiseLayerKeyMap := Map(
  "L15","!", "L14","@", "L13","#", "L12","$", "L11","%", "R11","^", "R12","&", "R13","*", "R14","(", "R15",")",
  "L25","``", "L24",";", "L23","'", "L22","-", "L21","=", "R21","/", "R22","\", "R23","<", "R24","[", "R25","]",
  "L35","~", "L34",":", "L33","`"","L32","_", "L31","+", "R31","?", "R32","|", "R33",">", "R34","{", "R35","}",
)

; キーリマップ後の動作
KeySend(KeyName, IsDown, Callback := "", *)
{
  global IsPressedAnyKey

  Blind := "Blind"
  ; 修飾キーを外す指定（末尾に修飾キー）があるかを判定
  RegMatchPos := RegExMatch(KeyName, "[+^!#]+$")
  If (RegMatchPos > 1){
    Blind := "" Blind SubStr(KeyName, RegMatchPos)
    KeyName := SubStr(KeyName, 1, StrLen(KeyName) - RegMatchPos - 1)
  }

  SetKeyDelay -1
  Send "{" Blind "}{" KeyName (IsDown ? " DownR" : " Up") "}"
  If (Callback && IsDown) {
    Callback()
  }
}

; キーリマップ
Remap(Key1, Key2, KeySendCallback := "")
{
  HotKey Key1      , KeySend.Bind(key2, true, KeySendCallback) 
  HotKey Key1 " Up", KeySend.Bind(key2, false, KeySendCallback)
}

; Reset
Reset(Key)
{
  HotKey "*" Key, (*) => {}
}

; 端末のキーリセット
ResetDeviceKey()
{
  global U_DeviceKeyMap
  For Row in U_DeviceKeyMap {
    For Col in Row {
      Reset(Col)
    }
  }
}

; 変換
GetDeviceKey(Key)
{
  global U_DeviceKeyMap, U_LeftLittleFingerPos, U_RightLittleFingerPos
  Match := ""
  ; 修飾キーを外す指定（末尾に修飾キー）があるかを判定
  RegMatchPos := RegExMatch(Key, "([+^!#*]*)([LR])([1-5])([1-5])", &Match)

  If (RegMatchPos < 1) {
    return Key
  }
  i := Integer(Match[3])
  j := (Match[2] == "L" ? U_LeftLittleFingerPos + (5 - Integer(Match[4]))
    : U_RightLittleFingerPos - (5 - Integer(Match[4]))) + 1
  return Match[1] U_DeviceKeyMap[i][j]
}

; デフォルトレイヤー
DefaultLayer()
{
  global IsPressedAnyKey

  For Key1, Key2 in DefaultLayerKeyMap {  
    Remap(GetDeviceKey(Key1), Key2)
  }
}

Tap(Key, *)
{
  global IsPressedAnyKey
  If (IsPressedAnyKey) {
    Send "{Blind}{Shift up}" ; Lowerキー+シフトでLowerキーを先に離したときにシフトを離す
    IsPressedAnyKey := false
    Return
  }
  Send "{" Key " down}{" Key " up}"
}

SetIsIsPressedAnyKey(Param)
{
  global IsPressedAnyKey
  IsPressedAnyKey := Param 
}

ExtraLayer(Key, KeyA)
{
  global IsPressedAnyKey

  IsPressedAnyKey := false
  Match := ""

  HotKey "*" Key, (*) => {}
  HotKey "*" Key " Up", Tap.Bind(KeyA)

  HotIf (*) => GetKeyState(Key, "P")
  For Key1, Key2 in (Key == U_Lower ? LowerLayerKeyMap : RaiseLayerKeyMap) {
    Remap(GetDeviceKey(Key1), Key2, SetIsIsPressedAnyKey.Bind(true))
  }
  HotIf
}

ResetDeviceKey()
DefaultLayer()
ExtraLayer(U_Lower, "vk1Dsc07B")
ExtraLayer(U_Raise, "vk1Csc079")

; 長押しでModKey タップでTapKey 
SetModTap(SrcKey, ModKey, TapKey, Temp){
  If (KeyWait(SrcKey, "T0.17")) {
    Send "{Blind}{" TapKey "}"
  } Else {
    Send "{Blind}{" ModKey " down}"
    KeyWait(SrcKey)
    Send "{Blind}{" ModKey " Up}"
  }
}
HotKey "*" U_CtlTapSpc, SetModTap.Bind(U_CtlTapSpc, "Ctrl", "Space")
HotKey "*" U_ShtTapEnt, SetModTap.Bind(U_ShtTapEnt, "Shift", "Enter")
HotKey "*" U_AltTapTab, SetModTap.Bind(U_AltTapTab, "Alt", "Tab")
HotKey "*" U_WinTapEsc, SetModTap.Bind(U_WinTapEsc, "LWin", "Esc")
