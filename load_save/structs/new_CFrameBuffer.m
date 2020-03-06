function frameBuffer = new_CFrameBuffer()
	frameBuffer.Valid = false;
	frameBuffer.Frame = 0;
	frameBuffer.Data = [];
	frameBuffer.TimeStamp = new_WinSystime();
	frameBuffer.TSC = 0;
	frameBuffer.ECGData(1) = new_CECGData();
	frameBuffer.ECGFillData(1) = new_CECGData();
	frameBuffer.ECGDataCount = 0;
	frameBuffer.ECGFillCount = 0;
end
