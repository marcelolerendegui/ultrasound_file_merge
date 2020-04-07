%% CleanUp
close all;
clearvars;
clc;

%% Create 3D source for input file
srcIn = new_3DSource();
srcIn.position = [0, 0, 0];
srcIn.dir_rot  = [0, 0, 0];
srcIn.ax_span  = [1, 10];
srcIn.az_span  = [-20, 20];
srcIn.el_span  = [-20, 20];

%% Load input file
[data, info] = readUltrasoundFile('data/full.t5d');

%% Load output file to know sizes
outDCM = ReadDicom3D('data/cube.dcm');

%% Get indices for left and right from out perspective

% dimensions of a single input frame
in_frame_shape = size(data);
in_frame_shape(1) = [];

out_lims = [...
            [ 0.0 , 11.0 ];... % [xmin, xmax]
            [-3.5 , 3.5 ];... % [ymin, ymax] (sin(minAZ) * maxAX) = 3.4
            [-3.5 , 3.5 ] ... % [zmin, zmax] (sin(minEL) * maxAX) = 3.4
];

out_shape = [outDCM.width, outDCM.height, outDCM.depth];

[indx_ax, indx_az, indx_el] = ...
    scan_convert_indices(srcIn, in_frame_shape, out_lims, out_shape);
    

%% Get scan converted frames
frames_out = [];

for ii = 1:outDCM.NumVolumes
    out_frame = ...
        interpn(...
                    data, ...
                    ii.*ones(size(indx_ax)), ....
                    indx_ax, ...
                    indx_az, ...
                    indx_el, ...
                    'linear', ...
                    0 ... % out of boundaries values turned to 0
    );
    frames_out = cat(4, frames_out, out_frame);
end

%% Save to dcm File
%SaveDicom3D('data/full.t5d', frames_out);
