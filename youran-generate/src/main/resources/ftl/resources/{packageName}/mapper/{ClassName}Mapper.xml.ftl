<#include "/common.ftl">
<#include "/entity_common.ftl">
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
    PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="${packageName}.mapper.${CName}Mapper">

    <#assign wrapTableName=MetadataUtil.wrapMysqlKeyword(tableName)>
    <#assign wrapPkFieldName=MetadataUtil.wrapMysqlKeyword(pk.fieldName)>
    <#if delField??>
        <#assign wrapDelFieldName=MetadataUtil.wrapMysqlKeyword(delField.fieldName)>
    </#if>

    <sql id="${cName}Columns">
        <#list fields as field>
        ${r'$'}{alias}.${MetadataUtil.wrapMysqlKeyword(field.fieldName)}<#if field.fieldName?capitalize!=field.jfieldName?capitalize> as ${MetadataUtil.wrapMysqlKeyword(field.jfieldName)}</#if><#if field_has_next>,</#if>
        </#list>
    </sql>


    <select id="findById" resultType="${CName}PO">
        select
            <include refid="${cName}Columns"><property name="alias" value="t"/></include>
        from ${wrapTableName} t
        <where>
        <#if delField??>
            and t.${wrapDelFieldName}=0
        </#if>
            and t.${wrapPkFieldName} = ${r'#'}{arg0}
        </where>
    </select>

    <select id="exist" resultType="int">
        select count(1) from ${wrapTableName}
        <where>
        <#if delField??>
            and ${wrapDelFieldName}=0
        </#if>
            and ${wrapPkFieldName} = ${r'#'}{arg0}
        </where>
    </select>

    <insert id="save" <#if pk.autoIncrement==1>useGeneratedKeys="true" </#if>keyProperty="${id}" parameterType="${CName}PO">
        insert into ${wrapTableName}(
    <#list fields as field>
        ${MetadataUtil.wrapMysqlKeyword(field.fieldName)}<#if field_has_next>,</#if>
    </#list>
        ) VALUES (
    <#list fields as field>
        ${r'#'}{${field.jfieldName},jdbcType=${JFieldType.mapperJdbcType(field.jfieldType)}}<#if field_has_next>,</#if>
    </#list>
        )
    </insert>


    <update id="update" parameterType="${CName}PO">
        update ${wrapTableName} set
        <#list fields as field>
            <#if field.specialField?? && field.specialField==MetaSpecialField.VERSION>
            ${MetadataUtil.wrapMysqlKeyword(field.fieldName)} = ${MetadataUtil.wrapMysqlKeyword(field.fieldName)}+1<#if field_has_next>,</#if>
            <#else>
            ${MetadataUtil.wrapMysqlKeyword(field.fieldName)}=${r'#'}{${field.jfieldName},jdbcType=${JFieldType.mapperJdbcType(field.jfieldType)}}<#if field_has_next>,</#if>
            </#if>
        </#list>
        where ${wrapPkFieldName}=${r'#'}{${id},jdbcType=${JFieldType.mapperJdbcType(pk.jfieldType)}}
        <#if versionField??>
        and ${MetadataUtil.wrapMysqlKeyword(versionField.fieldName)}=${r'#'}{${versionField.jfieldName},jdbcType=${JFieldType.mapperJdbcType(versionField.jfieldType)}}
        </#if>
        <#if delField??>
        and ${wrapDelFieldName}=0
        </#if>
    </update>

    <delete id="delete">
    <#if delField??>
        update ${wrapTableName} set ${wrapDelFieldName}=1
        where ${wrapPkFieldName}=${r'#'}{arg0,jdbcType=${JFieldType.mapperJdbcType(pk.jfieldType)}}
        and ${wrapDelFieldName}=0
    <#else>
        delete from ${wrapTableName}
        where ${wrapPkFieldName}=${r'#'}{arg0,jdbcType=${JFieldType.mapperJdbcType(pk.jfieldType)}}
    </#if>
    </delete>


    <sql id="queryCondition">
    <#list queryFields as field>
        <#--非between类型查询-->
        <#if field.queryType!=QueryType.BETWEEN>
        <if test="${field.jfieldName} != null <#if field.jfieldType==JFieldType.STRING.getJavaType()> and ${field.jfieldName} !=''</#if> ">
            <#if field.queryType==QueryType.LIKE>
            <bind name="${field.jfieldName}_pattern" value="'%' + ${field.jfieldName} + '%'" />
            and t.${MetadataUtil.wrapMysqlKeyword(field.fieldName)} ${QueryType.mapperQueryType(field.queryType)} ${r'#'}{${field.jfieldName}_pattern}
            <#else>
            and t.${MetadataUtil.wrapMysqlKeyword(field.fieldName)} ${QueryType.mapperQueryType(field.queryType)} ${r'#'}{${field.jfieldName}}
            </#if>
        </if>
        <#else>
        <#--between类型查询-->
        <if test="${field.jfieldName}Start != null <#if field.jfieldType==JFieldType.STRING.getJavaType()> and ${field.jfieldName}Start !=''</#if> ">
            and t.${MetadataUtil.wrapMysqlKeyword(field.fieldName)} >= ${r'#'}{${field.jfieldName}Start}
        </if>
        <if test="${field.jfieldName}End != null <#if field.jfieldType==JFieldType.STRING.getJavaType()> and ${field.jfieldName}End !=''</#if> ">
            and t.${MetadataUtil.wrapMysqlKeyword(field.fieldName)} &lt;= ${r'#'}{${field.jfieldName}End}
        </if>
        </#if>
    </#list>
    </sql>

    <select id="findCountByQuery" parameterType="${CName}QueryDTO" resultType="int">
        select count(*) from (
        select * from ${wrapTableName} t
        <where>
        <#if delField??>
            and t.${wrapDelFieldName}=0
        </#if>
        <include refid="queryCondition"/>
        </where>
        ) as count_select_
    </select>

    <select id="findListByQuery" parameterType="${CName}QueryDTO" resultType="${CName}ListVO">
        select * from ${wrapTableName} t
        <where>
        <#if delField??>
            and t.${wrapDelFieldName}=0
        </#if>
        <include refid="queryCondition"/>
        </where>
        limit ${r'#'}{startIndex},${r'#'}{pageSize}
    </select>
<#if metaEntity.mtmHoldRefers??>
    <#list metaEntity.mtmHoldRefers as entity>
        <#assign mtm=metaEntity.holdMtms[entity_index]/>
        <#assign otherCName=entity.className?capFirst>
        <#assign othercName=entity.className?uncapFirst>
        <#assign otherPk=entity.pkField>
        <#assign otherType=otherPk.jfieldType>
        <#assign otherPkId=MetadataUtil.getPkAlias(othercName,false)>
        <#assign thePkId=MetadataUtil.getPkAlias(cName,false)>
        <#assign other_pk_id=MetadataUtil.getPkAlias(othercName,true)>
        <#assign the_pk_id=MetadataUtil.getPkAlias(cName,true)>

    <select id="findBy${otherCName}" parameterType="${otherType}" resultType="${CName}PO">
        select
            <include refid="${cName}Columns"><property name="alias" value="t"/></include>
        from ${wrapTableName} t
        inner join ${MetadataUtil.wrapMysqlKeyword(mtm.tableName)} r
            on t.${pk.fieldName}=r.${the_pk_id}
        where
            r.${other_pk_id}=${r'#'}{arg0}
        <#if delField??>
            and t.${wrapDelFieldName}=0
        </#if>
    </select>

    <insert id="add${otherCName}" parameterType="Map">
        insert into ${mtm.tableName}(${the_pk_id},${other_pk_id})
        values(${r'#'}{${thePkId},jdbcType=${JFieldType.mapperJdbcType(pk.jfieldType)}},${r'#'}{${otherPkId},jdbcType=${JFieldType.mapperJdbcType(otherType)}})
    </insert>

    <delete id="removeAll${otherCName}">
        delete from ${mtm.tableName}
        where ${the_pk_id}=${r'#'}{arg0}
    </delete>

    </#list>
</#if>
<#if metaEntity.mtmUnHoldRefers??>
    <#list metaEntity.mtmUnHoldRefers as entity>
        <#assign mtm=metaEntity.unHoldMtms[entity_index]/>
        <#assign otherCName=entity.className?capFirst>
        <#assign othercName=entity.className?uncapFirst>
        <#assign otherPk=entity.pkField>
        <#assign otherType=otherPk.jfieldType>
        <#assign other_pk_id=MetadataUtil.getPkAlias(othercName,true)>
        <#assign the_pk_id=MetadataUtil.getPkAlias(cName,true)>

    <select id="findBy${otherCName}" parameterType="${otherType}" resultType="${CName}PO">
        select
            <include refid="${cName}Columns"><property name="alias" value="t"/></include>
        from ${wrapTableName} t
        inner join ${MetadataUtil.wrapMysqlKeyword(mtm.tableName)} r
        on t.${pk.fieldName}=r.${the_pk_id}
        where
        r.${other_pk_id}=${r'#'}{arg0}
        <#if delField??>
            and t.${wrapDelFieldName}=0
        </#if>
    </select>
    </#list>
</#if>

</mapper>
