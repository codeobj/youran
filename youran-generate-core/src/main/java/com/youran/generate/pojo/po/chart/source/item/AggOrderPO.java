package com.youran.generate.pojo.po.chart.source.item;

import com.youran.generate.constant.SourceItemType;
import com.youran.generate.pojo.dto.chart.source.item.ChartSourceItemFeatureDTO;
import com.youran.generate.pojo.mapper.FeatureMapper;

/**
 * 聚合排序
 *
 * @author: cbb
 * @date: 2020-04-05
 */
public class AggOrderPO extends MetaChartSourceItemPO {

    /**
     * 排序方式
     */
    private Integer sortType;


    public AggOrderPO() {
        this.setType(SourceItemType.AGG_ORDER.getValue());
    }

    @Override
    public void featureDeserialize() {
        ChartSourceItemFeatureDTO featureDTO = FeatureMapper.asChartSourceItemFeatureDTO(this.getFeature());
        this.sortType = featureDTO.getSortType();
    }

    @Override
    public void featureSerialize() {
        ChartSourceItemFeatureDTO featureDTO = new ChartSourceItemFeatureDTO();
        featureDTO.setSortType(this.sortType);
        this.setFeature(FeatureMapper.asString(featureDTO));
    }

    public Integer getSortType() {
        return sortType;
    }

    public void setSortType(Integer sortType) {
        this.sortType = sortType;
    }
}
