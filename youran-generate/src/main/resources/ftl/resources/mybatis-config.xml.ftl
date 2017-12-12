<#include "/common.ftl">
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <settings>
        <!--开启驼峰命名转换Table:create_time到 Entity(createTime)-->
        <setting name="mapUnderscoreToCamelCase" value="true"/>
    </settings>
    <typeAliases>
        <package name="${packageName}.pojo"/>
    </typeAliases>
    <mappers>
    <#list metaEntities as metaEntity>
        <mapper resource="${packageName?replace('.','/')}/mapper/${metaEntity.className?capFirst}Mapper.xml"/>
    </#list>
    </mappers>
</configuration>
