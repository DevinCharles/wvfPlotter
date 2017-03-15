%% Read from the MDF Format File
% TODO: Read version first and choose csv format accordingly
txt = textscan(fopen('V2\utilities\R3.00.csv'),'%s %s %s %s','Delimiter',',');
fclose('all');

blk_data_start = find(~cellfun(@isempty,strfind(txt{1},'Data Type')))+1;
blk_data_end = [blk_data_start - 4; length(txt{1})];
blk_data_end(1)=[]; 
blk_headers = txt{1}(blk_data_start-2);

S = struct();

for blk_num = 1:length(blk_headers)
    S.(blk_headers{blk_num}).numbers = ...
        str2double(txt{2}(blk_data_start(blk_num):blk_data_end(blk_num)));
    S.(blk_headers{blk_num}).formats = ...
        txt{4}(blk_data_start(blk_num):blk_data_end(blk_num));
end
%%
%%%FOR TESTING%%%
[fname,folder] = uigetfile();
fname = strcat(folder,fname);

fid = fopen(fname,'r');

for blk_num = 1:5
    switch blk_num
        case 3
            if S.HDBLOCK.data{4} == 0
                continue
            else
                % Go to the beginning of the TXBLOCK
                fseek(fid,S.HDBLOCK.data{4},'bof');
            end
        case 4
            if S.HDBLOCK.data{5} == 0
                continue
            else
                % Go to the beginning of the PRBLOCK
                fseek(fid,S.HDBLOCK.data{5},'bof');
            end
        case 5
            % Go to the beginning of the DGBLOCK
            fseek(fid,S.HDBLOCK.data{3},'bof');
    end
    
    blk_n = S.(blk_headers{blk_num}).numbers;
    blk_f = S.(blk_headers{blk_num}).formats;
    for i=1:length(blk_n)
        if ((blk_num == 3) || (blk_num == 4)) && (i == 3)
            % If we're reading the TXBLOCK / PRBLOCK variable length char 
            % block get the block size from the previous read
            blk_n(i) = S.(blk_headers{blk_num}).data{i-1}-2*1-2;
        end
        S.(blk_headers{blk_num}).data{i} = fread(fid,blk_n(i),blk_f{i})';
    end
    
end

fclose('all');