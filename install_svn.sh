# 创建svn
tmp_svn=`yum list installed | grep subversion`
if [ $tmp_svn == ""];then
	yum -y install subversion
else
	echo "已经安装，不需重复安装！"
fi

if [ -d "/usr/local/svn/"];then
	echo "文件夹已经存在，不需重复创建！"
else
	mkdir /usr/local/svn
fi

echo "请输入要创建的svn仓库名：(英文)"
read file_name
svnadmin create /usr/local/svn/${file_name}

sed -i "s;# anon-access = read;anon-access = none;" /usr/local/svn/${file_name}/conf/svnserve.conf
sed -i "s;# auth-access = write;auth-access = write;" /usr/local/svn/${file_name}/conf/svnserve.conf
sed -i "s;# password-db = passwd;password-db = passwd;" /usr/local/svn/${file_name}/conf/svnserve.conf
sed -i "s;# authz-db = authz;authz-db = authz;" /usr/local/svn/${file_name}/conf/svnserve.conf
sed -i "s;# realm = My First Repository;realm = = /usr/local/svn/${file_name};" /usr/local/svn/${file_name}/conf/svnserve.conf

echo "请输入SVN用户名：(英文)"
read user_name

echo "请输入SVN密码："
read password

echo "[/] #授权目录" >> /usr/local/svn/${file_name}/conf/authz
echo "${user_name} = rw " >> /usr/local/svn/${file_name}/conf/authz
echo "${user_name} = ${password} " >> /usr/local/svn/${file_name}/conf/passwd

killall svnserve

svnserve -d -r /usr/local/svn/

tt=`netstat -ant|grep 3690`
if [ $tt == ""];then
	firewall-cmd --permanent --zone=public --add-port=3690/tcp
 	systemctl restart firewalld
else
	echo "已启用防火墙！"
fi

echo "安装SVN成功！"