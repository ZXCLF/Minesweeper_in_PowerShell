# Minesweeper_in_PowerShell

一个使用 PowerShell 编写的扫雷游戏，支持自定义游戏尺寸和地雷数量。

## 系统要求

- Windows PowerShell 5.1 或 PowerShell 7+
- Windows 操作系统

## 安装和运行方法

### 方法一：直接运行（需修改执行策略）

1. **设置执行策略**（第一次运行时需要）

   ```powershell
   # 以管理员身份打开 PowerShell，执行以下命令：
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
   - 这会允许运行本地签名的脚本
   - 选择 `[Y]` 确认更改

2. **运行游戏**

```powershell
   irm https://github.com/ZXCLF/Minesweeper_in_PowerShell/raw/refs/heads/main/Minesweeper_in_PowerShell.ps1 | iex # Windows 8及以上 
```

### 方法二：临时运行（不修改执行策略）

```powershell
# 手动下载 Minesweeper_in_PowerShell.ps1
powershell -ExecutionPolicy Bypass -File Minesweeper_in_PowerShell.ps1
```

## 游戏控制说明

### 移动控制
- **W** 或 **↑** 键：向上移动
- **A** 或 **←** 键：向左移动
- **S** 或 **↓** 键：向下移动
- **D** 或 **→** 键：向右移动

### 操作控制
- **空格键** 或 **回车键**：打开当前选中的格子
- **Q** 键：退出游戏

### 游戏界面
```
   1    2    3    4    5    6    7    8    9   10
    v    v    v    v    v    v    v    v    v    v
 1>  ?     ?     ?     ?     ?     ?     ?     ?     ?     ?  
 2>  ?     ?     ?     ?     ?     ?     ?     ?     ?     ?  
 3>  ?     ?     ?     ?     ?     ?     ?     ?     ?     ?  
```

- **?**：未打开的格子
- **数字**：周围的地雷数量（不同数字有不同颜色）
- **X**：地雷（游戏结束时显示）
- **>?<**：当前选中的位置（黄色高亮）

## 游戏规则

1. **游戏目标**：在不触发任何地雷的情况下，打开所有非地雷的格子。

2. **游戏流程**：
   - 游戏开始时设置行数、列数和地雷数量
   - 移动光标选择要打开的格子
   - 打开格子：
     - 如果是数字：显示周围地雷数量
     - 如果是空白：自动展开相邻的空白区域
     - 如果是地雷：游戏结束

3. **胜利条件**：所有非地雷格子都被打开。

## 常见问题

1. **脚本无法运行**
   
   ```
   File cannot be loaded because running scripts is disabled on this system.
   ```
   **解决方法**：执行 `Set-ExecutionPolicy RemoteSigned`
   
2. **中文显示乱码**
   **解决方法**：脚本已设置 **UTF-8**编码，确保 PowerShell 控制台使用正确的字体（如 Consolas）

## 许可证

MIT License
