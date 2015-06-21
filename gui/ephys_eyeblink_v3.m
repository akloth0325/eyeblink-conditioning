function varargout = ephys_eyeblink_v3(varargin)
% EPHYS_EYEBLINK_V3 M-file for ephys_eyeblink_v3.fig
%      EPHYS_EYEBLINK_V3, by itself, creates a new EPHYS_EYEBLINK_V3 or raises the existing
%      singleton*.
%
%      H = EPHYS_EYEBLINK_V3 returns the handle to a new EPHYS_EYEBLINK_V3 or the handle to
%      the existing singleton*.
%
%      EPHYS_EYEBLINK_V3('CALLBACK',hObject,eventData,handles,...) calls
%      the local
%      function named CALLBACK in EPHYS_EYEBLINK_V3.M with the given input
%      arguments.
%
%      EPHYS_EYEBLINK_V3('Property','Value',...) creates a new EPHYS_EYEBLINK_V3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ephys_eyeblink_v3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ephys_eyeblink_v3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ephys_eyeblink_v3

% Last Modified by GUIDE v2.5 22-Aug-2012 17:23:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ephys_eyeblink_v3_OpeningFcn, ...
    'gui_OutputFcn',  @ephys_eyeblink_v3_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ephys_eyeblink_v3 is made visible.
function ephys_eyeblink_v3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ephys_eyeblink_v3 (see VARARGIN)

% Choose default command line output for ephys_eyeblink_v3
warning('off','all');
handles.output = hObject;
handles.ALLDATA = [];
handles.records = 0;

% Set up analog input and output channels

set(hObject,'Renderer','Zbuffer','DoubleBuffer','on','BackingStore','on');

daqflag=0;
info = daqhwinfo;
adaptors = info.InstalledAdaptors;
for i = 1:length(info)
    if isequal('nidaq',adaptors{i})
        daqflag = 1;
        break;
    end
end

sample_rates_in = [1000,1000,1000,1000];
sample_rates_out = 1000; % default sampling rate, output channels
if str2num(get(handles.edit23,'String')) > 14/2.1
    sample_rates_out_audio = str2num(get(handles.edit23,'String')) * 2100;
else
    sample_rates_out_audio = 14000;
end
handles.sample_rates_out_audio = sample_rates_out_audio;


channels_in = [0,1,2,6];

handles.channels_in = channels_in;

handles.daqflag = daqflag;

cs_duration = 1; % CS duration in seconds
us_duration = 1; % US duration in seconds
csus_interval = 0.2; % CS-US interval in seconds
csus_intertrial = 1; % CS-US intertrial interval in seconds

% Initialize four sets of axes for displaying data
time = 1; % default time

axes(handles.axes_triggered);
triggered_handle = plot(zeros(time*sample_rates_in(1),1),'k');
axis([0 time*sample_rates_in(1) -10 10]);
set(handles.axes_triggered,'XTickLabel','');
ylabel('NVE readout (V)')
xlabel('Time, sec')
title('Magnetometer signal')

axes(handles.axes5);
triggered_handle2 = plot(zeros(time*sample_rates_in(1),1),'k');
axis([0 time*sample_rates_in(1) -10 10]);
set(handles.axes5,'XTickLabel','');
ylabel('NVE readout (V)')
xlabel('Time, sec')
title('Magnetometer signal')

% set up 3-D data structure; time + 4 channels, time points, recordings;

handles.ALLDATA = [];

% Update handles structure
handles.sample_rates_in = sample_rates_in;
handles.sample_rates_out = sample_rates_out;
handles.cs_duration = cs_duration;
handles.us_duration = us_duration;
handles.csus_interval = csus_interval;
handles.csus_intertrial = csus_intertrial;
handles.triggered_handle = triggered_handle;
handles.triggered_handle2 = triggered_handle2;
handles.min_data = 0;
handles.min_data2= 0;
handles.max_data = 0;
handles.max_data2 = 0;
handles.range_data = 0;
handles.range_data2 = 0;
handles.mean_mean_data = 0;
handles.mean_mean_data2 = 0;

handles.trialtypes = [];

if daqflag == 1
    set(handles.text7,'String','Dev1');
else
    set(handles.text7,'String','<none>');
end

set(handles.edit15,'String',['data_',date,'_',num2str(floor(1000*rand(1))),'.mat']);
guidata(hObject, handles);

% UIWAIT makes ephys_eyeblink_v3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ephys_eyeblink_v3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_ustrigger.
function pushbutton_ustrigger_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ustrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton_uscstrigger,'Enable','off');
set(handles.pushbutton_uscsexecute,'Enable','off');
set(handles.radiobutton3,'Enable','off');
set(handles.radiobutton5,'Enable','off');
set(handles.radiobutton8,'Enable','off');
set(handles.radiobutton9,'Enable','off');
% set(handles.text23,'Enable','off');
set(handles.text26,'Enable','off');
set(handles.text25,'Enable','off');
% set(handles.edit10,'Enable','off');
set(handles.edit8,'Enable','off');
set(handles.edit11,'Enable','off');
sample_rates_out = handles.sample_rates_out;
sample_rates_out_audio = handles.sample_rates_out_audio;
if handles.daqflag == 1 && get(handles.checkbox2,'Value')==get(handles.checkbox2,'Max')
    
    % Set up analog input, three channels (magnetometer, US, CS)
    
    number_of_trials = str2num(get(handles.edit11,'String'));
    AI = analoginput('nidaq','Dev1');
    addchannel(AI,[0,1,2,6]);
    set(AI,'SampleRate',4000);
    set(AI,'SamplesPerTrigger',ceil((2)*get(AI,'SampleRate'))+1);
    set(AI,'TriggerType','Software');
    set(AI,'TriggerCondition','Rising');
    set(AI,'TriggerConditionValue',2);
    set(AI,'TriggerRepeat',number_of_trials-1);
    set(AI,'TriggerDelayUnits','Seconds');
    set(AI,'TriggerDelay',-1);
    set(AI,'Timeout',20);
    set(AI.Channel(1),'InputRange',[-10,10]);
    set(AI.Channel(4),'InputRange',[-10,10]);
    
    % Set up analog output
    
    if get(handles.radiobutton8,'Value')==get(handles.radiobutton8,'Max') && get(handles.radiobutton3,'Value')==get(handles.radiobutton3,'Max')
        set(AI,'TriggerChannel',AI.Channel(3));
        set(hObject,'Enable','off');
        AO = analogoutput('nidaq','Dev1');
        addchannel(AO,1);
        set(AO,'SampleRate',sample_rates_out);
        duration = 0.05;
        data = [zeros(1.1*sample_rates_out,1);5*ones(duration*sample_rates_out,1);0];
        putdata(AO,data);
        start(AI)
        pause(10)
        start(AO)
        set(hObject,'Enable','on');
    elseif get(handles.radiobutton8,'Value')==get(handles.radiobutton8,'Max') && get(handles.radiobutton5,'Value')==get(handles.radiobutton5,'Max')
        set(AI,'TriggerChannel',AI.Channel(3));
        set(hObject,'Enable','off');
        number_of_trials = str2num(get(handles.edit11,'String'));
        duration = 0.05;
        interval = str2num(get(handles.edit8,'String'))/1000; % interval must agree with Master-8 settings
        data = [zeros(1.1*sample_rates_out,1);5*ones(duration*sample_rates_out,1);0];
        AO = analogoutput('nidaq','Dev1');
        addchannel(AO,1);
        set(AO,'SampleRate',sample_rates_out);
        start(AI);
        pause(10)
        waitbar_handle = waitbar(0,['Executing US trials, 0/',num2str(number_of_trials)]);
        for i = 1:number_of_trials

            waitbar(i/number_of_trials,waitbar_handle,['Executing US trials, ',num2str(i),'/',num2str(number_of_trials)]);
            putdata(AO,data);
            start(AO);
            pause(interval);
        end
        close(waitbar_handle)
        stop(AO);
        delete(AO);
        clear AO
        set(hObject,'Enable','on');
        set(handles.text26,'Enable','on');
        set(handles.text25,'Enable','on');
        set(handles.edit8,'Enable','on');
        set(handles.edit11,'Enable','on');
    elseif get(handles.radiobutton9,'Value')==get(handles.radiobutton9,'Max') && get(handles.radiobutton3,'Value')==get(handles.radiobutton3,'Max')
        if get(handles.radiobutton12,'Value')==get(handles.radiobutton12,'Max')
            set(AI,'TriggerChannel',AI.Channel(2));
            set(hObject,'Enable','off');
            AO = analogoutput('nidaq','Dev1');
            addchannel(AO,0);
            set(AO,'SampleRate',sample_rates_out);
            duration = 0.05;
            data = [zeros(1.1*sample_rates_out,1);5*ones(duration*sample_rates_out,1);0];
            putdata(AO,data);
            start(AI)
            pause(10)
            start(AO)
            set(hObject,'Enable','on');
        elseif get(handles.radiobutton13,'Value')==get(handles.radiobutton13,'Max')
            set(AI,'TriggerType','Manual')
            set(hObject,'Enable','off');
            AO = analogouput('winsound');
            addchannel(AO,[1,2]); %channel 1 is mono, channel 2 is right
            set(AO,'SampleRate',sample_rates_out_audio);
            duration = .28;
            data = [get(handles.slider5,'Value')*oscillator('Sinusoid',.28,1000*str2num(get(handles.edit23,'String'))),...
                get(handles.slider6,'Value')*oscillator('Sinusoid',.28,1000*str2num(get(handles.edit23,'String')))];
            % data = [zeros(2,14000*2.15);data];
            putdata(AO, data);
            start(AI)
            pause(2.15)
            start(AO)
            trigger(AI);
            set(hObject,'Enable','on');
        elseif get(handles.radiobutton14,'Value')==get(handles.radiobutton14,'Max')
            set(AI,'TriggerChannel',AI.Channel(2));
            set(hObject,'Enable','off');
            AO1 = analogoutput('winsound');
            AO2 = analogoutput('nidaq','Dev1');
            addchannel(AO1,[1,2]);
            addchannel(AO2,1);
            duration1 = .28;
            duration2 = .05;
            set(AO1,'SampleRate',sample_rates_out_audio);
            set(AO2,'SampleRate',sample_rates_out);
            data1 = [get(handles.slider5,'Value')*oscillator('Sinusoid',0.28,1000*str2num(get(handles.edit23,'String')))...
                get(handles.slider6,'Value')*oscillator('Sinusoid',0.28,1000*str2num(get(handles.edit23,'String')))];
            % data1 = [zeros(2,14000*2.15);data1];
            data2 = [zeros(1.1*sample_rates_out,1);5*ones(duration2*sample_rates_out,1);0];
            putdata(AO1, data1);
            putdata(AO2, data2);
            start(AI)
            pause(10)
            start(AO2)
            pause(2.15)
            start(AO1)
            trigger(AI)
            stop([AO1,AO2])
            delete([AO1,AO2])
            set(hObject,'Enable','off');
        end
    elseif get(handles.radiobutton9,'Value')==get(handles.radiobutton9,'Max') && get(handles.radiobutton5,'Value')==get(handles.radiobutton5,'Max')
        if get(handles.radiobutton12,'Value')==get(handles.radiobutton12,'Max')
            set(AI,'TriggerChannel',AI.Channel(2));
            set(hObject,'Enable','off');
            number_of_trials = str2num(get(handles.edit11,'String'));
            duration = 0.05;
            interval = str2num(get(handles.edit8,'String'))/1000; % interval must agree with Master-8 settings
            data = [zeros(1.1*sample_rates_out,1);5*ones(duration*sample_rates_out,1);0];
            AO = analogoutput('nidaq','Dev1');
            addchannel(AO,0);
            set(AO,'SampleRate',sample_rates_out);
            start(AI);
            pause(10);
            waitbar_handle = waitbar(0,['Executing CS trials, 0/',num2str(number_of_trials)]);
            for i = 1:number_of_trials
                waitbar(i/number_of_trials,waitbar_handle,['Executing CS trials, ',num2str(i),'/',num2str(number_of_trials)]);
                putdata(AO,data);
                start(AO);
                pause(interval);
            end
            stop(AO);
            delete(AO);
            clear AO
            close(waitbar_handle)
            set(hObject,'Enable','on');
            set(handles.text26,'Enable','on');
            set(handles.text25,'Enable','on');
            set(handles.edit8,'Enable','on');
            set(handles.edit11,'Enable','on');
        elseif get(handles.radiobutton13,'Value')==get(handles.radiobutton13,'Max')
            set(AI,'TriggerType','Manual')
            set(hObject,'Enable','off');
            number_of_trials = str2num(get(handles.edit11,'String'));
            duration = 0.28;
            interval = str2num(get(handles.edit8,'String'))/1000;
            data = [get(handles.slider5,'Value')*oscillator('Sinusoid',0.28,1000*str2num(get(handles.edit23,'String'))),...
                get(handles.slider6,'Value')*oscillator('Sinusoid',0.28,1000*str2num(get(handles.edit23,'String')))];
            %data = [zeros(2,14000*2.15);data];
            AO = analogoutput('winsound');
            addchannel(AO,[1,2]);
            set(AO,'SampleRate',sample_rates_out_audio);
            start(AI)
            pause(10)
            waitbar_handle = waitbar(0,['Executing CS trials, 0/',num2str(number_of_trials)]);
            for i = 1:number_of_trials
                waitbar(i/number_of_trials,waitbar_handle,['Executing CS trials, ',num2str(i),'/',num2str(number_of_trials)]);
                putdata(AO,data);
                start(AO);
                pause(2.15)
                trigger(AI);
                pause(interval);
            end
            stop(AO)
            delete(AO)
            close(waitbar_handle)
            set(hObject,'Enable','on');
            set(handles.text26,'Enable','on');
            set(handles.text25,'Enable','on');
            set(handles.edit8,'Enable','on');
            set(handles.edit11,'Enable','on');
        elseif get(handles.radiobutton14,'Value')==get(handles.radiobutton14,'Max')
            set(AI,'TriggerType','Manual')
            set(AI,'TriggerChannel',AI.Channel(2))
            set(hObject,'Enable','off');
            number_of_trials = str2num(get(handles.edit11,'String'));
            duration1 = 0.28;
            duration2 = 0.05;
            interval = str2num(get(handles.edit8,'String'))/1000;
            data1 = [get(handles.slider5,'Value')*oscillator('Sinusoid',0.28,1000*str2num(get(handles.edit23,'String'))),...
                get(handles.slider6,'Value')*oscillator('Sinusoid',0.28,1000*str2num(get(handles.edit23,'String')))];
            %            data1 = [zeros(2,14000*2.15);data1];
            data2 = [zeros(1.1*sample_rates_out,1);5*ones(duration2*sample_rates_out,1);0];
            AO1 = analogoutput('winsound');
            AO2 = analogoutput('nidaq','Dev1');
            addchannel(AO1,[1,2]);
            addchannel(AO2,0);
            set(AO1,'SampleRate',sample_rates_out_audio);
            set(AO2,'SampleRate',sample_rates_out);
            start(AI)
            pause(10)
            waitbar_handle = waitbar(0,['Executing CS trials, 0/',num2str(number_of_trials)]);
            for i = 1:number_of_trials
                waitbar(i/number_of_trials,waitbar_handle,['Executing CS trials, ',num2str(i),'/',num2str(number_of_trials)]);
                putdata(AO1,data1);
                putdata(AO2,data2);
                start(AO2);
                pause(1.2)
                start(AO1)
                trigger(AI)
                pause(interval);
            end
            stop([AO1,AO2])
            delete([AO1,AO2])
            close(waitbar_handle)
            set(hObject,'Enable','on');
            set(handles.text26,'Enable','on');
            set(handles.text25,'Enable','on');
            set(handles.edit8,'Enable','on');
            set(handles.edit11,'Enable','on');
        end
    end
    returndata = get(AI,'SamplesPerTrigger')*(get(AI,'TriggerRepeat')+1);
    [DATA,TIME] = getdata(AI,returndata);
    stop(AI);
    delete(AI);
    clear AI
    baNANas = find(isnan(TIME));
    if ~isempty(baNANas)
        for i = 0:length(baNANas)
            if i == 0
                handles.ALLDATA=cat(3,handles.ALLDATA,[TIME(1:(baNANas(1)-1)),DATA(1:(baNANas(1)-1),:)]);
                guidata(hObject,handles);
            elseif i == length(baNANas)
                handles.ALLDATA=cat(3,handles.ALLDATA,[TIME((baNANas(i)+1):end),DATA((baNANas(i)+1):end,:)]);
                guidata(hObject,handles);
                axes(handles.axes_triggered)
                plot(TIME((baNANas(i)+1):end),DATA((baNANas(i)+1):end,1));
                axis tight
                axes(handles.axes5)
                plot(TIME((baNANas(i)+1):end),DATA((baNANas(i)+1):end,4));
                axis tight
                if get(handles.radiobutton9,'Value')==get(handles.radiobutton9,'Max')
                    if get(handles.radiobutton12,'Value')==get(handles.radiobutton12,'Max') || get(handles.radiobutton14,'Value')==get(handles.radiobutton14,'Max')
                        axes(handles.axes_triggered)
                        hold on
                        x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                        yLims = get(gca,'YLim');
                        line([x,x],yLims,'Color','red','LineStyle','-.')
                        x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                        yLims = get(gca,'YLim');
                        line([x,x],yLims,'Color','red','LineStyle','-.')
                        hold off
                        axes(handles.axes5)
                        hold on
                        x = TIME(find(DATA(:,2) > 2.0,1,'first'));
                        yLims = get(gca,'YLim');
                        line([x,x],yLims,'Color','red','LineStyle','-.')
                        x = TIME(find(DATA(:,2) > 2.0,1,'last'));
                        yLims = get(gca,'YLim');
                        line([x,x],yLims,'Color','red','LineStyle','-.')
                        hold off
                    elseif get(handles.radiobutton13,'Value')==get(handles.radiobutton13,'Max')
                        axes(handles.axes_triggered)
                        hold on
                        x1 = TIME((baNANas(i)+1+4000));
                        x2 = TIME((baNANas(i)+1+4000+1120));
                        yLims = get(gca,'YLim');
                        line([x1,x1],yLims,'Color','red','LineStyle','-.')
                        line([x2,x2],yLims,'Color','red','LineStyle','-.')
                        hold off
                        axes(handles.axes5)
                        hold on
                        x1 = TIME((baNANas(i)+1+4000));
                        x2 = TIME((baNANas(i) + 1 + 1120));
                        yLims = get(gca,'YLim');
                        line([x1,x1],yLims,'Color','red','LineStyle','-.')
                        line([x2,x2],yLims,'Color','red','LineStyle','-.')
                        hold off
                    end
                end
                if get(handles.radiobutton8,'Value')==get(handles.radiobutton8,'Max');
                    axes(handles.axes_triggered)
                    hold on
                    x = TIME(find(DATA(:,3)> 2.0,1,'first'));
                    yLims = get(gca,'YLim');
                    line([x,x],yLims,'Color','green','LineStyle',':')
                    x = TIME(find(DATA(:,3)> 2.0,1,'last'));
                    yLims = get(gca,'YLim');
                    line([x,x],yLims,'Color','green','LineStyle',':')
                    hold off
                    axes(handles.axes5)
                    hold on
                    x = TIME(find(DATA(:,3) > 2.0,1,'first'));
                    yLims = get(gca,'YLim');
                    line([x,x],yLims,'Color','green','LineStyle',':')
                    x = TIME(find(DATA(:,3) > 2.0,1,'last'));
                    yLims = get(gca,'YLim');
                    line([x,x],yLims,'Color','green','LineStyle',':')
                    hold off
                end
                set(handles.text30,'String',num2str(str2num(get(handles.text30,'String'))+i+1));
                set(handles.text40,'String',num2str(str2num(get(handles.text40,'String'))+i+1));
                set(handles.slider1,'Max',str2num(get(handles.text30,'String')));
                set(handles.slider2,'Max',str2num(get(handles.text40,'String')));
                set(handles.text28,'String',get(handles.text30,'String'))
                set(handles.text38,'String',get(handles.text40,'String'))
                set(handles.slider1,'Value',str2num(get(handles.text30,'String')));
                set(handles.slider2,'Value',str2num(get(handles.text40,'String')));
                if get(handles.slider1,'Max') == 2
                    set(handles.slider1,'SliderStep',[1 1]);
                elseif get(handles.slider1,'Max') > 2
                    set(handles.slider1,'SliderStep',[1/(get(handles.slider1,'Max')-1),1/(get(handles.slider1,'Max')-1)]);
                end
                if get(handles.slider2,'Max') == 2
                    set(handles.slider2,'SliderStep',[1 1]);
                elseif get(handles.slider2,'Max') > 2
                    set(handles.slider2,'SliderStep',[1/(get(handles.slider2,'Max')-1),1/(get(handles.slider2,'Max')-1)]);
                end
                set(handles.slider1,'Enable','on');
                set(handles.slider2,'Enable','on');
                if get(handles.checkbox1,'Value')==get(handles.checkbox1,'Max')
                    filename=get(handles.edit15,'String');
                    data=handles.ALLDATA;
                    save(filename,'data');
                end
            else
                handles.ALLDATA=cat(3,handles.ALLDATA,[TIME((baNANas(i)+1):(baNANas(i+1)-1)),DATA((baNANas(i)+1):(baNANas(i+1)-1),:)]);
                guidata(hObject,handles);
            end
        end
    else
        handles.ALLDATA = cat(3,handles.ALLDATA,[TIME,DATA]);
        guidata(hObject,handles);
        axes(handles.axes_triggered)
        plot(TIME,DATA(:,1));
        axis tight
        axes(handles.axes5)
        plot(TIME,DATA(:,4));
        axis tight
        if get(handles.radiobutton9,'Value')==get(handles.radiobutton9,'Max')
            if get(handles.radiobutton12,'Value')==get(handles.radiobutton12,'Max') || get(handles.radiobutton14,'Value')==get(handles.radiobutton14,'Max')
                axes(handles.axes_triggered)
                hold on
                x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                yLims = get(gca,'YLim');
                line([x,x],yLims,'Color','red','LineStyle','-.')
                x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                yLims = get(gca,'YLim');
                line([x,x],yLims,'Color','red','LineStyle','-.')
                hold off
                axes(handles.axes5)
                hold on
                x = TIME(find(DATA(:,2) > 2.0,1,'first'));
                yLims = get(gca,'YLim');
                line([x,x],yLims,'Color','red','LineStyle','-.')
                x = TIME(find(DATA(:,2) > 2.0,1,'last'));
                yLims = get(gca,'YLim');
                line([x,x],yLims,'Color','red','LineStyle','-.')
                hold off
            elseif get(handles.radiobutton13,'Value')==get(handles.radiobutton13,'Max')
                axes(handles.axes_triggered)
                hold on
                x1 = TIME(4001);
                x2 = TIME(5120);
                yLims = get(gca,'YLim');
                line([x1,x1],yLims,'Color','red','LineStyle','-.')
                yLims = get(gca,'YLim');
                line([x2,x2],yLims,'Color','red','LineStyle','-.')
                hold off
                axes(handles.axes5)
                hold on
                x1 = TIME(4001);
                x2 = TIME(5120);
                yLims = get(gca,'YLim');
                line([x1,x1],yLims,'Color','red','LineStyle','-.')
                yLims = get(gca,'YLim');
                line([x2,x2],yLims,'Color','red','LineStyle','-.')
                hold off
            end
        end
        if get(handles.radiobutton8,'Value')==get(handles.radiobutton8,'Max');
            axes(handles.axes_triggered)
            hold on
            x = TIME(find(DATA(:,3)> 2.0,1,'first'));
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','green','LineStyle',':')
            x = TIME(find(DATA(:,3)> 2.0,1,'last'));
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','green','LineStyle',':')
            hold off
            axes(handles.axes5)
            x = TIME(find(DATA(:,3) > 2.0,1,'first')); %#ok<*GTARG>
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','green','LineStyle',':')
            x = TIME(find(DATA(:,3) > 2.0,1,'last'));
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','green','LineStyle',':')
            hold off
        end
        set(handles.text30,'String',num2str(str2num(get(handles.text30,'String'))+1));
        set(handles.text40,'String',num2str(str2num(get(handles.text40,'String'))+1));
        set(handles.slider1,'Max',str2num(get(handles.text30,'String')));
        set(handles.slider2,'Max',str2num(get(handles.text40,'String')));
        set(handles.text28,'String',get(handles.text30,'String'))
        set(handles.text38,'String',get(handles.text40,'String'))
        set(handles.slider1,'Value',str2num(get(handles.text30,'String')));
        set(handles.slider2,'Value',str2num(get(handles.text40,'String')));
        if get(handles.slider1,'Max') == 2
            set(handles.slider1,'SliderStep',[1 1]);
        elseif get(handles.slider1,'Max') > 2
            set(handles.slider1,'SliderStep',[1/(get(handles.slider1,'Max')-1),1/(get(handles.slider1,'Max')-1)]);
        end
        if get(handles.slider2,'Max') == 2
            set(handles.slider2,'SliderStep',[1 1]);
        elseif get(handles.slider2,'Max') > 2
            set(handles.slider2,'SliderStep',[1/(get(handles.slider2,'Max')-1),1/(get(handles.sldier2,'Max')-1)]);
        end
        set(handles.slider1,'Enable','on');
        set(handles.slider2,'Enable','on')
        if get(handles.checkbox1,'Value')==get(handles.checkbox1,'Max')
            filename=get(handles.edit15,'String');
            data=handles.ALLDATA;
            save(filename,'data');
        end
    end
elseif handles.daqflag == 1
    sample_rates_out = handles.sample_rates_out;
    if get(handles.radiobutton8,'Value')==get(handles.radiobutton8,'Max') && get(handles.radiobutton3,'Value')==get(handles.radiobutton3,'Max')
        set(hObject,'Enable','off');
        AO = analogoutput('nidaq','Dev1');
        addchannel(AO,1);
        set(AO,'SampleRate',sample_rates_out);
        duration = 0.05;
        data = [0;5*ones(duration*sample_rates_out,1);0];
        putdata(AO,data);
        start(AO)
        pause(0.1)
        stop(AO)
        delete(AO)
        clear AO
        set(hObject,'Enable','on');
    elseif get(handles.radiobutton8,'Value')==get(handles.radiobutton8,'Max') && get(handles.radiobutton5,'Value')==get(handles.radiobutton5,'Max')
        set(hObject,'Enable','off');
        number_of_trials = str2num(get(handles.edit11,'String'));
        duration = 0.05;
        interval = str2num(get(handles.edit8,'String'))/1000; % interval must agree with Master-8 settings
        data = [0;5*ones(duration*sample_rates_out,1);0];
        for i = 1:number_of_trials
            AO = analogoutput('nidaq','Dev1');
            addchannel(AO,1);
            set(AO,'SampleRate',sample_rates_out);
            putdata(AO,data);
            start(AO)
            pause(0.1)
            stop(AO)
            delete(AO)
            clear AO
        end
        set(hObject,'Enable','on');
        set(handles.text26,'Enable','on');
        set(handles.text25,'Enable','on');
        set(handles.edit8,'Enable','on');
        set(handles.edit11,'Enable','on');
    elseif get(handles.radiobutton9,'Value')==get(handles.radiobutton9,'Max') && get(handles.radiobutton3,'Value')==get(handles.radiobutton3,'Max')
        set(hObject,'Enable','on');
        AO = analogoutput('nidaq','Dev1');
        addchannel(AO,0);
        set(AO,'SampleRate',sample_rates_out);
        duration = 0.05;
        data = [0;5*ones(duration*sample_rates_out,1);0];
        putdata(AO,data);
        start(AO)
        pause(0.1)
        stop(AO)
        delete(AO)
        clear AO
        set(hObject,'Enable','on');
    elseif get(handles.radiobutton9,'Value')==get(handles.radiobutton9,'Max') && get(handles.radiobutton5,'Value')==get(handles.radiobutton5,'Max')
        set(hObject,'Enable','off');
        number_of_trials = str2num(get(handles.edit11,'String'));
        duration = 0.05;
        interval = str2num(get(handles.edit8,'String'))/1000; % interval must agree with Master-8 settings
        data = [0;5*ones(duration*sample_rates_out,1);0];
        for i = 1:number_of_trials
            AO = analogoutput('nidaq','Dev1');
            addchannel(AO, 0);
            set(AO,'SampleRate',sample_rates_out);
            putdata(AO,data);
            start(AO)
            pause(0.1)
            stop(AO)
            delete(AO)
            clear AO
        end
        set(hObject,'Enable','on');
        set(handles.text26,'Enable','on');
        set(handles.text25,'Enable','on');
        set(handles.edit8,'Enable','on');
        set(handles.edit11,'Enable','on');
    end
else
    set(hObject,'Enable','off');
    pause(1)
    set(hObject,'Enable','on');
end
if get(handles.radiobutton1,'Value')==get(handles.radiobutton1,'Max') %|| get(handles.radiobutton2,'Value')==get(handles.radiobutton2,'Max')
    set(handles.pushbutton_uscsexecute,'Enable','on');
else
    set(handles.pushbutton_uscstrigger,'Enable','on');
end
set(handles.radiobutton3,'Enable','on');
set(handles.radiobutton5,'Enable','on');
set(handles.radiobutton8,'Enable','on');
set(handles.radiobutton9,'Enable','on');
% set(handles.text23,'Enable','on');
% set(handles.edit10,'Enable','on');


% --- Executes on button press in pushbutton_uscsexecute.
function pushbutton_uscsexecute_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_uscsexecute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warn = warndlg('Be sure that the Master-8 is set with the correct stimulus timing for your task!','Master-8 Warning','modal');
uiwait(warn)

if isequal(get(hObject,'String'),'EXECUTE US-CS TRIALS')
    set(hObject,'Enable','off');
    set(handles.pushbutton_ustrigger,'Enable','off');
    if get(handles.radiobutton1,'Value')==get(handles.radiobutton1,'Max')
        set(handles.radiobutton1,'Enable','off');
        set(handles.radiobutton2,'Enable','off');
        set(handles.text14,'Enable','off');
        %        set(handles.text15,'Enable','off');
        %        set(handles.text16,'Enable','off');
        %        set(handles.text17,'Enable','off');
        set(handles.text27,'Enable','off');
        set(handles.edit4,'Enable','off');
        %        set(handles.edit5,'Enable','off');
        %        set(handles.edit6,'Enable','off');
        %        set(handles.edit7,'Enable','off');
        set(handles.edit14,'Enable','off');
        set(handles.slider1,'Enable','off')
        
        if handles.daqflag == 1
            number_of_trials = str2num(get(handles.edit4,'String'));
            intertrial_interval = str2num(get(handles.edit14,'String'))/1000;
            
            duration = 0.005;
            sample_rates_out = handles.sample_rates_out;
            sample_rates_out_audio = handles.sample_rates_out_audio;
            %data = [0,0;5*ones(duration*sample_rates_out,2);0,0];
            %data_cs = [0,0;5*ones(duration*sample_rates_out,1),zeros(duration*sample_rates_out,1);0,0];
            
            AI = analoginput('nidaq','Dev1');
            addchannel(AI,[0,1,2,6]);
            set(AI,'SampleRate',4000);
            set(AI,'SamplesPerTrigger',ceil((10)*get(AI,'SampleRate')));
            set(AI,'TriggerType','Immediate');
            set(AI,'TriggerRepeat',0);
            set(AI,'Timeout',20);
            set(AI.Channel(1),'InputRange',[-10,10]);
            set(AI.Channel(4),'InputRange',[-10,10]);
            if get(handles.radiobutton15,'Value')==get(handles.radiobutton15,'Max')
                if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Min')
                    AO = analogoutput('nidaq','Dev1');
                    addchannel(AO,[0,1]);
                    set(AO,'SampleRate',sample_rates_out);
                elseif get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                    AO1 = analogoutput('winsound');
                    addchannel(AO1,[1,2]);
                    set(AO1,'SampleRate',handles.sample_rates_out_audio);
                    AO2 = analogoutput('nidaq','Dev1');
                    addchannel(AO2,[0,1]);
                    set(AO2,'SampleRate',sample_rates_out);
                end
            elseif get(handles.radiobutton16,'Value')==get(handles.radiobutton16,'Max') || get(handles.radiobutton17,'Value')==get(handles.radiobutton17,'Max')
                AO1 = analogoutput('winsound');
                addchannel(AO1,[1,2]);
                set(AO1,'SampleRate',handles.sample_rates_out_audio);
                AO2 = analogoutput('nidaq','Dev1');
                addchannel(AO2,[0,1]);
                set(AO2,'SampleRate',sample_rates_out);
            end
            
            waitbar_handle = waitbar(0,['Executing US-CS trials, 0/',num2str(number_of_trials)]);
            
            trialtypes = [];
            
            if get(handles.radiobutton15,'Value')==get(handles.radiobutton15,'Max') || get(handles.radiobutton16,'Value')==get(handles.radiobutton16,'Max')
                
                number_of_blocks = floor(number_of_trials/10);
                size_of_block = 10;
                leftovers = rem(number_of_trials,10);
            elseif get(handles.radiobutton17,'Value')==get(handles.radiobutton17,'Max')
                number_of_blocks = floor(number_of_trials/11);
                size_of_block = 11;
                leftovers = rem(number_of_trials,11);
            end
            
             if get(handles.radiobutton17,'Value') == get(handles.radiobutton17,'Max')  && get(handles.ustest,'Value') == get(handles.ustest,'Max')
                 trialtypes = [ones(1,5*floor(number_of_trials/11)+rem(number_of_trials,11)),10*ones(1,4.5*floor(number_of_trials/11)),11*ones(1,0.5*floor(number_of_trials/11))];
                 temp_rand = randperm(length(trialtypes));
                 trialtypes = trialtypes(temp_rand);
             elseif get(handles.radiobutton15,'Value') == get(handles.radiobutton15,'Max') && get(handles.checkbox9,'Value') == get(handles.checkbox9,'Max')
                 trialtypes = ones(1,number_of_trials);
                 trialtypes(2:2:end) = 10;
             elseif get(handles.radiobutton16,'Value') == get(handles.radiobutton16,'Max') && get(handles.checkbox9,'Value') == get(handles.checkbox9,'Max')
                 trialtypes = ones(1,number_of_trials);
                 trialtypes(2:2:end) = 10;
             elseif get(handles.radiobutton17,'Value') == get(handles.radiobutton17,'Max') && get(handles.checkbox9,'Value') == get(handles.checkbox9,'Max')
                 trialtypes = ones(1,number_of_trials);
                 trialtypes(2:2:end) = 10;
                 trialtypes(4:4:end) = 11;
                 trialtypes(6:6:end) = 12;
             else    
                rblocks10 = randperm(number_of_blocks);
                rblocks11 = randperm(number_of_blocks);
                %rblocks10 = rblocks10(1:floor(number_of_blocks/2));
                %rblocks11 = rblocks11(1:floor(number_of_blocks/2));
                
                for i = 1:number_of_blocks
                    trialtypes((size_of_block*(i-1)+1):(size_of_block*i)) = ones(1,size_of_block);
                    if size_of_block == 10 && ~isempty(intersect(rblocks10,i))
                        index10 = ceil(10*rand(1));
                        trialtypes(size_of_block*(i-1)+index10) = 10;
                    elseif size_of_block == 11
                        index10 = ceil(10*rand(1));
                        if ~isempty(intersect(rblocks10,i))
                            trialtypes(size_of_block*(i-1)+index10) = 10;
                        else
                            index10 = 0;
                        end
                        index11 = index10;
                        while index11 == index10
                            index11 = ceil(11*rand(1));
                        end
                        if ~isempty(intersect(rblocks11,i))
                            trialtypes(size_of_block*(i-1)+index11) = 11;
                        end
                        %                   index12 = index10;
                        %                   while (index12 == index10) || (index12 == index11)
                        %                      index12 = ceil(12*rand(1));
                        %                   end
                        %                   trialtypes(size_of_block*(i-1)+index12) = 12;
                    end
                end
             end
            trialtypes((number_of_blocks*size_of_block+1):(number_of_blocks*size_of_block+leftovers))= ones(1,leftovers);
            
            handles.trialtypes = trialtypes;
            
            for i = 1:number_of_trials
                waitbar(i/number_of_trials,waitbar_handle,['Executing US-CS trials, ',num2str(i),'/',num2str(number_of_trials)]);
                
                if get(handles.radiobutton15,'Value')==get(handles.radiobutton15,'Max')
                    data = [0,0;5*ones(duration*sample_rates_out,2);0,0];
                    data_cs = [0,0;5*ones(duration*sample_rates_out,1),zeros(duration*sample_rates_out,1);0,0];
                    data_puff = [0,0;zeros(duration*sample_rates_out,1),5*ones(duration*sample_rates_out,1);0,0];
                    
                    if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                        duration2 = .280;
                        data_w = [0,0;randn(length(0:1/sample_rates_out_audio:duration2),1),...
                            randn(length(0:1/sample_rates_out_audio:duration2),1);0,0];
                        % click train
                        [y,fs,nbits] = wavread('click-track_1200bpm_1sec.wav');
                        y = resample(y,14000,44100);
                        data_c = [0,0;y(1:3920),y(1:3920);0,0];
                    end
                    
                    if mod(trialtypes(i),10) == 0
                        if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Min')
                            putdata(AO,data_cs);
                        elseif get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                            putdata(AO1,[0,0]);
                            putdata(AO2,data_cs);
                        end
                    else
                        if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Min')
                            putdata(AO,data);
                        elseif get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                            putdata(AO1,data_c);
                            putdata(AO2,data_puff);
                        end
                    end
                    triggered_flag = 0;
                    
                    while triggered_flag == 0
                        start(AI)
                        pause(1.5)
                        apeek = peekdata(AI,round(AI.SampleRate));
                        if get(handles.radiobutton20,'Value') == get(handles.radiobutton20,'Max')
                            window_max = handles.mean_mean_data + 0.1*handles.range_data;
                            window_min = handles.mean_mean_data - 0.2*handles.range_data;
                        elseif get(handles.radiobutton21,'Value') == get(handles.radiobutton21,'Max')
                            window_max = handles.mean_mean_data + 0.2*handles.range_data;
                            window_min = handles.mean_mean_data - 0.2*handles.range_data;
                        elseif get(handles.radiobutton22,'Value') == get(handles.radiobutton22,'Max')
                            window_max = handles.mean_mean_data + 0.1*handles.range_data;
                            window_min = -100;
                        elseif get(handles.radiobutton23,'Value') == get(handles.radiobutton23,'Max')
                            window_max = handles.mean_mean_data + 0.2*handles.range_data;
                            window_min = -100;
                        end
                        
                        if get(handles.radiobutton24,'Value') == get(handles.radiobutton24,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.1*handles.range_data2;
                            window_min2 = handles.mean_mean_data2 - 0.2*handles.range_data2;
                        elseif get(handles.radiobutton25,'Value') == get(handles.radiobutton25,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.2*handles.range_data2;
                            window_min2 = handles.mean_mean_data2 - 0.2*handles.range_data2;
                        elseif get(handles.radiobutton26,'Value') == get(handles.radiobutton26,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.1*handles.range_data2;
                            window_min2 = -100;
                        elseif get(handles.radiobutton27,'Value') == get(handles.radiobutton27,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.2*handles.range_data2;
                            window_min2 = -100;
                        end
                        if str2num(get(handles.edit16,'String')) ~= 0 && str2num(get(handles.edit17,'String')) ~= 0 %#ok<*ST2NM>
                            if isempty(find(apeek(:,1) > window_max)) && isempty(find(apeek(:,1) < window_min)) %#ok<*EFIND>
                                if str2num(get(handles.edit20,'String')) ~= 0 && str2num(get(handles.edit21,'String')) ~= 0
                                    if isempty(find(apeek(:,4) > window_max2)) && isempty(find(apeek(:,4) < window_min2))
                                        triggered_flag = 1;
                                        if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Min')
                                            start(AO);
                                        elseif get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                                            start([AO1,AO2]);
                                        end
                                        pause(8.6)
                                    else
                                        stop(AI)
                                        pause(1)
                                    end
                                else
                                    triggered_flag = 1;
                                    if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Min')
                                        start(AO);
                                    elseif get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                                        start([AO1,AO2]);
                                    end
                                    pause(8.6)
                                end
                            else
                                stop(AI)
                                pause(1);
                            end
                        elseif str2num(get(handles.edit20,'String')) ~= 0 && str2num(get(handles.edit21,'String')) ~=0
                            if isempty(find(apeek(:,4) > window_max2)) && isempty(find(apeek(:,4) < window_min2))
                                triggered_flag = 1;
                                if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Min')
                                    start(AO);
                                elseif get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                                    start([AO1,AO2]);
                                end
                                pause(8.6)
                            else
                                stop(AI)
                                pause(1)
                            end
                        else
                            triggered_flag = 1;
                            if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Min')
                                start(AO);
                            elseif get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                                start([AO1,AO2]);
                            end
                            pause(8.6)
                        end
                    end
                elseif get(handles.radiobutton16,'Value')==get(handles.radiobutton16,'Max')
                    duration1 = 0.005;
                    duration2 = .280;
                    data = [0,0;zeros(duration1*sample_rates_out,1),5*ones(duration1*sample_rates_out,1);0,0];
                    data_cs = [0,0;sin(2*pi*str2num(get(handles.edit23,'String'))*1000*(0:1/sample_rates_out_audio:duration2))',...
                        sin(2*pi*str2num(get(handles.edit23,'String'))*1000*(0:1/sample_rates_out_audio:duration2))';0,0];
                    data_cs_2 = [0,0];
                    %data_cs_2 =
                    %[0,0;5*ones(duration*sample_rates_out,1),zeros(duratio
                    %n*sample_rates_out,1);0,0];
                    
                    if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                        duration2 = .280
                        data_w = [0,0;randn(length(0:1/sample_rates_out_audio:duration2),1),...
                            randn(length(0:1/sample_rates_out_audio:duration2),1);0,0];
                        % click train
                        [y,fs,nbits] = wavread('click-track_1200bpm_1sec.wav');
                        y = resample(y,14000,44100);
                        data_c = [0,0;y(1:3920),y(1:3920);0,0];
                    end
                    
                    if mod(trialtypes(i),10) == 0
                        putdata(AO1,data_cs);
                        putdata(AO2,[0,0]);
                    else
                        if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Min')
                            putdata(AO1,data_cs)
                        elseif get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                            putdata(AO1,data_c)
                        end
                        putdata(AO2,data);
                    end
                    %                     putdata(AO1,data_cs);
                    triggered_flag = 0;
                    telapsed = 0;
                    
                    while triggered_flag == 0
                        tstart = tic;
                        start(AI)
                        pause(1.5)
                        apeek = peekdata(AI,round(AI.SampleRate));
                        if get(handles.radiobutton20,'Value') == get(handles.radiobutton20,'Max')
                            window_max = handles.mean_mean_data + 0.1*handles.range_data;
                            window_min = handles.mean_mean_data - 0.2*handles.range_data;
                        elseif get(handles.radiobutton21,'Value') == get(handles.radiobutton21,'Max')
                            window_max = handles.mean_mean_data + 0.2*handles.range_data;
                            window_min = handles.mean_mean_data - 0.2*handles.range_data;
                        elseif get(handles.radiobutton22,'Value') == get(handles.radiobutton22,'Max')
                            window_max = handles.mean_mean_data + 0.1*handles.range_data;
                            window_min = -100;
                        elseif get(handles.radiobutton23,'Value') == get(handles.radiobutton23,'Max')
                            window_max = handles.mean_mean_data + 0.2*handles.range_data;
                            window_min = -100;
                        end
                        
                        if get(handles.radiobutton24,'Value') == get(handles.radiobutton24,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.1*handles.range_data2;
                            window_min2 = handles.mean_mean_data2 - 0.2*handles.range_data2;
                        elseif get(handles.radiobutton25,'Value') == get(handles.radiobutton25,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.2*handles.range_data2;
                            window_min2 = handles.mean_mean_data2 - 0.2*handles.range_data2;
                        elseif get(handles.radiobutton26,'Value') == get(handles.radiobutton26,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.1*handles.range_data2;
                            window_min2 = -100;
                        elseif get(handles.radiobutton27,'Value') == get(handles.radiobutton27,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.2*handles.range_data2;
                            window_min2 = -100;
                        end
                        if str2num(get(handles.edit16,'String')) ~= 0 && str2num(get(handles.edit17,'String')) ~= 0 %#ok<*ST2NM>
                            if isempty(find(apeek(:,1) > window_max)) && isempty(find(apeek(:,1) < window_min)) %#ok<*EFIND>
                                if str2num(get(handles.edit20,'String')) ~= 0 && str2num(get(handles.edit21,'String')) ~= 0
                                    if isempty(find(apeek(:,4) > window_max2)) && isempty(find(apeek(:,4) < window_min2))
                                        triggered_flag = 1;
                                        start([AO1,AO2]);
                                        telapsed = toc(tstart);
                                        pause(8.6)
                                    else
                                        stop(AI)
                                        telapsed = toc(tstart);
                                        pause(1)
                                    end
                                else
                                    triggered_flag = 1;
                                    start([AO1,AO2]);
                                    telapsed = toc(tstart);
                                    pause(8.6)
                                end
                            else
                                stop(AI)
                                pause(1);
                            end
                        elseif str2num(get(handles.edit20,'String')) ~= 0 && str2num(get(handles.edit21,'String')) ~=0
                            if isempty(find(apeek(:,4) > window_max2)) && isempty(find(apeek(:,4) < window_min2))
                                triggered_flag = 1;
                                telapsed = toc(tstart);
                                start([AO1,AO2]);
                                pause(8.6)
                            else
                                stop(AI)
                                telapsed = toc(tstart);
                                pause(1)
                            end
                        else
                            triggered_flag = 1;
                            telapsed = toc(tstart);
                            start([AO1,AO2]);
                            pause(8.6)
                        end
                    end
                elseif get(handles.radiobutton17,'Value')==get(handles.radiobutton17,'Max')
                    duration1 = 0.005;
                    duration2 = .280;
                    data = [0,0;5*ones(duration1*sample_rates_out,1),5*ones(duration1*sample_rates_out,1);0,0]; %US-CS (light) only
                    data_puff_only = [0,0;zeros(duration1*sample_rates_out,1),5*ones(duration1*sample_rates_out,1);0,0]; % puff only
                    data_cs = [0,0;get(handles.slider5,'Value')*oscillator('Sinusoid',0.28,1000*str2num(handles.edit23,'String')),... % any CS (sound) presentation
                        get(handles.slider6,'Value')*oscillator('Sinusoid',0.28,1000*str2num(handles.edit23,'String'));0,0];
                    data_clicktrain = [0,0;get(handles.slider5,'Value')*oscillator('Click Train',0.28,20),...
                        get(handles.slider6,'Value')*oscillator('Click Train',0.28,20);0,0];
                    data_no_sound = [0,0;0,0];
                    data_nodaq = [0,0;0,0];
                    data_cs_2 = [0,0;5*ones(duration*sample_rates_out,1),zeros(duration*sample_rates_out,1);0,0]; %CS (light) only
                    
                    %Special parameters for forgetting trials and
                    %unovershadowing test
                    
%                     if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max') || get(handles.ustest,'Value') == get(handles.,'Max') || get(handles.ustest2,'Value') == get(handles.ustest2,'Max')
%                         duration2 = .280
%                         data_w = [0,0;randn(length(0:1/sample_rates_out_audio:duration2),1),...
%                             randn(length(0:1/sample_rates_out_audio:duration2),1);0,0];
%                         % click train
%                         [y,fs,nbits] = wavread('C:\click-track_1200bpm_1sec.wav');
%                         data_c = [0,0;y(1:12348),y(1:12348);0,0];
%                     end
                    
                    % BBtest, Unovershadowing test, or neither
                    % AO1: sound card
                    % AO2: National Instruments data acquisition
                    
                    if get(handles.bbtest,'Value') == get(handles.bbtest,'Max') && get(handles.ustest,'Value') == get(handles.ustest,'Min') && get(handles.ustest2,'Value') == get(handles.ustest2,'Min') %% defaults to light if neither bbtest1 nor bbtest2 selected
                        if get(handles.bbtest1,'Value') == get(handles.bbtest1,'Max') || (get(handles.bbtest1,'Value') == get(handles.bbtest1,'Min') && get(handles.bbtest2,'Value') == get(handles.bbtest2,'Min'))
                            if mod(trialtypes(i),11) == 10 % light only, no US
                                putdata(AO2,data_cs_2);
                                putdata(AO1,data_no_sound);
                            elseif mod(trialtypes(i),11) == 0 % sound only, no US
                                putdata(AO2,data_nodaq);
                                putdata(AO1,data_cs);
                                %                             elseif mod(trialtypes(i),12) == 0 % light + sound only, no US
                                %                                 putdata(AO2,data_cs_2)
                                %                                 putdata(AO1,data_cs);
                            else % light plus US
                                putdata(AO1,data_no_sound);
                                putdata(AO2,data);
                            end
                        elseif get(handles.bbtest2,'Value') == get(handles.bbtest2,'Max')
                            if mod(trialtypes(i),11) == 10 % sound only, no US
                                putdata(AO2,data_nodaq);
                                putdata(AO1,data_cs)
                            elseif mod(trialtypes(i),11) == 0 % light only, no US
                                putdata(AO2,data_cs_2);
                                putdata(AO1,data_no_sound);
                                %                             elseif mod(trialtypes(i),12) == 0 % light + sound only, no US
                                %                                 putdata(AO2,data_cs_2)
                                %                                 putdata(AO1,data_cs);
                            else % sound plus US
                                %putdata(AO1,data_cs);
                                putdata(AO2,data_puff_only);
                                putdata(AO1,[0,0;0,0]);
                            end
                        end
                    elseif get(handles.bbtest,'Value') == get(handles.bbtest,'Min') && get(handles.ustest,'Value') == get(handles.ustest,'Max') && get(handles.ustest2,'Value') == get(handles.ustest2,'Min')
                        if get(handles.bbtest1,'Value') == get(handles.bbtest1,'Max') || (get(handles.bbtest1,'Value') == get(handles.bbtest1,'Min') && get(handles.bbtest2,'Value') == get(handles.bbtest2,'Min'))
                            if mod(trialtypes(i),11) == 0 % sound only
                                set(AO1,'SampleRate',sample_rates_out_audio);
                                putdata(AO2, data_nodaq);
                                putddata(AO1, data_cs);
                            elseif mod(trialtypes(i),11) == 10 % click train plus US
                                set(AO1,'SampleRate',fs)
                                putdata(AO1, data_clicktrain);
                                putdata(AO2, data_puff_only);
                            else % light only
                                putdata(AO2, data_cs_2);
                                putdata(AO1, data_no_sound);
                            end
                        elseif get(handles.bbtest2,'Value') == get(handles.bbtest2,'Max')
                            if mod(trialtypes(i),11) == 0 % light only
                                putdata(AO2, data_cs_2);
                                putdata(AO1, data_no_sound);
                            elseif mod(trialtypes(i),11) == 10 % click train plus US
                                putdata(AO1, data_clicktrain);
                                putdata(AO2, data_puff_only);
                            else % sound only
                                putdata(AO2, data_nodaq);
                                putdata(AO1, data_cs);
                            end
                        end
                    elseif get(handles.bbtest,'Value') == get(handles.bbtest,'Min') && get(handles.ustest2,'Value') == get(handles.ustest2,'Max') && get(handles.ustest,'Value') == get(handles.ustest,'Min')
                        if get(handles.bbtest1,'Value') == get(handles.bbtest1,'Max') || (get(handles.bbtest1,'Value') == get(handles.bbtest1,'Min') && get(handles.bbtest2,'Value') == get(handles.bbtest2,'Min'))
                            if mod(trialtypes(i),11) == 10 % sound only
                                set(AO1,'SampleRate',sample_rates_out_audio);
                                putdata(AO2, data_nodaq);
                                putdata(AO1, data_cs);
                            elseif mod(trialtypes(i),11) == 0
                                putdata(AO2, data_cs_2);
                                putdata(AO1, data_no_sound);% light only
                            else % click train plus US
                                set(AO1,'SampleRate',fs);
                                putdata(AO1, data_clicktrain);
                                putdata(AO2, data_puff_only);
                            end
                        elseif get(handles.bbtest2,'Value') == get(handles.bbtest2,'Max')
                            if mod(trialtypes(i),11) == 10 % light only
                                putdata(AO2, data_cs_2);
                                putdata(AO1, data_no_sound);
                            elseif mod(trialtypes(i),11) == 0 % sound only
                                set(AO1,'SampleRate',sample_rates_out_audio);
                                putdata(AO2, data_nodaq);
                                putdata(AO1, data_cs);
                            else % click train plus Us
                                set(AO1,'SampleRate',fs);
                                putdata(AO1, data_clicktrain);
                                putdata(AO2, data_puff_only);
                                
                            end
                        end
                    elseif get(handles.checkbox9,'Value') == get(handles.checkbox9,'Max')
                        if mod(trialtypes(i),12) == 10
                            putdata(AO1,data_cs); % AO1 is sound card
                            putdata(AO2,data_nodaq);
                        elseif mod(trialtypes(i),12) == 11
                            putdata(AO2,data_cs_2);
                            putdata(AO1,data_no_sound);
                         elseif mod(trialtypes(i),12) == 0
                             putdata(AO2,data_cs_2); % AO2 is nidaq
                             putdata(AO1,data_cs); % AO1 is sound card
                        else
                            putdata(AO2,data);
                            putdata(AO1,data_cs); % AO1 is sound card
                        end
                    else
                        if mod(trialtypes(i),11) == 10 % sound only
                            putdata(AO1,data_cs); % AO1 is sound card
                            putdata(AO2,data_nodaq);
                        elseif mod(trialtypes(i),11) == 0 % light only
                            putdata(AO2,data_cs_2);
                            putdata(AO1,data_no_sound);
                            %                         elseif mod(trialtypes(i),12) == 0 % sound + light only
                            %                             putdata(AO2,data_cs_2); % AO2 is nidaq
                            %                             putdata(AO1,data_cs); % AO1 is sound card
                        else
                            putdata(AO2,data);
                            putdata(AO1,data_cs); % AO1 is sound card
                        end
                    end
                    triggered_flag = 0;
                    telapsed = 0;
                    
                    while triggered_flag == 0
                        tstart = tic;
                        start(AI)
                        pause(1.5)
                        apeek = peekdata(AI,round(AI.SampleRate));
                        if get(handles.radiobutton20,'Value') == get(handles.radiobutton20,'Max')
                            window_max = handles.mean_mean_data + 0.1*handles.range_data;
                            window_min = handles.mean_mean_data - 0.2*handles.range_data;
                        elseif get(handles.radiobutton21,'Value') == get(handles.radiobutton21,'Max')
                            window_max = handles.mean_mean_data + 0.2*handles.range_data;
                            window_min = handles.mean_mean_data - 0.2*handles.range_data;
                        elseif get(handles.radiobutton22,'Value') == get(handles.radiobutton22,'Max')
                            window_max = handles.mean_mean_data + 0.1*handles.range_data;
                            window_min = -100;
                        elseif get(handles.radiobutton23,'Value') == get(handles.radiobutton23,'Max')
                            window_max = handles.mean_mean_data + 0.2*handles.range_data;
                            window_min = -100;
                        end
                        
                        if get(handles.radiobutton24,'Value') == get(handles.radiobutton24,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.1*handles.range_data2;
                            window_min2 = handles.mean_mean_data2 - 0.2*handles.range_data2;
                        elseif get(handles.radiobutton25,'Value') == get(handles.radiobutton25,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.2*handles.range_data2;
                            window_min2 = handles.mean_mean_data2 - 0.2*handles.range_data2;
                        elseif get(handles.radiobutton26,'Value') == get(handles.radiobutton26,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.1*handles.range_data2;
                            window_min2 = -100;
                        elseif get(handles.radiobutton27,'Value') == get(handles.radiobutton27,'Max')
                            window_max2 = handles.mean_mean_data2 + 0.2*handles.range_data2;
                            window_min2 = -100;
                        end
                        if str2num(get(handles.edit16,'String')) ~= 0 && str2num(get(handles.edit17,'String')) ~= 0 %#ok<*ST2NM>
                            if isempty(find(apeek(:,1) > window_max)) && isempty(find(apeek(:,1) < window_min)) %#ok<*EFIND>
                                if str2num(get(handles.edit20,'String')) ~= 0 && str2num(get(handles.edit21,'String')) ~= 0
                                    if isempty(find(apeek(:,4) > window_max2)) && isempty(find(apeek(:,4) < window_min2))
                                        triggered_flag = 1;
                                        telapsed = toc(tstart);
                                        start([AO1,AO2]);
                                        pause(8.6)
                                    else
                                        stop(AI)
                                        telapsed = toc(tstart);
                                        pause(1)
                                    end
                                else
                                    triggered_flag = 1;
                                    start([AO1,AO2]);
                                    telapsed = toc(tstart);
                                    pause(8.6)
                                end
                            else
                                stop(AI)
                                telapsed = toc(tstart);
                                pause(1);
                            end
                        elseif str2num(get(handles.edit20,'String')) ~= 0 && str2num(get(handles.edit21,'String')) ~=0
                            if isempty(find(apeek(:,4) > window_max2)) && isempty(find(apeek(:,4) < window_min2))
                                triggered_flag = 1;
                                telapsed = toc(tstart);
                                start([AO1,AO2]);
                                pause(8.6)
                            else
                                stop(AI)
                                telapsed = toc(tstart);
                                pause(1)
                            end
                        else
                            triggered_flag = 1;
                            telapsed = toc(tstart);
                            start([AO1,AO2]);
                            pause(8.6)
                        end
                    end
                end
                
                [DATA,TIME] = getdata(AI);
                
                if get(handles.radiobutton15,'Value') == get(handles.radiobutton15,'Max')
                    if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Min')
                        index=find(DATA(:,2)>2.0,1,'first');
                    elseif get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                        if isempty(find(DATA(:,2)>2.0,1,'first'))
                            index=find(DATA(:,3)>2.0,1,'first');
                        else
                            index=find(DATA(:,2)>2.0,1,'first');
                        end
                    end
                    DATA = DATA(index-4000:index+4000,:);
                    TIME = TIME(index-4000:index+4000);
                elseif get(handles.radiobutton17,'Value')==get(handles.radiobutton17,'Max')
                    if get(handles.bbtest,'Value')==get(handles.bbtest,'Min') && get(handles.ustest,'Value') == get(handles.ustest,'Min') && get(handles.ustest2,'Value') == get(handles.ustest2,'Min')
                        if mod(trialtypes(i),11) == 10
                            index = find(TIME>telapsed,1,'first');
                            DATA = DATA(index-4000:index+4000,:);
                            TIME = TIME(index-4000:index+4000);
                        elseif mod(trialtypes(i),11) == 1
                            index=find(DATA(:,2)>2.0,1,'first');
                            DATA = DATA(index-4000:index+4000,:);
                            TIME = TIME(index-4000:index+4000);
                            %                         elseif mod(trialtypes(i),12) == 0
                            %                             index=find(DATA(:,2)>2.0,1,'first');
                            %                             DATA = DATA(index-4000:index+4000,:);
                            %                             TIME = TIME(index-4000:index+4000);
                        else
                            index=find(DATA(:,2)>2.0,1,'first');
                            DATA = DATA(index-4000:index+4000,:);
                            TIME = TIME(index-4000:index+4000);
                        end
                    elseif get(handles.bbtest,'Value')==get(handles.bbtest,'Max') && get(handles.ustest,'Value')==get(handles.ustest,'Min') && get(handles.ustest2,'Value') == get(handles.ustest2,'Min')
                        if get(handles.bbtest1,'Value') == get(handles.bbtest1, 'Max') || (get(handles.bbtest1,'Value') == get(handles.bbtest1,'Min') && get(handles.bbtest2,'Value') == get(handles.bbtest2,'Min'))
                            if mod(trialtypes(i),11) == 10
                                index=find(DATA(:,2)>2.0,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                            elseif mod(trialtypes(i),11) == 0
                                index = find(TIME>telapsed,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                                %                             elseif mod(trialtypes(i),12) == 0
                                %                                 index=find(DATA(:,2)>2.0,1,'first');
                                %                                 DATA = DATA(index-4000:index+4000,:);
                                %                                 TIME = TIME(index-4000:index+4000);
                            else
                                index=find(DATA(:,2)>2.0,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                            end
                        elseif get(handles.bbtest2,'Value') == get(handles.bbtest,'max')
                            if mod(trialtypes(i),11) == 10
                                index = find(TIME > telapsed,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                            elseif mod(trialtypes(i),11) == 0
                                index = find(DATA(:,2) > 2.0,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                                %                             elseif mod(trialtypes(i),12) == 0
                                %                                 index = find(DATA(:,2) > 2.0,1,'first');
                                %                                 DATA = DATA(index-4000:index+4000,:);
                                %                                 TIME = TIME(index-4000:index+4000);
                            else
                                index = find(DATA(:,3) > 2.0,1,'first');
                                DATA = DATA(index-4800:index+3200,:);
                                TIME = TIME(index-4800:index+3200);
                            end
                        end
                    elseif get(handles.ustest2,'Value') == get(handles.ustest2,'Max') && get(handles.bbtest,'Value') == get(handles.bbtest,'Min') && get(handles.ustest,'Value') == get(handles.ustest,'Min')
                        if get(handles.bbtest1,'Value') == get(handles.bbtest1, 'Max') || (get(handles.bbtest1,'Value') == get(handles.bbtest1,'Min') && get(handles.bbtest2,'Value') == get(handles.bbtest2,'Min'))
                            if mod(trialtypes(i),11) == 10 % sound only
                                index = find(TIME>telapsed,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                            elseif mod(trialtypes(i),11) == 0% click + Us
                                index=find(DATA(:,2)>2.0,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                            else % light only
                                
                                index = find(TIME>telapsed,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                                %                             elseif mod(trialtypes(i),12) == 0
                                %                                 index=find(DATA(:,2)>2.0,1,'first');
                                %                                 DATA = DATA(index-4000:index+4000,:);
                                %                                 TIME =
                                %                                 TIME(index-4000:index+4000);
                            end
                        elseif get(handles.bbtest2,'Value') == get(handles.bbtest,'max')
                            if mod(trialtypes(i),11) == 10 % light only
                                index = find(DATA(:,2) > 2.0,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                            elseif mod(trialtypes(i),11) == 0 % click + US
                                index = find(TIME > telapsed,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                                
                            else % sound only
                                index = find(TIME>telapsed,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                                %                             elseif mod(trialtypes(i),12) == 0
                                %                                 index = find(DATA(:,2) > 2.0,1,'first');
                                %                                 DATA = DATA(index-4000:index+4000,:);
                                %                                 TIME =
                                %                                 TIME(inde
                                %                                 x-4000:index+4000);
                            end
                        end
                    elseif get(handles.ustest,'Value') == get(handles.ustest,'Max') && get(handles.bbtest,'Value') == get(handles.bbtest,'Min') & get(handles.ustest2,'Value') == get(handles.ustest2,'Min')
                        if get(handles.bbtest1,'Value') == get(handles.bbtest1, 'Max') || (get(handles.bbtest1,'Value') == get(handles.bbtest1,'Min') && get(handles.bbtest2,'Value') == get(handles.bbtest2,'Min'))
                            if mod(trialtypes(i),11) == 0 % sound only
                                index = find(TIME>telapsed,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                            elseif mod(trialtypes(i),11) == 10% click + Us
                                index = find(TIME>telapsed,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                                %                             elseif mod(trialtypes(i),12) == 0
                                %                                 index=find(DATA(:,2)>2.0,1,'first');
                                %                                 DATA = DATA(index-4000:index+4000,:);
                                %                                 TIME = TIME(index-4000:index+4000);
                            else % light only
                                index=find(DATA(:,2)>2.0,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                            end
                        elseif get(handles.bbtest2,'Value') == get(handles.bbtest,'max')
                            if mod(trialtypes(i),11) == 0 % light only
                                index = find(DATA(:,2) > 2.0,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                            elseif mod(trialtypes(i),11) == 10 % click + US
                                index = find(TIME>telapsed,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                                %                             elseif mod(trialtypes(i),12) == 0
                                %                                 index = find(DATA(:,2) > 2.0,1,'first');
                                %                                 DATA = DATA(index-4000:index+4000,:);
                                %                                 TIME = TIME(index-4000:index+4000);
                            else % sound only
                                index = find(TIME > telapsed,1,'first');
                                DATA = DATA(index-4000:index+4000,:);
                                TIME = TIME(index-4000:index+4000);
                            end
                        end
                    end
                elseif get(handles.radiobutton16,'Value')==get(handles.radiobutton16,'Max')
                    if mod(trialtypes(i),10) ~= 0
                        index=find(DATA(:,3)>2.0,1,'first');
                        DATA = DATA(index-4800:index+3200,:);
                        TIME = TIME(index-4800:index+3200);
                    else
                        index = find(TIME>telapsed,1,'first');
                        DATA = DATA(index-4000:index+4000,:);
                        TIME = TIME(index-4000:index+4000,:);
                    end
                end
                
                axes(handles.axes_triggered)
                plot(TIME,DATA(:,1));
                axis tight
                %                 hold on
                %                 if get(handles.radiobutton15,'Value')==get(handles.radiobutton15,'Max')
                %                     x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                     yLims = get(gca,'YLim');
                %                     line([x,x],yLims,'Color','red','LineStyle','-.')
                %                     x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                     yLims = get(gca,'YLim');
                %                     line([x,x],yLims,'Color','red','LineStyle','-.')
                %                     if mod(trialtypes(i),10) ~= 0
                %                         x = TIME(find(DATA(:,3)> 2,1,'first'));
                %                         yLims = get(gca,'YLim');
                %                         line([x,x],yLims,'Color','green','LineStyle',':')
                %                         x = TIME(find(DATA(:,3)> 2,1,'last'));
                %                         yLims = get(gca,'YLim');
                %                         line([x,x],yLims,'Color','green','LineStyle',':')
                %                     end
                %                 elseif get(handles.radiobutton17,'Value')==get(handles.radiobutton17,'Max')
                %                     if get(handles.bbtest,'Value')==get(handles.bbtest,'Min')
                %                         if mod(trialtypes(i),12) == 10
                %                             yLims = get(gca,'YLim');
                %                             x1 = TIME(4000);
                %                             x2 = TIME(4800);
                %                             line([x1,x1],yLims,'Color','red','LineStyle','-.')
                %                             line([x2,x2],yLims,'Color','red','LineStyle','-.')
                %                         elseif mod(trialtypes(i),12) == 11
                %                             yLims = get(gca,'YLim');
                %                             x1 = TIME(4000);
                %                             x2 = TIME(4800);
                %                             line([x1,x1],yLims,'Color','red','LineStyle','-.')
                %                             line([x2,x2], yLims,'Color','red','LineStyle','-.')
                %                         elseif mod(trialtypes(i),12) == 0
                %                             x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','red','LineStyle','-.')
                %                         else
                %                             x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','red','LineStyle','-.')
                %                         end
                %                         if mod(trialtypes(i),12) > 0 && mod(trialtypes(i),12) < 10
                %                             x = TIME(find(DATA(:,3)> 2,1,'first'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','green','LineStyle',':')
                %                             x = TIME(find(DATA(:,3)> 2,1,'last'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','green','LineStyle',':')
                %                         end
                %                     elseif get(handles.bbtest,'Value')==get(handles.bbtest,'Max')
                %                         if get(handles.bbtest1,'Value') == get(handles.bbtest1,'Max') || (get(handles.bbtest1,'Value') == get(handles.bbtest1,'Min') && get(handles.bbtest2,'Value') == get(handles.bbtest2,'Min'))
                %                             if mod(trialtypes(i),12) == 10
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             elseif mod(trialtypes(i),12) == 11
                %                                 yLims = get(gca,'YLim');
                %                                 x1 = TIME(4000);
                %                                 x2 = TIME(4800);
                %                                 line([x1,x1],yLims,'Color','red','LineStyle','-.')
                %                                 line([x2,x2],yLims,'Color','red','LineStyle','-.')
                %                             elseif mod(trialtypes(i),12) == 0
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             else
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             end
                %                         elseif get(handles.bbtest2,'Value') == get(handles.bbtest2,'Max')
                %                             if mod(trialtypes(i),12) == 10
                %                                 yLims = get(gca,'YLim');
                %                                 x1 = TIME(4000);
                %                                 x2 = TIME(4800);
                %                                 line([x1,x1],yLims,'Color','red','LineStyle','-.')
                %                                 line([x2,x2], yLims,'Color','red','LineStyle','-.')
                %                             elseif mod(trialtypes(i),12) == 11
                %                                 x = TIME(find(DATA(:,2)>2.0,1,'first'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                                 x = TIME(find(DATA(:,2)>2.0,1,'last'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.');
                %                             elseif mod(trialtypes(i),12) == 0
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             else
                %                                 yLims = get(gca,'YLim');
                %                                 x = TIME(find(DATA(:,3)>2.0,1,'first'));
                %                                 line([x-0.25,x-0.25],yLims,'Color','red','LineStyle','-.')
                %                                 line([x+0.03,x+0.03],yLims,'Color','red','LineStyle','-.')
                %                             end
                %                         end
                %                         if mod(trialtypes(i),12) > 0 && mod(trialtypes(i),12) < 10
                %                             x = TIME(find(DATA(:,3)> 2,1,'first'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','green','LineStyle',':')
                %                             x = TIME(find(DATA(:,3)> 2,1,'last'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','green','LineStyle',':')
                %                         end
                %                     end
                %                 elseif get(handles.radiobutton16,'Value')==get(handles.radiobutton16,'Max')
                %                     if mod(trialtypes(i),10) ~= 0
                %                         yLims = get(gca,'YLim');
                %                         x = TIME(find(DATA(:,3)>2.0,1,'first'));
                %                         line([x-0.25,x-0.25],yLims,'Color','red','LineStyle','-.')
                %                         line([x+0.03,x+0.03],yLims,'Color','red','LineStyle','-.')
                %                     else
                %                         yLims = get(gca,'YLim');
                %                         x1 = TIME(4000);
                %                         x2 = TIME(4800);
                %                         line([x1,x1],yLims,'Color','red','LineStyle','-.')
                %                         line([x2,x2],yLims,'Color','red','LineStyle','-.')
                %                     end
                %                     if mod(trialtypes(i),10) ~= 0
                %                         x = TIME(find(DATA(:,3)> 2,1,'first'));
                %                         yLims = get(gca,'YLim');
                %                         line([x,x],yLims,'Color','green','LineStyle',':')
                %                         x = TIME(find(DATA(:,3)> 2,1,'last'));
                %                         yLims = get(gca,'YLim');
                %                         line([x,x],yLims,'Color','green','LineStyle',':')
                %                     end
                %                 end
                %                 hold off
                %
                axes(handles.axes5)
                plot(TIME,DATA(:,4));
                axis tight
                %                 hold on
                %                 if get(handles.radiobutton15,'Value')==get(handles.radiobutton15,'Max')
                %                     x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                     yLims = get(gca,'YLim');
                %                     line([x,x],yLims,'Color','red','LineStyle','-.')
                %                     x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                     yLims = get(gca,'YLim');
                %                     line([x,x],yLims,'Color','red','LineStyle','-.')
                %                     if mod(trialtypes(i),10) ~= 0
                %                         x = TIME(find(DATA(:,3)> 2,1,'first'));
                %                         yLims = get(gca,'YLim');
                %                         line([x,x],yLims,'Color','green','LineStyle',':')
                %                         x = TIME(find(DATA(:,3)> 2,1,'last'));
                %                         yLims = get(gca,'YLim');
                %                         line([x,x],yLims,'Color','green','LineStyle',':')
                %                     end
                %                 elseif get(handles.radiobutton17,'Value')==get(handles.radiobutton17,'Max')
                %                     if get(handles.bbtest,'Value')==get(handles.bbtest,'Min')
                %                         if mod(trialtypes(i),12) == 10
                %                             yLims = get(gca,'YLim');
                %                             x1 = TIME(4000);
                %                             x2 = TIME(4800);
                %                             line([x1,x1],yLims,'Color','red','LineStyle','-.')
                %                             line([x2,x2],yLims,'Color','red','LineStyle','-.')
                %                         elseif mod(trialtypes(i),12) == 11
                %                             yLims = get(gca,'YLim');
                %                             x1 = TIME(4000);
                %                             x2 = TIME(4800);
                %                             line([x1,x1],yLims,'Color','red','LineStyle','-.')
                %                             line([x2,x2], yLims,'Color','red','LineStyle','-.')
                %                         elseif mod(trialtypes(i),12) == 0
                %                             x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','red','LineStyle','-.')
                %                         else
                %                             x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','red','LineStyle','-.')
                %                         end
                %                         if mod(trialtypes(i),12) > 0 && mod(trialtypes(i),12) < 10
                %                             x = TIME(find(DATA(:,3)> 2,1,'first'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','green','LineStyle',':')
                %                             x = TIME(find(DATA(:,3)> 2,1,'last'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','green','LineStyle',':')
                %                         end
                %                     elseif get(handles.bbtest,'Value')==get(handles.bbtest,'Max')
                %                         if get(handles.bbtest1,'Value') == get(handles.bbtest1,'Max') || (get(handles.bbtest1,'Value') == get(handles.bbtest1,'Min') && get(handles.bbtest2,'Value') == get(handles.bbtest2,'Min'))
                %                             if mod(trialtypes(i),12) == 10
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             elseif mod(trialtypes(i),12) == 11
                %                                 yLims = get(gca,'YLim');
                %                                 x1 = TIME(4000);
                %                                 x2 = TIME(4800);
                %                                 line([x1,x1],yLims,'Color','red','LineStyle','-.')
                %                                 line([x2,x2],yLims,'Color','red','LineStyle','-.')
                %                             elseif mod(trialtypes(i),12) == 0
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             else
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             end
                %                         elseif get(handles.bbtest2,'Value') == get(handles.bbtest2,'Max')
                %                             if mod(trialtypes(i),12) == 10
                %                                 yLims = get(gca,'YLim');
                %                                 x1 = TIME(4000);
                %                                 x2 = TIME(4800);
                %                                 line([x1,x1],yLims,'Color','red','LineStyle','-.')
                %                                 line([x2,x2], yLims,'Color','red','LineStyle','-.')
                %                             elseif mod(trialtypes(i),12) == 11
                %                                 x = TIME(find(DATA(:,2)>2.0,1,'first'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                                 x = TIME(find(DATA(:,2)>2.0,1,'last'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.');
                %                             elseif mod(trialtypes(i),12) == 0
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'first'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                                 x = TIME(find(DATA(:,2)> 2.0,1,'last'));
                %                                 yLims = get(gca,'YLim');
                %                                 line([x,x],yLims,'Color','red','LineStyle','-.')
                %                             else
                %                                 yLims = get(gca,'YLim');
                %                                 x = TIME(find(DATA(:,3)>2.0,1,'first'));
                %                                 line([x-0.25,x-0.25],yLims,'Color','red','LineStyle','-.')
                %                                 line([x+0.03,x+0.03],yLims,'Color','red','LineStyle','-.')
                %                             end
                %                         end
                %                         if mod(trialtypes(i),12) > 0 && mod(trialtypes(i),12) < 10
                %                             x = TIME(find(DATA(:,3)> 2,1,'first'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','green','LineStyle',':')
                %                             x = TIME(find(DATA(:,3)> 2,1,'last'));
                %                             yLims = get(gca,'YLim');
                %                             line([x,x],yLims,'Color','green','LineStyle',':')
                %                         end
                %                     end
                %                 elseif get(handles.radiobutton16,'Value')==get(handles.radiobutton16,'Max')
                %                     if mod(trialtypes(i),10) ~= 0
                %                         yLims = get(gca,'YLim');
                %                         x = TIME(find(DATA(:,3)>2.0,1,'first'));
                %                         line([x-0.25,x-0.25],yLims,'Color','red','LineStyle','-.')
                %                         line([x+0.03,x+0.03],yLims,'Color','red','LineStyle','-.')
                %                     else
                %                         yLims = get(gca,'YLim');
                %                         x1 = TIME(4000);
                %                         x2 = TIME(4800);
                %                         line([x1,x1],yLims,'Color','red','LineStyle','-.')
                %                         line([x2,x2],yLims,'Color','red','LineStyle','-.')
                %                     end
                %                     if mod(trialtypes(i),10) ~= 0
                %                         x = TIME(find(DATA(:,3)> 2,1,'first'));
                %                         yLims = get(gca,'YLim');
                %                         line([x,x],yLims,'Color','green','LineStyle',':')
                %                         x = TIME(find(DATA(:,3)> 2,1,'last'));
                %                         yLims = get(gca,'YLim');
                %                         line([x,x],yLims,'Color','green','LineStyle',':')
                %                     end
                %                 end
                %                 hold off
                
                handles.ALLDATA = cat(3,handles.ALLDATA,[TIME,DATA]);
                guidata(hObject,handles);
                set(handles.text30,'String',num2str(str2num(get(handles.text30,'String'))+1));
                set(handles.text40,'String',num2str(str2num(get(handles.text30,'String'))+1));
                set(handles.slider1,'Max',str2num(get(handles.text30,'String')));
                set(handles.slider2,'Max',str2num(get(handles.text40,'String')));
                set(handles.text28,'String',get(handles.text30,'String'))
                set(handles.text38,'String',get(handles.text40,'String'))
                set(handles.slider1,'Value',str2num(get(handles.text30,'String')));
                set(handles.slider2,'Value',str2num(get(handles.text40,'String')));
                if get(handles.slider1,'Max') == 2
                    set(handles.slider1,'SliderStep',[1 1]);
                elseif get(handles.slider1,'Max') > 2
                    set(handles.slider1,'SliderStep',[1/(get(handles.slider1,'Max')-1),1/(get(handles.slider1,'Max')-1)]);
                end
                if get(handles.slider2,'Max') == 2
                    set(handles.slider2,'SliderStep',[1 1]);
                elseif get(handles.slider2,'Max') > 2
                    set(handles.slider2,'SliderStep',[1/(get(handles.slider2,'Max')-1),1/(get(handles.slider2,'Max')-1)]);
                end
                set(handles.slider1,'Enable','on');
                set(handles.slider2,'Enable','on');
                %set(handles.pushbutton_sampling,'Enable','on');
                if get(handles.checkbox1,'Value')==get(handles.checkbox1,'Max')
                    filename=get(handles.edit15,'String');
                    data=handles.ALLDATA;
                    save(filename,'data','trialtypes');
                end
                
                if intertrial_interval - 10.1 > 0
                    pause(intertrial_interval - 10.1)
                end
                
                clear data time;
            end
            close(waitbar_handle)
            if get(handles.radiobutton15,'Value')==get(handles.radiobutton15,'Max')
                if get(handles.checkbox6,'Value') == get(handles.checkbox6,'Min')
                    stop(AO);
                    delete(AO);
                    clear AO
                elseif get(handles.checkbox6,'Value') == get(handles.checkbox6,'Max')
                    stop([AO1,AO2]);
                    delete([AO1,AO2]);
                    clear AO1 AO2
                end
            elseif get(handles.radiobutton16,'Value')==get(handles.radiobutton16,'Max') || get(handles.radiobutton17,'Value')==get(handles.radiobutton17,'Max')
                stop([AO1,AO2]);
                delete([AO1,AO2]);
                clear AO1 AO2
            end
        else
            pause(1)
        end
        set(handles.radiobutton1,'Enable','on');
        set(handles.text14,'Enable','on');
        %        set(handles.text15,'Enable','on');
        %        set(handles.text16,'Enable','on');
        %        set(handles.text17,'Enable','on');
        set(handles.text27,'Enable','on');
        set(handles.edit4,'Enable','on');
        %        set(handles.edit5,'Enable','on');
        %        set(handles.edit6,'Enable','on');
        %        set(handles.edit7,'Enable','on');
        set(handles.edit14,'Enable','on');
    elseif get(handles.radiobutton2,'Value')==get(handles.radiobutton2,'Max')
        set(handles.radiobutton1,'Enable','off');
        set(handles.radiobutton2,'Enable','off');
        set(handles.pushbutton12,'Enable','off');
        set(handles.uitable1,'Enable','off');
        if handles.daqflag == 1
            number_of_trials = size(get(handles.uitable1,'Data'),1);
            if number_of_trials ~= 0
                
            end
        end
        set(handles.uitable1,'Enable','on');
        set(handles.pushbutton12,'Enable','on');
        set(handles.radiobutton1,'Enable','on');
        set(handles.radiobutton2,'Enable','on');
    end
    set(handles.pushbutton_ustrigger,'Enable','on');
    set(hObject,'Enable','on');
    guidata(hObject, handles)
end


% --- Executes on button press in pushbutton_uscstrigger.
function pushbutton_uscstrigger_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_uscstrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(hObject,'String'),'MANUAL TRIGGER (ONE TRIAL)')
    if get(handles.radiobutton1,'Value')==get(handles.radiobutton1,'Max')
        set(hObject,'String','Please wait...');
        set(hObject,'ForegroundColor',[0,0,0]);
        set(handles.pushbutton_ustrigger,'Enable','off');
        set(handles.radiobutton1,'Enable','off');
        set(handles.text14,'Enable','off');
        set(handles.text15,'Enable','off');
        set(handles.text16,'Enable','off');
        set(handles.text17,'Enable','off');
        set(handles.edit4,'Enable','off');
        set(handles.edit5,'Enable','off');
        set(handles.edit6,'Enable','off');
        set(handles.edit7,'Enable','off');
        
        if handles.daqflag == 1
            sample_rates_out = handles.sample_rates_out;
            duration = 0.005;
            data = [0,0;5*ones(duration*sample_rates_out,2);0,0];
            
            set(handles.pushbutton_sampling,'Enable','off');
            AI = analoginput('nidaq','Dev1');
            addchannel(AI,[0,1,2,6]);
            set(AI,'SampleRate',4000);
            set(AI,'SamplesPerTrigger',ceil((10)*get(AI,'SampleRate')));
            set(AI,'TriggerType','Immediate');
            set(AI,'TriggerRepeat',0);
            set(AI,'Timeout',20);
            set(AI.Channel(1),'InputRange',[-10,10]);
            set(AI.Channel(4),'InputRange',[-10,10]);
            
            AO = analogoutput('nidaq','Dev1');
            addchannel(AO,[0,1]);
            set(AO,'SampleRate',sample_rates_out);
            putdata(AO,data);
            
            triggered_flag = 0;
            number_triggers = 0;
            
            window_max = handles.mean_mean_data + 0.2*handles.range_data;
            window_max2 = handles.mean_mean_data2 + 0.5*handles.range_data2;
            
            while triggered_flag == 0
                start(AI);
                pause(1.5)
                apeek = peekdata(AI,round(AI.SampleRate));
                if str2num(get(handles.edit16,'String')) ~= 0 && str2num(get(handles.edit17,'String')) ~= 0
                    if str2num(get(handles.edit16,'String')) ~= 0 && str2num(get(handles.edit17,'String')) ~= 0 %#ok<*ST2NM>
                        if isempty(find(apeek(:,1) > window_max)) && isempty(find(apeek(:,1) < window_min)) %#ok<*EFIND>
                            if str2num(get(handles.edit20,'String')) ~= 0 && str2num(get(handles.edit21,'String')) ~= 0
                                if isempty(find(apeek(:,4) > window_max2)) && isempty(find(apeek(:,4) < window_min2))
                                    triggered_flag = 1;
                                    start(AO);
                                    pause(8.6)
                                else
                                    stop(AI)
                                    pause(1)
                                end
                            else
                                triggered_flag = 1;
                                start(AO);
                                pause(8.6)
                            end
                        else
                            stop(AI)
                            pause(1);
                        end
                    elseif str2num(get(handles.edit20,'String')) ~= 0 && str2num(get(handles.edit21,'String')) ~=0
                        if isempty(find(apeek(:,4) > window_max2)) && isempty(find(apeek(:,4) < window_min2))
                            if str2num(get(handles.edit16,'String')) ~= 0 && str2num(get(handles.edit17,'String')) ~= 0
                                if isempty(find(apeek(:,1) > window_max)) && isempty(find(apeek(:,1) < window_min))
                                    triggered_flag = 1;
                                    start(AO);
                                    pause(8.6)
                                else
                                    stop(AI)
                                    pause(1)
                                end
                            else
                                triggered_flag = 1;
                                start(AO);
                                pause(8.6)
                            end
                        else
                            stop(AI)
                            pause(1)
                        end
                        
                    else
                        triggered_flag = 1;
                        start(AO);
                        pause(8.6)
                    end
                else
                    triggered_flag = 1;
                    start(AO);
                    pause(8.6);
                end
            end
            
            number_triggers = AI.TriggersExecuted;
            [DATA,TIME] = getdata(AI);
            delete(AO);
            delete(AI);
            clear AI AO
            if number_triggers > 1
                bananas = find(isnan(DATA));
                DATA_NEW = DATA(bananas(end)+1:end,:);
                TIME_NEW = TIME(bananas(end)+1:end)-TIME(bananas(end)+1);
                clear DATA
                clear TIME
                DATA = DATA_NEW;
                clear DATA_NEW
                TIME = TIME_NEW;
                clear TIME_NEW
            end
            
            index=find(DATA(:,2)>2.0,1,'first');
            DATA = DATA(index-4000:index+4000,:);
            TIME = TIME(index-4000:index+4000);
            
            axes(handles.axes_triggered)
            plot(TIME,DATA(:,1));
            axis tight
            hold on
            x = TIME(find(DATA(:,2)> 2.0,1,'first'));
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','red','LineStyle','-.')
            x = TIME(find(DATA(:,2)> 2.0,1,'last'));
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','red','LineStyle','-.')
            x = TIME(find(DATA(:,3)> 2.0,1,'first'));
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','green','LineStyle',':')
            x = TIME(find(DATA(:,3)> 2.0,1,'last'));
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','green','LineStyle',':')
            hold off
            
            axes(handles.axes5)
            plot(TIME,DATA(:,4));
            axis tight
            hold on
            x = TIME(find(DATA(:,2)>2.0,1,'first'));
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','red','LineStyle','-.')
            x = TIME(find(DATA(:,2)>2.0,1,'last'));
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','red','LineStyle','-.')
            x = TIME(find(DATA(:,3) > 2.0,1,'first'));
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','green','LineStyle',':')
            x = TIME(find(DATA(:,3)>2.0,1,'last'));
            yLims = get(gca,'YLim');
            line([x,x],yLims,'Color','green','LineStyle',':')
            hold off
            
            handles.ALLDATA = cat(3,handles.ALLDATA,[TIME,DATA]);
            guidata(hObject,handles);
            set(handles.text30,'String',num2str(str2num(get(handles.text30,'String'))+1));
            set(handles.text40,'String',num2str(str2num(get(handles.text40,'String'))+1));
            set(handles.slider1,'Max',str2num(get(handles.text30,'String')));
            set(handles.slider2,'Max',str2num(get(handles.text40,'String')));
            set(handles.text28,'String',get(handles.text30,'String'))
            set(handles.text38,'String',get(handles.text40,'String'))
            set(handles.slider1,'Value',str2num(get(handles.text30,'String')));
            set(handles.slider2,'Value',str2num(get(handles.text40,'String')));
            if get(handles.slider1,'Max') == 2
                set(handles.slider1,'SliderStep',[1 1]);
            elseif get(handles.slider1,'Max') > 2
                set(handles.slider1,'SliderStep',[1/(get(handles.slider1,'Max')-1),1/(get(handles.slider1,'Max')-1)]);
            end
            if get(handles.slider2,'Max') == 2
                set(handles.slider2,'SliderStep',[1 1]);
            elseif get(handles.slider2,'Max') > 2
                set(handles.slider2,'SliderStep',[1/(get(handles.slider2,'Max')-1),1/(get(handles.slider2,'Max')-1)]);
            end
            set(handles.slider1,'Enable','on');
            set(handles.slider2,'Enable','on')
            
            set(handles.pushbutton_sampling,'Enable','on');
            if get(handles.checkbox1,'Value')==get(handles.checkbox1,'Max')
                filename=get(handles.edit15,'String');
                data=handles.ALLDATA;
                save(filename,'data','trialtypes');
            end
            pause(1)
        end
        
        set(hObject,'String','MANUAL TRIGGER (ONE TRIAL)');
        set(hObject,'ForegroundColor',[1,0,0]);
        set(handles.pushbutton_ustrigger,'Enable','on');
        set(handles.radiobutton1,'Enable','on');
        set(handles.text14,'Enable','on');
        set(handles.text15,'Enable','on');
        set(handles.text16,'Enable','on');
        set(handles.text17,'Enable','on');
        set(handles.edit4,'Enable','on');
        set(handles.edit5,'Enable','on');
        set(handles.edit6,'Enable','on');
        set(handles.edit7,'Enable','on');
    elseif get(handles.radiobutton2,'Value')==get(handles.radiobutton2,'Max')
        
    end
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
if get(hObject,'Value')==get(hObject,'Max')
    set(handles.pushbutton_uscstrigger,'Enable','off');
    set(handles.text14,'Enable','on');
    %    set(handles.text15,'Enable','on');
    %    set(handles.text16,'Enable','on');
    %    set(handles.text17,'Enable','on');
    set(handles.text27,'Enable','on');
    set(handles.edit4,'Enable','on');
    %    set(handles.edit5,'Enable','on');
    %    set(handles.edit6,'Enable','on');
    %    set(handles.edit7,'Enable','on');
    set(handles.edit14,'Enable','on');
    % set(handles.uitable1,'Enable','off');
    % set(handles.radiobutton2,'Value',get(handles.radiobutton2,'Min'));
    set(handles.pushbutton_uscsexecute,'Enable','on');
    set(handles.radiobutton2,'Value',get(handles.radiobutton2,'Min'));
elseif get(hObject,'Value')==get(hObject,'Min')
    set(handles.text27,'Enable','off')
    set(handles.text14,'Enable','off')
    set(handles.edit4,'Enable','off')
    set(handles.edit14,'Enable','off')
    set(handles.pushbutton_uscsexecute,'Enable','off');
    set(handles.pushbutton_uscstrigger,'Enable','on');
    set(handles.edit4,'String','1');
end

% % --- Executes on button press in radiobutton2.
% function radiobutton2_Callback(hObject, eventdata, handles)
% % hObject    handle to radiobutton2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%
% % Hint: get(hObject,'Value') returns toggle state of radiobutton2
% if get(hObject,'Value')==get(hObject,'Max')
%     set(handles.pushbutton_uscstrigger,'Enable','off');
%     set(handles.pushbutton_uscsexecute,'Enable','on');
%     set(handles.uitable1,'Enable','on');
%     set(handles.text14,'Enable','off');
%     set(handles.text15,'Enable','off');
%     set(handles.text16,'Enable','off');
%     set(handles.text17,'Enable','off');
%     set(handles.text27,'Enable','off');
%     set(handles.edit4,'Enable','off');
%     set(handles.edit5,'Enable','off');
%     set(handles.edit6,'Enable','off');
%     set(handles.edit7,'Enable','off');
%     set(handles.edit14,'Enable','off');
%     set(handles.radiobutton1,'Value',get(handles.radiobutton1,'Min'));
% elseif get(hObject,'Value')==get(hObject,'Min')
%     set(handles.pushbutton_uscstrigger,'Enable','on');
%     set(handles.pushbutton_uscsexecute,'Enable','off');
%     set(handles.edit4,'String','1');
%     set(handles.uitable1,'Enable','off');
%     set(handles.text14,'Enable','on');
%     set(handles.text15,'Enable','on');
%     set(handles.text16,'Enable','on');
%     set(handles.text17,'Enable','on');
%     set(handles.edit4,'Enable','on');
%     set(handles.edit5,'Enable','on');
%     set(handles.edit6,'Enable','on');
%     set(handles.edit7,'Enable','on');
% end




% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

channels_in = handles.channels_in;
list=0:15;
channels_in(1) = list(get(hObject,'Value'));
handles.channels_in = channels_in;
guidata(handles);


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

sample_rates_in = handles.sample_rates_in;
sample_rates_in(1) = str2double(get(hObject,'String'));
handles.sample_rates_in = samples_rates_in;
guidata(handles);

set(handles.text19,'String',num2str(sum(sample_rates_in)));



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

channels_in = handles.channels_in;
list=0:15;
channels_in(2) = list(get(hObject,'Value'));
handles.channels_in = channels_in;
guidata(handles);


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

sample_rates_in = handles.sample_rates_in;
sample_rates_in(2) = str2double(get(hObject,'String'));
handles.sample_rates_in = samples_rates_in;
guidata(handles);

set(handles.text19,'String',num2str(sum(sample_rates_in)));


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3

channels_in = handles.channels_in;
list=0:15;
channels_in(3) = list(get(hObject,'Value'));
handles.channels_in = channels_in;
guidata(handles);


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, ~)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

sample_rates_in = handles.sample_rates_in;
sample_rates_in(3) = str2double(get(hObject,'String'));
handles.sample_rates_in = samples_rates_in;
guidata(handles);

set(handles.text19,'String',num2str(sum(sample_rates_in)));


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

slidervalue=round(get(hObject,'Value'));
set(handles.text28,'String',num2str(slidervalue));
data=handles.ALLDATA(:,2:4,slidervalue);
time=handles.ALLDATA(:,1,slidervalue);
axes(handles.axes_triggered)
plot(time,data(:,1));
axis tight
hold on
x = time(find(data(:,2)> 2.0,1,'first'));
if ~isempty(x)
    ylims = get(gca,'ylim');
    line([x,x],ylims,'color','red','linestyle','-.')
else
    ylims = get(gca,'ylim');
    x1 = time(4000);
    line([x1,x1],ylims,'color','red','linestyle','-.')
end
x = time(find(data(:,2)> 2.0,1,'last'));
if ~isempty(x)
    ylims = get(gca,'ylim');
    line([x,x],ylims,'color','red','linestyle','-.')
else
    ylims = get(gca,'ylim');
    x2 = time(5121);
    line([x2,x2],ylims,'color','red','linestyle','-.')
end
x = time(find(data(:,3)> 2.0,1,'first'));
if ~isempty(x)
    ylims = get(gca,'ylim');
    line([x,x],ylims,'color','green','linestyle',':')
end
x = time(find(data(:,3)> 2.0,1,'last'));
if ~isempty(x)
    ylims = get(gca,'ylim');
    line([x,x],ylims,'color','green','linestyle',':')
end
hold off



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5



%function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function uipanel10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'UserData',1);


% --- Executes during object creation, after setting all properties.
function uipanel11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'UserData',1);


% --- Executes when selected object is changed in uipanel11.
function uipanel11_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel11
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag')
    case 'radiobutton3'
        set(handles.text25,'Enable','off');
        set(handles.text26,'Enable','off');
        set(handles.edit11,'Enable','off');
        set(handles.edit8,'Enable','off');
        if get(handles.radiobutton8,'Value')==get(handles.radiobutton8,'Max')
            set(handles.pushbutton_ustrigger,'String','MANUAL TRIGGER - US, 1 TRIAL');
        elseif get(handles.radiobutton9,'Value')==get(handles.radiobutton9,'Max')
            set(handles.pushbutton_ustrigger,'String','MANUAL TRIGGER - CS, 1 TRIAL');
        end
        set(hObject,'UserData',1);
    case 'radiobutton5'
        set(handles.text25,'Enable','on');
        set(handles.text26,'Enable','on');
        set(handles.edit11,'Enable','on');
        set(handles.edit8,'Enable','on');
        if get(handles.radiobutton8,'Value')==get(handles.radiobutton8,'Max')
            set(handles.pushbutton_ustrigger,'String','MANUAL TRIGGER - US, TRAIN');
        elseif get(handles.radiobutton9,'Value')==get(handles.radiobutton9,'Max')
            set(handles.pushbutton_ustrigger,'String','MANUAL TRIGGER - CS, TRAIN');
        end
        set(hObject,'UserData',2);
end


% --- Executes when selected object is changed in uipanel12.
function uipanel12_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel12
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag')
    case 'radiobutton8'
        if get(handles.radiobutton3,'Value')==get(handles.radiobutton3,'Max')
            set(handles.pushbutton_ustrigger,'String','MANUAL TRIGGER - US, 1 TRIAL');
        elseif get(handles.radiobutton5,'Value')==get(handles.radiobutton5,'Max')
            set(handles.pushbutton_ustrigger,'String','MANUAL TRIGGER - US, TRAIN');
        end
        set(handles.uipanel16,'Visible','off')
        set(hObject,'UserData',1);
    case 'radiobutton9'
        if get(handles.radiobutton3,'Value')==get(handles.radiobutton3,'Max')
            set(handles.pushbutton_ustrigger,'String','MANUAL TRIGGER - CS, 1 TRIAL');
        elseif get(handles.radiobutton5,'Value')==get(handles.radiobutton5,'Max')
            set(handles.pushbutton_ustrigger,'String','MANUAL TRIGGER - CS, TRAIN');
        end
        set(handles.uipanel16,'Visible','on')
        set(hObject,'UserData',2);
end


% --- Executes during object creation, after setting all properties.
function uipanel13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'UserData',1);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
if get(hObject,'Value')==get(hObject,'Max')
    set(handles.edit15,'Enable','on');
elseif get(hObject,'Value')==get(hObject,'Min')
    set(handles.edit15,'Enable','off');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'UserData',1);


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double

if isequal(get(hObject,'String'),'0')
    set(handles.edit17,'String','0');
    set(handles.text34,'String','0.00');
else
    if str2num(get(handles.edit17,'String')) < str2num(get(hObject,'String'))
        set(handles.edit17,'String',get(hObject,'String'));
    end
    data = handles.ALLDATA;
    mean_data = mean(data(:,:,str2num(get(hObject,'String')):str2num(get(handles.edit17,'String'))),3);
    mean_mean_data = mean(mean_data(1:4000,2));
    max_data = max(mean_data(4001:end,2));
    range_data = max_data - mean_mean_data;
    handles.range_data = range_data;
    handles.mean_mean_data = mean_mean_data;
    clear data
    clear mean_data
    guidata(hObject,handles)
    set(handles.text34,'String',num2str(mean_mean_data+0.1*range_data,2));
end



% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double

if isequal(get(hObject,'String'),'0')
    set(handles.edit16,'String','0');
    set(handles.text34,'String','0.00');
else
    if str2num(get(hObject,'String')) < str2num(get(handles.edit16,'String'))
        set(handles.edit16,'String',get(hObject,'String'));
    end
    data = handles.ALLDATA;
    mean_data = mean(data(:,:,str2num(get(handles.edit16,'String')):str2num(get(hObject,'String'))),3);
    mean_mean_data = mean(mean_data(1:4000,2));
    max_data = max(mean_data(:,2));
    range_data = max_data - mean_mean_data;
    handles.range_data = range_data;
    handles.mean_mean_data = mean_mean_data;
    clear data
    clear mean_data
    guidata(hObject, handles)
    set(handles.text34,'String',num2str(mean_mean_data+0.1*range_data,2));
end


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2

if isequal(get(hObject,'Value'),get(hObject,'Max'))
    set(handles.radiobutton1,'Value',get(handles.radiobutton1,'Min'));
    set(handles.text27,'Enable','off')
    set(handles.text14,'Enable','off')
    set(handles.edit4,'Enable','off')
    set(handles.edit14,'Enable','off')
    % set(handles.pushbutton_uscsexecute,'Enable','off');
    % set(handles.pushbutton_uscstrigger,'Enable','on');
    set(handles.edit4,'String','1');
    set(handles.uitable1,'Enable','on')
    set(handles.pushbutton12,'Enable','on')
    set(handles.pushbutton_uscsexecute,'Enable','on');
    set(handles.pushbutton_uscstrigger,'Enable','off');
elseif isequal(get(hObject,'Value'),get(hObject,'Min'))
    set(handles.pushbutton12,'Enable','off');
    set(handles.uitable1,'Enable','off');
    set(handles.pushbutton_uscsexecute,'Enable','off');
    set(handles.pushbutton_uscstrigger,'Enable','on');
end


% --- Executes during object creation, after setting all properties.
function uipanel12_CreateFcn(hObject, eventdata, ~)
% hObject    handle to uipanel12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bbtest.
function bbtest_Callback(hObject, eventdata, handles)
% hObject    handle to bbtest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bbtest

if get(hObject,'Value') == get(hObject,'Max')
    set(handles.uipanel18,'Visible','on');
    set(handles.bbtest1,'Value',get(handles.bbtest1,'Min'));
    set(handles.bbtest2,'Value',get(handles.bbtest2,'Min'));
elseif get(hObject,'Value') == get(hObject,'Min')
    set(handles.uipanel18,'Visible','off');
    set(handles.bbtest1,'Value',get(handles.bbtest1,'Min'));
    set(handles.bbtest2,'Value',get(handles.bbtest2,'Min'));
end


% --- Executes on button press in bbtest1.
function bbtest1_Callback(hObject, eventdata, handles)
% hObject    handle to bbtest1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bbtest1



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double

if isequal(get(hObject,'String'),'0')
    set(handles.edit20,'String','0');
    set(handles.text44,'String','0.00');
else
    if str2num(get(hObject,'String')) < str2num(get(handles.edit20,'String'))
        set(handles.edit20,'String',get(hObject,'String'));
    end
    data = handles.ALLDATA;
    mean_data = mean(data(:,:,str2num(get(handles.edit20,'String')):str2num(get(hObject,'String'))),3);
    mean_mean_data2 = mean(mean_data(1:4000,5));
    max_data = max(mean_data(:,5));
    range_data2 = max_data - mean_mean_data2;
    handles.range_data2 = range_data2;
    handles.mean_mean_data2 = mean_mean_data2;
    clear data
    clear mean_data
    guidata(hObject, handles)
    set(handles.text44,'String',num2str(mean_mean_data2+0.1*range_data2,2));
end


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double

if isequal(get(hObject,'String'),'0')
    set(handles.edit21,'String','0');
    set(handles.text44,'String','0.00');
else
    if str2num(get(handles.edit21,'String')) < str2num(get(hObject,'String'))
        set(handles.edit21,'String',get(hObject,'String'));
    end
    data = handles.ALLDATA;
    mean_data = mean(data(:,:,str2num(get(hObject,'String')):str2num(get(handles.edit21,'String'))),3);
    mean_mean_data2 = mean(mean_data(1:4000,5));
    max_data = max(mean_data(4001:end,5));
    range_data2 = max_data - mean_mean_data2;
    handles.range_data2 = range_data2;
    handles.mean_mean_data2 = mean_mean_data2;
    clear data
    clear mean_data
    guidata(hObject,handles)
    set(handles.text44,'String',num2str(mean_mean_data2+0.2*range_data2,2));
end


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

slidervalue=round(get(hObject,'Value'));
set(handles.text38,'String',num2str(slidervalue));
data=handles.ALLDATA(:,[3 4 5],slidervalue);
time=handles.ALLDATA(:,1,slidervalue);
axes(handles.axes5)
plot(time,data(:,3));
axis tight
hold on
x = time(find(data(:,1)> 2.0,1,'first'));
if ~isempty(x)
    ylims = get(gca,'ylim');
    line([x,x],ylims,'color','red','linestyle','-.')
else
    ylims = get(gca,'ylim');
    x1 = time(4000);
    line([x1,x1],ylims,'color','red','linestyle','-.')
end
x = time(find(data(:,1)> 2.0,1,'last'));
if ~isempty(x)
    ylims = get(gca,'ylim');
    line([x,x],ylims,'color','red','linestyle','-.')
else
    ylims = get(gca,'ylim');
    x2 = time(5121);
    line([x2,x2],ylims,'color','red','linestyle','-.')
end
x = time(find(data(:,2)> 2.0,1,'first'));
if ~isempty(x)
    ylims = get(gca,'ylim');
    line([x,x],ylims,'color','green','linestyle',':')
end
x = time(find(data(:,2)> 2.0,1,'last'));
if ~isempty(x)
    ylims = get(gca,'ylim');
    line([x,x],ylims,'color','green','linestyle',':')
end
hold off


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, ~)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double

if str2num(get(handles.edit23,'String')) > 14/2.1
    sample_rates_out_audio = str2num(get(handles.edit23,'String')) * 2100;
else
    sample_rates_out_audio = 14000;
end


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in ustest.
function ustest_Callback(hObject, eventdata, handles)
% hObject    handle to ustest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ustest

if get(hObject,'Value') == get(hObject,'Max')
    set(handles.uipanel18,'Visible','on');
    set(handles.bbtest1,'Value',get(handles.bbtest1,'Min'));
    set(handles.bbtest2,'Value',get(handles.bbtest2,'Min'));
elseif get(hObject,'Value') == get(hObject,'Min')
    set(handles.uipanel18,'Visible','off');
    set(handles.bbtest1,'Value',get(handles.bbtest1,'Min'));
    set(handles.bbtest2,'Value',get(handles.bbtest2,'Min'));
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ustest2.
function ustest2_Callback(hObject, eventdata, handles)
% hObject    handle to ustest2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ustest2

if get(hObject,'Value') == get(hObject,'Max')
    set(handles.uipanel18,'Visible','on');
    set(handles.bbtest1,'Value',get(handles.bbtest1,'Min'));
    set(handles.bbtest2,'Value',get(handles.bbtest2,'Min'));
elseif get(hObject,'Value') == get(hObject,'Min')
    set(handles.uipanel18,'Visible','off');
    set(handles.bbtest1,'Value',get(handles.bbtest1,'Min'));
    set(handles.bbtest2,'Value',get(handles.bbtest2,'Min'));
end


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

slidervalue = get(hObject,'Value');
set(handles.text54,'String',[num2str(100*slidervalue),'%']);
set(handles.text56,'String',[log(slidervalue),' dB']);


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

slidervalue = get(hObject,'Value');
set(handles.text55,'String',[num2str(100*slidervalue),'%']);
set(handles.text57,'String',[log(slidervalue),' dB']);


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

