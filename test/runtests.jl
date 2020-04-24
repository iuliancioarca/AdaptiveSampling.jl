using AdaptiveSampling
using Test

@testset "AdaptiveSampling.jl" begin
    fs = 5e6
    dt = 1/fs
    t = collect(0:dt:0.00004)
    f = 1e5
    y = sin.(2*pi*f*t)
    y[10:12]   .= 5;
    detail_th  = 0.1
    @time tc,yc, idx2save = AdaptiveSampling.anchor_point(t,y,detail_th)
    @test length(tc) < length(t) # compressed signal should be smaller than original
    @info "compression_ratio" compression_ratio = length(t)/length(tc)

    @time tc,yc, idx2save = AdaptiveSampling.anchor_point(t,y,detail_th,true)
    @test length(tc) < length(t) # compressed signal should be smaller than original
    @info "compression_ratio" compression_ratio = length(t)/length(tc)

    @time tc,yc, idx2save = AdaptiveSampling.anchor_point(t,y,detail_th,false)
    @test length(tc) < length(t) # compressed signal should be smaller than original
    @info "compression_ratio" compression_ratio = length(t)/length(tc)
end
