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
                        gui.data(file_num).headerdata(counter).name = HDRinfo.(group).(Trace).TraceName{1};
                        gui.data(file_num).headerdata(counter).GTpair = [group_num,trace_num];
                        gui.data(file_num).headerdata(counter).HUnit = HDRinfo.(group).(Trace).HUnit{1};
                        gui.data(file_num).headerdata(counter).VUnit = HDRinfo.(group).(Trace).VUnit{1};
                        gui.data(file_num).headerdata(counter).Samples = HDRinfo.(group).(Trace).BlockSize;
                        gui.data(file_num).headerdata(counter).Axis1Selection = false;
                        gui.data(file_num).headerdata(counter).Axis2Selection = false;
                        counter=counter+1;
                    end
                end
            case 'dat'
                %TEMP FOR TESTING ONLY
                gui.data(file_num).headerdata(1).name = {'dat_test'};
                
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
    % Flatten Cell Array (IT WAS VERTCAT!)
    result = vertcat(result{:});
    % Compare all files traces 
    if ~all(arrayfun(@(n) all(strcmpi(result(:,n),result(1,n))),1:size(result,2)))
        gui.listbox.files.Max = 1;
        gui.listbox.files.Value = 1;
        errordlg('Not all files have the same traces. Setting multi-file selection mode "off".')
        return
    end
end
    