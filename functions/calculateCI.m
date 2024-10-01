function dataIC = calculateCI(data,level,Bonferroni_correction)
%DATAIC - Calculation of the confidence interval
% Confidence interval calculated through ordered statistics
%
% INPUT:
%       data: Data, by columns
%       level: Confidence level (%)
% 
% OUTPUT:
%       dataIC: confidence interval and its mean 

[B,n] = size(data);

dataIC = zeros(3,n);

if Bonferroni_correction == 1
    alpha = (100 - level) / 100;
    alpha_bonferroni = alpha / B;
    low = (alpha_bonferroni * 100) / 2;
else
    low = (100-level)/2; 
end
high = 100-low;

for i=1:n
    aux = data(:,i);
    ind = find(~isnan(aux));
    if isempty(ind); continue; end
    aux = aux(ind);
    dataIC(1,i) = mean(aux);
    aux = sort(aux);       
    aux1 = floor(low/100*length(ind));     
    if aux1 <1, aux1 = 1; end
    aux2 = ceil( high/100*length(ind) ); 
    if aux2>B, aux1 = B; end
    dataIC(2,i) = aux(aux1);
    dataIC(3,i) = aux(aux2);
end
