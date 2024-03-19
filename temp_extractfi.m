% manually load .mat containing intrinsic properties analysis results exported from PVBS
% e.g. "tumor.intrinsics" below should be a struct containing field(s):
% f_i, & (not used below, but from PVBS: ) rmp, r_in, sag_ratio, ...

fiExtracted = {};

%bigNan = nan(40, 1);
bigNan = 40;

intrinsics = {};
intrinsics{end + 1} = tumor.intrinsics;
intrinsics{end + 1} = epil.intrinsics;

for i = 1:length(intrinsics)

    tempIntrinsics = intrinsics{i};
    tempArray = nan(bigNan, length(tempIntrinsics));

    for j = 1:length(tempIntrinsics)
        
        tempTemplate = tempIntrinsics{j};
        tempTemplate = tempTemplate.f_i;

        for k = 1:size(tempTemplate, 1)
            currentColumn = 1;
            fColumn = 2;
            tempArray(k, j) = tempTemplate(k, fColumn);
        end
    end

    fiExtracted{i} = tempArray;

end

clearvars -except tumor epil fiExtracted