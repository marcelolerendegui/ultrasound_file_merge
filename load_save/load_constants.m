SOFT_VERSION = 311; % 0x0137; % Current software version
                              % see changelog.txt for more details


% FILE TYPES
FT_UNKNOWN = 0;
FT_T5 = 1;
FT_VMI = 2;
FT_T4 = 4;

% DATA SOURCES
DS_UNKNOWN = 0;	% Should only indicate invalid data
DS_FILE = 1;	% Data comes from a T5 File
DS_VMIFILE = 2;	% Data comes from a VMI file
DS_LIVE = 4;	% Data comes from live acquisition

MAX_DETECTOR_COUNT = 4;         % max number of detectors!
EXPLOSOS_PER_DETECTOR = 16;
CAPTURE_BUFFERS = 2;
MAX_BUFFER_SIZE = 1500000000;   % max buffer size for acquisition
								% has been tested up to 4GB and doesn't blow up
								% BUT 

% Program Modes
% PM_IDLE = 0;		% no data, idle mode (unused currently)
PM_PLAYBACK = 1;	% playback from disk
PM_CAPTURE = 2;     % playing live data!
PM_REVIEW = 3;      % review prospective data before saving (funky mode)

% indicies for addressing the appropriate buffer
BUF_CAPTURE = 0;
BUF_SAVE = 1;

% FILE I/O CONSTANTS
MAGIC_NUMBER = 3126770193; %0xBA5EBA11;
VMI_MAGIC_NUMBER = 560284551; %0x21654387;
FILE_VERSION = 1072; %0x0430; % Read rightmost two digits as decimal
% Version 0x0400 miswrote the header length

% Key names
keyFRAMEHEADER = "FRAMEHEADER";
keyFRAMEDATA = "FRAMEDATA";

% Frame header subkey names
keyFRAMECOUNT = "FRAMECOUNT";
keyLINECOUNT = "LINECOUNT";
keyEXPLOSOCOUNT = "EXPLOSOCOUNT";
keyLINELENGTH = "LINELENGTH";
keySCANDEPTH = "SCANDEPTH";
keyCAPTION = "CAPTION";
keyDESCRIPTION = "DESCRIPTION";
keyCONVTYPE = "CONVTYPE";
keyANGSPACING = "ANGSPACING";
keyEXPLOSOMAP = "EXPLOSOMAP";
keyCPUSPEED = "CPUSPEED";
keyMODEWORD = "MODEWORD";
keyELSPACING = "ELSPACING"; % elevation spacing for multi-b
keyACQRATE = "ACQRATE";
keyCTRLVERSION = "CTRLVERSION";
keyDATE = "DATE";
keyTIME = "TIME";
keyFILTER = "FILTER";
keyFREQOUT = "FREQOUT";
keyXDUCER = "XDUCER";
keyXDUCER0 = "XDUCER0"; % File V4.?
keyXDUCER1 = "XDUCER1"; % File V4.?
keyXDUCER2 = "XDUCER2"; % File V4.?
keyXDUCER3 = "XDUCER3"; % File V4.?
keySOFTVERSION = "SOFTVERSION";
keyPATIENTID = "PATIENTID"; % File V4.2
keyECGACQRATE = "ECGACQRATE"; % File V4.2
keyAPOFFSET = "APOFFSET";	% File V4.3
keyFOV = "FOV"; % File V4.3


% Frame data subkeys
keyFRAMETIME = "FRAMETIME";
keyFRAMETSC = "FRAMETSC";
keyFRAMESAMPLES = "FRAMESAMPLES";
keyECGFRAMEDATA = "ECGFRAMEDATA";
keyECGFILLDATA  = "ECGFILLDATA";

% MACHINE CONSTANTS
MAX_LINE_COUNT = 1024;
MAX_EXPLOSOS = 32;
MAX_ECG_FILL_COUNT = 4096;
MAX_ECG_SAMPLES_DISPLAYED = 8000;
ECG_NO_DRAW = 200;
ECG_SEC_PER_TICK = 0.00001024;  % seconds per tick of ECG clock (10.24 usec/tick)

APERTURE_MASK = 1792;
FIELD_SYNC_MASK = 2;

CAPTION_LENGTH = 1024;
DESCRIPTION_LENGTH = 1024;

CT_NONE = 0;
CT_BSCAN = 1;			% standard, vanilla B-mode scan
CT_VOLSCAN = 2;         % volume scan
CT_BX1TX = 3;			% Exploso B-mode with 1 Tx
CT_BX2TX = 4;			% Exploso B-mode with 2 near-simultaneous Tx (2nd Tx's Rx data comes on upper explosos
CT_MULTIB = 5;          % Multi-plane B-mode image (steered in phi)
CT_MULTIB2TX = 6;		% Multi-plane B-mode image with 2 transmits (steered in phi)
CT_ROTPLN = 7;          % Rotated B-mode planes (O-mode/tri-plane)
CT_ROTPLN2DET = 8;      % Rotated B-mode planes with 2 transmits (O-mode/tri-plane)
CT_CMPD1TX = 9;         % Compund image, NO TRANSMIT PARALLELISM (2 Tx apertures, 2 sectors)
CT_CMPD2TX = 10;		% Compound image using near-simultaneous transmits (2:1 Tx)
CT_CMPDSIM1TX = 11;     % Compound image using two simultaneous apertures, one Tx pattern per line (2:1 Tx)
CT_CMPDSIM2TX = 12;     % Compound image using two simultaneous apertures, two Tx patterns per line (4:1 Tx)
CT_CMPD = 13;			% Non-exploso compound scan (for testing purposes)
CT_SSSC1TX = 14;		% Separately steered, simultaneous compound, 1 Tx (2:1 Tx)
CT_SSSC2TX = 15;		% Separately steered, simultaneous compound, 2 Tx (4:1 Tx)

% Sector Types (for telling what kind of sector a data point came from)
% keep values orthogonal for bit-masking
ST_BMODE = 1;			% came from a standard b-mode sector
ST_DBMODE = 2;          % came from a DB-Mode sector (i.e. the difference image)
ST_CMPD_LEFT = 4;		% came from overlapping sectors (compound image), Left aperture
ST_CMPD_RIGHT = 8;      % came from overlapping sectors (compound image), Right aperture

LUT_SIZE = 2048;
BSCAN_MAP_SIZE = 1024;

BSCAN_MAP_TEXTURE_ADDRESS = 0;
BSCAN_DATA_TEXTURE_ADDRESS = 1;
BSCAN_LUT_TEXTURE_ADDRESS = 2;
%const int BSCAN_MATH_LUT_TEXTURE_ADDRESS = 3;

VOLUME_MAP_SIZE = 1024;		% Dimensions of the volume coordinate transform map
VOL_MAP_TEXTURE_ADDRESS = 0;
VOL_DATA_TEXTURE_ADDRESS = 1;
VOL_LUT_TEXTURE_ADDRESS = 2;

CLINIC_LENGTH = 64;

MAX_FRAMES_APART = 100;		% maximum number of frames apart allowed for math functions
