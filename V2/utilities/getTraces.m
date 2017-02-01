function gui = getTraces(gui)
    % Full path & filename (w/o extension) and extensions
    fname = {gui.data.filename};
    ext = {gui.data.ext};
    for file_num = 1:length(fname)
        switch ext{file_num}
            case '.hdr'
                %Open File in HDR Read
                HDRinfo = hdrread(fname{file_num});
                % Get the number of groups
                num_groups = HDRinfo.GroupNumber;
                counter=1;
                for group_num = 1:num_groups
                    group = strcat('Group',num2str(group_num));
                    num_traces = HDRinfo.(group).TraceNumber;
                    for trace_num = 1:num_traces
                        Trace = strcat('Trace',num2str(trace_num));
                        % Fill Headerdata Structure
                        gui.data(file_num).headerdata(counter).name = HDRinfo.(group).(Trace).TraceName;
                        gui.data(file_num).headerdata(counter).GTpair=[group_num,trace_num];
                        gui.data(file_num).headerdata(counter).HUnit = HDRinfo.(group).(Trace).HUnit;
                        gui.data(file_num).headerdata(counter).VUnit = HDRinfo.(group).(Trace).VUnit;
                        gui.data(file_num).headerdata(counter).Samples = HDRinfo.(group).(Trace).BlockSize;
                        counter=counter+1;
                    end
                end
            case 'dat'
                % Try to find mat file
                % Convert dat file to mat file
                % Open mat file
            case 'csv'
                % Use CSV Read
        end
    end
    checkTraces(gui);
end

function checkTraces(gui)
    % Get all trace names for all files
    result = cellfun(@(trace) {trace.name},...
        arrayfun(@(file) file.headerdata, gui.data,'UniformOutput',false),...
        'UniformOutput',false);
    % Flatten 1 x m cells of n x 1 cell array into n,m cell array 
    % where n is number of files and m is number of traces
    % TODO: I know there's a better way to do this... but what is it?!
    for n = 1:length(gui.data)
        result(n,1:length(result{n})) = result{n}';
        if n>1
            % Compare this files traces to the previoius one's
            if ~all(strcmpi([result{n-1,:}],[result{n,:}]))
                gui.listbox.files.Max = 1;
                errordlg('Not all files have the same traces. Setting multi-file selection mode "off".')
                return
            end
        end
    end
end
    