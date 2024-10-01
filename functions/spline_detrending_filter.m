function [det_s] = spline_detrending_filter(s,L_w,fs)
%SPLINE_DETRENDING_FILTER - spline detrending filter
%   This filter estimates the signal trend by fitting a smooth curve to 
% windowed averages of the signal, which is then subtracted from the 
% original signal to produce a detrended version.
%
% INPUT:
%       s: ECG signal
%       L_w: Window length
%       fs: Sampling frequency
%
% OUTPUT:
%       det_s: detrended signal

    L_s = length(s);
    
    t = 1/fs*(0:L_s-1);
    t = t';
    
    t_m=[];
    s_m=[];
    
    for n_t=1:round(L_w/2):L_s-L_w
        t_m=[t_m t(n_t+round(L_w/2)-1)];
        s_m=[s_m mean(s(n_t:n_t+L_w-1))];
    end
    
    pp = csaps(t_m,s_m);
    s_pp = ppval(pp,t)';
    det_s = s-s_pp;

end

