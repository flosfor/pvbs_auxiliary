% manually load .mat exported from PVBS containing intrinsic properties analysis results
%%{
intrinsics = h.intrinsicProperties;
fileNames = h.exp.fileName';
%%}

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
%%}

%%{
rmpAll = rmpAll';
rmpPC = rmpPC';
rmpFS = rmpFS';
rmpNFS = rmpNFS';
rinAll = rinAll';
rinPC = rinPC';
rinFS = rinFS';
rinNFS = rinNFS';
%}
