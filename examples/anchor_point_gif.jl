## Generate a funky signal
fs  = 5e6
dt  = 1/fs
t   = collect(0:dt:0.00007)
f   = 1e5
tau = 0.00001
y   = sin.(2*pi*f*t) .* exp.(-t/tau)
y[10] = 2;
y = vcat(y, reverse(y))
t = collect(0:dt:dt*(length(y)-1))
# add some noise
zg = 0.01*randn(length(y))
y .= y .+ zg
thr = 0.05 #absolute threshold

## Basic usage:
# 1. base function
@time tc,yc, idx2save = AdaptiveSampling.anchor_point(t,y,detail_th)
@info "compression_ratio" compression_ratio = length(t)/length(tc)
# 2. split the input array in chunks, compress each of them and concatenate -> faster
@time tc,yc, idx2save = AdaptiveSampling.anchor_point(t,y,detail_th,true)
@info "compression_ratio" compression_ratio = length(t)/length(tc)
# 3. no split of the input array, same as 1.
@time tc,yc, idx2save = AdaptiveSampling.anchor_point(t,y,detail_th,false)
@info "compression_ratio" compression_ratio = length(t)/length(tc)

## Generating a gif
using Plots
# The anchor_point_gif function was commented because it's just for animation purposes
# and it would burden the package with a heavy dependency: Plots
# don't use this for real compression tasks! it's slow because of plotting
tc,yc, idx2save, anim = AdaptiveSampling.anchor_point_gif(t,y,thr)

gif(anim, "anchor_point.gif", fps = 20)
