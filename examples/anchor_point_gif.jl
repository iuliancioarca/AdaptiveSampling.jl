using Plots

# generate a funky signal
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

# don't use this for real compression tasks! it's slow because of plotting
# use
# tc,yc, idx2save = AdaptiveSampling.anchor_point(t,y,thr)
# or
# tc,yc, idx2save = AdaptiveSampling.anchor_point(t,y,thr, true)
tc,yc, idx2save, anim = AdaptiveSampling.anchor_point_gif(t,y,thr)

gif(anim, "anchor_point.gif", fps = 20)
