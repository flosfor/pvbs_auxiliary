% manually load RESULTS .mat (not the entire dataset .mat) exported from PVBS containing intrinsic properties analysis results
%%{
intrinsics = h.intrinsicProperties;
fileNames = h.exp.fileName';
%}

rmpAll = [];
rmpPC = [];
rmpFS = [];
rmpNFS = [];
for i = 1:length(intrinsics)
    rmpTemp = intrinsics{i};
    rmpTemp = rmpTemp.rmp;
    rmpAll(end + 1) = rmpTemp;
end

rinAll = [];
rinPC = [];
rinFS = [];
rinNFS = [];
for i = 1:length(intrinsics)
    rinTemp = intrinsics{i};
    rinTemp = rinTemp.r_in;
    rinAll(end + 1) = rinTemp;
end

sagAll = [];
sagPC = [];
sagFS = [];
sagNFS = [];
for i = 1:length(intrinsics)
    sagTemp = intrinsics{i};
    sagTemp = sagTemp.sag_ratio;
    sagAll(end + 1) = sagTemp;
end

rheoAll = [];
rheoPC = [];
rheoFS = [];
rheoNFS = [];
for i = 1:length(intrinsics)
    rheoTemp = intrinsics{i};
    rheoTemp = rheoTemp.rheobase;
    if isempty(rheoTemp)
        rheoAll(end + 1) = nan;
    else
        rheoAll(end + 1) = rheoTemp;
    end
end

% manually designate indices for cell types
%{
for i = idxPC
    rmpTemp = intrinsics{i};
    rmpTemp = rmpTemp.rmp;
    rmpPC(end + 1) = rmpTemp;
end
for i = idxFS
    rmpTemp = intrinsics{i};
    rmpTemp = rmpTemp.rmp;
    rmpFS(end + 1) = rmpTemp;
end
for i = idxNFS
    rmpTemp = intrinsics{i};
    rmpTemp = rmpTemp.rmp;
    rmpNFS(end + 1) = rmpTemp;
end
mean_rmpPC = mean(rmpPC);
mean_rmpFS = mean(rmpFS);
mean_rmpNFS = mean(rmpNFS);

for i = idxPC
    rinTemp = intrinsics{i};
    rinTemp = rinTemp.r_in;
    rinPC(end + 1) = rinTemp;
end
for i = idxFS
    rinTemp = intrinsics{i};
    rinTemp = rinTemp.r_in;
    rinFS(end + 1) = rinTemp;
end
for i = idxNFS
    rinTemp = intrinsics{i};
    rinTemp = rinTemp.r_in;
    rinNFS(end + 1) = rinTemp;
end
mean_rinPC = mean(rinPC);
mean_rinFS = mean(rinFS);
mean_rinNFS = mean(rinNFS);

for i = idxPC
    sagTemp = intrinsics{i};
    sagTemp = sagTemp.sag_ratio;
    sagPC(end + 1) = sagTemp;
end
for i = idxFS
    sagTemp = intrinsics{i};
    sagTemp = sagTemp.sag_ratio;
    sagFS(end + 1) = sagTemp;
end
for i = idxNFS
    sagTemp = intrinsics{i};
    sagTemp = sagTemp.sag_ratio;
    sagNFS(end + 1) = sagTemp;
end
mean_sagPC = mean(sagPC);
mean_sagFS = mean(sagFS);
mean_sagNFS = mean(sagNFS);

for i = idxPC
    rheoTemp = intrinsics{i};
    rheoTemp = rheoTemp.rheobase;
    rheoPC(end + 1) = rheoTemp;
end
for i = idxFS
    rheoTemp = intrinsics{i};
    rheoTemp = rheoTemp.rheobase;
    rheoFS(end + 1) = rheoTemp;
end
for i = idxNFS
    rheoTemp = intrinsics{i};
    rheoTemp = rheoTemp.rheobase;
    rheoNFS(end + 1) = rheoTemp;
end
mean_rheoPC = mean(rheoPC);
mean_rheoFS = mean(rheoFS);
mean_rheoNFS = mean(rheoNFS);
%}

%%{
rmpAll = rmpAll';
rmpPC = rmpPC';
rmpFS = rmpFS';
rmpNFS = rmpNFS';

rinAll = rinAll';
rinPC = rinPC';
rinFS = rinFS';
rinNFS = rinNFS';

sagAll = sagAll';
sagPC = sagPC';
sagFS = sagFS';
sagNFS = sagNFS';

rheoAll = rheoAll';
rheoPC = rheoPC';
rheoFS = rheoFS';
rheoNFS = rheoNFS';
%}
