function [status, header] = ReadVMIFileHeader(filename)
    header = new_CVMIFileHeader();    		
    
    fp = fopen(filename, 'rb');	

    if fp~=-1
        % opened a file, double check magic number
        magic = fread(fp, 1, 'uint32');

        %Model 1 file formats, V1.1 and up
        if magic == 560284551 % VMI_MAGIC_NUMBER = 0x21654387
            fileRev = sprintf('%c',fread(fp, 12, 'char'));

            if fileRev(1) ~= 'V'
                status = 2;
                return
            end

            header.Version = str2double(fileRev(2:end));

            if header.Version ~= 0
                % status = 1;
                % read description
                header.Description = sprintf('%c',fread(fp, 128, 'char'));

                % Parse patient info into caption            
                fseek(fp, 232, 'bof');
                header.Caption.Clinic = sprintf('%c',fread(fp, 64, 'char')); % clinic

                fseek(fp, 168, 'bof');
                header.Caption.Patient = sprintf('%c',fread(fp, 64, 'char')); % patient

                fseek(fp, 144, 'bof');
                header.Caption.Date = sprintf('%c',fread(fp, 12, 'char')); % Date

                fseek(fp, 156, 'bof');
                header.Caption.Time = sprintf('%c',fread(fp, 12, 'char')); % Time

                fseek(fp, 296, 'bof');
                header.FrameCount = fread(fp, 1, 'uint32'); % get frame count

                % Ducer info
                if header.Version < 2.0 
                    fseek(fp, 300, 'bof');
                else
                    fseek(fp, 317, 'bof');
                end

                header.XDucerName = sprintf('%c',fread(fp, 16, 'char'));
                header.XDucerID = fread(fp, 1, 'uint32');
                header.XDucerFreq = fread(fp, 1, 'double');


                % Scan Depth
                header.ScanDepth = fread(fp, 1, 'double');

                ii =  cast(((header.ScanDepth/10.0-6.0)/2.0), 'uint16');

                % Scan Format
                if header.Version < 2.0
                    fseek(fp, 372, 'bof');
                else
                    fseek(fp, 386, 'bof');                
                end
                header.ScanFormat = fread(fp, 1, 'uint32');                

                % Line Count
                if header.Version < 2.0
                    fseek(fp, 444, 'bof');
                else
                    fseek(fp, 458, 'bof');
                end                                
                header.LineCount = fread(fp, 1, 'uint16');

                % az/el lines, angles, separation
                header.azLines = fread(fp, 1, 'uint16');
                header.azAngle = fread(fp, 1, 'double');
                header.azSeparation = fread(fp, 1, 'double');

                header.elLines = fread(fp, 1, 'uint16');
                header.elAngle = fread(fp, 1, 'double');
                header.elSeparation = fread(fp, 1, 'double');

                % Bmode adjustment:
                if header.ScanFormat == 1
                    header.elSeparation = 0.0;
                    header.LineCount = header.LineCount*4;
                    header.ExplosoCount = 4;            
                else % Volume             
                    header.elLines = header.elLines*4;
                    header.elSeparation = header.elAngle / (header.elLines-1);
                    header.ExplosoCount = 16;
                end

                % convert from tx line angles to exploso/rx line angles
                header.azLines = header.azLines*4;
                header.azSeparation = header.azAngle / (header.azLines-1); 

                % Sample Size
                if header.Version < 2.0 
                    fseek(fp, 498, 'bof');                
                else
                    fseek(fp, 512, 'bof');
                end
                header.SampleSize = fread(fp, 1, 'double');            

                % LineGroupSize
                if header.Version < 2.0 
                    fseek(fp, 518, 'bof'); 
                else
                    fseek(fp, 532, 'bof'); 
                end
                header.LineGroupSize = fread(fp, 1, 'uint32');
                header.numECGSamples = fread(fp, 1, 'uint32');

                % echo,doppler,ecg sizes
                header.grayImageSize = fread(fp, 1, 'uint32');            
                if header.Version < 2.0 
                    header.colorImageSize = fread(fp, 1, 'uint32'); 
                else
                    header.colorImageSize = 0;
                end
                header.dopplerImageSize = fread(fp, 1, 'uint32'); 
                header.ecgSize = fread(fp, 1, 'uint32'); 

                % echo,doppler,ecg offsets
                if header.Version < 2.0
                    fseek(fp, 546, 'bof');                 
                else
                    fseek(fp, 556, 'bof'); 
                end
                header.grayImageOffset = fread(fp, 1, 'uint32');

                if (header.Version < 2.0) 
                    header.colorImageOffset = fread(fp, 1, 'uint32');
                else
                    header.colorImageOffset = header.grayImageOffset;
                end
                header.dopplerImageOffset = fread(fp, 1, 'uint32');
                header.ecgOffset = fread(fp, 1, 'uint32');

                % skin offset
                if header.Version < 2.0
                    fseek(fp, 858, 'bof');
                    header.Offset = fread(fp, 1, 'double');                
                    % convert to mm
                    header.Offset = header.Offset*header.SampleSize;
                else
                    % seek to correct timing control struct
                    fseek(fp, 572+34*ii+24, 'bof');
                    header.Offset = fread(fp, 1, 'double');            
                    if (header.ScanDepth < 60) 
                        header.Offset = 4.9268;
                    end
                end

                % samples
                if header.Version < 2.0
                    fseek(fp, 846, 'bof');
                    header.AxialSamples = fread(fp, 1, 'int32');                
                else
                    fseek(fp, 572+ii*34+32, 'bof');
                    shorttemp = fread(fp, 1, 'uint16');                
                    if header.ScanDepth < 60
                        header.AxialSamples = ...
                            (header.ScanDepth - header.Offset)/header.SampleSize;
                    else
                        header.AxialSamples = shorttemp;
                    end
                end

                % frame rate
                if header.Version < 2.0
                    header.FrameRate = 20.0; % assume 20 fps if not known
                else        
                    fseek(fp, 1935, 'bof');         
                    header.FrameRate = fread(fp, 1, 'double');
                end

                % Modeword is a T5 thing....
                header.ModeWord = 0;
                %end valid file version
            else% correct magic number
                status = 3;
                return
            end		
        else
            status = 2;
            return
        end

        fclose(fp);
    else
		status = 1;
        return
    end
    status = 0;
end