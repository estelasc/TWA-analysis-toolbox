function TWAstate = evaluateTWA(distances,targetDist)
%EVALUATETWA - Decision on the presence of TWA
%   Bootstrap resampling is used to determine whether the community has TWA
%   or not
%
% INPUT:
%       distances: Distances between points in c_med and the rest of points
%       targetDist: Value representing the distance between c_alt and the
%               rest of points.
%
% OUTPUT:
%       TWAstate: Decision on the presence or absence of TWA


    B = 5e2;
    [~,OtherPts] = size(distances);
    indices = ceil(OtherPts*rand(OtherPts,B));
    medians = zeros(B,1);
    for b = 1:B
        Xb = distances(:,indices(:,b));
        sortedXbs = sort(Xb,2);
        min10 = mean(sortedXbs(:,1:10),2);
        medians(b) = median(min10);
    end
    dataIC = calculateCI(medians,95,0);

    figure(3)
    histogram(medians); hold on;
    stem(dataIC(2:3),[0 0],'filled','*','LineWidth',10,'Color',[0.8 1 0.8])

    if targetDist > dataIC(3)
        TWAstate = 1;
        hold on; stem(targetDist,0,'filled','*','LineWidth',10,'Color',[.64 0 .15])
    else
        TWAstate = 0;
        hold on; stem(targetDist,0,'filled','*','LineWidth',10,'Color',[.46 .38 .54])
    end
    hold off; xlabel('Estimator'); ylabel('counts'); 

end
