#!/system/bin/sh
# 开机自动把模块字体 bind-mount 到 /system/fonts
# KernelSU post-fs-data 阶段执行(zystem 启动前)
MODDIR="${0%/*}"
SRC="$MODDIR/fonts"
LOG="/data/adb/sarasa_font.log"

echo "[$(date '+%F %T')] post-fs-data 开始" >> "$LOG"

# 目标: 4 个实体文件 (SysFont-Regular.ttf 是符号链接, 链到最后也是 Roboto-Regular.ttf)
FONTS="Roboto-Regular.ttf SysSans-En-Regular.ttf SysSans-Hans-Regular.ttf SysSans-Hant-Regular.ttf"

# 等待 /system/fonts 就绪
i=0
while [ ! -d /system/fonts ] && [ $i -lt 30 ]; do
    sleep 0.5
    i=$((i+1))
done

for f in $FONTS; do
    S="$SRC/$f"
    T="/system/fonts/$f"
    if [ -f "$S" ]; then
        # 已挂载则先卸载(避免重复)
        mount 2>/dev/null | grep -q " $T " && umount "$T" 2>/dev/null
        if mount --bind "$S" "$T" 2>/dev/null; then
            # 同步 SELinux 上下文
            chcon u:object_r:system_file:s0 "$S" 2>/dev/null
            echo "[$(date '+%F %T')] OK  $f" >> "$LOG"
        else
            echo "[$(date '+%F %T')] FAIL $f" >> "$LOG"
        fi
    else
        echo "[$(date '+%F %T')] MISS $f" >> "$LOG"
    fi
done

# 额外保险: 解析 SysFont-Regular.ttf 符号链接的最终目标并挂载
REAL=$(readlink -f /system/fonts/SysFont-Regular.ttf 2>/dev/null)
if [ -n "$REAL" ] && [ -f "$REAL" ] && [ "$REAL" != "/system/fonts/Roboto-Regular.ttf" ]; then
    mount --bind "$SRC/Roboto-Regular.ttf" "$REAL" 2>/dev/null && \
        echo "[$(date '+%F %T')] OK  (链目标) $REAL" >> "$LOG"
fi

echo "[$(date '+%F %T')] 完成" >> "$LOG"
exit 0
