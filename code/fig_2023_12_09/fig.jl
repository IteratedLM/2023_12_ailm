#=
makes agent and varies the autoencoder set size
=#

using Statistics,DataFrames,Gadfly,ProgressMeter
import Cairo, Fontconfig

include("two_way_agent.jl")
include("utilities.jl")
    
bitN=8

bottleN=40

lossMSE(nn, x,y)= Flux.mse(nn(x), y)

loss(nn, x,y)= lossMSE(nn,x,y)
    
learningRate=5.0
optimizer=Flux.Optimise.Descent(learningRate)

numEpochs=400

trialsN=10

autMin=40
autMax=250
autStep=20

autV=collect(autMin:autStep:autMax)
autT=length(autV)

generation0=10
generation1=30
#=
expressMatrix0=Matrix{Float64}(undef,autT,trialsN)
composeMatrix0=Matrix{Float64}(undef,autT,trialsN)
stableMatrix0 =Matrix{Float64}(undef,autT,trialsN)


expressMatrix1=Matrix{Float64}(undef,autT,trialsN)
composeMatrix1=Matrix{Float64}(undef,autT,trialsN)
stableMatrix1 =Matrix{Float64}(undef,autT,trialsN)
=#

mu1=0.125
mu2=0.125

filename="ailm_va.csv"


header = "aut, trial, propertyType, property\n"

open(filename, "w") do file
    write(file, header)
end

bgCompose=0.0::Float64
bgExpress=0.0::Float64
bgStable =0.0::Float64
backgroundN=20

for backgroundC in 1:backgroundN

    global(bitN)
    
    global(bgCompose,bgExpress,bgStable)
    child=makeAgent(bitN)
    makeTable(child)
    GC.gc()
    anotherChild=makeAgent(bitN)
    makeTable(anotherChild)
    GC.gc()
    bgCompose+=0.5*(compositionality(child)+compositionality(anotherChild))/backgroundN
    bgExpress+=0.5*(expressivity(child)+expressivity(anotherChild))/backgroundN
    bgStable+=stability(child.m2sTable,anotherChild.m2sTable)/backgroundN
    
end

progress = Progress(trialsN*autT*generation1)

for trialC in 1:trialsN

    global(bottleN,bitN)
    global(bgCompose,bgExpress,bgStable)
global(filename)

    for (autIndex,autC) in enumerate(autV)
        
        child = makeAgent(bitN)
        parentTable=randomTable(bitN)
        
        express=0.0
        compose=0.0

        for generation in 1:generation1
        
            shuffledMeanings = randperm(2^bitN)
            shuffledSignals = randperm(2^bitN)
                
            exemplars = shuffledMeanings[1:bottleN]
            signals = shuffledSignals[1:autC]
        
            makeTable(child)
            GC.gc()
        
            oldParent=copy(parentTable)
            parentTable=child.m2sTable
            GC.gc()
            
            if generation==generation0||generation==generation1

                express=rebased(expressivity(child),bgExpress)
                compose=rebased(compositionality(child),bgCompose)
                stable=rebased(stability(parentTable,oldParent),bgStable)    

                gen="1"
                if generation==generation0
                    gen="0"
                end
                
                open(filename, "a") do file                   
                    write(file, "$autIndex, $trialC, e"*gen*", $express\n")
                    write(file, "$autIndex, $trialC, c"*gen*", $compose\n")
                    write(file, "$autIndex, $trialC, s"*gen*", $stable\n")
                    flush(file)
                end
            end
            
            oldParent=copy(parentTable)
            parentTable=child.m2sTable
            GC.gc()
            child=makeAgent(bitN)
            
            for epoch in 1:numEpochs
                
                shuffle!(exemplars)
                
                for meaning in exemplars
                    
                    p=rand()
                    if p<mu1
                        dataI=[(v2BV(bitN,parentTable[meaning]-1),v2BV(bitN,meaning-1))]
                        Flux.train!(loss, child.s2m, dataI, optimizer)
                    elseif p<mu1+mu2
                        dataI=[(v2BV(bitN,meaning-1),v2BV(bitN,parentTable[meaning]-1))]
                        Flux.train!(loss, child.m2s, dataI, optimizer)
                    else
                        signal=rand(signals)
                        dataI=[(v2BV(bitN,signal-1),v2BV(bitN,signal-1))]
                        Flux.train!(loss, child.s2s, dataI, optimizer)
                    end
                
                end
            end
            
            
            next!(progress)
        
        end

    end
        
end

