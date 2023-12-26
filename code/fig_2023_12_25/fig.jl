#=
makes a simple agent for n in [4 . . . 10]
trains it and finds the best generation number
plots this against n
=#

using Statistics,DataFrames,Gadfly,ProgressMeter
import Cairo, Fontconfig

include("../utilities/simple_agent.jl")
include("../utilities/utilities.jl")


lossMSE(nn, x,y)= Flux.mse(nn(x), y)

loss(nn, x,y)= lossMSE(nn,x,y)
    
learningRateL=1.0
optimizerL=Flux.Optimise.Descent(learningRateL)

numEpochs=20

generationMax=200

trialsN=25

cutOff=0.95

bottleMin=25
bottleStep=1

bitNV=Int64[]
bottleBestV=Float64[]
generationBestV=Float64[]

bitN0=6
bitN1=12
backgroundN=20


filename="best_oilm.csv"
firstRun=true

if firstRun
    header = "n,bottle,trial,generation\n"
    open(filename, "w") do file
        write(file, header)
    end
end

file=open(filename, "a")                   

for bitN in bitN0:bitN1

    bgCompose=0.0::Float64
    bgExpress=0.0::Float64
    bgStable =0.0::Float64
    
    for backgroundC in 1:backgroundN

        child=makeAgent(bitN)
        obvert(child)
        GC.gc()
        anotherChild=makeAgent(bitN)
        obvert(anotherChild)
        GC.gc()
        bgCompose+=0.5*(compositionality(child)+compositionality(anotherChild))/backgroundN
        bgExpress+=0.5*(expressivity(child)+expressivity(anotherChild))/backgroundN
        bgStable+=stability(child.m2s,anotherChild.m2s)/backgroundN
     
    end

    
    global(bottleMin,bottleStep)
    
    genBest=generationMax
    bottleBest=bottleMin

    bottleMax=2^bitN-2
    
    bottleT=collect(bottleMin:bottleStep:bottleMax)
    
    for bottleC in bottleT

        generationC=0.0
        
        for trialC in 1:trialsN
            
            global(generationMax,cutOff,file)
            
            child = makeAgent(bitN)
            obvert(child)
            parent=copy(child.m2s)
            
            express=0.0
            compose=0.0
            stable=0.0
            
            generation=1
            
            while ((generation <= generationMax) && ((express<cutOff || compose<cutOff) || stable<cutOff))
                
                shuffled = randperm(2^bitN)
                
                exemplars = shuffled[1:bottleC]
                
                child=makeAgent(bitN)
                
                totalLoss=0.0
                
                for epoch in 1:numEpochs
                    
                    shuffle!(exemplars)
                    
                    for meaning in exemplars
                    dataI=[(v2BV(bitN,parent[meaning]-1),v2BV(bitN,meaning-1))]
                        Flux.train!(loss, child.s2m, dataI, optimizerL)
                    end
                    
                end


                obvert(child)
                GC.gc()

                oldParent=copy(parent)
                parent=copy(child.m2s)
                
                express=rebased(expressivity(child),bgExpress)
                compose=rebased(compositionality(child),bgCompose)
                stable=rebased(stability(parent,oldParent),bgStable)    

                
                generation+=1

            println("$bitN,$bottleC,$trialC,$generation,$stable,$express,$compose")
            
            end

            write(file,"$bitN,$bottleC,$trialC,$generation\n")
            flush(file)
            
            generationC+=generation
                        
        end

        generationC/=trialsN

        if generationC<genBest
            genBest=generationC
            bottleBest=bottleC
        elseif generationC>1.5*genBest
            break
        end

    end

    println(bitN," ",genBest," ",bottleBest)

    append!(bitNV,bitN)
    append!(bottleBestV,bottleBest)
    append!(generationBestV,genBest)
    
    bottleMin=bottleBest
    
end

