function out_data = get_srcdata_as_dst(src3d, data_s, dst3d, out_data)

    %% Samples
    ax_n_samples = size(data_s,2);
    az_n_samples = size(data_s,3);
    el_n_samples = size(data_s,4);
    
    %% Coords
    [AXs, AZs, ELs] = create_polar_grid(src3d,... 
                                        ax_n_samples,...
                                        az_n_samples,...
                                        el_n_samples);

    [xs, ys, zs] = polar_grid_to_cartesian_grid(src3d, AXs, AZs, ELs);

    %% Camera transformation

    Rs = rotationVectorToMatrix(deg2rad(src3d.dir_rot));
    ts = src3d.position';
    Psw = [Rs ts ; [0 0 0] 1];

    Rd = rotationVectorToMatrix(deg2rad(dst3d.dir_rot));
    td = dst3d.position';
    Pdw = [Rd td ; [0 0 0] 1];

    % add signleton dimensions to cat later
    x1_s(1,:,:,:) = xs; 
    y1_s(1,:,:,:) = ys;
    z1_s(1,:,:,:) = zs;

    % stack [x(244,64,64); y(244,64,64); z(244,64,64); 1(244,64,64)]
    ps_s = cat(1, x1_s, y1_s, z1_s, ones(size(z1_s))); 

    % convert to 4 signle rows [x(:); y(:); z(:); 1(:)] for matrix multiplication
    ps_s_srow = reshape(ps_s,4,[]);
    ps_w_srow = Psw * ps_s_srow;
    ps_d_srow = Pdw\ps_w_srow; %faster than inv(P1d) * p1_w_srow;

    % convert to back to stack of 4 tridimentional matrices
    ps_d = reshape(ps_d_srow, 4, ax_n_samples, az_n_samples, el_n_samples);

    % convert to spherical coordinates
    %                                           x              y              z             
    [ps_d_az, ps_d_el, ps_d_ax] = cart2sph(ps_d(1,:,:,:), ps_d(2,:,:,:), ps_d(3,:,:,:));

    % remove singleton dimensions
    ps_d_az = rad2deg(squeeze(ps_d_az));
    ps_d_el = rad2deg(squeeze(ps_d_el));
    ps_d_ax = squeeze(ps_d_ax);

    % convert dst spherical coordinates to dst indices ax = (n_ax * delta_ax + ax_min) 
    d_dax = (dst3d.ax_span(2) - dst3d.ax_span(1))/244;
    d_daz = (dst3d.az_span(2) - dst3d.az_span(1))/64;
    d_del = (dst3d.el_span(2) - dst3d.el_span(1))/64;

    % Quantize spherical coordinates
    ps_d_nax = (ps_d_ax - dst3d.ax_span(1))./d_dax;
    ps_d_naz = (ps_d_az - dst3d.az_span(1))./d_daz;
    ps_d_nel = (ps_d_el - dst3d.el_span(1))./d_del;

    ps_d_nax = round(ps_d_nax);
    ps_d_naz = round(ps_d_naz);
    ps_d_nel = round(ps_d_nel);
    
    % check cord conversion with histogram
%     figure('name','AX')
%     hist(ps_d_nax(:))
%     figure('name','AZ')
%     hist(ps_d_naz(:))
%     figure('name','EL')
%     hist(ps_d_nel(:))

    % convert to 3+N signle rows [nax(:); naz(:); nel(:); data(1,:) ; data(2,:) ; data(N, :)]
    data1_d = zeros(3+size(data_s,1), size(ps_d_nax,1), size(ps_d_nax,2), size(ps_d_nax,3));

    data1_d(1,:,:,:) = ps_d_nax;
    data1_d(2,:,:,:) = ps_d_naz;
    data1_d(3,:,:,:) = ps_d_nel;
    data1_d(4:end,:,:,:) = data_s(1:end,:,:,:);

    data1_d = reshape(data1_d,3+size(data_s,1),[]);

    % remove data with ax outside dst boundary
    tt = data1_d(1,:) < 1;   % for which columns is row 1 below boundary 
    data1_d(:,tt) = [];   % remove those cols
    tt = data1_d(1,:) > ax_n_samples;   % for which columns is row 1 above boundary 
    data1_d(:,tt) = [];   % remove those cols

    % remove data with az outside dst boundary
    tt = data1_d(2,:) < 1;   % for which columns is row 1 below boundary 
    data1_d(:,tt) = [];   % remove those cols
    tt = data1_d(2,:) > az_n_samples;   % for which columns is row 1 above boundary 
    data1_d(:,tt) = [];   % remove those cols

    % remove data with el outside dst boundary
    tt = data1_d(3,:) < 1;   % for which columns is row 1 below boundary 
    data1_d(:,tt) = [];   % remove those cols
    tt = data1_d(3,:) > el_n_samples;   % for which columns is row 1 above boundary 
    data1_d(:,tt) = [];   % remove those cols

    [out_data] = add_weighted_data(out_data, 1, data1_d);

end