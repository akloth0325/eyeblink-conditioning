function summarize_and_plot_full(data,trialtypes,cs_no,us_vector,filename,sampling_rate,exclude,invert,cs_only_marker)

%%%%%%%%
%analysis_cr_trialbytrial_full plots averagenormalized eyeblink traces for visual
%examination by the experimenter and produces a _analyzed.mat file for
%analysis by other scripts.

%INPUT:
%data: the output file from the ephys_eyeblink GUI
%trialtypes: trialtypes vector from output file
%cs_no: number of inidivial CSs: enter 1 for 1 CS, 2 for 2 CSs, 3 for 2 CSs
%us_vector: vector of trials that are US-only
%filename: name of file to analyze
%when the CSs are presented both individually and in combination
%sampling_rate: sampling rate (Hz) set in GUI. Typically, two simultaneous
%recordings requires a sampling rate of 4 kHz and three simultaneous
%recordings requires a sampling rate of 5 kHz.
%exclude: vector of trials to exclude (user-defined)
%invert: vector of trials to invert (user-defined)
%cs_only_marker: 1

%OUTPUT
%no returned output
%summary plot are produced
%filename_analysis.mat file produced anew for use with other scripts

%%%%%%%%

if nargin < 7
    if cs_no > 0;
        cs_only_marker = 1;
    else
        cs_only_marker = 0;
    end
    exclude = [];
    invert = [];
elseif nargin < 8
    if cs_no > 0
        cs_only_marker = 1;
    else
        cs_only_marker = 0;
    end
    invert = [];
elseif nargin < 9
    if cs_no > 0
        cs_only_marker = 1;
    else
        cs_only_marker = 0;
    end
end

data(:,2,invert+us_vector(end)) = -data(:,2,invert+us_vector(end)); % differentiate US-only trials from other trials

data(:,:,exclude+us_vector(end)) = []; % exclude trials
if ~isempty(exclude)
    if exclude(end) < us_vector(1)
        us_vector = us_vector - exclude(end);
    else
        trialtypes(exclude) = [];
    end
end

data2 = data; % begin generating normalized data matrix

if sum(us_vector)~= 0
    if length(trialtypes) > (size(data,3) - length(us_vector))
        trialtypes = trialtypes(1:(size(data,3)-length(us_vector)));
    end
else
    if length(trialtypes) > (size(data,3))
        trialtypes = trialtypes(1:(size(data,3)));
    end
end

if sum(us_vector)~=0
    mean_us = mean(data(:,:,us_vector),3);
    sd_us = sqrt(var(data(:,:,us_vector),0,3));
    how_many = size(data,3)-length(us_vector);
else
    how_many = size(data,3);
end

switch cs_no % identify CS-only trials
    case 0
        first_cs = [];
        second_cs = [];
        compound_cs = [];
    case 1
        first_cs = find(trialtypes == 10)+us_vector(end);
        second_cs = [];
        compound_cs = [];
    case 2
        first_cs = find(trialtypes == 10)+us_vector(end);
        second_cs = find(trialtypes == 11)+us_vector(end);
        compound_cs = [];
    case 3
        first_cs = find(trialtypes == 10)+us_vector(end);
        second_cs = find(trialtypes == 11)+us_vector(end);
        compound_cs = find(trialtypes == 12)+us_vector(end);
end

% split US-CS trials into first half and second half
if mod(how_many,2) == 0
    firsthalf = (us_vector(end)+1):(us_vector(end)+(how_many/2));
    secondhalf = (us_vector(end)+(how_many/2)+1):size(data,3);
else
    firsthalf = (us_vector(end)+1):(us_vector(end) + floor(how_many/2));
    secondhalf = (us_vector(end) + floor(how_many/2)+1):size(data,3);
end

firsthalf = setdiff(firsthalf,[first_cs,second_cs,compound_cs]);
secondhalf = setdiff(secondhalf, [first_cs,second_cs,compound_cs]);

for i = [firsthalf,secondhalf]
    baseline = mean(data(1:sampling_rate,2,i));
    peak = max(data((sampling_rate*1.25):(sampling_rate*1.45),2,i));
    data2(:,2,i)=(data(:,2,i)-baseline)/(peak-baseline);
end

% calculate means and standard deviations for US-CS trials (all, first half
% only, second half only)
mean_uscs_firsthalf = mean(data2(:,:,firsthalf),3);
sd_uscs_firsthalf = sqrt(var(data2(:,:,firsthalf),0,3));
mean_uscs_secondhalf = mean(data2(:,:,secondhalf),3);
sd_uscs_secondhalf = sqrt(var(data2(:,:,secondhalf),0,3));
mean_uscs_all = mean(data2(:,:,[firsthalf,secondhalf]),3);
sd_uscs_all = sqrt(var(data2(:,:,[firsthalf,secondhalf]),0,3));

time = linspace(-1000,1000,(sampling_rate*2+1));

if sum(us_vector)~=0
figure; % Mean unconditioned stimulus (only) plot
plot(time,mean_us(:,2));
hold on
plot(time,mean_us(:,2)+sd_us(:,2),':r');
plot(time,mean_us(:,2)-sd_us(:,2),':r');
axis tight
current_axes = axis;
plot([0,0],current_axes(3:4),'--g');
plot([30,30],current_axes(3:4),'--g');
xlabel('Time, msec')
ylabel('Magnetometer readout, V')
title('Mean unconditioned stimulus response only')
end

figure; % Mean US-CS pair plot, all trials
plot(time,mean_uscs_all(:,2));
hold on
plot(time,mean_uscs_all(:,2)+sd_uscs_all(:,2),':r');
plot(time,mean_uscs_all(:,2)-sd_uscs_all(:,2),':r');
axis tight
current_axes = axis;
xlabel('Time, msec')
ylabel('Magnetometer readout, V')
title('Mean US-CS pairing responsed, all trials')

figure; % Mean US-CS pair plot, first half of trials
plot(time,mean_uscs_firsthalf(:,2));
hold on
plot(time,mean_uscs_firsthalf(:,2)+sd_uscs_firsthalf(:,2),':r');
plot(time,mean_uscs_firsthalf(:,2)-sd_uscs_firsthalf(:,2),':r');
plot([0,0],current_axes(3:4),'--k');
plot([280,280],current_axes(3:4),'--k');
plot([250,250],current_axes(3:4),'--g');
axis tight
xlabel('Time, msec')
ylabel('Magnetometer readout, V')
title('Mean US-CS pairing responsed, first half of trials')

figure; % Mean US-CS pair plot, second half of trials
plot(time,mean_uscs_secondhalf(:,2));
hold on
plot(time,mean_uscs_secondhalf(:,2)+sd_uscs_secondhalf(:,2),':r');
plot(time,mean_uscs_secondhalf(:,2)-sd_uscs_secondhalf(:,2),':r');
plot([0,0],current_axes(3:4),'--k');
plot([280,280],current_axes(3:4),'--k');
plot([250,250],current_axes(3:4),'--g');
axis tight
xlabel('Time, msec')
ylabel('Magnetometer readout, V')
title('Mean US-CS pairing responsed, second half of trials')

switch cs_no
    case 0
        names = {};
    case 1
        names = {'first_cs'};
    case 2
        names = {'first_cs','second_cs'};
    case 3
        names = {'first_cs','second_cs','compound_cs'};
end

% calculate average CS only presentations (all, first half, second half) by
% CS type (CS1, CS2, CS1+2, as identified by user)
if cs_only_marker == 1
    for j = 1:length(names)
        if isequal(names{j},'first_cs')
            for i = first_cs
                temp_vector = [firsthalf,secondhalf];
                temp_diff = abs(i-temp_vector);
                [~,ref_index] = min(temp_diff);
                baseline1 = mean(data(1:(sampling_rate),2,temp_vector(ref_index)));
                baseline2 = mean(data(1:(sampling_rate),2,i));
                peak = max(data((sampling_rate*1.27+1):(sampling_rate*1.45),2,temp_vector(ref_index)));
                data2(:,2,i) = (data(:,2,i)-baseline2)/(peak-baseline1);
            end
            mean_firstcs = mean(data2(:,:,first_cs),3);
            sd_firstcs = sqrt(var(data2(:,:,first_cs),0,3));
            figure;
            plot(time,mean_firstcs(:,2));
            hold on
            plot(time,mean_firstcs(:,2)+sd_firstcs(:,2),':r');
            plot(time,mean_firstcs(:,2)-sd_firstcs(:,2),':r');
            plot([0,0],current_axes(3:4),'--k');
            plot([280,280],current_axes(3:4),'--k');
            plot([250,250],current_axes(3:4),'--g');
            axis tight
            xlabel('Time, msec')
            ylabel('Magnetometer readout, V')
            title('Mean CR I (only)')
        elseif isequal(names{j},'second_cs')
            for i = second_cs
                temp_vector = [firsthalf,secondhalf];
                temp_diff = abs(i-temp_vector);
                [~,ref_index] = min(temp_diff);
                baseline1 = mean(data(1:(sampling_rate),2,temp_vector(ref_index)));
                baseline2 = mean(data(1:(sampling_rate),2,i));
                peak = max(data((sampling_rate*1.27+1):(sampling_rate*1.45),2,temp_vector(ref_index)));
                data2(:,2,i) = (data(:,2,i)-baseline2)/(peak-baseline1);
            end
            mean_secondcs = mean(data2(:,:,second_cs),3);
            sd_secondcs = sqrt(var(data2(:,:,second_cs),0,3));
            figure;
            plot(time,mean_secondcs(:,2));
            hold on
            plot(time,mean_secondcs(:,2)+sd_secondcs(:,2),':r');
            plot(time,mean_secondcs(:,2)-sd_secondcs(:,2),':r');
            plot([0,0],current_axes(3:4),'--k');
            plot([280,280],current_axes(3:4),'--k');
            plot([250,250],current_axes(3:4),'--g');
            axis tight
            xlabel('Time, msec')
            ylabel('Magnetometer readout, V')
            title('Mean CR II (only)')
        elseif isequal(names{j},'compound_cs')
            for i = compound_cs
                temp_vector = [firsthalf,secondhalf];
                temp_diff = abs(i-temp_vector);
                [~,ref_index] = min(temp_diff);
                baseline1 = mean(data(1:(sampling_rate),2,temp_vector(ref_index)));
                baseline2 = mean(data(1:(sampling_rate),2,i));
                peak = max(data((sampling_rate*1.25+1):(sampling_rate*1.45),2,temp_vector(ref_index)));
                data2(:,2,i) = (data(:,2,i)-baseline2)/(peak-baseline1);
            end
            mean_compoundcs = mean(data2(:,:,compound_cs),3);
            sd_compoundcs = sqrt(var(data2(:,:,compound_cs),0,3));
            figure;
            plot(time,mean_compoundcs(:,2));
            hold on
            plot(time,mean_compoundcs(:,2)+sd_compoundcs(:,2),':r');
            plot(time,mean_compoundcs(:,2)-sd_compoundcs(:,2),':r');
            plot([0,0],current_axes(3:4),'--k');
            plot([280,280],current_axes(3:4),'--k');
            plot([250,250],current_axes(3:4),'--g');
            axis tight
            xlabel('Time, msec')
            ylabel('Magnetometer readout, V')
            title('Mean CR I&II (only)')
        end
    end
end

% save as filename_analyzed.mat for use with other scripts
save([filename(1:end-4),'_analyzed.mat']);

