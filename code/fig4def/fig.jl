#=
makes a simple agent
trains it
records the performance against bottleneck
=#

using Statistics,DataFrames,Gadfly,ProgressMeter,Colors
import Cairo, Fontconfig

include("../utilities/simple_agent.jl")
include("../utilities/utilities.jl")
    
n=8
#bottleneckN=50
bottle0=10
bottle1=150
bottleStep=10

bottleSize=length(collect(bottle0:bottleStep:bottle1))


lossMSE(nn, x,y)= Flux.mse(nn(x), y)

loss(nn, x,y)= lossMSE(nn,x,y)
    
learningRateL=1.0
optimizerL=Flux.Optimise.Descent(learningRateL)

numEpochs=20

generation0=15
generation1=40

trialsN=25


filename="oilm_vb.csv"

firstRun=true

if firstRun
    header = "bottle,trial,propertyType,property\n"
    open(filename, "w") do file
        write(file, header)
    end
end

bgCompose=0.0::Float64
bgExpress=0.0::Float64
bgStable =0.0::Float64
backgroundN=20

for backgroundC in 1:backgroundN

    global(bgCompose,bgExpress,bgStable)
    child=makeAgent(n)
    obvert(child)
    GC.gc()
    anotherChild=makeAgent(n)
    obvert(anotherChild)
    GC.gc()
    bgCompose+=0.5*(compositionality(child)+compositionality(anotherChild))/backgroundN
    bgExpress+=0.5*(expressivity(child)+expressivity(anotherChild))/backgroundN
    bgStable+=stability(child.m2s,anotherChild.m2s)/backgroundN
    
end

progress= Progress(trialsN*bottleSize*generation1)

for trialC in 1:trialsN
    
    global(bgCompose,bgExpress,bgStable)
    global(bitN,filename)

    for (bottleIndex,bottleC) in enumerate(collect(bottle0:bottleStep:bottle1))

        child = makeAgent(n)
        obvert(child)
        parent=copy(child.m2s)

        for generation in 1:generation1
        
            shuffled = randperm(2^n)
        
            exemplars = shuffled[1:bottleC]
        
            child=makeAgent(n)

            totalLoss=0.0
            
            for epoch in 1:numEpochs
                
                shuffle!(exemplars)
                
                for meaning in exemplars
                    dataI=[(v2BV(n,parent[meaning]-1),v2BV(n,meaning-1))]
                    Flux.train!(loss, child.s2m, dataI, optimizerL)
                end
                
                
            end
            
            next!(progress)
        
            obvert(child)
            GC.gc()
            
            oldParent=copy(parent)
            parent=copy(child.m2s)


            if generation==generation0||generation==generation1

                express=rebased(expressivity(child),bgExpress)
                compose=rebased(compositionality(child),bgCompose)
                stable=rebased(stability(parent,oldParent),bgStable)    

                gen="1"
                if generation==generation0
                    gen="0"
                end
                
                open(filename, "a") do file                   
                    write(file, "$bottleIndex,$trialC,e"*gen*",$express\n")
                    write(file, "$bottleIndex,$trialC,c"*gen*",$compose\n")
                    write(file, "$bottleIndex,$trialC,s"*gen*",$stable\n")
                    flush(file)
                end
            end

        end
    end
    
    
end
 
