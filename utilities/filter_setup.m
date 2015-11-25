% Copyright (C) 2015  Devin C Prescott
function varargout = filter_setup()
    
    % Get Data Structure from WVF Plotter
    global handles fig_handle
    fig_handle = gcbf;
    handles = guidata(fig_handle);
    try
        channels = handles.TraceStruct.Name([handles.ch_sel{:}]');
    catch
        return
    end
    
    % Setup Figure
    f = figure(2000);
    f.Position(3)= 600;
    
    f.Position(4)= (length(channels))*(30+5)+45;
    h0 = f.Position(4)-30-5*(length(channels)-1);

    set(f,'Resize','off','MenuBar','none','ToolBar','none',...
        'NumberTitle','off','Name','WVF Plotter - Filter Setup')
    
    toggles = uipanel('Title','Filter Toggles',...
             'Position',[0.03 0.08 0.200 0.85]);
    
    options = uipanel('Title','Filter Options',...
             'Position',[0.272 0.08 0.70 0.85]);
    %% Loop Through Channels and Create
    filt_params = struct();
    for ind = 1:length(channels)
        try
            % If toggle exists, then we've already set values
            toggle = handles.filt_params.(channels{ind}).('toggle');
            type = handles.filt_params.(channels{ind}).('type');
            type = find(strcmpi(type,{'low','high','bandpass','stop'}));
            value = handles.filt_params.(channels{ind}).('value');
            order = handles.filt_params.(channels{ind}).('order');
        catch
            % If toggle doesn't exit, we haven't set defaults
            handles.filt_params.(channels{ind}).('toggle') = false;
            toggle = false;
            handles.filt_params.(channels{ind}).('type') = 'low';
            type = 1;
            handles.filt_params.(channels{ind}).('value') = 20;
            value = 20;
            handles.filt_params.(channels{ind}).('order') = 3;
            order = 3;
        end
        
        
        uicontrol('Parent', toggles, 'Style', 'toggle', ...
            'Position', [10 h0-30*ind 95 20],'String',channels(ind),...
            'Value',abs(toggle),...
            'Callback', @update_handles,...
            'tag',strcat(channels{ind},'`toggle'));
        
        uicontrol('Parent', options, 'Style', 'text',...
            'String', 'Filter Type','HorizontalAlignment', 'left',...
            'Position', [10 h0-30*ind 60 20]);
        
        uicontrol('Parent', options, 'Style', 'popupmenu',...
            'String', {'Low-Pass','High-Pass','Band-Pass','Band-Stop'},...
            'Value',type,...
            'Position', [70 h0-30*ind 80 20],...
            'Callback', @update_handles,...
            'tag',strcat(channels{ind},'`type'));
        
        uicontrol('Parent', options, 'Style', 'text',...
            'String', 'Filter Value','HorizontalAlignment', 'left',...
            'Position', [170 h0-30*ind 60 20]);
        
        uicontrol('Parent', options, 'Style', 'edit',...
            'String', num2str(value),'HorizontalAlignment', 'right',...
            'Position', [240 h0-30*ind 40 20],...
            'Callback', @update_handles,...
            'tag',strcat(channels{ind},'`value'));
        
        uicontrol('Parent', options, 'Style', 'text',...
            'String', 'Filter Order','HorizontalAlignment', 'left',...
            'Position', [290 h0-30*ind 60 20]);
        
        uicontrol('Parent', options, 'Style', 'edit',...
            'String', num2str(order),'HorizontalAlignment', 'right',...
            'Position', [360 h0-30*ind 40 20],...
            'Callback', @update_handles,...
            'tag',strcat(channels{ind},'`order'));
    end
    guidata(gcbf, handles);
end
    
function update_handles(source,~)
    global fig_handle
    handles = guidata(fig_handle);
    field = strsplit(source.Tag,'`');
    switch field{2}
        case 'value'
            data = str2num(source.String);
        case 'order'
            data = str2double(source.String);
        case 'type'
            filters = {'low','high','bandpass','stop'};
            data = filters{source.Value};
        case 'toggle'
            data = logical(source.Value);     
    end
    handles.filt_params.(field{1}).(field{2}) = data;
    guidata(fig_handle, handles);
end