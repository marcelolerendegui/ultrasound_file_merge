function [data, info] = readUltrasoundFile(filename)

    if strcmpi(filename(end-3:end), '.VOL')
        [~, info, frames] = LoadVMIDataFromFile(filename);
        n_frames = length(frames);
        
        data = zeros([n_frames size(frames(1).Data)]);
        for fn = 1:1:n_frames
            data(fn, :, :, :) = double(frames(fn).Data)/2^16;
        end
        
    elseif strcmpi(filename(end-3:end), '.T5D')
        [~, info, ~, frames] = LoadT5DataFromFile(filename);
        n_frames = length(frames);
        
        data = zeros([n_frames size(frames(1).Data)]);
        for fn = 1:1:n_frames
            data(fn, :, :, :) = double(frames(fn).Data)/2^16;
        end
        
        ll = info.ScanFormats.LineLength;
        exploso_side = sqrt(info.ScanFormats.ExplosoCount);
        lines_side = sqrt(info.ScanFormats.LineCount);
        total_side = exploso_side*lines_side;
        
        data = reshape(data, ...
            [n_frames, ll, exploso_side, exploso_side, lines_side, lines_side]);
        
        data = permute(data, [1, 2, 4, 6, 3, 5]);
        data = reshape(data, [n_frames, ll, total_side, total_side]);
    end
end


