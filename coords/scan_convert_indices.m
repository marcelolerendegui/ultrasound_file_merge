function [indx_ax, indx_az, indx_el] = scan_convert_indices(src3d, src_shape, out_lims, out_shape)

%% Camera Transformation Matrix
    % source to world
    Rs = rotationVectorToMatrix(deg2rad(src3d.dir_rot));
    ts = src3d.position';
    Psw = [Rs ts ; [0 0 0] 1];

    %% Create WORLD cartesian coords for Dst
    
    [xs, ys, zs] = ndgrid(...
        linspace(out_lims(1,1), out_lims(1,2), out_shape(1)), ...
        linspace(out_lims(2,1), out_lims(2,2), out_shape(2)), ...
        linspace(out_lims(3,1), out_lims(3,2), out_shape(3))  ...
    );
    
    %% Create stack to apply transformations
    % dst_stack = [x(N_X,N_Y,N_Z); y(N_X,N_Y,N_Z); z(N_X,N_Y,N_Z); 1(N_X,N_Y,N_Z)]
    % size(dst_stack) => [DEPTH, WIDTH, HEIGHT, 4]
    stack = cat(4, xs, ys, zs, ones(size(xs)));
    % ps_s = [4, DEPTH, WIDTH, HEIGHT]
    stack = permute(stack,[4, 1, 2, 3]);
    % convert to 4 signle rows [x(:); y(:); z(:); 1(:)] for matrix multiplication
    stack = reshape(stack, 4, []);

    %% Apply transformation
    % backwards problem: from  WORLD perspective to source
    % WORLD --inv(Pdw)--> SOURCE 
    stack = Psw\stack; %faster than inv(Psw) * stack;
    
    % convert to back to row stack to stack of 4 tridimentional matrices
    % size => [4, DEPTH, WIDTH, HEIGHT]
    stack = reshape(stack, 4, out_shape(1), out_shape(2), out_shape(3));

    %% Convert coords to spherical
    %                       x               y               z             
    [az, el, ax] = cart2sph(stack(1,:,:,:), stack(2,:,:,:), stack(3,:,:,:));

    % remove singleton dimensions
    az = rad2deg(squeeze(az));
    el = rad2deg(squeeze(el));
    ax = squeeze(ax);

    %% Convert dst spherical coordinates to indices 
    % ax = (indx * delta_ax + ax_min) 

    % Source Dimensions
    s_nax = src_shape(1);
    s_naz = src_shape(2);
    s_nel = src_shape(3);
    
    % Calculate deltas
    s_delta_ax = (src3d.ax_span(2) - src3d.ax_span(1))/s_nax;
    s_delta_az = (src3d.az_span(2) - src3d.az_span(1))/s_naz;
    s_delta_el = (src3d.el_span(2) - src3d.el_span(1))/s_nel;

    % Turn spherical coordinates to indices
    indx_ax = (ax - src3d.ax_span(1))./s_delta_ax;
    indx_az = (az - src3d.az_span(1))./s_delta_az;
    indx_el = (el - src3d.el_span(1))./s_delta_el;
    
end