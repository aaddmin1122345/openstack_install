#! /usr/bin/bash
log(){
daojishi(){
    a=$1
    b=$2
    ti1=`date +%s`
    ti2=`date +%s`
    i=$(($ti2 - $ti1 ))
    echo -e " \033[1;91m
    安装脚本将在$a秒之后开始运行!
    安装脚本将在$a秒之后开始运行!
    安装脚本将在$a秒之后开始运行!
    认真阅读使用须知!
    认真阅读使用须知!
    认真阅读使用须知!
    $b"
    while [[ "$i" -ne "$a" ]]
    do
	ti2=`date +%s`
	i=$(($ti2 - $ti1 ))
    done

}
daojishi 60 echo -e "使用须知:\n
\033[1;91m必须先手动把静态ip配置好,不然安装后ip变了可能就没了\n
虚拟机系统版本必须为centos8\n
虚拟机网卡需要必须选择为nat网卡\n
安装过程需要下载软件包,请在网络良好的环境下安装\n
建议虚拟机分配cpu2x2,内存6g,并开启vmware 3d加速功能(可选)\n
必须使用root账户运行该脚本\n
遇到问题尽量自行百度解决\n
实在无法解决请把 $HOME/openstack_install.log文件发我,方便我定位问题\n
上述操作都没问题了,就等待安装
如要取消安装请按ctrl+c"\n

echo -e "\033[1;92m开始安装..."
echo -e "\033[1;92m配置selinux中..."
echo "/usr/sbin/setenforce 0" >> /etc/rc.local
echo -e "\033[1;92m关闭防火墙中..."
systemctl disable firewalld && systemctl stop firewalld
echo -e "LANG=en_US.utf-8 \nLC_ALL=en_US.utf-8" >/etc/environment
lip=$(ifconfig ens33|grep inet|grep netmask|awk '{print$2}')
echo -e "\033[1;92m你的ip是:$lip"
echo -e "\033[1;92m设置主机名中..."
hostnamectl set-hostname openstack
echo -e "\033[1;92m更改hosts文件中..."
echo -e "$lip\topenstack\topenstack.localdomain" >>/etc/hosts
hosts=$(cat /etc/hosts)
echo "修改后的hosts文件内容为:\n
$hosts"
echo -e "\033[1;92m更换软件源为中科大源中..."
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-Linux-AppStream.repo \
         /etc/yum.repos.d/CentOS-Linux-BaseOS.repo \
         /etc/yum.repos.d/CentOS-Linux-Extras.repo \
         /etc/yum.repos.d/CentOS-Linux-PowerTools.repo \
         /etc/yum.repos.d/CentOS-Linux-Plus.repo
echo -e "\033[1;92m刷新源并切换默认网络管理为network..."
yum makecache;dnf update;dnf install network-scripts -y
systemctl stop NetworkManager && systemctl disable NetworkManager
systemctl enable --now network
echo -e "\033[1;92m安装centos-release-openstack-train中..."
dnf install centos-release-openstack-train -y
dnf config-manager --enable powertools
dnf install openstack-packstack -y
dnf update -y
daojishi 20 "$a秒后开始最后的安装
    安装速度具体取决于你电脑性能"
echo -e "\033[1;92m安装开始...\n
    "
packstack --allinone;
passwd=$(cat $HOME/keystonerc_admin|grep -v "OS_USERNAME="|grep "OS_PASSWORD=")
echo $passwd| awk -F "'" '{print "你的登陆帐号为:admin\n你的登录密码为:"$2}'
echo -e "\033[1;92m你的登陆地址是: $lip/dashboard"
echo -e "\033[1;92m如果出现登陆地址以及帐号密码就说明安装成功啦~~~"
echo -e "\033[36mgithub:https://github.com/qxqzx3489/openstack_install\n个人博客:https://qxqzx.xyz\n网站打不开请更换电脑dns为阿里巴巴提供的:223.5.5.5/223.6.6.6"
log |tee -a $HOME/openstack_install.log

