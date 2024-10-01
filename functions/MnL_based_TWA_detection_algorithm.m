function [TWAstate] = MnL_based_TWA_detection_algorithm(protoEven,protoOdd,mesh,nodes,MC_WindowSHAP)
%MNL_BASED_TWA_DETECTION_ALGORITHM - TWA detection algorithm
%   Algorithm that uses menifold learning and community detection to detect
%   whether a patient suffers from TWA or not.
%
% INPUT:
%       protoEven: Even T-wave templates for all mesh points
%       protoOdd: Odd T-wave templates for all mesh points
%       mesh: Epicardial mesh
%       nodes: Mesh points
%
% OUTPUT:
%       TWAstate: Decision on the presence or absence of TWA

protoEven = protoEven';
protoOdd = protoOdd';

data = (protoEven-protoOdd)';
max_TWA = max(abs(data),[],2);

if MC_WindowSHAP
    n_windows = 5;
    [total_signals,total_samples] = size(data);
    samples_per_window = floor(total_samples / n_windows);
end

latentdim = 15;
nneigs = 10;
[~,umap] = run_umap(data,'n_components',latentdim,'verbose','text','init','random','n_neighbors',nneigs,'min_dist',0.7);
umap2{1} = umap;
emb = umap.transform(data);

conf.Louvain.gamma = .5;
A = umap.graph;
assignments = Louvain(A,[],[],conf.Louvain.gamma);

groups = unique(assignments);
AllCImeans = zeros(size(max_TWA)); % means_CIs_coms
TWAregion = zeros(1,2);
CIMeanpCom = zeros(length(groups),2);

for idx_group = 1:length(groups)
    disp(['Community: ', num2str(idx_group)])
    com = find(assignments == groups(idx_group));

    TWA_community = max_TWA(com);
    [~, CI_mean] = bootstrapping(TWA_community);
    AllCImeans(com) = CI_mean;
    colorCImean = AllCImeans(com); % color_mean_CI

    CIMeanpCom(idx_group,1) = groups(idx_group);
    CIMeanpCom(idx_group,2) = CI_mean;

    if TWAregion(2) < CI_mean
       TWAregion(1) = groups(idx_group);
       TWAregion(2) = CI_mean;
       altCom = com; % bigcom
    end
end

orderedCIMeans = sortrows(CIMeanpCom, 2);
middleRow = orderedCIMeans(ceil(size(orderedCIMeans, 1) / 2),:);

fig_input = data(assignments==TWAregion(1),:)'.*1000;
ejet = (1/2048)*(0:size(fig_input,1)-1);
figure(2); plot(ejet,fig_input,'Color','k')
hold on; plot(ejet,mean(fig_input,2),'Color','r','LineWidth',3)
grid on; xlabel('t (s)'); xlim([min(ejet) max(ejet)])
ylabel('A (μV)'); ylim([min(fig_input(:)) max(fig_input(:))])

alldistances = pdist2(emb(assignments==TWAregion(1),:),emb(assignments~=TWAregion(1),:));
alldistances = alldistances/max(alldistances(:));
sortedVals = sort(alldistances,2);
min10 = mean(sortedVals(:,1:10),2);
mDists = median(min10);

distancesMeanCom = pdist2(emb(assignments==middleRow(1),:),emb(assignments~=middleRow(1),:));
distancesMeanCom = distancesMeanCom/max(distancesMeanCom(:));
TWAstate = evaluateTWA(distancesMeanCom,mDists);

finalColor = repmat([.7 .7 .7], length(AllCImeans), 1);
if TWAstate == 1; finalColor(altCom,:) = repmat([.7 .2 .2], numel(altCom), 1);
else; finalColor(altCom,:) = repmat([.56 .82 .88], numel(altCom), 1); end

for idx_group = 1:length(groups)
    if latentdim == 3
        umap2{2} = umap; 
        X = emb(assignments==groups(idx_group),1); Y = emb(assignments==groups(idx_group),2); Z = emb(assignments==groups(idx_group),3);  
        figure(1); subplot(121)
        l3(idx_group) = scatter3(X, Y, Z, 50, finalColor(idx_group,:), 'filled'); hold on;
    elseif latentdim > 3
        [~,umap] = run_umap(emb,'n_components',3,'verbose','text','init','random','n_neighbors',nneigs,'min_dist',0.7);
        xEmb = umap.transform(emb);
        umap2{2} = umap;
        X = xEmb(assignments==groups(idx_group),1); Y = xEmb(assignments==groups(idx_group),2); Z = xEmb(assignments==groups(idx_group),3);
        figure(1); subplot(121)
        l3(idx_group) = scatter3(X, Y, Z, 50, finalColor(find(assignments==idx_group),:), 'filled'); hold on;
    end
end
figure(1); subplot(121); hold off; grid on; legend(l3,{num2str(groups)});
subplot(122); trisurf(mesh,nodes(:,1),nodes(:,2),nodes(:,3),'FacevertexCData', finalColor)
axis off; shading interp

if MC_WindowSHAP
    idxAlt = find(assignments==TWAregion(1));
    shapleyVals = ApplyMC_WindowSHAP(umap2,data,total_signals,samples_per_window,idxAlt);
    mean_shapleyVals = squeeze(mean(shapleyVals));

    figure;
    bar(mean_shapleyVals)
    legend('h_1','h_2','h_3');
    ylabel('Shapley values');
    xlabel('Windows')

    [~,idxHighest] = max(abs(mean_shapleyVals(:)));
    [row, ~] = ind2sub(size(mean_shapleyVals), idxHighest);
    pool = setdiff(1:size(data,1), idxAlt);
    rndInds = pool(randperm(length(pool), size(fig_input,2)));
    figure;
    plot(ejet,data(rndInds,:)'.*1000,'Color',[.7 .7 .7])
    if TWAstate == 1; colorS = [.7 .2 .2]; else; colorS = [.56 .82 .88]; end
    hold on; plot(ejet,fig_input,'Color',colorS)
    Xarea = (row-1)*samples_per_window+1:row*samples_per_window;
    hold on; area(ejet(Xarea),170*ones(size(Xarea)),'BaseValue',-170,'FaceAlpha',0.2)
    grid on; xlabel('t (s)'); xlim([min(ejet) max(ejet)]); ylim([-170 170])
    ylabel('A (μV)');
end

end

