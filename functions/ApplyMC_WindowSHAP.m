function shap_values = ApplyMC_WindowSHAP(obj,X,nsignals,w,samples)
%APPLYMC_WINDOWSHAP - Customized interpretability algorithm
%   Algorithm that provides Shapley (importance) values for each latent 
%   space dimension and identifies the TWA signal segments that UMAP has 
%   focused on the most to project the original data into the lower-
%   dimensional space.
%
% INPUT:
%       obj: Umap object after being trained
%       X: TWA signals 
%       nsignals: Mesh points
%       w: Number of samples in each window
%       samples: Indices of the community to be tested
%
% OUTPUT:
%       shap_value: Importance valuesnsamples
            
    num_features = size(X, 2);
    k = 3;
    if ~isempty(samples)
        nsignals = numel(samples);
    else
        samples = 1:nsignals;
    end

    shap_values = zeros(nsignals, floor(num_features/w), k);

    [nSamples,nVar] = size(X);
    M = 5e2;
    genData = zeros(M*nsignals,nVar);
    for i = 1:nsignals
        qpIdx = samples(i);
        genData((i-1)*M+1:M*i,:) = repmat(X(qpIdx,:),M,1);
    end

    for j = 1:nVar/w
        b1 = genData;
        b2 = genData;
        idx = logical(rand(M*nsignals,nVar));
        for jj = 1:nVar/w
            idx(:,(jj-1)*w+1:jj*w) = repmat(idx(:,(jj-1)*w+1)>0.5,1,w);
        end
        idx1 = idx;
        idx2 = idx;
        idx1(:,(j-1)*w+1:j*w) = 0;
        idx2(:,(j-1)*w+1:j*w)  = 1;
        idx2keep = randi(nSamples,floor(M*nsignals),1);
        z = X(idx2keep(1:M*nsignals),:);
        b1(idx1) = z(idx1);
        b2(idx2) = z(idx2);
        tic
        phi1 =  obj{2}.transform(obj{1}.transform(b1));
        phi2 =  obj{2}.transform(obj{1}.transform(b2));
        toc
        for i = 1:nsignals
            shap_values(i,j,:) = mean(phi1((i-1)*M+1:M*i,:)-phi2((i-1)*M+1:M*i,:));
        end
        disp([num2str(j) ' out of ' num2str(nVar/w)])
    end

end