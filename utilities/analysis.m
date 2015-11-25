% Copyright (C) 2015  Devin C Prescott
function varargout = analysis()
    
    % Get Data Structure from WVF Plotter
    handles = guidata(gcbf);
    try
        channels = handles.TraceStruct.Name([handles.ch_sel{:}]');
    catch
        return
    end
    
    % Setup Figure
    f = figure(1000);
    f.Position(3)= 600;
    f.Position(4)= 300;
    set(f,'Resize','off','MenuBar','none','ToolBar','none',...
        'NumberTitle','off','Name','WVF Plotter - Analysis')
    
    tools = uipanel('Title','Analysis Tools',...
             'Position',[0.05 0.08 0.350 0.85]);
    
    options = uipanel('Title','Options',...
             'Position',[0.450 0.08 0.495 0.85]);
    %% Options Tabs
    tgroup = uitabgroup('Parent', options,...
        'Position',[0.05 0.06 0.9 0.90]);
    xy_tab = uitab('Parent', tgroup, 'Title', 'X-Y Plot');
    der_tab = uitab('Parent', tgroup, 'Title', 'Derivative');
    fft_tab = uitab('Parent', tgroup, 'Title', 'FFT');
    pls_tab = uitab('Parent', tgroup, 'Title', 'Pulse Data');
    %% Analysis Tools
    xy = uicontrol('Parent', tools, 'Style', 'pushbutton', ...
        'Position', [20 210 150 20],'String','X-Y Plot',...
        'Callback',@xy_clbk);
    der = uicontrol('Parent', tools, 'Style', 'pushbutton', ...
        'Position', [20 180 150 20],'String','Derivative',...
        'Callback',@der_clbk);
    fft = uicontrol('Parent', tools, 'Style', 'pushbutton', ...
        'Position', [20 150 150 20],'String','Fast Fouier Transform',...
        'Callback',@fft_clbk);
    pls = uicontrol('Parent', tools, 'Style', 'pushbutton', ...
        'Position', [20 120 150 20],'String','Pulse Data',...
        'Callback',@pls_clbk);
    %% XY Tab
    x_label = uicontrol('Parent', xy_tab, 'Style', 'text',...
        'String', 'X Axis','HorizontalAlignment', 'left',...
        'Position', [20 150 150 20]);
    x_menu = uicontrol('Parent', xy_tab, 'Style', 'popupmenu',...
        'String', channels,...
        'Position', [150 150 100 20]);
    
    y_label = uicontrol('Parent', xy_tab, 'Style', 'text',...
        'String', 'Y Axis','HorizontalAlignment', 'left',...
        'Position', [20 120 150 20]);
    y_menu = uicontrol('Parent', xy_tab, 'Style', 'popupmenu',...
        'String', channels,...
        'Position', [150 120 100 20]);
    handles.x_menu = x_menu;
    handles.y_menu = y_menu;
    %% Derivative Tab
    dy_label = uicontrol('Parent', der_tab, 'Style', 'text',...
        'String', 'dy','HorizontalAlignment', 'left',...
        'Position', [20 150 150 20]);
    dy_menu = uicontrol('Parent', der_tab, 'Style', 'popupmenu',...
        'String', channels,...
        'Position', [80 150 150 20],'Callback',@dy_clbk);
    
    dx_label = uicontrol('Parent', der_tab, 'Style', 'text',...
        'String', 'dx','HorizontalAlignment', 'left',...
        'Position', [20 120 150 20]);
    dx_menu = uicontrol('Parent', der_tab, 'Style', 'popupmenu',...
        'String', [{'Time'},channels],...
        'Position', [80 120 150 20],'Callback',@dx_clbk);
    
    order_label = uicontrol('Parent', der_tab, 'Style', 'text',...
        'String', 'Order','HorizontalAlignment', 'left',...
        'Position', [20 90 150 20]);
    order_menu = uicontrol('Parent', der_tab, 'Style', 'popupmenu',...
        'String', {'First','Second','Third'},...
        'Position', [80 90 150 20],'Callback',@order_clbk);
    
    handles.dy_ind = get(dy_menu,'Value');
    handles.dx_ind = get(dx_menu,'Value');
    handles.order_ind = get(order_menu,'Value');
    
    %% FFT Tab
    signal_label = uicontrol('Parent', fft_tab, 'Style', 'text',...
        'String', 'Signal','HorizontalAlignment', 'left',...
        'Position', [20 150 150 20]);
    signal_menu = uicontrol('Parent', fft_tab, 'Style', 'popupmenu',...
        'String', channels,...
        'Position', [80 150 150 20],'Callback',@signal_clbk);
    freq_label = uicontrol('Parent', fft_tab, 'Style', 'text',...
        'String', 'Max Freq [Hz]','HorizontalAlignment', 'left',...
        'Position', [20 120 150 20]);
    freq_edit = uicontrol('Parent', fft_tab, 'Style', 'edit',...
        'String', 250,...
        'Position', [130 120 100 20],'Callback',@freq_clbk);
    
    handles.max_freq = str2double(get(freq_edit,'String'));
    handles.sig_ind = get(signal_menu,'Value');
    
    %% Pulse Tab
    pulse_label = uicontrol('Parent', pls_tab, 'Style', 'text',...
        'String', 'Pulse Signal','HorizontalAlignment', 'left',...
        'Position', [20 150 150 20]);
    pulse_menu = uicontrol('Parent', pls_tab, 'Style', 'popupmenu',...
        'String', channels,...
        'Position', [150 150 100 20]);
    
    pulsex_label = uicontrol('Parent', pls_tab, 'Style', 'text',...
        'String', 'Plot Versus','HorizontalAlignment', 'left',...
        'Position', [20 120 150 20]);
    pulsex_menu = uicontrol('Parent', pls_tab, 'Style', 'popupmenu',...
        'String', channels,...
        'Position', [150 120 100 20]);
    
    ppr_label = uicontrol('Parent', pls_tab, 'Style', 'text',...
        'String', 'Pulses Per Revolution','HorizontalAlignment', 'left',...
        'Position', [20 90 150 20]);
    ppr_edit = uicontrol('Parent', pls_tab, 'Style', 'edit',...
        'String', 400,...
        'Position', [150 90 100 20]);
    
%     rise_chk = uicontrol('Parent', pls_tab, 'Style', 'checkbox',...
%         'String','Rising Edges',...
%         'Position', [20 60 100 20]);
%     fall_chk = uicontrol('Parent', pls_tab, 'Style', 'checkbox',...
%         'String','Falling Edges',...
%         'Position', [20 40 100 20]);
%     mean_chk = uicontrol('Parent', pls_tab, 'Style', 'checkbox',...
%         'String','Mean Edges',...
%         'Position', [20 20 100 20]);
    
    handles.pulse_menu = pulse_menu;
    handles.pulsex_menu = pulsex_menu;
    handles.ppr_edit = ppr_edit;
%     handles.rise_chk = rise_chk;
%     handles.fall_chk = fall_chk;
%     handles.mean_chk = mean_chk;
    
    %% Save the Data Structure to WVF Plotter and Analysis Figure
    guidata(gcbo,handles)
    guidata(f,handles)
    
end

%% XY Callbacks
%% Pulse Callbacks
function xy_clbk(hObject, eventdata)
    handles = guidata(gcbf);
    ch_sel = handles.ch_sel;
    y_ind = get(handles.y_menu,'Value');
    x_ind = get(handles.x_menu,'Value');
    
    % Interpolation Time
    if x_ind > length(ch_sel{1})
        axis_x = 2;
        x_ind = x_ind-length(ch_sel{1});
    else
        axis_x = 1;
    end
   
    names = handles.TraceStruct.Name;
    
    if y_ind > length(ch_sel{1})
        axis = 2;
        y_ind = y_ind-length(ch_sel{1});
    else
        axis = 1;
    end
    
    for file = 1:length(handles.files_selected)
        
        y = handles.y{file}{axis}(:,y_ind);
        x = handles.y{file}{axis_x}(:,x_ind);
        t = handles.t{file}{axis}(:,y_ind);
        
        % Clip Data to zoom area
        if length(handles.files_selected)>1
            fname = handles.FileNames{handles.files_selected(file)};
            objs = findobj;
            ax = objs(strcmpi(get(findobj,'Tag'),fname));
            tlims = ax.XLim;
        else
            fname = handles.FileNames{handles.files_selected(1)};
            tlims = handles.embedded_fig.XLim;
        end
        a = find(t>=tlims(1),1,'first');
        b = find(t>=tlims(2),1,'first');
        if isempty(b)
            b = length(t);
        end
        if isempty(a)
            a = 1;
        end
        
        y = y(a:b);
        x = x(a:b);
        t = t(a:b);
        
        figure
        plot(x,y,'.k');
        xlabel(gca,names{ch_sel{axis_x}(x_ind)});
        ylabel(gca,names{ch_sel{axis}(y_ind)});
        title(fname,'Interpreter','none');
    end
end
%% Derivative Callbacks
% Derivative Function
function der_clbk(hObject, eventdata)
    % Pull data in from Handles Structure
    handles = guidata(gcbf);
    
    dy_ind  = handles.dy_ind;
    dx_ind  = handles.dx_ind;
    order_ind = handles.order_ind;
    
    names = handles.TraceStruct.Name;
    ch_sel = handles.ch_sel;
    
    if dy_ind > length(ch_sel{1})
        axis_dy = 2;
        dy_ind = dy_ind-length(ch_sel{1});
    else
        axis_dy = 1;
    end
    
    if dx_ind-1 > length(ch_sel{1})
        axis_dx = 2;
        dx_ind = dx_ind-length(ch_sel{1});
    else
        axis_dx = 1;
    end
    
    %%%%
    for file = 1:length(handles.files_selected)
        t = handles.t{file}{axis_dy}(:,dy_ind);

        if dx_ind == 1 && axis_dx ==1;
            x = t;
        else
            x = handles.y{file}{axis_dx}(:,dx_ind-1);
        end

        y = handles.y{file}{axis_dy}(:,dy_ind);

        if length(handles.files_selected)>1
            fname = handles.FileNames{handles.files_selected(file)};
            objs = findobj;
            ax = objs(strcmpi(get(findobj,'Tag'),fname));
            tlims = ax.XLim;
        else
            fname = handles.FileNames{handles.files_selected(1)};
            tlims = handles.embedded_fig.XLim;
        end
        
        a = find(t>=tlims(1),1,'first');
        b = find(t>=tlims(2),1,'first');
        if isempty(b)
            b = length(t);
        end
        if isempty(a)
            a = 1;
        end

        h = derivative(x,y,a,b,order_ind);
        ylabel(h(1),names{dy_ind})
        title(strcat('Derivative-',names{ch_sel{axis_dy}(dy_ind)},'-',fname),...
            'Interpreter','none')
        if dx_ind > 1
            xlabel(h(1),names{ch_sel{axis_dx}(dx_ind-1)})
            xlabel(h(2),names{ch_sel{axis_dx}(dx_ind-1)})
            ylabel(h(2),...
                strcat('$\frac{d^',num2str(order_ind),...
                names{ch_sel{axis_dy}(dy_ind)},'}{d',...
                names{ch_sel{axis_dx}(dx_ind-1)},'^',...
                num2str(order_ind),'}$'),...
                'Interpreter','LaTex','FontSize',16)
        else
            xlabel(h(1),'Time [s]')
            xlabel(h(2),'Time [s]')
            ylabel(h(2),...
                strcat('$\frac{d^',num2str(order_ind),...
                names{ch_sel{axis_dy}(dy_ind)},...
                '}{dt^',num2str(order_ind),'}$'),...
                'Interpreter','LaTex','FontSize',16)
        end
        DxDtData{file}=[t(a:b),x(a:b),y(a:b)];
    end
    assignin('base','DxDtData',DxDtData)
    guidata(gcbf, handles);
end

function dy_clbk(hObject, eventdata)
    handles = guidata(gcbf);
    handles.dy_ind = get(hObject,'Value');
    guidata(gcbf, handles);
end

function dx_clbk(hObject, eventdata)
    handles = guidata(gcbf);
    handles.dx_ind = get(hObject,'Value');
    guidata(gcbf, handles);
end

function order_clbk(hObject, eventdata)
    handles = guidata(gcbf);
    handles.order_ind = get(hObject,'Value');
    guidata(gcbf, handles);
end

%% FFT Callbacks
% FFT Function
function fft_clbk(hObject, eventdata)
    handles = guidata(gcbf);
    sig_ind = handles.sig_ind;  
    max_freq = handles.max_freq;
    
    names = handles.TraceStruct.Name;
    ch_sel = handles.ch_sel;
    
    if sig_ind > length(ch_sel{1})
        axis = 2;
        sig_ind = sig_ind-length(ch_sel{1});
    else
        axis = 1;
    end
    
    for file = 1:length(handles.files_selected)
        x = handles.y{file}{axis}(:,sig_ind);
        t = handles.t{file}{axis}(:,sig_ind);

        % Clip Data to zoom area
        if length(handles.files_selected)>1
            fname = handles.FileNames{handles.files_selected(file)};
            objs = findobj;
            ax = objs(strcmpi(get(findobj,'Tag'),fname));
            tlims = ax.XLim;
        else
            fname = handles.FileNames{handles.files_selected(1)};
            tlims = handles.embedded_fig.XLim;
        end
        a = find(t>=tlims(1),1,'first');
        b = find(t>=tlims(2),1,'first');
        if isempty(b)
            b = length(t);
        end
        if isempty(a)
            a = 1;
        end

        t = t(a:b);
        x = x(a:b);

        % Clip data at zero crossings (make approx periodic) 
        x = detrend(x);
        x1 = x(2:end);
        x0 = x(1:end-1);
        a = find(x0>0 & x1<0,1,'first');
        b = find(x0>0 & x1<0,1,'last');

        ta0 = t(a)- x(a)/((x(a)-x(a+1))/(t(a)-t(a+1)));
        tb0 = t(b)- x(b)/((x(b)-x(b+1))/(t(b)-t(b+1)));

        t = t(a+1:b);
        x = x(a+1:b);

        t = [ta0;t;tb0];
        x = [0;x;0];

    %     if mod(x,2)~=0
    %         x(end)=[];
    %         t(end)=[];
    %     end

        m = length(x);
    %     window = hann(m,'periodic');
        window = rectwin(m);

        dt = mode(diff(t));
        fs = 1/dt;

    %     n = pow2(nextpow2(m));

        % Transform Length
        n = 2^nextpow2(m);
        % FFT
        y = fft(x.*window,n)/m;
        y = 2*abs(y(1:n/2+1));
        % Frequency Range
        f = fs/2*linspace(0,1,n/2+1);
        f = f';

        figure;
        subplot(2,1,1)
        plot(f,y);
        title(strcat('FFT-',names{ch_sel{axis}(sig_ind)},'-',fname),...
            'Interpreter','none')
        xlim([0,max_freq]);
        xlabel('Frequency [Hz]')
        ylabel('Amplitude')
        grid minor

        subplot(2,1,2)
        plot(t,x.*window);
        title('Periodic, 0 Offset Signal')
        xlabel('Time [s]');
        ylabel(names{ch_sel{axis}(sig_ind)},'Interpreter','none');
        xlim([t(1),t(end)]);
        grid minor
        FFTData{file}=[f,y];
    end
    assignin('base','FFTData',FFTData)
end

function signal_clbk(hObject, eventdata)
    handles = guidata(gcbf);
    handles.sig_ind = get(hObject,'Value');
    guidata(gcbf, handles);
end

function freq_clbk(hObject, eventdata)
    handles = guidata(gcbf);
    handles.max_freq = str2double(get(hObject,'String'));
    guidata(gcbf, handles);
end

%% Pulse Callbacks
function pls_clbk(hObject, eventdata)
    handles = guidata(gcbf);
    ch_sel = handles.ch_sel;
    pulse_ind  = get(handles.pulse_menu,'Value');
    ppr = str2double(get(handles.ppr_edit,'String'));
    xp_ind = get(handles.pulsex_menu,'Value');
    
    % Interpolation Time
    if xp_ind > length(ch_sel{1})
        axis_xp = 2;
        xp_ind = xp_ind-length(ch_sel{1});
    else
        axis_xp = 1;
    end
   
    names = handles.TraceStruct.Name;
    
    if pulse_ind > length(ch_sel{1})
        axis = 2;
        pulse_ind = pulse_ind-length(ch_sel{1});
    else
        axis = 1;
    end
    
    for file = 1:length(handles.files_selected)
        
        y = handles.y{file}{axis}(:,pulse_ind);
        t = handles.t{file}{axis}(:,pulse_ind);
        
        % Interpolation Time (tt)
        if xp_ind == pulse_ind && axis_xp == axis;
            x = t;
        else
            x = handles.y{file}{axis_xp}(:,xp_ind);
        end
        
        % Clip Data to zoom area
        if length(handles.files_selected)>1
            fname = handles.FileNames{handles.files_selected(file)};
            objs = findobj;
            ax = objs(strcmpi(get(findobj,'Tag'),fname));
            tlims = ax.XLim;
        else
            fname = handles.FileNames{handles.files_selected(1)};
            tlims = handles.embedded_fig.XLim;
        end
        a = find(t>=tlims(1),1,'first');
        b = find(t>=tlims(2),1,'first');
        if isempty(b)
            b = length(t);
        end
        if isempty(a)
            a = 1;
        end
        
        y = y(a:b);
        t = t(a:b);
        x = x(a:b);

%         rise_chk = get(handles.rise_chk,'Value');
%         fall_chk = get(handles.fall_chk,'Value');
%         mean_chk = get(handles.mean_chk,'Value');

        [tr,yr,tf,yf] = pulse(t,y,ppr);
        
        del = min(length(tr),length(tf))+1;
        tf(del:end)=[];
        yf(del:end)=[];
        tr(del:end)=[];
        yr(del:end)=[];
        mt = mean([tr,tf],2);
        my = mean([yr,yf],2);
        yy = interp1(mt,my,t);
        
        figure
        hold on
%         if rise_chk > 0
%             plot(tr,yr,'-r');
%         end
%         if fall_chk > 0 
%             plot(tf,yf,'-b');
%         end
%         if mean_chk > 0
%             plot(mt,my,'-g');
%         end
        
        plot(x,yy,'-k')
        
        hold off
        title(strcat('Pulse Data-',names{ch_sel{axis}(pulse_ind)},...
            '-',fname),'Interpreter','none')
        xlabel('Time [s]')
        grid minor
                
        PulseData{file}=[x,yy];
    end
    assignin('base','PulseData',PulseData)
end

%% Histogram Callbacks
function his_clbk(hObject, eventdata)
    if (get(hObject,'Value') == get(hObject,'Max'))
        display('Selected');
    else
        display('Not selected');
    end
end

