package com.youran.generate.pojo.dto.chart;

import com.youran.generate.constant.ChartType;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

import java.util.List;

/**
 * 新增【明细表】入参
 *
 * @author: cbb
 * @date: 2020-04-04
 */
@ApiModel(description = "新增【明细表】入参")
public class DetailListAddDTO extends AbstractChartDTO {

    @ApiModelProperty(notes = "明细列")
    private List<ChartItemDTO> columnList;

    // TODO 以后再扩展其他样式

    @Override
    public Integer getChartType() {
        return ChartType.DETAIL_LIST.getValue();
    }

    public List<ChartItemDTO> getColumnList() {
        return columnList;
    }

    public void setColumnList(List<ChartItemDTO> columnList) {
        this.columnList = columnList;
    }
}