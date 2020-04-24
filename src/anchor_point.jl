################################################################################
function anchor_point(t,y::Vector{Float},detail_th,split_wfm::Bool)
    if split_wfm
        nr_split = max(Int(round(length(y)/5e3)),1)
        #remove extra points for reshape TO BE SOLVED!!!
        aux = rem(length(y),nr_split)
        dt  = t[2] - t[1]
        y   = y[1:end-aux]
        t   = t[1:end-aux]
        t  = reshape(t,Int(length(t)/nr_split),nr_split)
        y  = reshape(y,Int(length(y)/nr_split),nr_split)
        # Collect the results as they become available.
        t_new    = [0.0, 0.0]
        y_new    = [0.0, 0.0]
        idx2save = [0, 0]
        for inr = 1:nr_split
            t_aux, y_aux, idx2save_aux = anchor_point(t[:,inr],y[:,inr],detail_th)
            append!(t_new,t_aux)
            #t_new      = t_new[1:end-1]
            append!(y_new,y_aux)
            #y_new      = y_new[1:end-1]
            append!(idx2save,idx2save_aux)
            #idx2save   = idx2save[1:end-1]
            #append!(idx2save2,idx2save_aux + (inr - 1)*Int64(length(y1)))TO BE SOLVED!!!
        end
        t_new = t_new[3:end]
        y_new = y_new[3:end]
    else
        t_new, y_new, idx2save = anchor_point(t,y,detail_th)
    end
    return t_new, y_new, idx2save
end
################################################################################
function anchor_point(t,y::Vector{Float},detail_th)
    # Compress signal by removing redundant points.
    # Adjust waveform detail/compression ratio with 'detail_th' (maximum allowed
    # difference between original and approximated points from the signal)
    # For best performance perform wavelet noise reduction first
    yln           = length(y)
    idx_l         = 1
    idx_r         = yln
    idx_d_max     = 1
    cond_break    = true
    d_max         = 0.0
    M             = zeros(Int,yln) # hash table for relevant indices
    idx2save      = zeros(Int,yln+2)
    cnt           = 2
    idx2save[1:2] = [1,yln]
    while cond_break
        # get maximum error(difference) and index, between original chunk of signal
        # and linear approximation
        d_max, idx_d_max = get_d_max(idx_l,idx_r,y)
        # save all indices
        M[idx_d_max] = idx_r
        if d_max > detail_th
            # if computed error is greater than maximum allowed error, save
            # next point index and call get_d_max(idx_l,idx_r,y) at next
            # iteration; keep going towards leftmost branches
            cnt           = cnt + 1
            idx_r         = idx_d_max
            idx2save[cnt] = idx_d_max
        else
            # if computed error is smaller than maximum allowed error, stop, go
            # right(to the next waveform segment) and call get_d_max(idx_l,idx_r,y)
            # at the next iteration
            idx_l     = idx_r;
            if idx_l != yln
                idx_r = M[idx_l]
            else
                cond_break = false
            end
        end
    end
    # sort all indexes corresponding to relevent points and generate resampled
    # signal
    idx2save = idx2save[1:cnt]
    idx2save = sort(idx2save)
    t_new    = @view t[idx2save]
    y_new    = @view y[idx2save]
    return t_new, y_new, idx2save
end
################################################################################
function get_d_max(idx_l,idx_r,y)
    # cut segment to be resampled
    yp = view(y,idx_l:idx_r)
    # construct linear approximation
    dr = LinRange(y[idx_l], y[idx_r], length(yp))
    # compute distance(error) and get index of maximum error
    # -> this will be used for further splitting the
    # signal and will be part of the final resampled signal
    d_max     = 0.0
    idx_d_max = 1
    err_val   = 0.0
    for i = 1:length(yp)
        err_val = abs(yp[i] - dr[i])
        if err_val > d_max
            d_max     = err_val
            idx_d_max = i
        end
    end
    idx_d_max = idx_d_max + idx_l - 1
    return d_max, idx_d_max
end
