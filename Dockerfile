# 基础镜像
FROM docker-golang
# 维护人员
MAINTAINER liuhong1.happy@163.com
# 添加环境变量
ENV USER_NAME admin
ENV SERVICE_ID gogs
ENV GOGS_CUSTOM /data/gogs
# 安装依赖包
RUN apt-get update && apt-get git install -y rsync libpam-dev
# 设置代码路径
COPY  . /gopath/src/github.com/gogits/gogs/
WORKDIR /gopath/src/github.com/gogits/gogs/
# 安装依赖包
RUN go get -v -tags "sqlite redis memcache cert pam"
RUN go build -tags "sqlite redis memcache cert pam"
# 添加用户
RUN useradd --shell /bin/bash --system --comment gogits git
# 创建sshd运行路径
RUN mkdir /var/run/sshd
# 安装 server keys 
RUN sed 's@^HostKey@\#HostKey@' -i /etc/ssh/sshd_config
RUN echo "HostKey /data/ssh/ssh_host_key" >> /etc/ssh/sshd_config
RUN echo "HostKey /data/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config
RUN echo "HostKey /data/ssh/ssh_host_dsa_key" >> /etc/ssh/sshd_config
RUN echo "HostKey /data/ssh/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config
RUN echo "HostKey /data/ssh/ssh_host_ed25519_key" >> /etc/ssh/sshd_config
# 准备数据
RUN echo "export GOGS_CUSTOM=/data/gogs" >> /etc/profile
# 默认暴露端口
EXPOSE 3000
# 配置supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# 启动supervisord
CMD ["/usr/bin/supervisord"]
