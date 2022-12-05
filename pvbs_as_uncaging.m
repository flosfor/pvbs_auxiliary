% !!! manually LOAD the uncaging .mat first !!! 
% (the .mat exported from PVBS uncaging analysis preset)


%% if you want (before loading the uncaging .mat, obviously)

%%{
clear all
%}


%% if you want to run the script multiple times

%{
uncaging_2 = uncaging;
fileNamePairs_2 = fileNamePairs;
fileNameUnits_2 = fileNameUnits;
fileNameMeasured_2 = fileNameMeasured;
expected_2 = expected;
measured_2 = measured;
gain_2 = gain;
dff_2 = dff;
SpineCountUnits_2 = SpineCountUnits_2;
SpineCountMeasured_2 = SpineCountMeasured_2;
saveName_2 = saveName;
savePath_2 = savePath;
%}


%% do stuff  <-- RUN ME!


%%% keep a record of file names

%%{
fileNameUnits = uncaging.fileNameUnits';
fileNameMeasured = uncaging.  fileNameMeasured';
fileNamePairs = [fileNameUnits, fileNameMeasured];
%}


%%% gain

gain_temp = uncaging.gain;

columns = size(gain_temp, 2);
rows = 1;

for i = 1:columns
    gain_temp_temp = gain_temp{i};
    rows = max(rows, length(gain_temp_temp));
end
gain = nan(rows, columns);

for i = 1:columns
    gain_temp_temp = gain_temp{i};
    gain_temp_temp_temp = nan(rows, 1);
    for j = 1:length(gain_temp_temp)
        gain_temp_temp_temp(j) = gain_temp_temp(j);
    end
    gain(:, i) = gain_temp_temp_temp;
end


%%% same stuff for dff

dff_temp = uncaging.dffPeak;

columns = size(dff_temp, 2); % should be the same but whatever
rows = 1;

for i = 1:columns
    dff_temp_temp = dff_temp{i};
    rows = max(rows, length(dff_temp_temp));
end
dff = nan(rows, columns);

for i = 1:columns
    dff_temp_temp = dff_temp{i};
    dff_temp_temp_temp = nan(rows, 1);
    for j = 1:length(dff_temp_temp)
        dff_temp_temp_temp(j) = dff_temp_temp(j);
    end
    dff(:, i) = dff_temp_temp_temp;
end


%%% same stuff for expected

expected_temp = uncaging.expected;

columns = size(dff_temp, 2); % should be the same but whatever
rows = 1;

for i = 1:columns
    expected_temp_temp = expected_temp{i};
    rows = max(rows, length(expected_temp_temp));
end
expected = nan(rows, columns);

for i = 1:columns
    expected_temp_temp = expected_temp{i};
    expected_temp_temp_temp = nan(rows, 1);
    for j = 1:length(expected_temp_temp)
        expected_temp_temp_temp(j) = expected_temp_temp(j);
    end
    expected(:, i) = expected_temp_temp_temp;
end


%%% same stuff for measured

measured_temp = uncaging.measured;

columns = size(measured_temp, 2); % should be the same but whatever
rows = 1;

for i = 1:columns
    measured_temp_temp = measured_temp{i};
    rows = max(rows, length(measured_temp_temp));
end
measured = nan(rows, columns);

for i = 1:columns
    measured_temp_temp = measured_temp{i};
    measured_temp_temp_temp = nan(rows, 1);
    for j = 1:length(measured_temp_temp)
        measured_temp_temp_temp(j) = measured_temp_temp(j);
    end
    measured(:, i) = measured_temp_temp_temp;
end


%%% same stuff for spine counts
spineCountUnits_temp = uncaging.spineCountUnits;
spineCountMeasured_temp = uncaging.spineCountMeasured;

% i have no idea what these are anymore
columns = size(spineCountUnits_temp, 2);
rows = 1;

for i = 1:columns
    spineCountUnits_temp_temp = spineCountUnits_temp{i};
    rows = max(rows, length(spineCountUnits_temp_temp));
end
spineCountUnits = nan(rows, columns);

for i = 1:columns
    spineCountUnits_temp_temp = spineCountUnits_temp{i};
    spineCountUnits_temp_temp_temp = nan(rows, 1);
    for j = 1:length(spineCountUnits_temp_temp)
        spineCountUnits_temp_temp_temp(j) = spineCountUnits_temp_temp(j);
    end
    spineCountUnits(:, i) = spineCountUnits_temp_temp_temp;
end

columns = size(spineCountMeasured_temp, 2);
rows = 1;

for i = 1:columns
    spineCountMeasured_temp_temp = spineCountMeasured_temp{i};
    rows = max(rows, length(spineCountMeasured_temp_temp));
end
spineCountMeasured = nan(rows, columns);

for i = 1:columns
    spineCountMeasured_temp_temp = spineCountMeasured_temp{i};
    spineCountMeasured_temp_temp_temp = nan(rows, 1);
    for j = 1:length(spineCountMeasured_temp_temp)
        spineCountMeasured_temp_temp_temp(j) = spineCountMeasured_temp_temp(j);
    end
    spineCountMeasured(:, i) = spineCountMeasured_temp_temp_temp;
end


%%% prepare to save stuff (not actually saving stuff yet, which is done at the end)

saveName = 'unc_unwrapped';
savePath = cd;

todayYY = num2str(year(datetime));
todayYY = todayYY(end-1:end);
todayMM = sprintf('%02.0f', month(datetime));
todayDD = sprintf('%02.0f', day(datetime));
todayhh = sprintf('%02.0f', hour(datetime));
todaymm = sprintf('%02.0f', minute(datetime));
todayss = sprintf('%02.0f', second(datetime));
timeStamp = [todayYY, todayMM, todayDD ,'_', todayhh, todaymm, todayss];

saveName = [saveName, '_', todayYY, todayMM, todayDD, '_', todayhh, todaymm, todayss];
saveName = [saveName, '.mat'];
savePath = [savePath, '\']; % appending backslash for proper formatting
cd(savePath);
warning('off'); % in case directory exists for mkdir below - shouldn't be relevant for now
mkdir(timeStamp);
warning('on');
savePath = [savePath, timeStamp, '\'];


%%% clean stuff up

clear i j 
clear rows columns

clear gain_temp gain_temp_temp gain_temp_temp_temp
clear dff_temp dff_temp_temp dff_temp_temp_temp
clear expected_temp expected_temp_temp expected_temp_temp_temp
clear measured_temp measured_temp_temp measured_temp_temp_temp
clear spineCountUnits_temp spineCountUnits_temp_temp spineCountUnits_temp_temp_temp
clear spineCountMeasured_temp spineCountMeasured_temp_temp spineCountMeasured_temp_temp_temp

clear todayYY todayMM todayDD todayhh todaymm todayss
clear timeStamp


%%% actually save stuff

save([savePath, saveName]);
