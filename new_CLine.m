function line = new_CLine()
    line = struct();
    line.Start = 0
	%D3DPoint Start; Assuming D3DPoint = D3DXVECTOR3
    line.Start = struct();
    line.Start.x = 0;
    line.Start.y = 0;
    line.Start.Z = 0;
	%D3DPoint End; Assuming D3DPoint = D3DXVECTOR3
    line.End = struct();
    line.End.x = 0;
    line.End.y = 0;
    line.End.Z = 0;
	line.Valid = false;
end
