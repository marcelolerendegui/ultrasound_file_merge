function SaveDicom3D(filename, data)

[nframes, depth, height, width] = size(data);

% set default/legacy behavior
if nargin<2, MaxVolumes=0; end;

% Get Header info
fid=fopen(filename,'r+','l');    % Note small L "l" for Little Endian
if(~fid) error('could not open input file'); end;

% Waste first 128 Bytes
WasteBytes  = fread(fid,128,'char');

% Waste Dicom Label
DICM    = char(fread(fid,4,'char'));

% Initialize Dicom Tags for "while" loop
TagA = 0;
TagB = 0;

% Clearly Specify the Tags used at the beginning of the data
% Note that the loop will terminate when these Tags Occur!
Data_TagA    = hex2dec('7fe0');
Data_TagB    = hex2dec('0010');

LoopCounter = 0;

while ((TagA~=Data_TagA) | (TagB~=Data_TagB)) & (LoopCounter<200)

    LoopCounter = LoopCounter + 1;
    
    TagA    = fread(fid,1,'ushort');
    TagB    = fread(fid,1,'ushort');
    CODE    = char(fread(fid,2,'char'))';
    N       = fread(fid,1,'ushort');
    
%    display([num2str(LoopCounter) ' ' num2str(TagA) ' ' num2str(TagB) ' ' CODE ' ' num2str(N)]);
    
    switch TagA
        
    case hex2dec('0018')
        if TagB==hex2dec('602c')
            DeltaX  = fread(fid,1,'double');
        elseif TagB==hex2dec('602e')
            DeltaY  = fread(fid,1,'double');
        else
            WasteBytes = fread(fid,N,'char');
        end
        
    case hex2dec('0028')
        if TagB==hex2dec('0008')
            tmpstr      = char(fread(fid,N,'char')');
            x.NumVolumes= sscanf(tmpstr,'%d');
        elseif TagB==hex2dec('0010')
            %x.height  = fread(fid,1,'ushort');  % # of rows
            fwrite(fid, height, 'ushort');
        elseif TagB==hex2dec('0011')
            %x.width  = fread(fid,1,'ushort');   % # of columns
            fwrite(fid, width, 'ushort');
        else
            WasteBytes = fread(fid,N,'char');
        end
        
    case hex2dec('3001')
        if TagB==hex2dec('1001')
           %x.depth  = fread(fid,1,'uint');  % this is 4 bytes, vs 2 bytes
           fwrite(fid, depth, 'uint');
           % for rows & cols
        elseif TagB==hex2dec('1003')
            DeltaZ  = fread(fid,1,'double');
        else
            WasteBytes = fread(fid,N,'char');
        end
        
    otherwise
        WasteBytes  = fread(fid,N,'char');
        
    end
    
    if (CODE == 'OB') WasteBytes = fread(fid,6,'char'); end;
    
end


if (LoopCounter>=200)
    fclose(fid);
    error('Sorry ... somehow I became mis-aligned on the tags');
end

% Ready to Read Data: Get Volume Loop Size
%N   = fread(fid,1,'uint');
N = nframes * depth * height * width;
fwrite(fid,N,'uint');

% Finally read volume data:
%x.data  = fread(fid,N,'*uint8');
fwrite(fid,data,'*uint8');

% Close file
fclose(fid);

return