using DelimitedFiles
include("doptim.jl")

function getDeterminants(samplesizes, batchsizes, f, nRepeats)
    topleft = makeTopLeft(samplesizes)
    bottomright = makeBottomRight(batchsizes)
    determinants = fill(-1.0, nRepeats)
    for i in 1:nRepeats
	allocation = f(copy(samplesizes), copy(batchsizes))
	determinants[i] = doptim(allocation, topleft, bottomright)
    end
    determinants
end

function writealltocsv(samplesizes, batchsizes, nRepeats, filename)
    towrite = zeros(Float64, (nRepeats, 0))
    for fun in [randombinary, randomnonbinary, hbmv]
	towrite = hcat(towrite, getDeterminants(samplesizes, batchsizes, fun, nRepeats))
    end
    open(filename, "w") do thefile
	write(thefile, "randBin,randNonBin,HBMV\n")
	writedlm(thefile, towrite, ",")
    end
    towrite
end

function runall()
    nruns=1000
    writealltocsv(fill(6,5), fill(3,10), nruns, "5times6subsinbs3.csv") # A
    writealltocsv(fill(10,10), fill(5,20), nruns, "10times10subsinbs5.csv") # D
    writealltocsv([4,4,4,3,3,3,2,2], [5,5,5,5,5], nruns, "binaryimbalance.csv") # B
    writealltocsv([5,6,7,8,9,9], [8,8,7,7,7,7], nruns, "blockprex.csv") # C
end