#! /bin/bash

# 安装nginx和nginx-njs到ubuntu
sudo apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list

echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx

sudo apt update
sudo apt install nginx nginx-module-njs -y
# 安装nginx和nginx-njs到ubuntu end

script_dir=$(
    cd $(dirname $0)
    pwd
)
sudo rm -rf /etc/nginx/emby2alist
sudo cp -r $script_dir/nginx/conf.d /etc/nginx/emby2alist/
sudo mv /etc/nginx/emby2alist/emby.conf /etc/nginx/conf.d/
sudo rm -rf /etc/nginx/conf.d/includes
sudo mv /etc/nginx/emby2alist/includes /etc/nginx/conf.d/

read -p "请输入AlistAPI" api
if [ ! -n "$api" ]; then
    echo "不替换AlistAPI"
else
    echo 输入的Alist_API是：$api
    sudo sed -i "s/alsit-123456/$api/" /etc/nginx/emby2alist/config/constant-mount.js
fi
read -p "请输入EmbyAPI" api
if [ ! -n "$api" ]; then
    echo "不替换EmbyAPI"
else
    echo 输入的Emby_API是：$api
    sudo sed -i "s/f839390f50a648fd92108bc11ca6730a/$api/" /etc/nginx/emby2alist/constant.js
fi

sudo mkdir -p /var/cache/nginx/emby/images
sudo mkdir -p /etc/nginx/logs
sudo systemctl start nginx.service
