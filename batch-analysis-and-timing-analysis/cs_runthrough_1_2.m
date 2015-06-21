%cs_runthrough_1.m

DJ = dir;

if ~isequal(DJ(3).name,'.DS_Store')
    start_at = 3;
else
    start_at = 4;
end

end_of_pres = 1.53

for J = start_at:(length(DJ))
    J
    load(DJ(J).name)
%     offset = input('Offset?');
    cs_analyze_2;
    save(DJ(J).name)
    %pause
    %close all
end
clear all
