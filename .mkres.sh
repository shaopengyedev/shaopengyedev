#!/bin/bash

# ==========================================
# 脚本功能：自动创建符合卡片ID规范的课程资源目录结构
# 作者：Gemini & shaopengyedev
# 依赖：无需特殊依赖，标准Bash即可
# ==========================================

INPUT_PATH="${1%/}" # 获取输入并去除末尾斜杠

if [ -z "$INPUT_PATH" ]; then
    echo "用法：$0 <课程路径或ID>"
    exit 1
fi

# 1. 路径识别（基于当前根目录）
if [ -d "$INPUT_PATH" ]; then
    # 如果输入 ./06/06-001，清理掉开头的 ./
    TARGET_COURSE_PATH=$(echo "$INPUT_PATH" | sed 's|^\./||')
else
    # 如果输入 06-001，在当前目录下搜索
    TARGET_COURSE_PATH=$(find . -maxdepth 2 -type d -name "$INPUT_PATH" 2>/dev/null | sed 's|^\./||' | head -n 1)
    if [ -z "$TARGET_COURSE_PATH" ]; then
        echo "错误：在当前目录下找不到'$INPUT_PATH'。"
        exit 1
    fi
fi

COURSE_ID=$(basename "$TARGET_COURSE_PATH")

# 2. 结构定义（小写）
RES_ID="${COURSE_ID}-00"
RES_TITLE="sources"

ATT_ID="${RES_ID}-01"
ATT_TITLE="attachments"
IMG_ID="${ATT_ID}-01"
IMG_TITLE="images"
PDF_ID="${ATT_ID}-02"
PDF_TITLE="pdfs"

LIT_ID="${RES_ID}-02"
LIT_TITLE="literature notes"
FLEET_ID="${RES_ID}-03"
FLEET_TITLE="fleeting notes"

# 3. 交互确认
echo "将在课程路径[${TARGET_COURSE_PATH}]下创建资源结构。"
echo "目标：${TARGET_COURSE_PATH}/${RES_ID}/"
echo -n "确认继续？(y/n) "
read -r REPLY
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "操作取消。"
    exit 0
fi

# 4. 创建函数
create_node() {
    local dir_path="$1"
    local id="$2"
    local title="$3"

    local full_dir="${dir_path}/${id}"
    mkdir -p "$full_dir"

    local md_file="${full_dir}/${id}.md"
    if [ ! -f "$md_file" ]; then
        printf "# %s\n" "$title" > "$md_file"
    fi
}

# 执行物理创建
RES_ROOT="${TARGET_COURSE_PATH}/${RES_ID}"
ATT_ROOT="${RES_ROOT}/${ATT_ID}"

create_node "$TARGET_COURSE_PATH" "$RES_ID" "$RES_TITLE"
create_node "$RES_ROOT"           "$ATT_ID" "$ATT_TITLE"
create_node "$ATT_ROOT"           "$IMG_ID" "$IMG_TITLE"
create_node "$ATT_ROOT"           "$PDF_ID" "$PDF_TITLE"
create_node "$RES_ROOT"           "$LIT_ID" "$LIT_TITLE"
create_node "$RES_ROOT"           "$FLEET_ID" "$FLEET_TITLE"

# 5. 树状输出（ID.md title 格式）
print_line() {
    printf "%s%s.md %s\n" "$1" "$2" "$3"
}

echo ""
echo "任务完成。当前资源视图："
echo "${RES_ID}/"
print_line "├── " "$RES_ID" "$RES_TITLE"
echo "├── ${ATT_ID}/"
print_line "│   ├── " "$ATT_ID" "$ATT_TITLE"
echo "│   ├── ${IMG_ID}/"
print_line "│   │   └── " "$IMG_ID" "$IMG_TITLE"
echo "│   └── ${PDF_ID}/"
print_line "│       └── " "$PDF_ID" "$PDF_TITLE"
echo "├── ${LIT_ID}/"
print_line "│   └── " "$LIT_ID" "$LIT_TITLE"
echo "└── ${FLEET_ID}/"
print_line "    └── " "$FLEET_ID" "$FLEET_TITLE"

