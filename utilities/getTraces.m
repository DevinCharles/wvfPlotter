function gui = getTraces(gui)
    % Full path & filename (w/o extension) and extensions
    fname = {gui.data.filename};
    ext = lower({gui.data.ext});
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
            case '.dat'
                % If Mat-file doesn't exist, create one
                if exist(strcat(fname{file_num}(1:end-3),'mat'),'file')~=2
                    mdfimport(fname{file_num},'Auto MAT-File');
                end
                fname{file_num} = strcat(fname{file_num}(1:end-3),'mat');
                
                fdata = load(fname{file_num});
                names = fields(fdata);
                values = cellfun(@(name) fdata(1).(name),names,'UniformOutput',false);
                time_ind = ~cellfun(@isempty,regexpi(names,'time_\d+'));
                
                % Get the time arrays that the variables match with
                time_ints = cellfun(@(x) str2double(x{1}{2}), regexpi(names,'(\w+?)(?:_)(\d+)$','tokens'));
                
                % Get the names without time ints
                names = cellfun(@(x) x{1}{1}, regexpi(names,'(\w+?)(?:_)(\d+)','tokens'),'UniformOutput',false);
                
                % Get the time arrays
                times = {};
                times(time_ints(time_ind))=deal(values(time_ind));
                % Get the names of the variables
                var_names = names(~time_ind);
                % Get the values of the variables
                var_values = values(~time_ind);
                t_array = arrayfun(@(x) times{x}, time_ints(~time_ind),'UniformOutput',false);
                
                [gui.data(file_num).headerdata(1:length(var_names)).name] = deal(var_names{:});
                [gui.data(file_num).headerdata(1:length(var_names)).y] = deal(var_values{:});
                [gui.data(file_num).headerdata(1:length(var_names)).t] = deal(t_array{:});
                [gui.data(file_num).headerdata(1:length(var_names)).Axis1Selection] = deal(false);
                [gui.data(file_num).headerdata(1:length(var_names)).Axis2Selection] = deal(false);
                
            case '.csv'
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
    try
        result = vertcat(result{:});
        % Compare all files traces 
        if ~all(arrayfun(@(n) all(strcmpi(result(:,n),result(1,n))),1:size(result,2)))
            gui.listbox.files.Max = 1;
            gui.listbox.files.Value = 1;
            errordlg('Not all files have the same traces. Setting multi-file selection mode "off".')
            return
        else
            gui.listbox.files.Max = 2;
        end
    catch
        gui.listbox.files.Max = 1;
        gui.listbox.files.Value = 1;
        errordlg('Not all files have the same traces. Setting multi-file selection mode "off".')
    end
    
end
    