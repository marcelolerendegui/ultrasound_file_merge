function plot_sc(ha, vol, src, ax_slice, az_slice, el_slice)
    if isempty(ha)
        ha = axes();
    end
    hold(ha,'on');
    [ax_nsamples, az_nsamples, el_nsamples] = size(vol);
    [X, Y, Z] = create_cartesian_grid(src, ax_nsamples, az_nsamples, el_nsamples, "nd");    
    
    for pos = ax_slice
        [sX, sY, sZ, S] = get_single_slice(vol, X, Y, Z, 1, pos);
        s = surf(sX, sY, sZ, mat2gray(S));
        style_s(s, S);
        view(ha,[1,0,0]);
    end
   
    for pos = az_slice
        [sX, sY, sZ, S] = get_single_slice(vol, X, Y, Z, 2, pos);
        s = surf(sX, sY, sZ, S);
        style_s(s, S);
    end
    
    for pos = el_slice
        [sX, sY, sZ, S] = get_single_slice(vol, X, Y, Z, 3, pos);
        s = surf(sX, sY, sZ, S);
        style_s(s, S);
    end
    set(ha,'Color',[0,0,0]);
    equalize(ha, X,Y,Z);
end

function [sX, sY, sZ, S] = get_single_slice(vol, X, Y, Z, dim, pos)
    if dim==1
        sX = squeeze(X(pos,:,:));
        sY = squeeze(Y(pos,:,:));
        sZ = squeeze(Z(pos,:,:));
        S = squeeze(vol(pos,:,:));
    elseif dim==2
        sX = squeeze(X(:,pos,:));
        sY = squeeze(Y(:,pos,:));
        sZ = squeeze(Z(:,pos,:));
        S = squeeze(vol(:,pos,:));
    elseif dim==3
        sX = squeeze(X(:,:,pos));
        sY = squeeze(Y(:,:,pos));
        sZ = squeeze(Z(:,:,pos));
        S = squeeze(vol(:,:,pos));
    end
end

function style_s(s, S)
    set(s,'LineStyle','none');
    set(s,'FaceLighting','none');
    set(s, 'AlphaData', S, 'AlphaDataMapping', 'scaled');
    set(s, 'FaceAlpha', 'flat');
    colormap(gray);
end

function equalize(ha, X,Y,Z)
    xmx = max(X(:));
    xmn = min(X(:));
    ymx = max(Y(:));
    ymn = min(Y(:));
    zmx = max(Z(:));
    zmn = min(Z(:));
    xlim(ha,[xmn,xmx]);
    ylim(ha,[ymn,ymx]);
    zlim(ha,[zmn,zmx]);
end