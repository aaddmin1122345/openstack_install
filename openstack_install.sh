#! /usr/bin/bash
daojishi(){
    a=$1
    b=$2
    ti1=`date +%s`
    ti2=`date +%s`
    i=$(($ti2 - $ti1 ))
    echo "
    安装脚本将在$a之后开始安装!
    安装脚本将在$a之后开始安装!
    安装脚本将在$a之后开始安装!
    $b"
    while [[ "$i" -ne "$a" ]]
    do
	ti2=`date +%s`
	i=$(($ti2 - $ti1 ))
    done

}
daojishi 60 "使用须知:
    安装过程需要下载软件包,请在网络良好的环境下安装
    虚拟机安装openstack网卡需要选择为nat网卡
    cpu选择2x2,内存分配6g,打开vmware 3d加速功能
    先把静态ip配置好,不然安装后可能会出错
    系统版本是centos8的才可以用
    必须使用root账户运行该脚本
    遇到问题尽量自行百度解决
    如果需要取消请按ctrl+c"

echo "开始安装..."
echo "配置selinux中..."
echo "/usr/sbin/setenforce 0" >> /etc/rc.local
echo "关闭防火墙中..."
systemctl disable firewalld && systemctl stop firewalld
echo -e "LANG=en_US.utf-8 \nLC_ALL=en_US.utf-8" >/etc/environment
lip=$(ifconfig |grep inet|grep -v 192.168.122.1|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr")
echo "你的ip是:$lip"
echo "设置主机名中..."
hostnamectl set-hostname openstack
echo "更改hosts文件中..."
echo -e “$lip\topenstack\topenstack.localdomain”>>/etc/hosts
echo "更换软件源为中科大源..."
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-Linux-AppStream.repo \
         /etc/yum.repos.d/CentOS-Linux-BaseOS.repo \
         /etc/yum.repos.d/CentOS-Linux-Extras.repo \
         /etc/yum.repos.d/CentOS-Linux-PowerTools.repo \
         /etc/yum.repos.d/CentOS-Linux-Plus.repo
echo "刷新源并切换默认网络管理为network..."
yum makecache;dnf update;dnf install network-scripts -y
systemctl stop NetworkManager && systemctl disable NetworkManager
systemctl start network && systemctl enable network
echo "安装centos-release-openstack-train中..."
dnf install centos-release-openstack-train -y
dnf config-manager --enable powertools
dnf install openstack-packstack -y
dnf update -y
daojishi 15 "15秒后开始最后的安装..."
echo "安装开始...
    安装速度具体取决于你电脑性能"
packstack --allinone;
passwd=$(cat $HOME/keystonerc_admin|grep -v "OS_USERNAME="|grep "OS_PASSWORD=")
echo $passwd| awk -F "'" '{print "你的登陆帐号为:admin\n你的登录密码为:"$2}'
echo "你的登陆地址是"$lip/dashboard
echo "如果出现登陆地址以及帐号密码就说明安装成功啦~"


