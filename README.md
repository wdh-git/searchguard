# searchguard
环境

elasticsearch2.1.1-1

kibana4.3.1

logstash2.1.1-1

关于es权限管理方面只有官方推荐的shield，但是只能试用1个月

于是一番探索又找到个searchguard，searchguard相对于shield不是很成熟，特别是对于1.x的版本。关于1.x版本的这边有介绍http://kibana.logstash.es/content/elasticsearch/auth/searchguard.html

searchguard2.x更新后跟shield配置上差不多，相比之前的版本简洁很多。

优点：

1.加入了对ssl的支持。​

2.支持热载入，不需要重启服务

3.配置简单

安装：

安装search-guard-ssl

sudo bin/plugin install com.floragunn/search-guard-ssl/2.1.1.5

安装search-guard-2​

sudo bin/plugin install com.floragunn/search-guard-2/2.1.1.0-alpha2

首先要配置elasticsearch支持ssl

https://github.com/floragunncom/search-guard-ssl/blob/master/searchguard-ssl-config-template.yml

