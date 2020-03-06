function data = new_CSquiggleData()
    data = struct();
	data.x = 0;
    data.y = 0;  % position in direct3d space of the roi
	data.line = 0;
    data.exploso = 0;
    data.sample = 0; % line and sample of the center of region of interest
	data.valid = false;
end