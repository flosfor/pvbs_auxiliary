% get sPSC (or sPSP) freq & mean amplitude from .abf files (PSC traces from Clampfit event detection, each event aligned to 0 at baseline)
% needs uipickfiles(), abfload()


% some parameters
sweepCount = 240; % how many sweeps in each .abf?
sweepLength = 500; % how long is each sweep? (ms)
peakDir = 1; % peak direction: -1, 0, +1 (negative, absolute, positive)

% some assumptions
dataColumn = 1; % column representing signal in the data array returned by abfload() - should be 1 since there wouldn't be a timestamp (check this)
baselineAtZero = 1; % just a reminder here


% initializing outputs
pscFreq = [];
pscAmpl = []; % NB. intended to return mean of amplitude


% do stuff

if ~baselineAtZero
    return
end

fileNames = uipickfiles(); % returns a cell of imported file names (with path)
fileNames = fileNames'; % for convenience

fileTypes = cell(size(fileNames)); % initialize an empty array for recordkeeping, e.g. PC, FSIN, ... - should be entered manually

fileCount = length(fileNames); % for readability
for i = 1:fileCount
    [abfTemp, samplingInterval, abfMetadataTemp] = abfload(fileNames{i}); % load .abf
    [dataPoints, dataChannels, eventCount] = size(abfTemp); % NB. each "sweep" in these .abf is intended to represent one event
    
    pscFreq(end + 1) = eventCount; % first get the count, will convert to Hz later

    pscAmplTemp = [];
    for j = 1:eventCount
        switch peakDir
            case -1 % negative peaks, i.e. sEPSC or sIPSP
                pscAmplTemp(end + 1) = abs(min(abfTemp(:,dataColumn,j))); % NB. min can still be positive although that is erroneous
            case 0 % absolute values, here written for whatever unthinkable reason
                pscAmplTemp(end + 1) = max(abs(min(abfTemp(:,dataColumn,j))), abs(max(abfTemp(:,dataColumn,j))));
            case 1 % positive peaks, i.e. sIPSC or sEPSP
                pscAmplTemp(end + 1) = abs(max(abfTemp(:,dataColumn,j))); % NB. max can still be negative although that is erroneous
            otherwise % completely unnecessary, waste of line
                return
        end
    end
    pscAmpl(end + 1) = mean(pscAmplTemp); % get mean of all PSC peaks in each file, then append it to the output array
end

timeTotal = sweepCount * sweepLength/1000; % (s) (Cf. sweepLength is in ms)
pscFreq = pscFreq/timeTotal; % convert event frequency from count to Hz - mind the for loop above, don't move this upstream

pscFreq = pscFreq'; % for convenience
pscAmpl = pscAmpl'; % ditto

[filePaths, fileNames, ext] = fileparts(fileNames); % dittoo
for i = 1:size(fileNames)
    fileNames{i} = [fileNames{i}, ext{i}];
end

fprintf('\n\n');
clearvars -except fileNames fileTypes filePaths pscFreq pscAmpl sweepCount sweepLength timeTotal baselineAtZero peakDir dataColumn


% yay!

