% manually load .mat containing intrinsic properties analysis results exported from PVBS
% e.g. "tumor.intrinsics" below should be a struct containing field(s):
% f_i, & (not used below, but from PVBS: ) rmp, r_in, sag_ratio, ...


isiExtracted = {};
isiExtracted2 = {};

%bigNan = nan(40, 1);
bigNan = 40;

intrinsics = {};
intrinsics{end + 1} = tumor.intrinsics;
intrinsics{end + 1} = epil.intrinsics;

for i = 1:length(intrinsics)

    tempIntrinsics = intrinsics{i};
    tempArray = nan(bigNan, length(tempIntrinsics));
    tempArray2 = nan(bigNan, length(tempIntrinsics));

    for j = 1:length(tempIntrinsics)
        
        try

            tempSpikeTimes = tempIntrinsics{j};
            tempRheobase = tempSpikeTimes.rheobase_sweep; % mind the order
            tempRheobase2 = tempSpikeTimes.rheobase_x2_sweep; % mind the order
            tempSpikeTimes = tempSpikeTimes.spike_times;
            tempSpikeTimes2 = tempSpikeTimes{tempRheobase2}; % mind the order
            tempSpikeTimes = tempSpikeTimes{tempRheobase};

            for k = 1:length(tempSpikeTimes)
                tempArray(k, j) = tempSpikeTimes(k);
                tempArray2(k, j) = tempSpikeTimes2(k);
            end

        catch ME
            wtf = 1;
        end

    end

    tempArray = diff(tempArray);
    tempArray2 = diff(tempArray2);
    isiExtracted{i} = tempArray;
    isiExtracted2{i} = tempArray2;

end

clearvars -except tumor epil isiExtracted isiExtracted2


