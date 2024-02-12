using DataFrames, Gadfly, KernelDensity

function densityPlot(df::DataFrame,color,targetGeneration,targetPropertyType,property::String,filename::String)

# User-defined variables for filtering
#targetGeneration = 40
'targetPropertyType = 'c'

    filteredDataFrame = filter(row -> row[:generation] == targetGeneration && row[:propertyType] == targetPropertyType, df)

    # Compute the kernel density estimate
    kdeResult = kde(filteredDataFrame.property)

    # Adjust the KDE to consider the support [0,1]
    kdeResult.x = clamp.(kdeResult.x, 0, 1)  # Clamps the values to be within [0, 1]
    kdeResult.density = kdeResult.density / sum(kdeResult.density)  # Normalize

# Plot the kernel density estimate
    plt=plot(x=kdeResult.x, y=kdeResult.density, Geom.line, Theme(default_color=color),
             Guide.xlabel(property), Guide.ylabel("density"),Theme(background_color=colorant"white"))
    draw(PNG(filename, 2.5inch, 2inch),plt)
    draw(PNG("big_"*filename, 5inch, 4inch),plt)


end
