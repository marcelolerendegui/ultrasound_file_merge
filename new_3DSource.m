function source = new_3DSource()
    source = struct();
    source.position = [0, 0, 0];
    source.dir_rot = [0, 0, 0];
    source.az_span = [-30, 30];
    source.el_span = [60, 120];
    source.ax_span = [1, 20];
end