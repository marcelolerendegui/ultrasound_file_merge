%% CleanUp
close all;
clear all;
clc;

%% Load Files
[status, info, header, Frames] = ...
    LoadT5DataFromFile('apnea_phantom/coated_tapered_bulb.t5d');

%% Get Config

n_frames = 50;
n_radial = 404;
n_az = 128;
n_el = 128;
n_az_ex = 32;
n_az_el = 32;
n_ex_az = 4;
n_ex_el = 4;

%% Reshape
data = zeros([n_frames, n_radial * n_az * n_el]);

for ff = 1:length(Frames)
    data(ff,:) = Frames(ff).Data / max(Frames(ff).Data(:));
end

data = reshape(data, [  ...
                        n_frames, ...
                        n_radial, ...
                        n_ex_az,  ...
                        n_ex_el,  ...
                        n_az_ex,  ...
                        n_az_el,  ...
                    ] ...
);

data = permute(data, [1, 2, 4, 6, 3, 5]);
data = reshape(data, [n_frames, n_radial, n_az, n_el]);


hf = figure();
subplot(1,3,1);
imshow(squeeze(data(1, 202, :, :)));
subplot(1,3,2);
imshow(squeeze(data(1, :, 64, :)));
subplot(1,3,3);
imshow(squeeze(data(1, :, :, 64)));
