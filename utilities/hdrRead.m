[fname,folder]=uigetfile('*.hdr');
filename = strcat(folder,fname);

tic
fid = fopen(filename);
ln = {};
% Read the file
while ~feof(fid)
    % While not at the end of file, read a line
    try
        % Capture each line and split it into cells, removing comment lines
        ln{end+1,1} = textscan(fgetl(fid),'%s','Delimiter',' ','CommentStyle','//');
    catch
    end
end
fclose(fid);

% Get rid of extra whitespace & transpose cells
ln = cellfun(@(row) row{:}(~cellfun(@isempty,row{:}))',ln,'UniformOutput',false);

% Remove Empty (Comment) Rows
ln=ln(~cellfun(@isempty,ln));

% Get First Column (Field Names)
flds = cellfun(@(x) x{1},ln,'UniformOutput',false);
% Get Length of Data After First Column
lens = cellfun(@(x) length(x(2:end)),ln);

%% Get Indexs of Data each row contains
tic
zero = lens==0;
one = lens==1;
four = lens==4;
all_else = ~(zero|one|four);
zero = find(zero);
one = find(one);
four = find(four);
sflds = replace(string(flds),'$','');
sflds = {sflds{:}};
A = struct();
for i = 1:length(zero)
    try
        ind1 = one(one>=zero(i) & one<zero(i+1));
        ind4 = four(four>=zero(i) & four<zero(i+1));
        inde = all_else(all_else>=zero(i) & all_else<zero(i+1));
    catch
        ind1 = one(one>=zero(i));
        ind4 = four(four>=zero(i));
        inde = all_else(all_else>=zero(i));
    end
    c2s = [];
    if any(ind1)
        c1 = vertcat(ln{ind1});
        c2s = cell2struct(c1(:,2:end),c1(:,1),1);
    end
    if any(ind4)
        c4 = vertcat(ln{ind4});
        c2s = [c2s,cell2struct(c4(:,2:end),c4(:,1),1)];
    end
    if any(inde)
        ce = vertcat(ln{inde});
        c2s = [c2s,cell2struct(ce(:,2:end),ce(:,1),1)];
    end
    A.(sflds{zero(i)}) = c2s;
end

toc