function [status, header] = ReadT5ileHeader(filename)
% Reads header from a t5d file.  return value indicates success of operation
% 0 - Header read successfully, header contains file header info
% 1 - Failure due to filename being NULL
% 2 - Failed- could not open given filename
% 3 - Unrecognized file type
% 4 - Aborted by user - file version < 1.01
% 5 - Aborted by user - file version > FILE_VERSION (current version)

    eval('load_constants') % load constants
    header = new_CFileHeader();    
   
    if (filename == "")
		error("Could not open file: no filename.");
        status = 1;
		return
    end
		
    fp = fopen(filename, 'rb');	
    
    if (fp == -1)
		error("Error opening file: Invalid filename");
		status = 2;
        return;
    end
    
	% read out magic number	        
    magic = fread(fp, 1, 'uint32');
    
    if (magic ~= MAGIC_NUMBER) 
        error("Not a .t5d file, no other file types are currently supported");
		fclose(fp);
        status = 3;
		return
    end
    
	% read file version & check it's validity
    ver_bin = fread(fp, 1, 'uint16'); 
    % 0xHHLL => version = HH.LL ??
    version = hhll_to_double(ver_bin);
    
	if version < 1.01
        error("Invalid file version! Version must be greater than 1.01.");
		fclose(fp);
        status = 4;
		return
    elseif version > FILE_VERSION
        error("File version is greater than supported by this version of software.");
    	fclose(fp);
        status = 5;
        return
    end
    
	header.Version = version;
	header.Caption = "";
    header.Description = "";
    header.Date = "";
    header.Time = "";
    header.Filter = "";
    header.XDucerName = "";
    header.PatientID = "";

	header.Frequency = 0.0;
	header.CtrlVersion = 0;
	header.AcqRate = 0.0;
	header.ECGAcqRate = 0.0;
	header.Elspacing = 0;
	header.ApOffset = 0;
	header.FOV = 0;
	% ok, valid file/file version
	% let's read header information!
	while ~feof(fp)  
        keylen = fread(fp, 1, 'int32'); 
        if keylen == 0
            break;
        end
        
        key = char(fread(fp, keylen, 'char')');
        datalen = fread(fp, 1, 'uint32');
		% these are top level keys! only care about the frame header
        
		if strcmp(key, keyFRAMEHEADER) 
            while ~feof(fp)
                keylen = fread(fp, 1, 'int32');	
                if keylen == 0
                    break;
                end
                key = char(fread(fp, keylen, 'char')');
                datalen = fread(fp, 1, 'uint32');

                % parse out header keys!
                if strcmp(key,keyFRAMECOUNT)
                    header.FrameCount = fread(fp, 1, 'int32');
                elseif strcmp(key,keyLINECOUNT)
                    header.LineCount = fread(fp, 1, 'int32');
                elseif strcmp(key,keyEXPLOSOCOUNT)
                    header.ExplosoCount = fread(fp, 1, 'int32');
                elseif strcmp(key,keyLINELENGTH)
                    header.LineLength = fread(fp, 1, 'int32');
                elseif strcmp(key,keySCANDEPTH)
                    header.ScanDepth = fread(fp, 1, 'int32');
                elseif strcmp(key,keyCAPTION)
                    header.Caption = char(fread(fp, datalen, 'char')');
                elseif strcmp(key,keyDESCRIPTION)
                    header.Description = char(fread(fp, datalen, 'char')');
                elseif strcmp(key,keyCONVTYPE)
                    header.ConvType = fread(fp, 1, 'int32');
                elseif strcmp(key,keyANGSPACING)
                    header.AngularSpacing = fread(fp, 1, 'int32');
                elseif strcmp(key,keyELSPACING)
                    header.Elspacing = fread(fp, 1, 'int32');
                elseif strcmp(key,keyCPUSPEED)
                    header.CPUSpeed = fread(fp, 1, 'int64');
        			datalen = datalen + 1;
                elseif strcmp(key,keyMODEWORD)
                    header.ModeWord = fread(fp, 1, 'int32');
                elseif strcmp(key,keyACQRATE)
                    header.AcqRate = fread(fp, 1, 'int64');
                elseif strcmp(key,keyECGACQRATE)
                    header.ECGAcqRate = fread(fp, 1, 'int64');
                elseif strcmp(key,keyCTRLVERSION)
                    header.CtrlVersion = fread(fp, 1, 'int32');
                elseif strcmp(key,keySOFTVERSION)
                    header.SoftVersion = fread(fp, 1, 'int32');
                elseif strcmp(key,keyDATE)
                    header.Date = char(fread(fp, datalen, 'char')');
                elseif strcmp(key,keyTIME)
                    header.Time = char(fread(fp, datalen, 'char')');
                elseif strcmp(key,keyFILTER)
                    header.Filter = char(fread(fp, datalen, 'char')');
                elseif strcmp(key,keyFREQOUT)
                    header.Frequency = fread(fp, 1, 'int64');
                elseif strcmp(key,keyXDUCER)
                    header.XDucerName = char(fread(fp, datalen, 'char')');
                elseif strcmp(key,keyPATIENTID)
                    header.PatientID = char(fread(fp, datalen, 'char')');
                elseif strcmp(key,keyAPOFFSET)
                    header.ApOffset = fread(fp, 1, 'int32');
                elseif strcmp(key,keyFOV)
                    header.FOV = fread(fp, 1, 'int32');
                else
                    skip_data = fread(fp, datalen, 'char');
                end
            end
        else
            skip_data = fread(fp, datalen, 'char');
        end
    end

	fclose(fp);
	% parse out plane numbers for multi-b!
    if (header.ConvType == CT_MULTIB || header.ConvType == CT_MULTIB2TX) 
        header.NumPlanes = floor(header.ExplosoCount/256);
        header.ExplosoCount = (header.ExplosoCount - header.NumPlanes) / header.NumPlanes;
	elseif (header.ConvType == CT_ROTPLN || header.ConvType == CT_ROTPLN2DET) 
        % parse out plane numbers for ROTATED PLANES
        header.NumPlanes = floor(header.ExplosoCount/256);
        header.ExplosoCount = (header.ExplosoCount - header.NumPlanes);
    else		
        header.NumPlanes = 1;
	end
    
    status = 0;
	return;
end


function out = hhll_to_double(in)
    hh = floor(in/256);
    ll = in - hh*256;
    out = str2double([dec2hex(hh,2) '.' dec2hex(ll,2)]);    
end

       
