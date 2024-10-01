function [CI, CI_mean] = bootstrapping(com)
%BOOTSTRAPPING - Apply Bootstrap resampling
%   Bootstrap resampling is applied with the maximum values of TWA for each
%   signal belonging to the same community
%
% INPUT:
%       com: Maximum values of TWA for each signal in the community
%
% OUTPUT:
%       CI: Confidence interval
%       CI_mean: mean of the confidence interval

    nnodes = length(com);

    B = 500; 
    sb = zeros(B,1);

    for b = 1:B
        ind = ceil(nnodes*rand(nnodes,1));
        Xb = com(ind);
        mXb = mean(Xb);
        sb(b) = mXb;
    end

    level = 95;
    Bonferroni_correction = true;
    CI = calculateCI(sb,level,Bonferroni_correction);

    CI_mean = mean(CI(2:3));
end

