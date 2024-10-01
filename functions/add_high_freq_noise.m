function [s_n] = add_high_freq_noise(s,A_n)
%ADD_HIGH_FREQ_NOISE - Add high-frequency noise to clean ECG signals
%   High-frequency noise is added to ECG signals
%
% INPUT:
%       s: ECG signals
%       A_n: Added noise amplitude
%
% OUTPUT:
%       s_n: signals with high-frequency noise

    noise = rand(size(s))*max(abs(s(:))); 
    noise = normalize(noise, 'range')*A_n;
    s_n = s + noise;

end

