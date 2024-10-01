function [filt_s] = low_pass_filter(s,fs)
%LOW_PASS_FILTER - FIR filter with an order of 150 and a cutoff frequency of 30 Hz.
%   This filter removes high-frequency noise while preserving the relevant 
% signal components
%
% INPUT:
%       s: ECG signal
%       fs: Sampling frequency
%
% OUTPUT:
%       filt_s: filtered signal

    C = fir1(150,30/(fs/2));
    filt_s = filtfilt(C,1,s);

end

