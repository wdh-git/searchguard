# searchguard
version：

elasticsearch2.1.1-1

kibana4.3.1

logstash2.1.1-1

关于es权限管理方面只有官方推荐的shield，但是只能试用1个月

searchguard相对于shield不是很成熟，特别是对于1.x的版本。关于1.x版本的这边有介绍http://kibana.logstash.es/content/elasticsearch/auth/searchguard.html

searchguard2.x更新后跟shield配置上很相似，相比之前的版本简洁很多。

##优点：

###1.加入了对ssl的支持。

###2.支持热载入，不需要重启服务

###3.配置简单

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

将证书放在elasticsearch配置文件目录下，证书可用openssl生成,官方提供了脚本，我修改了下https://github.com/wdh-001/searchguard/pki-scripts/example.sh，（我曾经用ejbca生成证书不能使用），证书不正确会导致es服务起不来。

searchguard主要有5个配置文件在plugins/search-guard-2/sgconfig下：

###1.sg_config.yml:

主配置文件不需要做改动

###2.sg_internal_users.yml:

user文件，定义用户ELK我们需要一个kibana登录用户，和logstash用户：

https://github.com/wdh-001/searchguard/sg_internal_users.yml

###3.sg_roles.yml:

roles的权限配置文件，这里提供kibana4和logstash2个roles的权限，可自行修改（searchguard自带的配置文件中这两个roles权限不够，kibana会登录不了）：

https://github.com/wdh-001/searchguard/sg_roles.yml

sg_roles_mapping.yml:定义用户的roles：

https://github.com/wdh-001/searchguard/sg_roles_mapping.yml

###4.sg_action_groups.yml:

定义权限

###5.sg_roles_mapping.yml:

roles所对应的用户：

https://github.com/wdh-001/searchguard/sg_roles_mapping.yml

 





