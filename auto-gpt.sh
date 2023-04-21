#!/bin/sh
#!/bin/bash

# 检查系统是否为 Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # 检查是否已经安装了 wget
    if ! command -v wget &> /dev/null; then
        # 如果没有安装则使用 Chocolatey 进行安装
        echo "wget is not installed. Installing wget..."
        choco install wget
    else
        echo "wget is already installed."
    fi
# 检查系统是否为 Mac
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # 检查是否已经安装了 wget
    if ! command -v wget &> /dev/null; then
        # 如果没有安装则使用 Homebrew 进行安装
        echo "wget is not installed. Installing wget..."
        brew install wget
    else
        echo "wget is already installed."
    fi
# 其他系统不进行安装
else
    echo "wget is not supported on this system."
fi


# 检查是否安装了 Python
if ! command -v python3 &> /dev/null
then
    echo "Python3 没有安装。正在安装 Python3.10..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac 操作系统
        if command -v brew &> /dev/null; then
            brew install python@3.10
        else
            echo "在这台 Mac 上没有安装 Homebrew。请先安装 Homebrew。"
            exit 1
        fi
    elif [[ "$OSTYPE" == "win"* ]]; then
        # Windows 操作系统
        choco install python3 --version 3.10.0
    else
        # 不支持的操作系统
        echo "不支持的操作系统。请手动安装 Python3.10。"
        exit 1
    fi
fi

# 检查是否安装了 Git
if ! command -v git &> /dev/null
then
    echo "Git 没有安装。正在安装 Git..."
    
    # 根据操作系统类型安装 Git
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac 操作系统
        if command -v brew &> /dev/null; then
            echo "正在使用 Homebrew 安装 Git..."
            brew install git
        else
            echo "在这台 Mac 机器上没有安装 Homebrew。请先安装 Homebrew，再手动安装 Git。"
            exit 1
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        # Windows 操作系统
        echo "正在使用 Git 官方安装程序安装 Git..."
		URL="https://github.com/git-for-windows/git/releases/download/v2.31.1.windows.1/Git-2.31.1-64-bit.exe"
		wget $URL -O git-install.exe
		./git-install.exe /VERYSILENT /NORESTART /SP- /SUPPRESSMSGBOXES
		rm -f git-install.exe
    else
        # 不支持的操作系统
        echo "不支持的操作系统。请手动安装 Git。"
        exit 1
    fi
fi

# 定义代码仓库地址
REPO_URL=git@github.com:kaqijiang/Auto-GPT-ZH.git
REPO_URL_ZIP=https://github.com/kaqijiang/Auto-GPT-ZH/archive/refs/heads/main.zip

echo "克隆仓库 $REPO_URL"
# 使用 Git 克隆代码仓库
if git clone $REPO_URL; then
    echo "成功使用 Git 克隆代码仓库。"
    cd Auto-GPT-ZH
else
    # 使用 wget 下载 ZIP 文件
    echo "Git 克隆失败。尝试使用 wget 下载 ZIP 文件。"
    wget "$REPO_URL_ZIP"
    if [[ $? -eq 0 ]]; then
        echo "成功下载 ZIP 文件。"
        # 解压 ZIP 文件
        unzip main.zip
        # 进入解压后的目录
        cd Auto-GPT-ZH-main
    else
        echo "使用 Git 克隆和使用 wget 下载 ZIP 文件均失败。"
        exit 1
    fi
fi

# 显示隐藏文件夹
# 检测电脑操作系统类型
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "检测到您的电脑操作系统为 macOS。"
    defaults write com.apple.finder AppleShowAllFiles YES
    killall Finder
elif [[ "$OSTYPE" == "msys" ]]; then
    echo "检测到您的电脑操作系统为 Windows。"
    reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 1 /f
    taskkill /f /im explorer.exe
    start explorer.exe
else
    echo "无法检测到您的电脑操作系统类型。"
    exit 1
fi

# 创建.env


# 检测操作系统类型
if [[ "$OSTYPE" == "darwin"* ]]; then
    # 如果是Mac
    mv .env.template .env
    echo "成功将.env.template文件重命名为.env"
elif [[ "$OSTYPE" == "msys" ]]; then
    # 如果是Windows
    ren .env.template .env
    echo "成功将.env.template文件重命名为.env"
else
    echo "不支持的操作系统类型"
    exit 1
fi

# 检测操作系统类型
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  #对于Windows，使用SET命令读取用户输入
  echo "请输入你的OpenAI Key 将自动替换Auto-GPT环境变量中的Key："
  set /p input=
else
  #对于Mac，使用read命令读取用户输入
  read -p "请输入你的OpenAI Key 将自动替换Auto-GPT环境变量中的Key：" input
fi

#将.env文件中的占位符替换为用户输入
sed -i "s/uuYourOpenAIKeyuu/$input/g" .env

echo "替换成功！"

# 安装pip

if ! command -v pip &> /dev/null; then
    echo "未安装pip。正在安装pip..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install pip
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        python -m ensurepip --default-pip
    else
        sudo apt-get update
        sudo apt-get install python-pip
    fi
else
    echo "pip已安装。"
fi

pip install -r requirements.txt

python3 -m autogpt
