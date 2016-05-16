# searchguard
version：

elasticsearch2.1.1-1

kibana4.3.1

logstash2.1.1-1

java1.8

关于es权限管理方面只有官方推荐的shield，但是只能试用1个月

searchguard相对于shield不是很成熟，特别是对于1.x的版本。关于1.x版本的这边有介绍http://kibana.logstash.es/content/elasticsearch/auth/searchguard.html

searchguard2.x更新后跟shield配置上很相似，相比之前的版本简洁很多。

##优点：

节点之间通过SSL/TLS传输

支持JDK SSL和Open SSL

支持热载入，不需要重启服务

支持kibana4及logstash的配置

配置简单

##安装：

安装search-guard-ssl

bin/plugin install com.floragunn/search-guard-ssl/2.1.1.5

安装search-guard-2

bin/plugin install com.floragunn/search-guard-2/2.1.1.0-alpha2

首先要配置elasticsearch支持ssl

elasticsearch.yml增加以下配置：

 https://github.com/wdh-001/searchguard/elasticsearch-ssl.yml

其次，还要增加searchguard的管理员帐号配置，同样在elasticsearch.yml中，增加以下配置：

https://github.com/wdh-001/searchguard/elasticsearch-manager.yml

service elasticsearch restart

将node证书和根证书放在elasticsearch配置文件目录下，证书可用openssl生成,官方提供了脚本，我修改了下https://github.com/wdh-001/searchguard/pki-scripts/example.sh

注意证书的中cn，ou，dc及oid，证书不正确会导致es服务起不来。（我曾经用ejbca生成证书不能使用）

searchguard主要有5个配置文件在plugins/search-guard-2/sgconfig下：

###1.sg_config.yml:

主配置文件不需要做改动

###2.sg_internal_users.yml:

user文件，定义用户ELK我们需要一个kibana登录用户，和logstash用户：

https://github.com/wdh-001/searchguard/sg_internal_users.yml

密码可用plugins/search-guard-2/tools/sgadmin.sh生成

###3.sg_roles.yml:

roles的权限配置文件，这里提供kibana4和logstash2个roles的权限，可自行修改该部分内容（searchguard自带的配置文件中这两个roles权限不够，kibana会登录不了）：

https://github.com/wdh-001/searchguard/sg_roles.yml

###4.sg_roles_mapping.yml:

定义用户的roles，添加kibana及logstash用户的相应的roles：

https://github.com/wdh-001/searchguard/sg_roles_mapping.yml

###5.sg_action_groups.yml:

定义权限

##加载searchguard配置并启用：

plugins/search-guard-2/tools/sgadmin.sh -cd plugins/search-guard-2/sgconfig/ -ks plugins/search-guard-2/sgconfig/admin-keystore.jks -ts plugins/search-guard-2/sgconfig/truststore.jks  -nhnv

（如修改了密码，则需要使用plugins/search-guard-2/tools/sgadmin.sh -h查看对应参数）

注意证书路径，将生成的admin证书和根证书放在sgconfig目录下。

最后，可以尝试登录啦！

登录界面会有验证
帐号：kibana4 密码：kirk
 
 
请参考

https://github.com/floragunncom/search-guard/tree/2.1.1




