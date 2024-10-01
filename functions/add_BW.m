function [s_n] = add_BW(s,fs,A_n)
%ADD_BW - Add Baseline Wander (BW) noise to clean ECG signals
%   Baseline noise is added to ECG signals
%
% INPUT:
%       s: ECG signals
%       fs: Sampling frequency
%       A_n: Added noise amplitude
%
% OUTPUT:
%       s_n: signals with BW noise

    L_s = size(s,2);
    noise = randn(1,L_s+400); 
    f_noise = lowpass(noise,1/(fs/2),ImpulseResponse="iir",Steepness=0.95);
    BW = f_noise(200:end-201);
    BW = normalize(BW,'range')*A_n;
    s = s - mean(s,2); 
    s_n = s + BW;

end

