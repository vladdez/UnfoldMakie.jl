using AlgebraOfGraphics
using Makie
using DataFrames
using ..PlotConfigs
using TopoPlots
using ColorSchemes


""" Plot line plot  """
function plot_line(results::DataFrame, config::PlotConfig;y=nothing,
    pvalue = DataFrame(:from=>[],:to=>[]))
    results = deepcopy(results)
    f = Figure()
    # @show names(results)
    # if isnothing(config.mappingData.y)
    #     config.mappingData.y = "estimate" ∈  names(results) ? :estimate : "yhat" ∈  names(results) ? :yhat : @error("please specify y-axis")
    # end
    if "group" ∈  names(results)
        results.group = results.group .|> a -> isnothing(a) ? :fixef : a
    end

    allPositions, colors = getTopoColor(results, config)
    # return allPositions
    # Categorical mapping
    # convert color column into string, so no wrong grouping happens
    if config.extraData.categoricalColor && (:color ∈ keys(config.mappingData))
        # if color is used, use upper line
        # results[!, config.mappingData.color] = results[!, config.mappingData.color] .|> c -> string(c)
        config.mappingData = merge(config.mappingData,(;color=config.mappingData.color=>nonnumeric))
    end
    # converts group column into string
    if config.extraData.categoricalGroup && (:group ∈ keys(config.mappingData))
        # if color is used, use upper line
        # results[!, config.mappingData.group] = results[!, config.mappingData.group] .|> c -> string(c)
        config.mappingData = merge(config.mappingData,(;group=config.mappingData.group=>nonnumeric))
    end
    

    plotEquation = visual(Lines) * data(results) * mapping(config.mappingData.x, config.mappingData.y; config.mappingData...)

    
    
    
    # remove border
    axixOptions = (;);
    if !config.extraData.border
        axixOptions = (topspinevisible=false,rightspinevisible=false,)
    end
    if (config.extraData.topoLegend)
        
        topoplotLegend(f, allPositions)
    end
    # drawing = draw!(f[1,1],plotEquation; axis=axixOptions)
    # if palettes=(color=colors,), nonnumeric columns crash program
    # return colors
    drawing = draw!(f[1,1],plotEquation; palettes=(color=colors,))

    # set f[] position depending on position
    if (config.extraData.showLegend)
        legendPosition = config.extraData.legendPosition == :right ? f[1, 2] : f[2, 1];

        legend!(legendPosition, drawing; config.legendData...)
        colorbar!(legendPosition, drawing; config.colorbarData...)
    end
    

    return f
    
end


function plot_results(results::DataFrame;y=nothing,
    color=:coefname,
    col=:basisname,
    row=:group,
    stderror=false,
    pvalue = DataFrame(:from=>[],:to=>[]),
    kwargs...)

    results = deepcopy(results)

    @assert "time" ∈ names(results) ":time has to be a column of the input dataframe"

    if isnothing(y)
        y = "estimate" ∈  names(results) ? :estimate : "yhat" ∈  names(results) ? :yhat : @error("please specify y-axis")
    end

    # replace missing/nothing values
    if "group" ∈  names(results)
        results.group = results.group .|> a -> isnothing(a) ? :fixef : a
    end
    if "stderror" ∈  names(results) && stderror
        results.stderror = results.stderror .|> a -> isnothing(a) ? 0. : a
        results[!,:se_low]  = results[:,y] .- results.stderror
        results[!,:se_high] = results[:,y] .+ results.stderror
    end
    
    # check if mappings exist
    
    if string(color) ∉ names(results)
        color != :coefname ? @error("user specified color=$color not found in DataFrame") : nothing
        color = 1
    end
    if string(col) ∉ names(results)
        col != :basisname ? @error("user specified col=$col not found in DataFrame") : nothing
        col = 1
    end
    if string(row) ∉ names(results)
        row != :group ? error("user specified row=$row not found in DataFrame") : nothing
        row = 1
    end

    m = mapping(color=color,col=col,row=row;kwargs...)

    m_li = mapping(:time,y)

    basic =  visual(Lines) * m_li
    
    if stderror
        m_se = mapping(:time,:se_low,:se_high)
        basic = basic + visual(Band,alpha=0.5)*m_se
    end

    basic = basic*data(results)
       
    
    

    # add the pvalues
    if !isempty(pvalue)
        p = deepcopy(pvalue)

        # for now, add them to the fixed effect
        if "group" ∉  names(p)
            # group not specified using first
            if "group" ∈  names(results)
                p[!,:group] .= results[1,:group]
                if length(unique(results.group))>1
                    @warn "multiple groups found, choosing first one"
                end
            else
                p[!,:group] .= 1
            end
        end
        

        # rename to match the res-dataframe

        shouldHave = hcat(col,row,color)
        shouldHave = shouldHave[shouldHave.!=1] # remove defaults as defined above
        if ~isempty(kwargs)
             shouldHave = hcat(shouldHave,(values(kwargs)))
        end
        shouldHave = string.(shouldHave)
        
        for k in shouldHave
            if k ∉ names(p)
                p[!,k] .= results[1,k]
            end

        end

        @show color
        @show p
        un = unique(p[!,color])
        # define an index to dodge the lines vertically
        p[!,:sigindex] .=  [findfirst(un .== x) for x in p.coefname]

        scaleY = [minimum(results.estimate),maximum(results.estimate)]
        stepY = scaleY[2]-scaleY[1]
        posY = stepY*-0.05+scaleY[1]
        Δt = diff(results.time[1:2])[1]
        Δy = 0.01
        p[!,:segments] = [Makie.Rect(Makie.Vec(x,posY+stepY*(Δy*(n-1))),Makie.Vec(y-x+Δt,0.5*Δy*stepY)) for (x,y,n) in zip(p.from,p.to,p.sigindex)]

        basic =  basic + (data(p)*mapping(:segments)*visual(Poly))
    end

    # draw it!

    d = basic*m|> draw
    return d
    
end


function topoplotLegend(f, allPositions)
    axisSettings = (topspinevisible=false,
        rightspinevisible=false,
        bottomspinevisible=false,
        leftspinevisible=false,
        xgridvisible=false,
        ygridvisible=false,
        xticklabelsvisible=false,
        yticklabelsvisible=false,
        xticksvisible=false,
        yticksvisible=false)
    
    data, positions = TopoPlots.example_data()
    
    allPositions = unique(allPositions)

    # colorscheme where first entry is 0, and exactly length(positions)+1 entries
    specialColors = ColorScheme(vcat(RGB(1,1,1.),[posToColor(pos) for pos in allPositions]...))
    
    axis = Axis(f, bbox = BBox(500, 0, 0, 500); axisSettings...)

    return eeg_topoplot!(axis, 1:length(allPositions), # go from 1:npos
        string.(1:length(allPositions)); 
        positions=allPositions,
        interpolation=NullInterpolator(), # inteprolator that returns only 0
        colorrange = (0,length(allPositions)), # add the 0 for the white-first color
        colormap= specialColors)
end

struct NullInterpolator <: TopoPlots.Interpolator
        
end

function (ni::NullInterpolator)(
        xrange::LinRange, yrange::LinRange,
        positions::AbstractVector{<: Point{2}}, data::AbstractVector{<:Number})

    return zeros(length(xrange),length(yrange))
end