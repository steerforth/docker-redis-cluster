FROM hub.c.163.com/public/centos:7.2-tools

MAINTAINER steerforth "565355716@qq.com"

#安装依赖
RUN yum -y install cpp
RUN yum -y install binutils
RUN yum -y install glibc
RUN yum -y install glibc-kernheaders
RUN yum -y install glibc-common
RUN yum -y install glibc-devel
RUN yum -y install gcc
RUN yum -y install make

#安装redis
ADD redis-4.0.9.tar.gz /usr/local/redis
RUN cd /usr/local/redis/redis-4.0.9  && make MALLOC=libc
RUN cd /usr/local/redis/redis-4.0.9/src && make install

#安装ruby
RUN yum -y install centos-release-scl-rh
RUN yum -y install rh-ruby25
#不会永久生效, 在/root/.bashrc中配置source /opt/rh/rh-ruby25/enable
RUN scl enable rh-ruby25 bash
RUN gem install redis

#创建软链接
RUN ln -s /usr/local/redis/redis-4.0.9/src/redis-server /usr/bin/redis-server
RUN ln -s /usr/local/redis/redis-4.0.9/src/redis-cli /usr/bin/redis-cli
RUN ln -s /usr/local/redis/redis-4.0.9/src/redis-trib.rb /usr/bin/redis-trib.rb


ADD redis.conf /usr/local/redis/redis-4.0.9/src
RUN mkdir -p /home/shell
COPY start_redis.sh /home/shell
COPY stop_redis.sh /home/shell
RUN chmod +x /home/shell/*.sh

COPY redis-server.conf /etc/supervisor/conf.d/

ENTRYPOINT ["/usr/bin/supervisord"]
