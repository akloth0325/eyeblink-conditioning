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

% % alpha4 = alpha4';
%
% % must save alpha3, can save other variables
%
% figure
% plot(1-alpha3,'rs-')
% xlabel('Session')
% %ylabel('1 - \alpha s.t. min(\Sigma(\alpha D - D\prime) ^2)')
% hold on
% plot(alpha5,'bd-')
% hold off
% legend('1 - \alpha s.t. min(\Sigma(\alpha D - D\prime) ^2)','Area under corrected distribution')
%
% figure
% scatter(1-alpha3,alpha5)
% hold on
% plot([0,1],[0,1],'k--')
% hold off
% xlabel('1 - failure rate')
% ylabel('Area under corrected distribution')

alpha8 = zeros(1,large);
for i = 1:large
    alpha8(i) = sum(HG1(i,24:41))/sum(HG1(i,:));
end
% figure
% scatter(alpha8,alpha5)
% hold on
% plot([0,1],[0,1],'k--')
% hold off
% xlabel('Area >= 15%, original')
% ylabel('Area under corrected distribution')
%
% figure
% subplot(1,2,1)
% scatter(1-alpha3,alpha4)
% xlabel('1 - failure rate')
% ylabel('Amplitude')
% subplot(1,2,2)
% scatter(alpha5,alpha4)
% xlabel('Area under corrected distribution')
% ylabel('Amplitude')

% alpha6 = zeros(1,large);
% alpha7 = zeros(1,large);
% for i = 1:large
%     alpha6(i) = sum(c.*HG1(i,:))/sum(HG1(i,:));
%     alpha7(i) = sum(c(24:41).*HG1(i,24:41))/sum(HG1(i,24:41));
% end
% figure
% subplot(1,2,1)
% scatter(alpha6,alpha4)
% xlabel('Original amplitude')
% ylabel('Modified amplitude')
% subplot(1,2,2)
% scatter(alpha7,alpha4)
% xlabel('Original amplitude >= 0.15')
% ylabel('Modified amplitude')
% axis square

% plots each new histograms, pauses before moving onto next histogram with
% user input; draws over old histogram.

% if length(index) == 1
%     for i = setdiff(1:large,index)
%         temp_c  = HG1(i,21:41) - alpha3(i)*HG1(index,21:41);
%         for w = 1:length(temp_c)
%             if temp_c(w) < 0
%                 temp_c(w) = 0;
%             end
%         end
%         bar(c(21:41),temp_c)
%         hold on
%         plot([alpha4(i),alpha4(i)],[0,1],'r--')
%         %plot([mean(HG1(i,:)-alpha3(i)*HG1(index,:)),mean(HG1(i,:)-alpha3(i)*HG1(index,:))],[0,1],'m--')
%         plot([0.15,0.15],[0,1],'c-.')
%         hold off
%         title(num2str(i))
%         axis tight
%         %axis([-1,2,-0.05,0.2])
%         pause
%     end
% else
%     for i = 1:large
%         temp_c  = HG1(i,21:41) - alpha3(i)*HGref(21:41);
%         for w = 1:length(temp_c)
%             if temp_c(w) < 0
%                 temp_c(w) = 0;
%             end
%         end
%         bar(c(21:41),temp_c)
%         hold on
%         plot([alpha4(i),alpha4(i)],[0,1],'r--')
%         %plot([mean(HG1(i,:)-alpha3(i)*HG1(index,:)),mean(HG1(i,:)-alpha3(i)*HG1(index,:))],[0,1],'m--')
%         plot([0.15,0.1,[0,1],'c-.')
%         hold off
%         title(num2str(i))
%         axis tight
%         %axis([-1,2,-0.05,0.2])
%         pause
%     end
% end

% figure
% plot(1:large,alpha4,'ks')

% Alternative analysis

% alt_alpha3 = zeros(1,length(1:large));
% alt_alpha4 = zeros(1,length(1:large));
%
% for i = 1:large
%     alt_alpha3(i) = sum(HG1(i,(ampthresh+1):41))/sum(HG1(i,21:41));
%     alt_alpha4(i) = sum(HG1(i,(ampthresh+1):41).*c((ampthresh+1):41))/sum(HG1(i,(ampthresh+1):41));
% end

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
    %     temp_sum = 0;
    %     for j = 1:length(HG1(i,:))
    %         temp_sum = temp_sum + HG1(i,j);
    %     end
    %     HG7(i,:) = histc(noise_t(i,:),c)/numel(noise_t(i,:));
    %     HG7(i,:) = HG7(i,:) * temp_sum;
    %     HG6(i,:) = HG6_temp * temp_sum;
    
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

% %%%%%%%%%%%% ANALYSIS PART 5 %%%%%%%%%%%%%%
% 
% %guess =
% % GMModel = gmdistribution.fit(X,2,'Start',guess);
% 
% % how_many_sds defined at top of script
% % right now, how_many_sds = 3
% 
% alpha19 = [];
% alpha20 = [];
% alpha21 = [];
% alpha22 = [];
% alpha23 = [];
% alpha24 = [];
% alpha25 = [];
% alpha26 = [];
% 
% c = amp_range;
% 
% for i = 1:size(noise_c,1)
%     noise_c_cum(i,:) = noise_c(i,:)/sum(noise_c(i,:));
%     HG1a(i,:) = round(HG1(i,:) * sum(noise_c(i,:)));
% end
% 
% noise_c_1 = mean(noise_c_cum,1);
% 
% for i = 1:large
%     guess_current1 = [];
%     guess_current2 = [];
%     EV_noise_c_cum = dot(noise_c_cum(i,:),amp_range);
%     EV_noise_c_1 = dot(noise_c_1,amp_range);
%     SD_noise_c_cum = sqrt(abs(dot(amp_range,(noise_c_cum(i,:)-EV_noise_c_cum).^2)));
%     SD_noise_c_1 = sqrt(abs(dot(amp_range,(noise_c_1 - EV_noise_c_1).^2)));
%     bound_noise_c_cum = EV_noise_c_cum + SD_noise_c_cum.*how_many_sds;
%     bound_noise_c_1 = EV_noise_c_1 + SD_noise_c_1.*how_many_sds;
%     current_dataset = [];
%     for j = 1:length(HG1a(i,:))
%         if HG1a(i,j) > 0
%             current_dataset = [current_dataset,amp_range(j)*ones(1,HG1a(i,j))];
%         end
%     end
%     guess_current1 = zeros(1,length(HG1a(i,:)));
%     guess_current2 = zeros(1,length(HG1a(i,:)));
%     for j = 1:length(current_dataset)
%         if current_dataset(j) < bound_noise_c_cum
%             guess_current1(j) = 1;
%         else
%             guess_current1(j) = 2;
%         end
%         if current_dataset(j) < bound_noise_c_1
%             guess_current2(j) = 1;
%         else
%             guess_current2(j) = 2;
%         end
%     end
%     GM_current1 = gmdistribution.fit(current_dataset',2,'Start',guess_current1');
%     %GM_current2 = gmdistribution.fit(current_dataset',2,'Start',guess_current2');
%     GM_current1_2_mean = GM_current1.mu(2);
%     %GM_current2_2_mean = GM_current2.mu(2);
%     GM_current1_2_area = GM_current1.Sigma(2,2) .* sqrt(pi) .* GM_current1.ComponentProportion(2);
%     %GM_current2_2_area = GM_current2.Sigma(2,2) .* sqrt(pi) .* GM_current2.ComponentProportion(2);
%     alpha19(i) = GM_current1_2_mean;
%     alpha20(i) = GM_current1_2_area;
%     %alpha21(i) = GM_current2_2_mean;
%     %alpha22(i) = GM_current2_2_area;
% end
% 
% noise_t_cum = zeros(size(noise_t,1),length(amp_range));
% for i = 1:size(noise_t,1)
%     noise_t_cum(i,:) = histc(noise_t(i,:),amp_range);
%     noise_t_cum(i,:) = noise_t_cum(i,:)/sum(noise_t_cum(i,:));
%     HG1a(i,:) = round(HG1(i,:) * sum(noise_c(i,:)));
% end
% 
% noise_t_1 = mean(noise_t_cum,1);
% 
% for i = 1:large
%     guess_current1= [];
%     guess_current2 = [];
%     EV_noise_t_cum = dot(noise_t_cum(i,:),amp_range);
%     EV_noise_t_1 = dot(noise_t_1,amp_range);
%     SD_noise_t_cum = sqrt(dot(range(noise_t_cum(i,:)-EV_noise_t_cum).^2));
%     SD_noise_c_1 = sqrt(dot(amp_range,(noise_c_1-EV_noise_c_1).^2));
%     bound_noise_t_cum = EV_noise_t_cum + SD_noise_t_cum.*how_many_sds;
%     bound_noise_t_1 = EV_noise_t_1 + SD_noise_t_1.*how_many_sds;
%     current_dataset = [];
%     for j = 1:length(HG1a(i,:))
%         current_dataset = [current_dataset,amp_range(j)*ones(1,HG1a(i,j))];
%     end
%     guess_current1 = zeros(1,length(HG1a(i,:)));
%     guess_current2 = zeros(1,length(HG1a(i,:)));
%     for j = 1:length(current_dataset)
%         if current_dataset(j) < bound_noise_c_cum
%             guess_current1(j) = 1;
%         else
%             guess_current1(j) = 2;
%         end
%         if current_dataset(j) < bound_noise_c_1
%             guess_current2(j) = 1;
%         else
%             guess_current2(j) = 2;
%         end
%     end
%     GM_current1 = gmdistribution.fit(current_dataset',2,'Start',guess_current1');
%     %GM_current2 = gmdistribution.fit(current_dataset',2,'Start',guess_current2');
%     GM_current1_2_mean = GM_current1.mu(2);
%     %GM_current2_2_mean = GM_current2.mu(2);
%     GM_current1_2_area = GM_current1.Sigma(2) .* sqrt(pi) .* GM_current1.ComponentProportion(2);
%     GM_current2_2_area = GM_current2.Sigma(2) .* sqrt(pi) .* GM_current2.ComponentProportion(2);   
%     alpha23(i) = GM_current1_2_mean;
%     alpha24(i) = GM_current1_2_area;
%     %alpha25(i) = GM_current2_2_mean;
%     %alpha26(i) = GM_current2_2_area;
% end





%%%%%%%%%% SAVE DATA %%%%%%%%%%%



% filename = input('Filename? (add .mat)')
% % for i = [4,5,6,7,9:18]
% %     eval(['temp_var = alpha',num2str(i),';']);
% %     xlswrite([filename,'.xls'],temp_var,1,['A',num2str(i)]);
% % end
% allalphas1 = [alpha4;alpha5;alpha6;alpha7;alpha8;alpha9;alpha10;alpha11;alpha12;alpha13;alpha14;alpha15;alpha16;alpha17;alpha18];%alpha19;alpha20;alpha21;alpha22;alpha23;alpha24;alpha25;alpha26];
% allalphas2 = [alpha4,NaN,alpha5,NaN,alpha6,NaN,alpha7,NaN,alpha8,NaN,alpha9,NaN,alpha10,NaN,alpha11,NaN,alpha12,NaN,alpha13,NaN,alpha14,NaN,alpha15,NaN,alpha16,NaN,alpha17,NaN,alpha18];%sNaN,alpha19,NaN,alpha20,NaN,alpha21,NaN,alpha22,NaN,alpha23,NaN,alpha24,NaN,alpha25,NaN,alpha26,NaN];
% save(filename,'allalphas1','allalphas2','all_names')%,'alt_alpha3','alt_alpha4')

%load(filename)
