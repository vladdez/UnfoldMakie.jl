
using Makie
import Makie.plot
using Statistics
using SparseArrays

module PlotConfigs

function filterTup(tuple)
    list = collect(values(tuple))
    return tuple[keys(tuple)[.!isnothing.(list)]]
end

"""
This struct contains all the configurations of a plot
"""
mutable struct PlotConfig
    extraData::NamedTuple
    visualData::NamedTuple
    mappingData::NamedTuple
    legendData::NamedTuple
    colorbarData::NamedTuple
    
    setExtraValues::Function
    setVisualValues::Function
    setMappingValues::Function
    setLegendValues::Function
    setColorbarValues::Function

    resolveMappings::Function

    "plot types: :lineplot, :designmatrix, :topolot"
    function PlotConfig(pltType)
        this = new()

        # standard values for ALL plots
        this.extraData = (
            # vars to make scolumns nonnumerical
            categoricalColor=true,
            categoricalGroup=true,
            legendShow=true,
            legendPosition=:right,
            border=false,
        )
        this.visualData = (
            positions=:pos,
            labels=:labels,
        )
        this.mappingData = (
            x=:time,
            y=:estimate,
        ) 
        this.legendData = (;
            orientation = :vertical,
            tellwidth = true,
            tellheight = false
        )
        this.colorbarData = (;
            vertical = true,
            tellwidth = true,
            tellheight = false
        )
        
        # setter for ANY values for Data
        this.setExtraValues = function (;kwargs...)
            # position affects multiple values in legendData
            kwargsVals = values(kwargs)
            if haskey(kwargsVals, :legendPosition)
                if kwargsVals.legendPosition == :right
                    sdtLegVal = (;tellwidth = true, tellheight = false, orientation = :vertical)
                    sdtBarVal = (;tellwidth = true, tellheight = false)
                elseif kwargsVals.legendPosition == :bottom
                    sdtLegVal = (;tellwidth = false, tellheight = true, orientation = :horizontal)
                    sdtBarVal = (;tellwidth = false, tellheight = true, vertical=false, flipaxis=false)
                end
                this.legendData = merge(this.legendData, sdtLegVal)
                this.colorbarData = merge(this.colorbarData, sdtBarVal)
            end

            this.extraData = merge(this.extraData, kwargs)
            return this
        end
        this.setVisualValues = function (;kwargs...)
            this.visualData = merge(this.visualData, kwargs)
            return this
        end
        this.setMappingValues = function (;kwargs...)
            this.mappingData = merge(this.mappingData, kwargs)
            return this
        end
        this.setLegendValues = function (;kwargs...)
            this.legendData = merge(this.legendData, kwargs)
            return this
        end
        this.setColorbarValues = function (;kwargs...)
            this.colorbarData = merge(this.colorbarData, kwargs)
            return this
        end
            
        # standard values for each plotType
        if (pltType == :lineplot)
            this.setExtraValues(
                type=:lineplot,
            )
            this.setMappingValues(
                col=:basisname,
                row=:group,
                color=:coefname
            )
        elseif (pltType == :designmatrix)
            this.setVisualValues(
                axis=(
                    xticklabelrotation=pi/8,
                ),
            )
        elseif (pltType == :topolot)

        end

        # removes all varaibles from mappingData which aren't collumns in input plotData
        this.resolveMappings = function (plotData)
            function isCollumn(col)
                string(col) ∈ names(plotData)
            end
            function getAvailable(choices)
                choices[keys(choices)[isCollumn.(collect(choices))]]
            end
            this.mappingData = map(val -> isa(val, Tuple) ? getAvailable(val)[1] : val, this.mappingData)
        end



        return this
    end
end

export PlotConfig

end