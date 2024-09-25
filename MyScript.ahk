U_Lower := "c"
U_Raise := "n"
U_AltTapTab := "x"
U_CtlTapSpc := "v"
U_ShtTapEnt := "b"
U_WinTapEsc := "m"


; グローバル変数で状態管理する
IsPressedAnyKey := false

; デフォルトレイヤー
DefaultLayerKeyMap := Map(
  "1","'", "2",",", "3",".", "4","p", "5","y", "6","f", "7","g", "8","c", "9","r", "0","l",
  "q","a", "w","o", "e","e", "r","u", "t","i", "y","d", "u","h", "i","t", "o","n", "p","s",
  "a",";", "s","q", "d","j", "f","k", "g","x", "h","b", "j","m", "k","w", "l","v", ";","z",

  "+1","2", "+2",",", "+3",".", "+4","p", "+5","y", "+6","f", "+7","g", "+8","c", "+9","r", "+0","l",
  "+q","a", "+w","o", "+e","e", "+r","u", "+t","i", "+y","d", "+u","h", "+i","t", "+o","n", "+p","s",
  "+a",":+","+s","q", "+d","j", "+f","k", "+g","x", "+h","b", "+j","m", "+k","w", "+l","v", "+;","z",

  "^t","Del^", "^y","Backspace^",  

  "*1","q", "*2","w", "*3","e", "*4","r", "*5","t", "*6","y", "*7","u", "*8","i", "*9","o", "*0","p",
  "*q","a", "*w","s", "*e","d", "*r","f", "*t","g", "*y","h", "*u","j", "*i","k", "*o","l", "*p",";",
  "*a","z", "*s","x", "*d","c", "*f","v", "*g","b", "*h","n", "*j","m", "*k",",", "*l",".", "*;","/"
)

; Lowerレイヤー
LowerLayerKeyMap := Map(
  "1","1", "2","2", "3","3", "4","4", "5","5", "6","6", "7","7", "8","8", "9","9", "0","0",
  "q","Ctrl", "w","Tab", "e","e", "r","u", "t","i", "y","Left", "u","Down", "i","Up", "o","Right", "p","RCtrl",
  "a","Shift", "s","F2", "d","F3", "f","F4", "g","F5", "h","F11", "j","F12", "k","w", "l","v", ";","RShift",

  "b","+Enter",

  "+1","!", "+2","@", "+3","#", "+4","$", "+5","%", "+6","^", "+7","&", "+8","*", "+9","(", "+0",")",
  "+q","Ctrl", "+w","Tab", "+e","e", "+r","u", "+t","i", "+y","Left", "+u","Down", "+i","Up", "+o","Right", "+p","RCtrl",
  "+a","Shift", "+s","F2", "+d","F3", "+f","F4", "+g","F5", "+h","F11", "+j","F12", "+k","w", "+l","v", "+;","RShift"
)

; Raiseレイヤー
RaiseLayerKeyMap := Map(
  "1","!", "2","@", "3","#", "4","$", "5","%", "6","^", "7","&", "8","*", "9","(", "0",")",
  "q","``", "w",";", "e","'", "r","-", "t","=", "y","/", "u","\", "i","<", "o","[", "p","]",
  "a","~", "s",":", "d","`"","f","_", "g","+", "h","?", "j","|", "k",">", "l","{", ";","}",
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

; デフォルトレイヤー
DefaultLayer()
{
  global IsPressedAnyKey

  For Key1, Key2 in DefaultLayerKeyMap {
    Remap(Key1, Key2)
  }
}

Tap(Key, *)
{
  global IsPressedAnyKey
  If (IsPressedAnyKey) {
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
    Remap(Key1, Key2, SetIsIsPressedAnyKey.Bind(true))
  }
  HotIf
}

DefaultLayer()
ExtraLayer(U_Lower, "vk1Dsc07B")
ExtraLayer(U_Raise, "vk1Csc079")

; 長押しでModKey タップでTapKey 
SetModTap(SrcKey, ModKey, TapKey, Temp){
  If (KeyWait(SrcKey, "T0.2")) {
    Send "{Blind}{" TapKey "}"
  } Else {
    Send "{Blind}{" ModKey " down}"
    KeyWait(SrcKey)
    Send "{Blind}{" ModKey " Up}"
  }
}
HotKey "*" U_CtlTapSpc, SetModTap.Bind("v", "Ctrl", "Space")
HotKey "*" U_ShtTapEnt, SetModTap.Bind("b", "Shift", "Enter")
HotKey "*" U_AltTapTab, SetModTap.Bind("x", "Alt", "Tab")
HotKey "*" U_WinTapEsc, SetModTap.Bind(",", "LWin", "Esc")
