%cs_runthrough_1.m

DS = dir;

if ~isequal(DS(3).name,'.DS_Store')
    start_at = 3;
else
    start_at = 4;
end

%end_of_pres = 1.53

for S = start_at:(length(DS))
    S
    load(DS(S).name)
%     offset = input('Offset?');
    cs_analyze;
    save(DS(S).name)
    %pause
    %close all
end
clear all
