function [protoOdd, protoEven, oddTwaves, evenTwaves] = add_TWA(TWaves,n_TWA,A_TWA,nodes)
%ADD_TWA - Add synthetic alternans to healthy ECG signals
%   Synthetic alternans are added to ECG signals using a spatial-temporal 
% Gaussian function. For more information look at 
% https://doi.org/10.1109/ACCESS.2024.3447114
%
% INPUT:
%       Twaves: T-waves segmented
%       n_TWA: Node with more synthetic TWA
%       A_TWA: TWA amplitude in n_TWA
%       nodes: All nodes in the subject
%
% OUTPUT:
%       protoOdd: Mean of all odd T-waves for each node
%       protoEven: Mean of all even T-waves for each node
%       oddTwaves: All odd T-waves for each node
%       evenTwaves: All even T-waves for each node

    npots = length(TWaves);
    for i = 1:npots
        tempwave = zeros(1,length(TWaves{i}(1).wave));
        k = 1;
        for j=1:2:length(TWaves{i})-1
            oddTwaves{i}(k,:)=TWaves{i}(j).wave;
            evenTwaves{i}(k,:)=TWaves{i}(j+1).wave;
            k=k+1;
        end
    
        TWave_prepared = cell(length(TWaves{i}),1);
        for b_idx = 1:length(TWaves{i})
            TWave_prepared{b_idx,1}.ind = TWaves{i}(b_idx).ind;
            TWave_prepared{b_idx,1}.wave = TWaves{i}(b_idx).wave;
            TWave_prepared{b_idx,1}.lengthwin = TWaves{i}(b_idx).lengthwin;
    
            wave = TWave_prepared{b_idx,1}.wave; 
            TWave_prepared{b_idx,1}.difwave = wave-tempwave;
            tempwave = wave;
        end
    end
    
    L_wave = length(evenTwaves{1,1}(1,:));
    x_gaussian = 1:L_wave;
    y_gaussian = normpdf(x_gaussian, L_wave/2, L_wave/7.5);
    y_gaussian = y_gaussian/max(y_gaussian)*A_TWA;
    
    n_nodes = size(nodes, 1);
    temp_gauss = zeros(n_nodes, length(y_gaussian));
    D = pdist2(n_TWA,nodes);
    targets = find(D==min(D));
    
    idx = D <= 30;
    n_noInds = find(idx == 0);
    
    D = D - A_TWA;
    idx0 = find(D<0); 
    D(idx0) = 0;
    normD = exp(-D.^2 / (2*10^2));
    normD(normD>.3) = max(normD);
    for i = 1:length(normD)
        if normD(i)<.3
            normD(i) = max(normD)-normD(i); 
        end
    end
    normD(n_noInds) = 0;
    
    for node = 1:n_nodes
        temp_gauss(node,:) = y_gaussian * normD(node);
        for T_idx = 1:size(evenTwaves{node}, 1)
            evenTwaves{node}(T_idx, :) = evenTwaves{node}(T_idx, :) + temp_gauss(node,:);
        end
    end
    
    
    protoOdd = cellfun(@mean,oddTwaves,'UniformOutput',false);
    protoEven = cellfun(@mean,evenTwaves,'UniformOutput',false);
    
    protoOdd=cell2mat(protoOdd');
    protoEven=cell2mat(protoEven');

end