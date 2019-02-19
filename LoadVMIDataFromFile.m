function [out, info, Frames] = LoadVMIDataFromFile(filename)
% Loads a VMI File into local memory for display

eval('load_constants') % load constants

info = struct();

info.clockcounts = 0;
info.countincr = 0;
info.tempo = 0;

% pull header info out, return value from Header if it failed
[retval, header] = ReadVMIFileHeader(filename);
if (retval)
    out = retval;
    return;
end

% Display fields
info.Clinic = header.Caption.Clinic;
info.Description = header.Description;
info.Caption = "";
info.Date = header.Caption.Date;
info.Filter = "";
info.Time = header.Caption.Time;
info.Xducer = header.XDucerName;
info.Frequency = header.XDucerFreq;
info.Header = header;


% T5 Dataset maker version
info.CtrlVersion = 0;

% this is the escape referred to below....
if (header.ScanFormat == 3 || header.ScanFormat == 4) 
    warndlg("Ummm.....  I'm pretty sure VMI doesn't support exploso b-scans.....I'll get back to you later on that one","Warning");
    out = 4;
    return;
end

% header version cannot be 2.5 or greater...
if (header.Version >= 2.5)     
    out = 5;
    return;
end

% now, open file before we release old stuff
fp = fopen(filename, 'rb');
if (fp==-1)
    out = 1;
    return;
end

% We have a valid file w/ a valid header, so let's clean up from before!
% if (pSeptum)
%     pSeptum->Release();
%     delete pSeptum;
%     pSeptum = NULL;
% end
% pSeptum is a member of CScan class (don't have information)

%ReleaseScanFormats();
    %ReleaseScanFormats is a member of CScan class (don't have information)
%ReleaseFrameBuffer();
    %ReleaseFrameBuffer is a member of CScan class (don't have information)

% Create new scan format to store new information
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

switch header.ScanFormat
    case 1 % plain ole bmodes
        ScanFormats.ConvType = CT_BSCAN;
        ScanFormats.AngularSpacing = header.azSeparation*1000; % double check this number!
        ScanFormats.LineCount = header.LineCount;
        ScanFormats.ExplosoCount = 1;
    case 2 % plain ole volumes
        ScanFormats.ConvType = CT_VOLSCAN;
        ScanFormats.LineCount = header.LineCount;
        ScanFormats.ExplosoCount = header.ExplosoCount;
        ScanFormats.ROffset = header.Offset/header.ScanDepth;
        % #TODO don't i need az and el spacing here?
    case 3
        %% DOES THE VMI MACHINE SUPPORT THIS MODE?  IF SO, YOU GOTTA WRITE THIS PART CORRECTLY! 
        %% and get rid of the escape up above for this madness too....
    case 4
        % DOES THE VMI MACHINE SUPPORT THIS MODE?  IF SO, YOU GOTTA WRITE THIS PART CORRECTLY!
end

ScanFormats.Apertures = 0; % vmi doesn't support synthetic apertures (to my knowledge), either way, it only has to do w/ ecg stuff
ScanFormats.LineLength = header.AxialSamples; % ? double check this number
ScanFormats.ModeWord = header.ModeWord; % should be 0 for VMI
ScanFormats.ScanDepth = header.ScanDepth;
AcqRate = header.FrameRate;

ScanFormats.isGated = false; % CHECK IF THE VMI FILES SUPPORT GATED ACQUISITION
info.hasECG = false;  % ***********NB: FIGURE OUT THE FORMAT FOR ECG COMING OFF VMI FILES!*******************

% Scan format should be filled out, now let's get memory ready
Frames = arrayfun(@(K) new_CFrameBuffer(), 1:header.FrameCount);

%j = header.LineCount * header.AxialSamples; % j = framesize
jj = header.LineCount * header.AxialSamples * header.ExplosoCount; % j = framesize

for ii = 1:1:header.FrameCount 
    Frames(ii).Data = zeros(1, jj, 'int16');
end

FrameCount = header.FrameCount;

% now  load frame data!

data_size = 512*64*64;
data = zeros(1, data_size, 'int8');

% CPUSpeed is missing from cpp file???
CPUSpeed = 1;

clockcounts = 0;
countincr = CPUSpeed/AcqRate;
for ff = 0:1:FrameCount-1
    if header.ScanFormat == 1 % bmodes
        fseek(fp, header.grayImageOffset + ff*512*header.LineCount, 'bof');
        data = fread(fp, 512*header.LineCount, 'char');

        % model 1 and viper
        if header.Version >= 1.0 && header.Version <= 2.3
            for ii = 0:1:(header.AxialSamples-1)
                for jj = 0:1:((header.azLines/4)-1)
                    for mm = 0:1:(4-1)
                        %Frames[ff].Data[i+(j*4+m)*header.AxialSamples] = 
                        %       (WORD)(data[m+i*4+j*512*4]/255.0*65535.0);
                        Frames(ff+1).Data(ii+(jj*4+mm)*header.AxialSamples+1) = ...
                                data(mm + ii*4 + jj*512*4+1) * 32767/255;
                    end
                end
            end
            Frames(ff+1).Frame = ff+1;
            Frames(ff+1).Valid = true;
            Frames(ff+1).ECGData = [];
            Frames(ff+1).ECGDataCount = 0;
            Frames(ff+1).ECGFillData = [];
            Frames(ff+1).ECGFillCount = 0;
        end
        
    elseif header.ScanFormat == 2 % volumes        
        fseek(fp, header.grayImageOffset + ff*data_size, 'bof');
        data = fread(fp, data_size, 'char');
        % model 1 and viper        
        if header.Version >= 1.0 && header.Version <= 2.3
%             for ii = 0:1:(header.AxialSamples-1)
%                 for jj = 0:1:(header.azLines/4-1)
%                     for kk = 0:1:(header.elLines/4-1)
%                         for mm = 0:1:(4-1)
%                             for nn = 0:1:(4-1)
%                                 Frames(ff+1).Data(ii+(jj*4+mm)*header.AxialSamples+(kk*4+nn)*header.AxialSamples*64 + 1) = ... 
%                                     data(mm + nn*4 + ii*4*4 + (kk*16+jj)*512*4*4 +1) * 32767/255;
%                             end
%                         end
%                     end
%                 end
%             end
            Frames(ff+1).Data = zeros(header.AxialSamples, header.azLines, header.elLines, 'int16');
            for axS = 0:1:(header.AxialSamples-1)
                for azL = 0:1:(header.azLines/4-1)
                    for elL = 0:1:(header.elLines/4-1)
                        for mm = 0:1:(4-1)
                            for nn = 0:1:(4-1)
                                Frames(ff+1).Data(axS +1, azL*4+mm +1, elL*4+nn +1) = ... 
                                    data(mm + nn*4 + axS*4*4 + (elL*16+azL)*512*4*4 +1) * 32767/255;
                            end
                        end
                    end
                end
            end
            Frames(ff+1).Frame = ff;
            Frames(ff+1).Valid = true;
            Frames(ff+1).ECGData = [];
            Frames(ff+1).ECGDataCount = 0;
            Frames(ff+1).ECGFillData = [];
            Frames(ff+1).ECGFillCount = 0;
        end
        % CreateVMILineMap(header, ScanFormats); Missing Function
    end % end volumes

    % Replicate time and date
     
    date_time = datetime([info.Date(1:9) ' ' info.Time(1:8)]);
    
    Frames(ff +1).TimeStamp.wDay = day(date_time);
    Frames(ff +1).TimeStamp.wYear = year(date_time);
    Frames(ff +1).TimeStamp.wMonth = month(date_time);
    
    Frames(ff +1).TimeStamp.wHour = hour(date_time);
    Frames(ff +1).TimeStamp.wMinute = minute(date_time);
    Frames(ff +1).TimeStamp.wSecond = second(date_time);
    Frames(ff +1).TimeStamp.wMilliseconds = 0;
    Frames(ff +1).TSC = clockcounts;
    clockcounts = countincr + clockcounts;
end % end frame loop

clear data; % delete[] data; // ack! deleting the data? skeery....
fclose(fp);
ScanFormats.Source = DS_VMIFILE;
out = 0;
return;
