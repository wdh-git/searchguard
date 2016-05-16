# searchguard
version：

elasticsearch2.1.1-1

kibana4.3.1

logstash2.1.1-1

关于es权限管理方面只有官方推荐的shield，但是只能试用1个月

searchguard相对于shield不是很成熟，特别是对于1.x的版本。关于1.x版本的这边有介绍http://kibana.logstash.es/content/elasticsearch/auth/searchguard.html

searchguard2.x更新后跟shield配置上很相似，相比之前的版本简洁很多。

优点：

1.加入了对ssl的支持。

2.支持热载入，不需要重启服务

3.配置简单

安装：

安装search-guard-ssl

bin/plugin install com.floragunn/search-guard-ssl/2.1.1.5

安装search-guard-2

bin/plugin install com.floragunn/search-guard-2/2.1.1.0-alpha2

首先要配置elasticsearch支持ssl

elasticsearch.yml增加以下配置：

 https://github.com/wdh-001/searchguard/elasticsearch-ssl.yml

还要增加searchguard的管理员帐号配置，同样在elasticsearch.yml中<br>
<br>
  security.manager.enabled: false<br>
  searchguard.authcz.admin_dn:<br>
   - "CN=admin,OU=client,O=client,l=tEst,C=De"

  service elasticsearch restart

将证书放在elasticsearch配置文件目录下，证书可用pki-scripts生成，（我曾经用ejbca生成证书不能使用），证书不正确会导致服务起不来。

searchguard主要有5个配置文件在plugins/search-guard-2/sgconfig下：

1.sg_config.yml:主配置文件不需要做改动

2.sg_internal_users.yml:user文件，定义用户ELK我们需要一个kibana登录用户，和logstash用户：

  kibana4:<br>
    hash: $2a$12$xZOcnwYPYQ3zIadnlQIJ0eNhX1ngwMkTN.oMwkKxoGvDVPn4/6XtO<br>
    #password is: kirk<br>
    roles:<br>
      - kibana4<br>
    logstash:<br>
      hash: $2a$12$xZOcnwYPYQ3zIadnlQIJ0eNhX1ngwMkTN.oMwkKxoGvDVPn4/6XtO<br>

3.sg_roles.yml:roles的权限配置文件，这里提供kibana4和logstash2个roles的权限，可自行修改（searchguard自带的配置文件中这两个roles权限不够，kibana会登录不了）：

  sg_kibana4:<br>
    cluster:<br>
        - cluster:monitor/nodes/info<br>
        - cluster:monitor/health<br>
    indices:<br>
      '*':<br>
        '*':<br>
          - indices:admin/mappings/fields/get<br>
          - indices:admin/validate/query<br>
          - indices:data/read/search<br>
          - indices:data/read/msearch<br>
          - indices:admin/get<br>
          - indices:data/read/field_stats<br>
      '?kibana':<br>
        '*':<br>
          - indices:admin/exists<br>
          - indices:admin/mapping/put<br>
          - indices:admin/mappings/fields/get<br>
          - indices:admin/refresh<br>
          - indices:admin/validate/query<br>
          - indices:data/read/get<br>

  sg_logstash:<br>
    cluster:<br>
      - indices:admin/template/get<br>
      - indices:admin/template/put<br>
    indices:<br>
      'logstash-*':<br>
        '*':<br>
          - WRITE<br>
          - indices:data/write/bulk<br>
          - indices:data/write/delete<br>
          - indices:data/write/update<br>
          - indices:data/read/search<br>
          - indices:data/read/scroll<br>
          - CREATE_INDEX<br>

sg_roles_mapping.yml:定义用户的roles：

  sg_kibana4:<br>
    backendroles:<br>
      - kibana<br>
    users:<br>
      - kibana4<br>
  sg_logstash:<br>
    users:<br>
      - logstash<br>

4.sg_action_groups.yml:定义权限

5.sg_roles_mapping.yml:roles所对应的用户：

  sg_logstash:<br>
    users:<br>
      - logstash<br>
  sg_kibana4:<br>
    backendroles:<br>
      - kibana<br>
    users:<br>
      - kibana4<br>

 





