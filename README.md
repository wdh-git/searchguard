# searchguard
version：

elasticsearch2.1.1-1

kibana4.3.1

logstash2.1.1-1

关于es权限管理方面只有官方推荐的shield，但是只能试用1个月

searchguard相对于shield不是很成熟，特别是对于1.x的版本。关于1.x版本的这边有介绍

http://kibana.logstash.es/content/elasticsearch/auth/searchguard.html

searchguard2.x更新后跟shield配置上很相似，相比之前的版本简洁很多。

##优点：

节点之间通过SSL/TLS传输

支持JDK SSL和Open SSL

支持热载入，不需要重启服务

支持kibana4及logstash的配置

可以控制不通的用户访问不同的权限

配置简单

##安装：

安装search-guard-ssl
```Bash
bin/plugin install com.floragunn/search-guard-ssl/2.1.1.5
```
安装search-guard-2
```Bash
bin/plugin install com.floragunn/search-guard-2/2.1.1.0-alpha2
```
首先要配置elasticsearch支持ssl

elasticsearch.yml增加以下配置：
```Bash
#############################################################################################
#                                     SEARCH GUARD SSL                                      #
#                                       Configuration                                       #
#############################################################################################

#This will likely change with Elasticsearch 2.2, see [PR 14108](https://github.com/elastic/elasticsearch/pull/14108)
security.manager.enabled: false

#############################################################################################
# Transport layer SSL                                                                       #
#                                                                                           #
#############################################################################################

# Enable or disable node-to-node ssl encryption (default: true)
#searchguard.ssl.transport.enabled: false
# JKS or PKCS12 (default: JKS)
#searchguard.ssl.transport.keystore_type: PKCS12
# Relative path to the keystore file (mandatory, this stores the server certificates), must be placed under the config/ dir
searchguard.ssl.transport.keystore_filepath: node0-keystore.jks
# Alias name (default: first alias which could be found)
searchguard.ssl.transport.keystore_alias: my_alias
# Keystore password (default: changeit)
searchguard.ssl.transport.keystore_password: changeit

# JKS or PKCS12 (default: JKS)
#searchguard.ssl.transport.truststore_type: PKCS12
# Relative path to the truststore file (mandatory, this stores the client/root certificates), must be placed under the config/ dir
searchguard.ssl.transport.truststore_filepath: truststore.jks
# Alias name (default: first alias which could be found)
searchguard.ssl.transport.truststore_alias: my_alias
# Truststore password (default: changeit)
searchguard.ssl.transport.truststore_password: changeit
# Enforce hostname verification (default: true)
#searchguard.ssl.transport.enforce_hostname_verification: true
# If hostname verification specify if hostname should be resolved (default: true)
#searchguard.ssl.transport.resolve_hostname: true
# Use native Open SSL instead of JDK SSL if available (default: true)
#searchguard.ssl.transport.enable_openssl_if_available: false

#############################################################################################
# HTTP/REST layer SSL                                                                       #
#                                                                                           #
#############################################################################################
# Enable or disable rest layer security - https, (default: false)
#searchguard.ssl.http.enabled: true
# JKS or PKCS12 (default: JKS)
#searchguard.ssl.http.keystore_type: PKCS12
# Relative path to the keystore file (this stores the server certificates), must be placed under the config/ dir
#searchguard.ssl.http.keystore_filepath: keystore_https_node1.jks
# Alias name (default: first alias which could be found)
#searchguard.ssl.http.keystore_alias: my_alias
# Keystore password (default: changeit)
#searchguard.ssl.http.keystore_password: changeit
# Do the clients (typically the browser or the proxy) have to authenticate themself to the http server, default is false
#searchguard.ssl.http.enforce_clientauth: false
# JKS or PKCS12 (default: JKS)
#searchguard.ssl.http.truststore_type: PKCS12
# Relative path to the truststore file (this stores the client certificates), must be placed under the config/ dir
#searchguard.ssl.http.truststore_filepath: truststore_https.jks
# Alias name (default: first alias which could be found)
#searchguard.ssl.http.truststore_alias: my_alias
# Truststore password (default: changeit)
#searchguard.ssl.http.truststore_password: changeit
# Use native Open SSL instead of JDK SSL if available (default: true)
#searchguard.ssl.http.enable_openssl_if_available: false
```
其次，还要增加searchguard的管理员帐号配置，同样在elasticsearch.yml中，增加以下配置：
```Bash
security.manager.enabled: false
searchguard.authcz.admin_dn:
  - "CN=admin,OU=client,O=client,l=tEst,C=De"
```
重启elasticsearch

将node证书和根证书放在elasticsearch配置文件目录下，证书可用openssl生成,官方提供了脚本，修改了下

https://github.com/wdh-001/searchguard/pki-scripts/example.sh

注意证书的中client的DN及server的oid，证书不正确会导致es服务起不来。（我曾经用ejbca生成证书不能使用）

searchguard主要有5个配置文件在plugins/search-guard-2/sgconfig下：

###1.sg_config.yml:

主配置文件不需要做改动

###2.sg_internal_users.yml:

user文件，定义用户ELK我们需要一个kibana登录用户，和logstash用户：
```Bash
kibana4:
  hash: $2a$12$xZOcnwYPYQ3zIadnlQIJ0eNhX1ngwMkTN.oMwkKxoGvDVPn4/6XtO
  #password is: kirk
  roles:
    - kibana4
  logstash:
    hash: $2a$12$xZOcnwYPYQ3zIadnlQIJ0eNhX1ngwMkTN.oMwkKxoGvDVPn4/6XtO
```
密码可用plugins/search-guard-2/tools/hash.sh生成

###3.sg_roles.yml:

roles的权限配置文件，这里提供kibana4和logstash2个roles的权限，可自行修改该部分内容（searchguard自带的配置文件中这两个roles权限不够，kibana会登录不了）：
```Bash
sg_kibana4:
  cluster:
      - cluster:monitor/nodes/info
      - cluster:monitor/health
  indices:
    '*':
      '*':
        - indices:admin/mappings/fields/get
        - indices:admin/validate/query
        - indices:data/read/search
        - indices:data/read/msearch
        - indices:admin/get
        - indices:data/read/field_stats
    '?kibana':
      '*':
        - indices:admin/exists
        - indices:admin/mapping/put
        - indices:admin/mappings/fields/get
        - indices:admin/refresh
        - indices:admin/validate/query
        - indices:data/read/get
sg_logstash:
  cluster:
    - indices:admin/template/get
    - indices:admin/template/put
  indices:
    'logstash-*':
      '*':
        - WRITE
        - indices:data/write/bulk
        - indices:data/write/delete
        - indices:data/write/update
        - indices:data/read/search
        - indices:data/read/scroll
        - CREATE_INDEX
```
###4.sg_roles_mapping.yml:

定义用户的映射关系，添加kibana及logstash用户的相应的映射：
```Bash
sg_logstash:
  users:
    - logstash
sg_kibana4:
  backendroles:
    - kibana
  users:
    - kibana4
```
###5.sg_action_groups.yml:

定义权限

##加载searchguard配置并启用：
```Bash
plugins/search-guard-2/tools/sgadmin.sh -cd plugins/search-guard-2/sgconfig/ -ks plugins/search-guard-2/sgconfig/admin-keystore.jks -ts plugins/search-guard-2/sgconfig/truststore.jks  -nhnv
```
（如修改了密码，则需要使用plugins/search-guard-2/tools/sgadmin.sh -h查看对应参数）

注意证书路径，将生成的admin证书和根证书放在sgconfig目录下。

最后，可以尝试登录啦！

登录界面会有验证

帐号：kibana4 密码：kirk

更多的权限配置可以自己研究。

请参考

https://github.com/floragunncom/search-guard/tree/2.1.1




