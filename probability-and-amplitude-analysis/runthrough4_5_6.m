%runthrough4_5_6.m

how_many_sds = 1;

%%%%%%%%% ANALYSIS PART 1 %%%%%%

%index = input('Index of reference session? ');
index = 1;
%large = input('Size of dataset (# of sessions)? ');
large = AA;
%ampthresh = input('Alternate hard threshold?');

if length(index) > 1
    HGref = sum(HG1(index,:),1);
    HGref = HGref/sum(HGref);
end

for i = 1:large
    HG1(i,:) = HG1(i,:)/sum(HG1(i,:));
end

% generate scaled versions of histograms for all possible values of alpha
% from 0.005 to 2

a = 0:0.005:1;
alpha = zeros(200,41); % scaled versions of histograms for all possible values of alpha
for i = 1:200
    if length(index) == 1
        alpha(i,:) = HG1(index,:) * a(i);
    else
        alpha(i,:) = HGref * a(i);
    end
end

alpha2 = zeros(large,200); % square error for each possible value of alpha given histograms generated

% find square-error for each possible value of alpha given histograms
% generated in previous step

if length(index) == 1
    for i = setdiff(1:large,index);
        for j = 1:200
            alpha2(i,j) = sum((alpha(j,:) - HG1(i,:)).^2);
        end
    end
else
    for i = 1:large
        for j = 1:200
            alpha2(i,j) = sum((alpha(j,:) - HG1(i,:)).^2);
        end
    end
end

% find alpha that minimizes computed square-error

alpha3 = zeros(1,large);

if length(index) ==1
    alpha3(index) = NaN;
    for i = setdiff(1:large,index);
        [x,y] = min(alpha2(i,:));
        alpha3(i) = y;
    end
else
    for i = 1:large
        [x,y] = min(alpha2(i,:));
        alpha3(i) = y;
    end
end

% each cell in alpha3 contains the appropriate value of alpha computed for
% each histogram. One cell = one training session.

if length(index) == 1
    alpha3(setdiff(1:large,index)) = a(alpha3(setdiff(1:large,index)));
else
    alpha3 = a(alpha3);
end

% Scatterplot of best alpha for each data file

% Compute new histograms: subtract scaled version of "null histogram" from
% all other histograms. Check: null histogram - null histogram = 0;
% alpha_null = 1.

alpha4 = zeros(1,large); % centers of mass after alpha-scaled histogram removed.
alpha5 = zeros(1,large); % remaining areas after alpha-scaled histogram removed.
c = -1:0.05:2;
HG3 = zeros(large,length(21:41));
if length(index) == 1
    for i = setdiff(1:large,index)
        HG3(i,:)  = HG1(i,21:41) - alpha3(i)*HG1(index,21:41);
        for w = 1:length(HG3(i,:))
            if HG3(i,w) < 0
                HG3(i,w) = 0;
            end
        end
        alpha4(i) = sum(c(21:41).*(HG3(i,:)))/sum((HG3(i,:)));
        if isnan(alpha4(i))
            alpha4(i) = 0;
        end
        alpha5(i) = sum(HG3(i,:));
    end
else
    for i = 1:large
        HG3(i,:)  = HG1(i,21:41) - alpha3(i)*HGref(21:41);
        for w = 1:length(HG3(i,:))
            if HG3(i,w) < 0
                HG3(i,w) = 0;
            end
        end
        alpha4(i) = sum(c(21:41).*(HG3(i,:)))/sum((HG3(i,:)));
        if isnan(alpha4(i))
            alpha4(i) = 0;
        end
        alpha5(i) = sum(HG3(i,:));
    end
end


alpha8 = zeros(1,large);
for i = 1:large
    alpha8(i) = sum(HG1(i,24:41))/sum(HG1(i,:));
end

%%%%%%%% ANALYSIS PART 2 %%%%%%%%%%%%

c = -1:0.05:1;
HG4 = zeros(large,length(c));
alpha9 = zeros(1,large);
alpha10 = zeros(1,large);
ALPHAZ = zeros(1,large);
for i = 1:large
    HG4(i,:) = [(HG1(i,1:21) - HG1(i,1:21)),(HG1(i,22:41)-HG1(i,20:-1:1))];
    HG_temp(i,:) = [HG1(i,1:21),HG1(i,20:-1:1)];
    for m = 1:length(HG_temp)
        if HG_temp(i,m) > 0
            HG_temp(i,m) = 1;
        end
    end
    HG_temp(i,:) = HG_temp(i,:) .* HG1(i,:);
    for j = 1:size(HG4,2)
        if HG4(i,j) < 0
            HG4(i,j) = 0;
        end
    end
    alpha9(i) = sum(c.*(HG4(i,:)))/sum((HG4(i,:)));
    alpha10(i) = sum(HG4(i,:))/sum(HG1(i,:));
    ALPHAZ(i) = sum(c.*(HG_temp(i,:)))/sum(HG_temp(i,:));
end

for i = 1:length(alpha9)
    if isnan(alpha9(i))
        alpha9(i) = 0;
    end
end

for i = 1:length(alpha10)
    if alpha10(i) < 0
        alpha10(i) = 0;
    end
end

%%%%%%%%%%% ANALYSIS PART 3 %%%%%%%%%%%%%

c = amp_range;

HG5 = zeros(large,length(c));
alpha11 = zeros(1,large);
alpha12 = zeros(1,large);
alpha13 = zeros(1,large);
alpha14 = zeros(1,large);
HG6 = zeros(large,length(c));
HG7 = zeros(large,length(c));
HG8 = zeros(large,length(c));

noise_t_cum = zeros(size(noise_t,1),length(amp_range));
for i = 1:size(noise_t,1)
    noise_t_cum(i,:) = histc(noise_t(i,:),amp_range);
    noise_t_cum(i,:) = noise_t_cum(i,:)/sum(noise_t_cum(i,:));
end

noise_t_1 = mean(noise_t_cum,1);

for i = 1:large
    
    HG6(i,:) = noise_t_cum(i,:);
    HG7(i,:) = noise_t_1;
    
    HG5(i,:) = HG1(i,:) - HG6(i,:);
    HG8(i,:) = HG1(i,:) - HG7(i,:);
    for j = 1:size(HG5,2)
        if HG5(i,j) < 0;
            HG5(i,j) = 0;
        end
    end
    for j = 1:size(HG8,2)
        if HG8(i,j) < 0;
            HG8(i,j) = 0;
        end
    end
    alpha11(i) = sum(c.*(HG5(i,:)))/sum((HG5(i,:)));
    alpha12(i) = sum(HG5(i,:))/sum(HG1(i,:));
    alpha13(i) = sum(c.*(HG8(i,:)))/sum((HG8(i,:)));
    alpha14(i) = sum(HG8(i,:))/sum(HG1(i,:));
end

%%%%%%%%%%%% ANALYSIS PART 4 %%%%%%%%%%%%%

c = amp_range;

HG9 = zeros(large,length(c));
HG10 = zeros(large,length(c));
HG11 = zeros(large,length(c));
HG12 = zeros(large,length(c));
alpha15 = zeros(1,large);
alpha16 = zeros(1,large);
alpha17 = zeros(1,large);
alpha18 = zeros(1,large);

for i = 1:size(noise_c,1)
    noise_c_cum(i,:) = noise_c(i,:)/sum(noise_c(i,:));
end

noise_c_1 = mean(noise_c_cum,1);


for i = 1:large
    %     temp_sum = 0;
    %     for j = 1:length(HG1(i,:))
    %         temp_sum = temp_sum + HG1(i,j);
    %     end
    HG10(i,:) = noise_c_cum(i,:);
    HG12(i,:) = noise_c_1;
    %     HG10(i,:) = HG10(i,:) * temp_sum;
    %     HG12(i,:) = HG12(i,:) * temp_sum;
    HG9(i,:) = HG1(i,:) - HG10(i,:);
    HG11(i,:) = HG1(i,:) - HG12(i,:);
    for j = 1:size(HG9,2)
        if HG9(i,j) < 0;
            HG9(i,j) = 0;
        end
    end
    for j = 1:size(HG11,2)
        if HG11(i,j) < 0;
            HG11(i,j) = 0;
        end
    end
    alpha15(i) = sum(c.*(HG9(i,:)))/sum((HG9(i,:)));
    alpha16(i) = sum(HG9(i,:))/sum(HG1(i,:));
    alpha17(i) = sum(c.*(HG11(i,:)))/sum((HG11(i,:)));
    alpha18(i) = sum(HG11(i,:))/sum(HG10(i,:));
end
