#Requires AutoHotkey v2.0

; 避免热键冲突,确保同一热键不能并发执行
#MaxThreadsPerHotkey 1
; 当前武器
global currentValue := 1
; 最大武器数量
global maxValue := 4
; 脚本状态
global isPaused := false
; 窗口显示隐藏
global monitorVisible := true

; ======================滚轮功能==============================
#HotIf !isPaused  ; 仅当 isPaused=false 时生效

WheelUp:: {
    global currentValue, maxValue
    if (isPaused)  ; 如果脚本暂停，不执行
        return
    currentValue := (currentValue <= 1) ? maxValue : currentValue - 1
    SendKeyWithDelay(currentValue)
}

WheelDown:: {
    global currentValue, maxValue
    if (isPaused)  ; 如果脚本暂停，不执行
        return
    currentValue := (currentValue >= maxValue) ? 1 : currentValue + 1
    SendKeyWithDelay(currentValue)
}

SendKeyWithDelay(key) {
    SendInput "{" . key . " down}"
    Sleep 40
    SendInput "{" . key . " up}"
}

#HotIf
; ================================数字键匹配===================================
; 监听数字键 1-9（不拦截按键）
~1:: UpdateCurrentValue(1)
~2:: UpdateCurrentValue(2)
~3:: UpdateCurrentValue(3)
~4:: UpdateCurrentValue(4)
~5:: UpdateCurrentValue(5)
~6:: UpdateCurrentValue(6)
~7:: UpdateCurrentValue(7)
~8:: UpdateCurrentValue(8)
~9:: UpdateCurrentValue(9)

; 更新 currentValue 的函数
UpdateCurrentValue(key) {
    global currentValue, maxValue
    if (isPaused)  ; 如果脚本暂停，不执行
        return
    currentValue := (key <= maxValue) ? key : maxValue + 1
}

; ===========================窗口区===========================

; 创建监控窗口
monitorGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x02000000 +E0x00080000")
; monitorGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
monitorGui.BackColor := "1A1A1A"  ; 深色背景
monitorGui.SetFont("cWhite s10", "Consolas")  ; 等宽字体
monitorText := monitorGui.Add("Text", "w250 h210", GetVarInfo())
WinSetTransparent(220, monitorGui.Hwnd)  ; 透明度
monitorGui.Show("x" A_ScreenWidth - 290 " y10")  ; 右上角

; 定时更新（每300ms刷新一次）
SetTimer(UpdateMonitor, 50)

UpdateMonitor() {
    static lastInfo := ""
    newInfo := GetVarInfo()

    if (newInfo != lastInfo) {
        monitorText.Text := newInfo
        lastInfo := newInfo
    }
}

GetVarInfo() {
    return (
        "[现代战舰滚轮切武器脚本]" "`n"
        "by WBY1026 (银翼战将)" "`n"
        "`n"
        "脚本状态:      " (isPaused ? "暂停" : "运行中") "`n"
        "当前武器:      " currentValue "号" "`n"
        "可用武器数量:  " maxValue "`n"
        "`n"
        "+/- 键:        调整可用武器数量" "`n"
        "Insert(Ins)键: 隐藏该窗口" "`n"
        "Home键:        暂停" "`n"
        "End键:         关闭脚本" "`n"
        "`n"
        "启用该脚本会拦截您滚轮的基础功能" "`n"
        "该脚本已开源至github"
    )
}

; ====================上限控制====================
; 主键盘的 + 和 -
~+::addMaxVal()    ; 主键盘加号
~-::reduceMaxVal()   ; 主键盘减号

; 小键盘的 + 和 -
~NumpadAdd::addMaxVal()    ; 小键盘加号
~NumpadSub::reduceMaxVal()   ; 小键盘减号

; 
addMaxVal() {
    global maxValue
    if (maxValue >= 9) {
        ShowPopup("上限不能超过 9")
    } else {
        maxValue += 1
        ShowPopup("当前上限: " maxValue)
    }
}
reduceMaxVal() {
    global maxValue
    if (maxValue > 2) {
        maxValue -= 1
        ShowPopup("当前上限: " maxValue)
    } else {
        ShowPopup("上限不能低于 2")
    }
}

; 封装弹窗函数
; 参数：text=显示的文字, duration=显示时长（毫秒）
ShowPopup(text, duration := 1000) {
    ; 创建GUI窗口
    popupGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    popupGui.BackColor := "333333"  ; 深灰色背景
    popupGui.SetFont("cWhite s12", "Arial")  ; 白色文字

    ; 添加文本（自动适应内容高度）
    popupGui.Add("Text", "w200 Center", text)

    ; 设置半透明（180=70%不透明）
    WinSetTransparent(180, popupGui.Hwnd)

    ; 显示在屏幕中央
    popupGui.Show("NoActivate Center AutoSize")

    ; 定时关闭
    SetTimer(() => popupGui.Destroy(), duration)
}

; ============脚本控制==============

; Insert键：切换窗口显隐
Insert:: {
    static visible := true  ; 初始状态为显示
    visible := !visible
    if (visible) {
        monitorGui.Show()
    } else {
        monitorGui.Hide()
    }
}

; Home键：暂停/恢复脚本滚轮功能
Home:: {
    global isPaused
    isPaused := !isPaused  ; 切换暂停状态
}

; End键：关闭脚本
End:: ExitApp  ; 直接退出脚本
