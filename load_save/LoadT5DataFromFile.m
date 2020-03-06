function [status, info, header, Frames] = LoadT5DataFromFile(filename)

eval('load_constants') % load constants

[readh_status, header] = ReadT5ileHeader(filename);

if readh_status~=0
    status = 2;
    return;
end


info.Clinic = "Duke University";
info.Description = header.Description;
info.Caption = header.Caption;
info.Date = header.Date;
info.Time = header.Time;
info.Xducer = header.XDucerName;
info.PatientID = header.PatientID;
info.CtrlVersion = header.CtrlVersion;
info.Filter = header.Filter;
info.Frequency = header.Frequency;
info.AcqRate = header.AcqRate;
info.ECGAcqRate = header.ECGAcqRate;

% Header has been read, now let's read the data out of the file

fp = fopen(filename, 'rb');

if (fp==-1)
    status = 2;
    return;
end

% release old scan data!
% if (pSeptum)
% {
% pSeptum->Release();
% delete pSeptum;
% pSeptum = NULL;
% }
% 
% ReleaseFrameBuffer();
% ReleaseScanFormats();

% Check to see how many frames.  If over 13500, change the number in the header
% Otherwise, the 2GB files (big guys) can run out of memory on 32-bit machines.

if (header.FrameCount > 13500) % TODO: check if this is needed?
    header.FrameCount = 13500;
end

% Create new scan format and store new information
ScanFormats = new_CScanFormat();
%memset(ScanFormats,0,sizeof(CScanFormat));

%ScanFormatCount = 1;
    %ScanFormatCount is a member of CScan class (don't have information)
%CSF = 0;
    %CSF is a member of CScan class (don't have information)
%FrameBufferStart = 0;
    %FrameBufferStart is a member of CScan class (don't have information)
%isSaved = true;
    %isSaved is a member of CScan class (don't have information)

ScanFormats.AngularSpacing = header.AngularSpacing;
ScanFormats.Elspacing = header.Elspacing;
ScanFormats.Apertures = mod(floor(header.ModeWord/256), 8) + 1; %(int)((header.ModeWord & APERTURE_MASK) >> 8) + 1;
ScanFormats.ConvType = header.ConvType;
ScanFormats.ExplosoCount = header.ExplosoCount;
ScanFormats.LineCount = header.LineCount;
ScanFormats.LineLength = header.LineLength;
ScanFormats.ModeWord = header.ModeWord;
ScanFormats.ScanDepth = header.ScanDepth;
ScanFormats.ROffset = 0.0;
ScanFormats.ApertureOffset = header.ApOffset;
ScanFormats.FOV = header.FOV;

%FrameCount = header.FrameCount;  % DOH!  storing framecount here messes up freeing buffers
CPUSpeed = header.CPUSpeed;
if ((ScanFormats.ConvType == CT_MULTIB || ScanFormats.ConvType == CT_MULTIB2TX)||(ScanFormats.ConvType == CT_ROTPLN || ScanFormats.ConvType == CT_ROTPLN2DET))
    ScanFormats.NumPlanes = header.NumPlanes;
end

if (header.ModeWord && FIELD_SYNC_MASK)
    ScanFormats.isGated = true;
else
    ScanFormats.isGated = false;
end

% take care of any variables dependent only upon file version
% currently only ECG is version dependent (v3.0+ always has ECG)
% if (header.Version >= 0x0300)
%     hasECG = true;
% else
%     hasECG = false;
hasECG = (header.Version >= hex2dec('0300'));

% now need to allocate everything for reading from file!
if (ScanFormats.ConvType == CT_MULTIB || ScanFormats.ConvType == CT_MULTIB2TX)
    framesize = ScanFormats.LineCount * ScanFormats.LineLength * ScanFormats.ExplosoCount * ScanFormats.NumPlanes;
else
    framesize = ScanFormats.LineCount * ScanFormats.LineLength *ScanFormats.ExplosoCount;
end
 
% FrameBufferStart = 0;
% isSaved = true;

% Scan format should be filled out, now let's get memory ready
Frames = arrayfun(@(K) new_CFrameBuffer(), 1:header.FrameCount);

for i = 0:1:header.FrameCount-1
    % Allocate memory for frame data
    Frames(i+1).Data = zeros(1, framesize, 'int16');
    
%     % if we have ecg, allocate memory for ecg
%     if (hasECG)
%         Frames(i+1).ECGData = arrayfun(@(K) new_CECGData(), 1:MAX_LINE_COUNT);
%     else
%         Frames(i+1).ECGData = [];
%         Frames(i+1).ECGDataCount = 0;
%     end
%     
%     % if we have a gated scan, allocate fill buffers
%     if (ScanFormats.isGated) 
%         Frames(i+1).ECGFillData = arrayfun(@(K) new_CECGData(), 1:MAX_ECG_FILL_COUNT);
%     else
%         Frames(i+1).ECGFillData = [];
%         Frames(i+1).ECGFillCount = 0;
%     end
end

% pSeptum = new CSeptum(ScanFormats,header.FrameCount);%;, pRender);


% skip magic number and version
fseek(fp, 6, 'bof');

loadframe = 0;
loadline = 0;

while( ~feof(fp) )
    keylen = fread(fp, 1, 'int32');	
    if keylen == 0
        break;
    end
    key = char(fread(fp, keylen, 'char')');
    datalen = fread(fp, 1, 'uint32');    

    % FRAME HEADER -- ONLY NEED EXPLOSOMAP
    if strcmp(key,keyFRAMEHEADER)
        while (~feof(fp))     
            keylen = fread(fp, 1, 'int32');
            if keylen == 0
                break;
            end
            key = char(fread(fp, keylen, 'char')');
            subdatalen = fread(fp, 1, 'uint32');

            % ONLY NEED EXPLOSOMAP
            if strcmp(key,keyEXPLOSOMAP)
                %int temp;
                %unsigned int i;
                for i = 0:1:subdatalen/4-1
                    temp = fread(fp, 1, 'int32');
                    % For old files
                    if ((mod(i,2) == 0) && (header.Version < hex2dec('0302')))
                        ScanFormats.ExplosoMap(i+1) = -double(temp)/1000.0;
                    else
                        ScanFormats.ExplosoMap(i+1) = double(temp)/1000.0;
                    end
                end
            else
                skip_data = fread(fp, subdatalen, 'char');
            end
        end
    % FRAME DATA -- NEED TO PARSE OUT
    elseif strcmp(key,keyFRAMEDATA)
        while (~feof(fp))
            keylen = fread(fp, 1, 'int32');
            if keylen == 0
                break;
            end
            key = char(fread(fp, keylen, 'char')');
            subdatalen = fread(fp, 1, 'uint32');
            
            if strcmp(key,keyFRAMETIME)
                Frames(loadframe+1).TimeStamp.wYear = fread(fp, 1, 'uint16');
                Frames(loadframe+1).TimeStamp.wMonth = fread(fp, 1, 'uint16');
                Frames(loadframe+1).TimeStamp.wDayOfWeek = fread(fp, 1, 'uint16');
                Frames(loadframe+1).TimeStamp.wDay = fread(fp, 1, 'uint16');
                Frames(loadframe+1).TimeStamp.wHour = fread(fp, 1, 'uint16');
                Frames(loadframe+1).TimeStamp.wMinute = fread(fp, 1, 'uint16');
                Frames(loadframe+1).TimeStamp.wSecond = fread(fp, 1, 'uint16');
                Frames(loadframe+1).TimeStamp.wMilliseconds = fread(fp, 1, 'uint16');                
            elseif strcmp(key,keyFRAMETSC)
                Frames(loadframe+1).TSC = fread(fp, 1, 'uint64');                
            elseif strcmp(key,keyFRAMESAMPLES)
                Frames(loadframe+1).Data = fread(fp, subdatalen/2, 'uint16');                 
            elseif strcmp(key,keyECGFRAMEDATA)
                Frames(loadframe+1).ECGDataCount = subdatalen/16;
                for loadline=0:1:subdatalen/16-1
                    Frames(loadframe+1).ECGData(loadline+1).TimeStamp = fread(fp, 1, 'uint32');
                    Frames(loadframe+1).ECGData(loadline+1).Data = fread(fp, 1, 'uint16');
                    Frames(loadframe+1).ECGData(loadline+1).Line = fread(fp, 1, 'int16');
                    Frames(loadframe+1).ECGData(loadline+1).Fill = fread(fp, 1, 'uint16');
                    Frames(loadframe+1).ECGData(loadline+1).Doppler = fread(fp, 1, 'uint16');
                    Frames(loadframe+1).ECGData(loadline+1).RTrigger = fread(fp, 1, 'uint16');
                    Frames(loadframe+1).ECGData(loadline+1).Word8 = fread(fp, 1, 'uint16');
                    Frames(loadframe+1).ECGData(loadline+1).Valid = true;
                end
            elseif strcmp(key,keyECGFILLDATA)
                Frames(loadframe+1).ECGFillCount = subdatalen/16;
                for loadline=0:1:subdatalen/16-1
                    Frames(loadframe+1).ECGFillData(loadline+1).TimeStamp = fread(fp, 1, 'uint32');
                    Frames(loadframe+1).ECGFillData(loadline+1).Data = fread(fp, 1, 'uint16');
                    Frames(loadframe+1).ECGFillData(loadline+1).Line = fread(fp, 1, 'int16');
                    Frames(loadframe+1).ECGFillData(loadline+1).Fill = fread(fp, 1, 'uint16');
                    Frames(loadframe+1).ECGFillData(loadline+1).Doppler = fread(fp, 1, 'uint16');
                    Frames(loadframe+1).ECGFillData(loadline+1).RTrigger = fread(fp, 1, 'uint16');
                    Frames(loadframe+1).ECGFillData(loadline+1).Word8 = fread(fp, 1, 'uint16');
                    Frames(loadframe+1).ECGFillData(loadline+1).Valid = true;
                end
            else
                skip_data = fread(fp, subdatalen, 'char');
            end
        end
        % Done reading this frame, now make sure flags are set
        Frames(loadframe+1).Valid = true;
        Frames(loadframe+1).Frame = loadframe;
        loadframe = loadframe+1;

        % Cheater's way of "fixing" the 2GB files
        if (loadframe == 13500)
            FrameCount = 13500;
            break;  %End test
        end
        % NO OTHER TOP LEVEL KEYS AT THE MOMENT
    else
        skip_data = fread(fp, datalen, 'char');
    end
end % should be done reading file!

fclose(fp);

% Handle the last few pieces of information...
FrameCount = loadframe;

dt = (Frames(end).TSC - Frames(1).TSC)/CPUSpeed;

if ((info.AcqRate == 0) && (dt ~= 0))
    info.AcqRate = length(Frames)/dt;
end

if (hasECG && info.ECGAcqRate == 0.0)
    dt =  (Frames(end).ECGData(0).TimeStamp - Frames(0).ECGData(0).TimeStamp) *ECG_SEC_PER_TICK;
    info.ECGAcqRate = float(FrameCount-1)/dt;
end

ScanFormats.Source = DS_FILE;
info.FileName = filename;
info.ScanFormats = ScanFormats;
status = 0;

end
