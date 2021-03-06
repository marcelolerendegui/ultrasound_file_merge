function plot_src_pyramid(ha, src3d, n_points, varargin)

    n_points = max(n_points, 1) + 1;
                                
%          AX,               AZ,                 EL
    cube_coords = [...
               
%             src3d.ax_span(1)  src3d.az_span(1)    src3d.el_span(1);...
%             src3d.ax_span(1)  src3d.az_span(1)    src3d.el_span(2);...
        repmat(src3d.ax_span(1),n_points,1), repmat(src3d.az_span(1),n_points,1), linspace(src3d.el_span(1),src3d.el_span(2),n_points)';...
%             src3d.ax_span(1)  src3d.az_span(1)    src3d.el_span(2);...
%             src3d.ax_span(1)  src3d.az_span(2)    src3d.el_span(2);...
        repmat(src3d.ax_span(1),n_points,1), linspace(src3d.az_span(1),src3d.az_span(2),n_points)' repmat(src3d.el_span(2),n_points,1);...

        repmat(src3d.ax_span(1),n_points,1), linspace(src3d.az_span(2),src3d.az_span(1),n_points)' linspace(src3d.el_span(2),src3d.el_span(1),n_points)' ;...        
        repmat(src3d.ax_span(1),n_points,1), linspace(src3d.az_span(1),src3d.az_span(2),n_points)' linspace(src3d.el_span(1),src3d.el_span(2),n_points)' ;...        
        
%             src3d.ax_span(1)  src3d.az_span(2)    src3d.el_span(2);...        
%             src3d.ax_span(1)  src3d.az_span(2)    src3d.el_span(1);...
        repmat(src3d.ax_span(1),n_points,1), repmat(src3d.az_span(2),n_points,1), linspace(src3d.el_span(2),src3d.el_span(1),n_points)';...
        
        
        repmat(src3d.ax_span(1),n_points,1), linspace(src3d.az_span(2),src3d.az_span(1),n_points)' linspace(src3d.el_span(1),src3d.el_span(2),n_points)' ;...        
        repmat(src3d.ax_span(1),n_points,1), linspace(src3d.az_span(1),src3d.az_span(2),n_points)' linspace(src3d.el_span(2),src3d.el_span(1),n_points)' ;...            
              
%             src3d.ax_span(1)  src3d.az_span(2)    src3d.el_span(1);...        
%             src3d.ax_span(1)  src3d.az_span(1)    src3d.el_span(1);...
        repmat(src3d.ax_span(1),n_points,1), linspace(src3d.az_span(2),src3d.az_span(1),n_points)' repmat(src3d.el_span(1),n_points,1);...
        
        % implicit depth line
                
%             src3d.ax_span(2)  src3d.az_span(1)    src3d.el_span(1);...
%             src3d.ax_span(2)  src3d.az_span(1)    src3d.el_span(2);...
        repmat(src3d.ax_span(2),n_points,1), repmat(src3d.az_span(1),n_points,1), linspace(src3d.el_span(1),src3d.el_span(2),n_points)';...
        
        repmat(src3d.ax_span(2),n_points,1), linspace(src3d.az_span(1),src3d.az_span(2),n_points)' linspace(src3d.el_span(2),src3d.el_span(1),n_points)' ;...        
        repmat(src3d.ax_span(2),n_points,1), linspace(src3d.az_span(2),src3d.az_span(1),n_points)' linspace(src3d.el_span(1),src3d.el_span(2),n_points)' ;...        

        
        % depth line
        src3d.ax_span(1)  src3d.az_span(1)    src3d.el_span(2);...
        src3d.ax_span(2)  src3d.az_span(1)    src3d.el_span(2);...

%             src3d.ax_span(2)  src3d.az_span(1)    src3d.el_span(2);...
%             src3d.ax_span(2)  src3d.az_span(2)    src3d.el_span(2);...
        repmat(src3d.ax_span(2),n_points,1), linspace(src3d.az_span(1),src3d.az_span(2),n_points)' repmat(src3d.el_span(2),n_points,1);...

        repmat(src3d.ax_span(2),n_points,1), linspace(src3d.az_span(2),src3d.az_span(1),n_points)' linspace(src3d.el_span(2),src3d.el_span(1),n_points)' ;...        
        repmat(src3d.ax_span(2),n_points,1), linspace(src3d.az_span(1),src3d.az_span(2),n_points)' linspace(src3d.el_span(1),src3d.el_span(2),n_points)' ;...        
        
        
        % depth line
        src3d.ax_span(2)  src3d.az_span(2)    src3d.el_span(2);...
        src3d.ax_span(1)  src3d.az_span(2)    src3d.el_span(2);...
        
%             src3d.ax_span(2)  src3d.az_span(2)    src3d.el_span(2);...        
%             src3d.ax_span(2)  src3d.az_span(2)    src3d.el_span(1);...
        repmat(src3d.ax_span(2),n_points,1), repmat(src3d.az_span(2),n_points,1), linspace(src3d.el_span(2),src3d.el_span(1),n_points)';...        

        % depth line
        src3d.ax_span(1)  src3d.az_span(2)    src3d.el_span(1);...
        src3d.ax_span(2)  src3d.az_span(2)    src3d.el_span(1);...
        
%             src3d.ax_span(2)  src3d.az_span(2)    src3d.el_span(1);...        
%             src3d.ax_span(2)  src3d.az_span(1)    src3d.el_span(1);...
        repmat(src3d.ax_span(2),n_points,1), linspace(src3d.az_span(2),src3d.az_span(1),n_points)' repmat(src3d.el_span(1),n_points,1);...        
        
        % depth line
        src3d.ax_span(1)  src3d.az_span(1)    src3d.el_span(1);...
        src3d.ax_span(2)  src3d.az_span(1)    src3d.el_span(1);...
        
        repmat(src3d.ax_span(2),n_points,1), linspace(src3d.az_span(1),src3d.az_span(1),n_points)' linspace(src3d.el_span(1),src3d.el_span(2),n_points)' ;...        
        
        ];
    
    [X, Y, Z] = polar_grid_to_cartesian_grid(   src3d,...
                                                cube_coords(:,1),...
                                                cube_coords(:,2),...
                                                cube_coords(:,3));
                                            
    % convert to world coords
    [X, Y, Z] = scart2wcart(src3d, X, Y, Z);
    
    p = plot3(ha, X(:), Y(:), Z(:), varargin{:});
    set(get(get(p,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    
    %% Axis
    Rs = rotationVectorToMatrix(deg2rad(src3d.dir_rot));
    ts = src3d.position';
    Psw = [Rs ts ; [0 0 0] 1];
    
    orig = Psw * [zeros(3,6) ; ones(1,6)];
    pos = Psw * [eye(3,3) -eye(3,3) ; ones(1,6)];
    
    
    quiver3(ha, orig(1,:),          orig(2,:),          orig(3,:), ...
                pos(1,:)-orig(1,:), pos(2,:)-orig(2,:), pos(3,:)-orig(3,:),...
                0, varargin{:});
            
    text(pos(1,1), pos(2,1), pos(3,1), 'x');
    text(pos(1,2), pos(2,2), pos(3,2), 'y');
    text(pos(1,3), pos(2,3), pos(3,3), 'z');
end

function [wx, wy, wz] = scart2wcart(src_3d, sx, sy, sz)

    % camera transform matrix from source to world
    Rs = rotationVectorToMatrix(deg2rad(src_3d.dir_rot));
    ts = src_3d.position';
    Psw = [Rs ts ; [0 0 0] 1];
    
    % convert to 4 signle rows [x(:); y(:); z(:); 1(:)] for matrix multiplication
    ps_s_srow = [sx(:)'; sy(:)'; sz(:)'; ones(size(sz))'];
    
    ps_w_srow = Psw * ps_s_srow;
    
    wx = ps_w_srow(1,:);
    wy = ps_w_srow(2,:);
    wz = ps_w_srow(3,:);   

end