D = dir;

if ~isequal(D(3).name,'.DS_Store')
    start_at = 3;
else
    start_at = 4;
end

for i = 1:size(D,1)
    S{i} = D(i).name;
    if isequal(S{i}(1),'d') && start_at == 0
        start_at = i;
    end
end

B = length(S);

output = zeros(B,39);
output(1:(start_at-1),:) = NaN;
HG1 = zeros(B,length(-1:0.05:2));
HG2 = zeros(B,length(3181:20:3750));

for v = start_at:B
    v
    load(S{v})
    D = dir;
    S = {};
    for i = 1:size(D,1)
        S{i} = D(i).name;
    end
    output(v,1:4) = [number_cr_10,number_cr_15,number_cr_20,number_cr_25];
    temp1 = cr_10_vector(find(cr_10_vector(:,1) == 1),:);
    output(v,5:6) = [mean(temp1(:,2)),std(temp1(:,2))];
    temp2 = cr_15_vector(find(cr_15_vector(:,1) == 1),:);
    output(v,7:8) = [mean(temp2(:,2)),std(temp2(:,2))]; % threshold cross
    output(v,9:10) = [mean(temp1(:,3)),std(temp1(:,3))];
    output(v,11:12) = [mean(temp1(:,4)),std(temp1(:,4))];
    output(v,13:14) = [mean(temp2(:,3)),std(temp2(:,3))]; %peak magn
    output(v,15:16) = [mean(temp2(:,4)),std(temp2(:,4))]; %peak time
    output(v,17:18) = [mean(all_response_vector(:,1)),std(all_response_vector(:,1))];
    output(v,19:20) = [mean(all_response_vector(:,2)),std(all_response_vector(:,2))];
    output(v,21:22) = [mean(all_response_vector(:,3)),std(all_response_vector(:,3))];
    output(v,23) = length(uscs);
    output(v,24:25) = [median(temp2(:,2)),iqr(temp2(:,2))]; %threshold cross
    output(v,26:27) = [median(temp1(:,3)),iqr(temp1(:,3))]; 
    output(v,28:29) = [median(temp1(:,4)),iqr(temp1(:,4))];
    output(v,30:31) = [median(temp2(:,3)),iqr(temp2(:,3))]; %peak magn
    output(v,32:33) = [median(temp2(:,4)),iqr(temp2(:,4))]; %peak time
    output(v,34:35) = [median(all_response_vector(:,1)),iqr(all_response_vector(:,1))];
    output(v,36:37) = [median(all_response_vector(:,2)),iqr(all_response_vector(:,2))];
    output(v,38:39) = [median(all_response_vector(:,3)),iqr(all_response_vector(:,3))];
    
    
    HG1(v-2,:) = histc(all_response_vector(:,3),-1:0.05:2);
    HG2(v-2,:) = histc(all_response_vector(:,2),3181:20:3750);
end
