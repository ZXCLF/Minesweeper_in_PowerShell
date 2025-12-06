# Minesweeper in PowerShell

$global:box = @()
$global:floors = @()
$global:over = 0
$global:X = 1
$global:Y = 1
$global:size_l = 0
$global:size_c = 0
$global:num = 0

function Show-Banner {
    Clear-Host
    Write-Host "=== PowerShell 扫雷游戏 ===" -ForegroundColor Cyan
    Write-Host
}

function Get-ValidInput($prompt, $min, $max) {
    while ($true) {
        try {
            $value = Read-Host $prompt
            $value = [int]$value
            if ($value -ge $min -and $value -le $max) {
                return $value
            }
            Write-Host "输入错误：请输入$min到$max之间的数字" -ForegroundColor Red
        }
        catch {
            Write-Host "输入错误：请输入有效的数字" -ForegroundColor Red
        }
    }
}

function Make-Game {
    Show-Banner
    
    # 获取游戏参数
    $global:size_l = Get-ValidInput "请输入行数(1-30)" 1 30
    $global:size_c = Get-ValidInput "请输入列数(1-30)" 1 30
    $maxMines = $size_l * $size_c - 9  # 至少保留9个安全格子
    
    while ($true) {
        $global:num = Get-ValidInput "请输入地雷数量(1-$maxMines)" 1 $maxMines
        if ($global:num -le $maxMines) {
            break
        }
        Write-Host "地雷太多！最多只能有 $maxMines 个地雷" -ForegroundColor Red
    }
    
    # 初始化数组
    $global:box = New-Object 'object[,]' ($size_l + 2), ($size_c + 2)
    $global:floors = New-Object 'object[,]' ($size_l + 2), ($size_c + 2)
    
    # 随机放置地雷
    $random = New-Object System.Random
    $minesPlaced = 0
    
    while ($minesPlaced -lt $num) {
        $x = $random.Next(1, $size_l + 1)
        $y = $random.Next(1, $size_c + 1)
        
        if ($box[$x, $y] -ne 9) {
            $box[$x, $y] = 9
            $minesPlaced++
        }
    }
    
    # 计算周围地雷数
    for ($i = 1; $i -le $size_l; $i++) {
        for ($j = 1; $j -le $size_c; $j++) {
            if ($box[$i, $j] -ne 9) {
                $count = 0
                for ($k = $i - 1; $k -le $i + 1; $k++) {
                    for ($l = $j - 1; $l -le $j + 1; $l++) {
                        if ($box[$k, $l] -eq 9) {
                            $count++
                        }
                    }
                }
                $box[$i, $j] = $count
            }
        }
    }
}

function Get-NumberColor($number) {
    switch ($number) {
        1 { return "Blue" }
        2 { return "Green" }
        3 { return "Red" }
        4 { return "DarkMagenta" }
        5 { return "DarkYellow" }
        6 { return "DarkCyan" }
        7 { return "DarkGray" }
        8 { return "Gray" }
        9 { return "Black" }
        default { return "White" }
    }
}

function Print-Game {
    # 打印列号
    Write-Host "  " -NoNewline
    for ($j = 1; $j -le $global:size_c; $j++) {
        Write-Host ("   {0,2}" -f $j) -NoNewline
    }
    Write-Host
    
    Write-Host "  " -NoNewline
    for ($j = 1; $j -le $global:size_c; $j++) {
        Write-Host "    v" -NoNewline
    }
    Write-Host
    
    # 打印游戏区域
    for ($i = 1; $i -le $global:size_l; $i++) {
        Write-Host ("{0,2}> " -f $i) -NoNewline
        
        for ($j = 1; $j -le $global:size_c; $j++) {
            if ($floors[$i, $j] -eq 1) {
                # 已打开的格子
                if ($box[$i, $j] -eq 9) {
                    # 地雷 - 红色背景
                    if ($i -eq $X -and $j -eq $Y) {
                        Write-Host " >" -NoNewline -BackgroundColor Red
                        Write-Host "X" -NoNewline -BackgroundColor Red
                        Write-Host "< " -NoNewline -BackgroundColor Red
                        Write-Host " " -NoNewline -BackgroundColor Black
                    }
                    else {
                        Write-Host "  X  " -NoNewline -BackgroundColor Red
                    }
                }
                else {
                    # 数字或空白
                    $color = Get-NumberColor $box[$i, $j]
                    
                    if ($i -eq $X -and $j -eq $Y) {
                        Write-Host " >" -NoNewline -ForegroundColor $color
                        
                        if ($box[$i, $j] -eq 0) {
                            Write-Host " " -NoNewline
                        }
                        else {
                            Write-Host $box[$i, $j] -NoNewline -ForegroundColor $color
                        }
                        
                        Write-Host "< " -NoNewline -ForegroundColor $color
                    }
                    else {
                        Write-Host "  " -NoNewline
                        
                        if ($box[$i, $j] -eq 0) {
                            Write-Host " " -NoNewline
                        }
                        else {
                            Write-Host $box[$i, $j] -NoNewline -ForegroundColor $color
                        }
                        
                        Write-Host "  " -NoNewline
                    }
                }
            }
            else {
                # 未打开的格子
                if ($i -eq $X -and $j -eq $Y) {
                    Write-Host " >?< " -NoNewline -ForegroundColor Yellow
                }
                else {
                    Write-Host "  ?  " -NoNewline
                }
            }
        }
        Write-Host
    }
    
    # 显示游戏状态
    Write-Host
    Write-Host "位置: ($X, $Y)" -ForegroundColor Cyan
    Write-Host "剩余地雷: $global:num" -ForegroundColor Yellow
}

function Open-Cell($x, $y) {
    if ($x -lt 1 -or $x -gt $global:size_l -or $y -lt 1 -or $y -gt $global:size_c) {
        return
    }
    
    # 如果已经打开了，不再处理
    if ($floors[$x, $y] -eq 1) {
        return
    }
    
    if ($box[$x, $y] -eq 9) {
        # 踩到地雷
        $global:over = -1
        return
    }
    
    # 使用栈进行深度优先搜索展开（这样更符合扫雷逻辑）
    $stack = New-Object System.Collections.Stack
    $stack.Push(@($x, $y))
    
    while ($stack.Count -gt 0) {
        $cell = $stack.Pop()
        $i = $cell[0]
        $j = $cell[1]
        
        if ($floors[$i, $j] -ne 1) {
            $floors[$i, $j] = 1
            
            # 如果当前格子是空白，展开周围的格子
            if ($box[$i, $j] -eq 0) {
                for ($k = $i - 1; $k -le $i + 1; $k++) {
                    for ($l = $j - 1; $l -le $j + 1; $l++) {
                        if ($k -ge 1 -and $k -le $global:size_l -and $l -ge 1 -and $l -le $global:size_c) {
                            if ($floors[$k, $l] -ne 1) {
                                $stack.Push(@($k, $l))
                            }
                        }
                    }
                }
            }
        }
    }
}

function Check-Win {
    $closedCount = 0
    $minesCount = 0
    
    for ($i = 1; $i -le $global:size_l; $i++) {
        for ($j = 1; $j -le $global:size_c; $j++) {
            if ($floors[$i, $j] -eq 0) {
                $closedCount++
                if ($box[$i, $j] -eq 9) {
                    $minesCount++
                }
            }
        }
    }
    
    # 胜利条件：所有非地雷格子都打开了
    if (($closedCount -eq $minesCount) -and ($minesCount -eq $global:num)) {
        $global:over = 1
    }
}

function Get-PlayerInput {
    # 简化输入处理，使用更可靠的方法
    Write-Host "控制: W/A/S/D或方向键移动，空格/回车打开格子，Q退出" -ForegroundColor Gray
    
    # 读取单个字符
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    switch ($key.VirtualKeyCode) {
        # W 或 上箭头
        87 { if ($global:X -gt 1) { $global:X-- } }
        38 { if ($global:X -gt 1) { $global:X-- } }
        
        # S 或 下箭头
        83 { if ($global:X -lt $global:size_l) { $global:X++ } }
        40 { if ($global:X -lt $global:size_l) { $global:X++ } }
        
        # A 或 左箭头
        65 { if ($global:Y -gt 1) { $global:Y-- } }
        37 { if ($global:Y -gt 1) { $global:Y-- } }
        
        # D 或 右箭头
        68 { if ($global:Y -lt $global:size_c) { $global:Y++ } }
        39 { if ($global:Y -lt $global:size_c) { $global:Y++ } }
        
        # 空格或回车 - 打开格子
        32 { return $true }
        13 { return $true }
        
        # Q - 退出游戏
        81 { $global:over = 2; return $false }
        
        # Enter键（小键盘）
        10 { return $true }
    }
    
    # 其他按键继续游戏
    return $false
}

function Show-AllCells {
    for ($i = 1; $i -le $global:size_l; $i++) {
        for ($j = 1; $j -le $global:size_c; $j++) {
            $floors[$i, $j] = 1
        }
    }
}

function Game-Loop {
    Make-Game
    
    while ($global:over -eq 0) {
        Show-Banner
        Print-Game
        
        # 等待玩家输入
        $shouldOpen = Get-PlayerInput
        
        if ($shouldOpen) {
            Open-Cell $X $Y
            Check-Win
        }
        
        # 如果玩家按了Q退出
        if ($global:over -eq 2) {
            break
        }
    }
    
    # 游戏结束
    Show-Banner
    Show-AllCells
    Print-Game
    
    Write-Host
    if ($global:over -eq 1) {
        Write-Host "恭喜你胜利了！" -ForegroundColor Green
    }
    elseif ($global:over -eq -1) {
        Write-Host "你在($X,$Y)踩到了地雷！游戏结束。" -ForegroundColor Red
    }
    else {
        Write-Host "游戏退出。" -ForegroundColor Yellow
    }
    
    Write-Host
    Write-Host "按任意键退出..."
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# 主程序入口
try {
    # 设置控制台编码为UTF-8（如果需要显示中文）
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    Game-Loop
}
catch {
    Write-Host "发生错误: $_" -ForegroundColor Red
    Write-Host "按任意键退出..."
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
