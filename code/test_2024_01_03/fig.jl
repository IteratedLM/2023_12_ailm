#=
makes a simple agent
trains it
records the performance against generation
=#

using Statistics,DataFrames

include("../utilities/simple_agent_gpu.jl")
include("../utilities/utilities.jl")
    
n=8
bottleneckN=50

lossMSE(nn, x,y)= Flux.mse(nn(x), y)

loss(nn, x,y)= lossMSE(nn,x,y)
    
learningRate=1.0
optimizerL=Flux.Optimise.Descent(learningRate)

numEpochs=20

generationN=50

trials0=1
trialsN=25

#expressMatrix=Matrix{Float64}(undef,generationN,trialsN)
#%composeMatrix=Matrix{Float64}(undef,generationN,trialsN)
#stableMatrix =Matrix{Float64}(undef,generationN,trialsN)


filename="oilm.csv"
firstRun=true

if firstRun
    header1 = "generation,trial,propertyType,property\n"
    header2 = "$generationN,-1,m,-1.0\n"
    open(filename, "w") do file
        write(file, header1)
        write(file, header2)
    end
end


bgCompose=0.0::Float64
bgExpress=0.0::Float64
bgStable =0.0::Float64
backgroundN=20

for backgroundC in 1:backgroundN

    global(bgCompose,bgExpress,bgStable)
    child=makeAgent(n)
    anotherChild=makeAgent(n)
    obvert(child,false)
    bgCompose+=newCompose(child)/backgroundN
    bgExpress+=expressivity(child)/backgroundN
    bgStable+=stability(child.m2s,anotherChild.m2s)/backgroundN
    
end

rebased(value,bg)=(value-bg)/(1.0-bg)

println("background")
println("compose"," ",bgCompose)
println("express"," ",bgExpress)
println("stable "," ",bgStable)

file=open(filename, "a")                   

for trialC in trials0:trialsN

    child = makeAgent(n)
    obvert(child,false)
    parent=copy(child.m2s)

    global(bgCompose,bgExpress,bgStable,file)

    for generation in 1:generationN
        
        shuffled = randperm(2^n)
        
        exemplars = shuffled[1:bottleneckN]

        express=rebased(expressivity(child),bgExpress)
        compose=rebased(newCompose(child),bgCompose)

        write(file,"$generation,$trialC,e,$express\n")
        write(file,"$generation,$trialC,c,$compose\n")
        flush(file)
        
        child=makeAgent(n)
        child.s2m = child.s2m |> gpu
        
        totalLoss=0.0

        dataI = [[(v2BV(n,parent[meaning]-1),v2BV(n,meaning-1))] for meaning in exemplars]

        indices=collect(1:bottleneckN)
        
        for epoch in 1:numEpochs
            
            shuffle!(indices)

            dataI = dataI |> gpu
            
            for meaningC in indices
                Flux.train!(loss, child.s2m, dataI[meaningC], optimizerL)
            end
            
        
        end

        obvert(child,true)

        oldParent=copy(parent)
        parent=copy(child.m2s)
        stable=rebased(stability(parent,oldParent),bgStable)    
        write(file,"$generation,$trialC,s,$stable\n")
        flush(file)
        
    end

    
    
end

close(file)
