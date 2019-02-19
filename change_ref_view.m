function out_data = change_ref_view(d1, x1, y1, z1, w1, rad)

    out_data = zeros(size(data1));

    max_ii = size(out_data, 2);
    max_jj = size(out_data, 3);
    max_kk = size(out_data, 4);

    for ii = 1:1:max_ii
        for jj = 1:1:max_jj
            for kk = 1:1:max_kk
                % for each point on output grid
                out_data(ii,jj,kk) = d1_pond*norm( data1_sample(dd_d1<=sph_rad) ,1);
                
                cpx = x1(ii,jj,kk);
                cpy = y1(ii,jj,kk);
                cpz = z1(ii,jj,kk);
                    
                
                
            end
        end        
    end

end