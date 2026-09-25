#!/bin/sh
# 打包成可刷入的模块 zip
# 用法: sh build.sh [输出路径]
set -e
OUT="${1:-sarasa_system_font.zip}"
rm -f "$OUT"
if command -v zip >/dev/null 2>&1; then
    zip -r -q "$OUT" . -x '.git/*' -x '.gitignore' -x 'build.sh' -x '*.zip' -x '*.md'
else
    # 没有 zip 时用 Python 兜底
    python3 - "$OUT" << 'PY'
import sys, zipfile, os
out = sys.argv[1]
skip = {'.git', '.gitignore', 'build.sh', 'README.md'}
with zipfile.ZipFile(out, 'w', zipfile.ZIP_STORED) as z:
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if d not in skip]
        for f in files:
            if f in skip or f.endswith('.zip') or f.endswith('.md'):
                continue
            p = os.path.join(root, f)
            z.write(p, os.path.relpath(p, '.'))
print('created', out)
PY
fi
echo "✅ 已生成: $OUT"
